import importlib.util
from pathlib import Path
import unittest
import io
import zipfile

spec = importlib.util.spec_from_file_location('prepare', Path(__file__).parents[1] / 'prepare-legacy.py')
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class CopyDataTests(unittest.TestCase):
    def test_null_and_literal_escape_are_distinct(self):
        self.assertIsNone(prepare.unescape(b'\\N'))
        self.assertEqual(prepare.unescape(b'\\\\N'), '\\N')
        self.assertEqual(prepare.unescape(b'a\\tb\\n\\r\\134'), 'a\tb\n\r\\')

    def test_utf8_and_hex_octal_escapes(self):
        self.assertEqual(prepare.unescape(b'\\303\\251'), '\u00e9')
        self.assertEqual(prepare.unescape(b'\\x41'), 'A')
        self.assertRaises(ValueError, prepare.unescape, b'\\x')

    def test_sql_is_never_executed_and_raw_copy_is_preserved(self):
        import base64
        raw = b'DROP DATABASE example;\nCOPY public.example (id, value) FROM stdin;\n1\t\\\\N\n2\t\\N\n\\.\n-- PostgreSQL database dump complete\n'
        result = prepare.parse_dump(raw)[0]
        self.assertEqual(result['rows'], [['1', '\\N'], ['2', None]])
        self.assertEqual(base64.b64decode(result['copyBase64']), b'1\t\\\\N\n2\t\\N\n')

    def test_rejects_truncation_and_ambiguous_headers(self):
        self.assertRaises(ValueError, prepare.parse_dump, b'COPY public.x (id) FROM stdin;\n1\n')
        self.assertRaises(ValueError, prepare.parse_dump, b'COPY public.x (id, id) FROM stdin;\n\\.\n-- PostgreSQL database dump complete')

    def test_storage_requires_complete_matching_export(self):
        tables = [{'name': 'storage.objects', 'columns': ['id', 'bucket_id', 'name', 'metadata', 'archived_at', 'is_delete_marker'],
                   'rows': [['id', 'screenshots', 'test.png', '{"size":3}', None, 'f']]}]
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w') as archive:
            archive.writestr('pgdzdxsiagfjioxwuqxf/screenshots/test.png', b'abc')
        raw = buf.getvalue()
        assets = prepare.storage_assets(raw, prepare.digest(raw), tables)
        self.assertEqual(assets[0]['sha256'], prepare.digest(b'abc'))
        self.assertRaises(ValueError, prepare.storage_assets, raw, 'changed', tables)
        tables[0]['rows'][0][3] = '{"size":4}'
        self.assertRaises(ValueError, prepare.storage_assets, raw, prepare.digest(raw), tables)

    def test_unmapped_storage_entry_is_refused_without_extraction(self):
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w') as archive:
            archive.writestr('../../not-an-object', b'abc')
        raw = buf.getvalue()
        self.assertRaises(ValueError, prepare.storage_assets, raw, prepare.digest(raw), [{'name':'storage.objects','columns':[],'rows':[]}])


if __name__ == '__main__':
    unittest.main()
