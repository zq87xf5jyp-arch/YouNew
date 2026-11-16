#!/usr/bin/env python3
"""External availability check, deliberately separate from deterministic iOS tests.

No photo files are retained. Exit nonzero for invalid images AND inconclusive
network failures; the JSON report distinguishes them. No fallback URL is used.
"""
import argparse
import concurrent.futures
import datetime
import json
import re
import socket
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAX_BYTES = 16 * 1024 * 1024


def registry_urls(root=ROOT):
    tests = (root / 'YouNewTests/PriorityCityHeroMediaTests.swift').read_text()
    cities = re.search(r'private let priorityCities:.*?= \[(.*?)\n    \]', tests, re.S).group(1)
    pairs = re.findall(r'\("([^"]+)", "([^"]+)", "([^"]+)", "[^"]+"\)', cities)
    registry = (root / 'YouNew/Data/CuratedPlaceHeroMediaRegistry.swift').read_text()
    heroes = dict(re.findall(r'\.hero: visual\("([^"]+)"[^\n]*?remote: "([^"]+)"', registry))
    assert len(pairs) == 8, 'Priority city contract changed: review network coverage'
    result = {}
    for name, province, city_id in pairs:
        place_id = f'nl-city-{province.lower().replace("-", "_")}-{city_id.replace("-", "_")}'
        result[name] = heroes[place_id]
    assert len(set(result.values())) == len(result), 'Duplicate hero URL'
    return result


def validate_image(status, content_type, data):
    if status != 200:
        raise ValueError(f'HTTP {status}')
    if not content_type.lower().startswith('image/'):
        raise ValueError(f'Not an image Content-Type: {content_type}')
    if not 8000 < len(data) <= MAX_BYTES:
        raise ValueError(f'Unexpected image size: {len(data)}')
    # Reject HTML/errors even if the upstream sends an image MIME type.
    if not (data.startswith(b'\xff\xd8\xff') or data.startswith(b'\x89PNG\r\n\x1a\n') or
            (data.startswith(b'RIFF') and data[8:12] == b'WEBP')):
        raise ValueError('Response has no supported image signature')


def check_url(name, url, attempts=3, timeout=35, opener=urllib.request.urlopen, sleep=time.sleep):
    history = []
    for attempt in range(attempts):
        try:
            request = urllib.request.Request(url, headers={
                'User-Agent': 'YouNewMediaAudit/1.0 (https://younew.nl; support@younew.nl)',
                'Accept': 'image/jpeg,image/png,image/webp,image/*;q=0.8'})
            with opener(request, timeout=timeout) as response:
                data = response.read(MAX_BYTES + 1)
                content_type = response.headers.get('Content-Type', '')
                validate_image(response.status, content_type, data)
                history.append({'result': 'pass', 'status': response.status, 'contentType': content_type,
                                'bytes': len(data), 'finalURL': response.url})
                return {'city': name, 'url': url, 'result': 'pass', 'attempts': history}
        except urllib.error.HTTPError as error:
            retry = error.code in (408, 429) or error.code >= 500
            category = 'network_unconfirmed' if retry else 'invalid'
            history.append({'result': category, 'status': error.code, 'error': str(error)})
        except (urllib.error.URLError, TimeoutError, socket.timeout, ConnectionError) as error:
            retry = True
            category = 'network_unconfirmed'
            history.append({'result': category, 'error': str(error)})
        except ValueError as error:
            retry = False
            category = 'invalid'
            history.append({'result': category, 'error': str(error)})
        if not retry or attempt == attempts - 1:
            return {'city': name, 'url': url, 'result': category, 'attempts': history}
        sleep(2 * (attempt + 1))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
        results = list(executor.map(lambda item: check_url(*item), registry_urls().items()))
    report = {'checkedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'results': results}
    Path(args.output).write_text(json.dumps(report, indent=2) + '\n')
    for result in results:
        print(f'{result["city"]}: {result["result"]} ({len(result["attempts"])} attempts)')
    return 0 if all(r['result'] == 'pass' for r in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
