#!/usr/bin/env python3
"""Cache five replacement-photo source checks without touching approved selections.
No binary downloads or activation. Reuse the existing bounded, robots-aware client.
"""
import html
import importlib.util
import json
import re
from pathlib import Path
from urllib.parse import quote

spec = importlib.util.spec_from_file_location('travel', Path(__file__).with_name('prepare-travel-expansion.py'))
travel = importlib.util.module_from_spec(spec)
spec.loader.exec_module(travel)
output = travel.ROOT / 'DataProject/research/travel-media-followup-20261115'
candidates = [
    ('museum.foam', 'Amsterdam Keizersgracht 0609 001.JPG', 'Replacement for rejected soap image; very narrow facade crop requires visual review. Entity source remains unresolved.'),
    ('museum.huis-marseille', 'Huismarseille.jpg', 'Alternative to previous oversized response; facade photograph, visual review pending.'),
    ('place.rotterdam-markthal', 'Markthal - Rotterdam.jpg', 'Alternative to rejected streetscape; inspect building prominence and crop.'),
    ('museum.eindhoven-prehistorisch-dorp', 'PreHistorisch Dorp.jpg', 'Historical 2016 view, not evidence of current VONK appearance. EXIF credits Freekje Groenemans Fotografie while author field says Eindhoven Museum; rights clarification required.'),
    ('place.eindhoven-park-theatre', '13-06-29-eindhoven-50mm-52.jpg', 'Alternative to rejected backstage photograph; visual identity and presentation pending.')
]

def plain(value):
    parser = travel.Text()
    parser.feed(value)
    return ' '.join(parser.parts)

for entity_id, filename, note in candidates:
    target = output / (entity_id + '.json')
    if target.exists():
        print(entity_id, 'cached')
        continue
    url = 'https://commons.wikimedia.org/wiki/File:' + quote(filename)
    entry = dict(id=entity_id, sourceURL=url, checkedAt=travel.TODAY,
                 status='needs_review', publicationAuthorized=False, reviewerId=None,
                 visualIdentityChecked=False, rightsEvidenceChecked=False, files=[], reviewNote=note)
    try:
        allowed, robots_hash, robots_state = travel.permission(url)
        entry.update(robotsSHA256=robots_hash, robotsStatus=robots_state)
        if not allowed:
            raise ValueError('Robots disallowed or unavailable; no request made')
        data, status, final, content_type = travel.request(url)
        page = html.unescape(data.decode('utf8'))
        entry.update(httpStatus=status, finalURL=final, sourcePageSHA256=travel.sha(data))
        author = re.search(r'id="fileinfotpl_aut"[^>]*>.*?</td>\s*<td[^>]*>(.*?)</td>', page, re.S)
        licenses = re.findall(r'<span class="licensetpl_link"[^>]*>(.*?)</span>', page, re.S)
        license_values = re.findall(r'https?://creativecommons.org/licenses/(by(?:-sa)?)/(\d\.\d)', ' '.join(licenses))
        if not author or not license_values:
            raise ValueError('Explicit author/license metadata unavailable')
        kind, version = license_values[0]
        entry.update(author=plain(author[1]), license='CC ' + kind.upper() + ' ' + version,
                     licenseURL=f'https://creativecommons.org/licenses/{kind}/{version}/',
                     shareAlike=kind == 'by-sa', licenseMetadataExtracted=True,
                     changes='None; image bytes not downloaded or transformed.')
        entry['attribution'] = f'{filename} — {entry["author"]} — {entry["license"]}'
        entry['requiredAttribution'] = 'Retain title, author, source and license links; identify future modifications; apply ShareAlike to derivatives when required.'
    except Exception as error:
        entry['limitation'] = str(error)[:200]
    travel.write(target, entry)
    print(entity_id, entry.get('license', entry.get('limitation')), flush=True)
