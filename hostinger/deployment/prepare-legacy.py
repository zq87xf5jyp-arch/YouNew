#!/usr/bin/env python3
"""Read a pinned PostgreSQL plain dump as data only; never execute its SQL."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import io
import zipfile


def digest(value):
    return hashlib.sha256(value).hexdigest()


def unescape(value):
    if value == b'\\N':
        return None
    escapes = {ord('b'): 8, ord('f'): 12, ord('n'): 10, ord('r'): 13,
               ord('t'): 9, ord('v'): 11, ord('\\'): 92}
    out = bytearray()
    i = 0
    while i < len(value):
        char = value[i]
        i += 1
        if char != 92:
            out.append(char)
            continue
        if i == len(value):
            raise ValueError('Incomplete COPY escape')
        char = value[i]
        i += 1
        if char in escapes:
            out.append(escapes[char])
        elif 48 <= char <= 55:
            digits = bytes([char])
            while i < len(value) and len(digits) < 3 and 48 <= value[i] <= 55:
                digits += bytes([value[i]])
                i += 1
            out.append(int(digits, 8))
        elif char == ord('x'):
            digits = b''
            while i < len(value) and len(digits) < 2 and value[i] in b'0123456789abcdefABCDEF':
                digits += bytes([value[i]])
                i += 1
            if not digits:
                raise ValueError('Invalid hex escape')
            out.append(int(digits, 16))
        else:
            out.append(char)
    return out.decode('utf-8', errors='strict')


def parse_dump(raw):
    tables = []
    lines = iter(raw.splitlines(keepends=True))
    for line in lines:
        if not line.startswith(b'COPY '):
            continue
        match = re.fullmatch(rb'COPY ([a-z_][a-z_0-9]*\.[a-z_][a-z_0-9]*) \(([a-z_0-9, ]+)\) FROM stdin;\n', line)
        if not match:
            raise ValueError('Unsupported COPY header')
        name = match[1].decode()
        if any(t['name'] == name for t in tables):
            raise ValueError('Repeated COPY table')
        columns = match[2].decode().split(', ')
        if len(set(columns)) != len(columns):
            raise ValueError('Duplicate column')
        payload = bytearray()
        rows = []
        for row in lines:
            if row == b'\\.\n':
                break
            if not row.endswith(b'\n'):
                raise ValueError('Unterminated COPY row')
            values = row[:-1].split(b'\t')
            if len(values) != len(columns):
                raise ValueError('COPY column count mismatch')
            rows.append([unescape(v) for v in values])
            payload.extend(row)
        else:
            raise ValueError('Unterminated COPY block')
        tables.append({'name': name, 'columns': columns, 'rows': rows,
                       'copyBase64': base64.b64encode(payload).decode(),
                       'copySha256': digest(payload)})
    if not tables or b'-- PostgreSQL database dump complete' not in raw:
        raise ValueError('Incomplete PostgreSQL dump')
    return tables


def storage_assets(original, expected_sha, tables):
    if digest(original) != expected_sha:
        raise ValueError('Storage checksum mismatch')
    table = next(t for t in tables if t['name'] == 'storage.objects')
    assets = []
    with zipfile.ZipFile(io.BytesIO(original)) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise ValueError('Duplicate storage entry')
        expected_names = []
        for values in table['rows']:
            row = dict(zip(table['columns'], values))
            if row['archived_at'] or row['is_delete_marker'] != 'f':
                raise ValueError('Storage version needs review')
            name = 'pgdzdxsiagfjioxwuqxf/' + row['bucket_id'] + '/' + row['name']
            expected_names.append(name)
            info = archive.getinfo(name)
            metadata = json.loads(row['metadata'])
            if info.file_size != metadata['size'] or info.file_size > 1048576:
                raise ValueError('Storage size mismatch')
            content = archive.read(info)  # Read only; never extract untrusted paths.
            assets.append({'id': row['id'], 'sha256': digest(content),
                           'bytes': len(content), 'dataBase64': base64.b64encode(content).decode()})
        if set(names) != set(expected_names):
            raise ValueError('Storage export incomplete or has extra files')
    return assets


def prepare(source, expected_sha, destination, storage, storage_sha):
    original = source.read_bytes()
    if digest(original) != expected_sha:
        raise ValueError('Source checksum mismatch')
    raw = gzip.decompress(original)
    tables = parse_dump(raw)
    assets = storage_assets(storage.read_bytes(), storage_sha, tables)
    bundle = {'schemaVersion': 1, 'sourceSha256': digest(original),
              'sqlSha256': digest(raw), 'tables': tables,
              'storageSha256': storage_sha, 'assets': assets}
    # Mode is set before any sensitive bytes are written. Never replace an export.
    fd = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w', encoding='utf-8') as out:
        json.dump(bundle, out, ensure_ascii=False, separators=(',', ':'))
    return {'tables': len(tables), 'rows': sum(len(t['rows']) for t in tables), 'assets': len(assets),
            'sourceSha256': digest(original), 'bundleSha256': digest(destination.read_bytes())}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--sha256', required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--storage', type=Path, required=True)
    parser.add_argument('--storage-sha256', required=True)
    args = parser.parse_args()
    print(json.dumps(prepare(args.source, args.sha256, args.output, args.storage, args.storage_sha256)))
