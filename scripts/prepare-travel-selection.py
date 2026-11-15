#!/usr/bin/env python3
"""Prepare a field-scoped owner review request. Never creates an approval receipt.
Network checks are opt-in and cached; regeneration/verification are offline.
"""
import argparse, csv, html, importlib.util, json, re, time, urllib.parse
from pathlib import Path
spec = importlib.util.spec_from_file_location('prep', Path(__file__).with_name('prepare-travel-expansion.py'))
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)
ROOT = p.ROOT
OUT = ROOT / 'DataProject/research/travel-approval-20261115'
SELECTION = ROOT / 'docs/younew-upgrade/TRAVEL_APPROVAL_SELECTION_2026-11-15.json'
REVIEW = ROOT / 'docs/younew-upgrade/TRAVEL_APPROVAL_REVIEW_2026-11-15.md'


def read(path):
    return json.loads(path.read_text())


def binding(path):
    return {'path': str(path.relative_to(ROOT)), 'sha256': p.sha(path.read_bytes())}


def validate_coordinate(evidence):
    """Fail closed on address ambiguity or a coordinate unrelated to its BAG point."""
    normalize = lambda value: re.sub(r'[^a-z0-9]', '', str(value).lower())
    address = evidence['officialAddress']
    bag = evidence['bag']
    assert evidence['addressMatched'] and bag['bron'] == 'BAG'
    for expected, actual in [('street', 'straatnaam'), ('house', 'huis_nlt'),
                             ('locality', 'woonplaatsnaam')]:
        assert normalize(address[expected]) == normalize(bag[actual])
    if address['postcode']:
        assert normalize(address['postcode']) == normalize(bag['postcode'])
    longitude, latitude = map(float, re.fullmatch(
        r'POINT\(([-\d.]+) ([-\d.]+)\)', bag['centroide_ll']).groups())
    assert 50.7 <= latitude <= 53.7 and 3.2 <= longitude <= 7.3
    assert evidence['coordinate'] == {'latitude': latitude, 'longitude': longitude}
    source_path = ROOT / evidence['officialSourceEvidenceFile']
    assert p.sha(source_path.read_bytes()) == evidence['officialSourceEvidenceSHA256']
    assert read(source_path)['status'] == 'opened'


def build(check=False):
    index_path = p.DIR / 'index.json'
    index = read(index_path)
    visual_path = OUT / 'visual-review.json'
    visual = read(visual_path)
    refs = {r['id']: r for r in index['records']}
    records = []
    selected_fields = ['id', 'entity_type', 'category', 'city_id', 'province_id',
                       'title', 'description', 'official_source', 'website',
                       'last_checked', 'review_frequency_days', 'search_keywords']
    for ref in index['records']:
        if ref['origin'] == 'existing_compact_approval' or not ref['sourceContentChecked']:
            continue
        source_path = ROOT / ref['recordFile']
        record = next(r for r in read(source_path)['records'] if r['id'] == ref['id'])
        fields = {key: record[key] for key in selected_fields}
        fields['description_nl'] = record['attributes']['description_nl']
        records.append({'id': record['id'], 'source': binding(source_path),
                        'primarySourceEvidence': binding(ROOT / record['attributes']['source_evidence_file']),
                        'fields': fields})
    photos = []
    held = []
    for decision in visual['photos']:
        if decision['decision'] != 'propose_for_owner_approval':
            held.append({'id': decision['id'], 'reason': decision['reason']})
            continue
        eid = decision['id']
        assert refs[eid]['sourceContentChecked']
        evidence_path = p.DIR / 'media-evidence' / (eid + '.json')
        evidence = read(evidence_path)
        source_path = OUT / 'media-source-checks' / (eid + '.json')
        source = read(source_path)
        normalize = lambda u: u.replace('http:', 'https:').rstrip('/')
        assert normalize(decision['licenseURL']) in [normalize(u) for u in source['licenseURLs']]
        assert decision['visuallyInspected'] and decision['author']
        # All files are existing derivatives: no duplicate downloads or copies.
        for file in evidence['files']:
            assert p.sha((ROOT / file['path']).read_bytes()) == file['sha256']
        title = next(r['title'] for r in read(ROOT / refs[eid]['recordFile'])['records'] if r['id'] == eid)
        photos.append({'id': eid, 'title': title, 'author': decision['author'],
                       'license': decision['license'], 'licenseURL': decision['licenseURL'],
                       'sourceURL': decision['sourceURL'], 'captureDate': decision['captureDate'],
                       'attribution': f"{title} — {decision['author']} — {decision['license']}; resized as WebP, no crop or content edits.",
                       'shareAlike': evidence['shareAlike'],
                       'files': evidence['files'], 'previousEvidence': binding(evidence_path),
                       'sourceCheck': binding(source_path), 'visualReview': binding(visual_path)})
    coordinates = []
    unresolved_coordinates = []
    for path in sorted((OUT / 'coordinates').glob('*.json')):
        evidence = read(path)
        if evidence['coordinate'] is None:
            unresolved_coordinates.append({'id': evidence['id'], 'reason': evidence['limitation']})
            continue
        validate_coordinate(evidence)
        assert evidence['addressMatched'] and refs[evidence['id']]['sourceContentChecked']
        coordinates.append({'id': evidence['id'], 'coordinate': evidence['coordinate'],
                            'address': evidence['bag']['weergavenaam'],
                            'method': evidence['method'], 'evidence': binding(path),
                            'licenseEvidence': binding(OUT / 'coordinate-license.json')})
    collections_path = ROOT / 'DataProject/staging/travel-expansion-20261115/collections.json'
    collections = read(collections_path)['collections']
    selection = {'schemaVersion': 1, 'status': 'needs_review', 'publicationAuthorized': False,
                 'approvedAt': None, 'reviewerId': None, 'preparedAt': '2026-11-15',
                 'scope': 'Only the exact record fields, photo derivatives, address coordinates and collection memberships listed here are proposed for owner approval and subsequent governed iOS integration. No approval is granted by this file. Historical package statuses remain unchanged. No production, TestFlight, App Store or merge authorization.',
                 'excludedFields': ['prices', 'opening_hours', 'new_ticket_urls', 'menu_urls', 'booking_urls', 'unlisted_draft_fields'],
                 'index': binding(index_path), 'counts': {'records': len(records), 'photos': len(photos),
                 'coordinates': len(coordinates), 'collections': len(collections), 'newRuntimeItems': 0},
                 'records': records, 'photos': photos, 'coordinates': coordinates,
                 'collections': {'source': binding(collections_path), 'items': collections},
                 'heldPhotos': held, 'unresolvedCoordinates': unresolved_coordinates,
                 'unresolvedSources': [r['id'] for r in index['records'] if not r['sourceContentChecked']]}
    encoded = json.dumps(selection, ensure_ascii=False, indent=2) + '\n'
    selection_hash = p.sha(encoded.encode())
    if check:
        assert SELECTION.read_text() == encoded, 'Stale selection'
    else:
        SELECTION.write_text(encoded)
    lines = ['# Travel content: exact owner review request', '',
             '**Pending human approval. No new runtime content has been activated.**', '',
             f'Selection SHA-256: `{selection_hash}`.', '',
             f"Proposed scope: **{len(records)} EN/NL records, {len(photos)} photographs, {len(coordinates)} address coordinates, {len(collections)} collections**. All object IDs already exist in the PR #70 review index; no additional entities are introduced here.", '',
             'This request includes photographs of existing park entries. It does not approve other park draft fields, prices, hours or ticket links. The earlier 4-photo / 5-coordinate / 6-ticket approval remains unchanged.', '',
             'Approval will permit subsequent implementation through the governed exporter; it will not itself activate records, publish entire packages or authorize a merge/deployment. The exporter currently supports the earlier Leiden selection only; support for this new exact selection must be implemented and tested after approval.', '',
             '## EN/NL text and official sites', '',
             'These are proposed source-backed descriptions, not new reviews or ratings. Nine unresolved primary sources are excluded. Historical base files and publication flags are unchanged.', '',
             '| ID / city | EN | NL | Official source |', '|---|---|---|---|']
    for item in records:
        r = item['fields']
        esc = lambda text: text.replace('|', '\\|').replace('\n', ' ')
        lines.append(f"| `{r['id']}` / {r['city_id']} | {esc(r['description'])} | {esc(r['description_nl'])} | [{esc(r['title'])}]({r['website']}) |")
    lines += ['', '## Photographs', '',
              'All 40 existing candidates were inspected locally. The 32 selected photographs have matching Commons identity, author and license evidence; they still need owner approval. Historical images are not promises of today’s appearance. Credit, source/license links, resize disclosure and applicable ShareAlike terms must accompany integration. No images were downloaded again.', '',
              'Van Gogh Museum photographer corrected to **Minke Wagenaar** using the Photograph section; Vincent van Gogh is the artist of a depicted work, not the photographer. The unrelated soap-foam image is excluded.', '']
    for photo in photos:
        preview = next(f['path'] for f in photo['files'] if f['width'] == 480)
        lines += [f"### {photo['title']} — `{photo['id']}`", '',
                  f"{photo['author']} · [{photo['license']}]({photo['licenseURL']}) · [Original source]({photo['sourceURL']}) · {photo['captureDate']}. Resized WebP; no content edits.", '',
                  f"![{photo['title']}](../../{preview})", '']
    lines += ['## Address coordinates', '',
              'Official visitor addresses were matched exactly by street, house number, postcode (where supplied) and city to BAG via PDOK. These are address-object centroids, **not surveyed entrances**; no camera position or city centre is substituted. Source: Kadaster / PDOK, BAG, [CC0 1.0 metadata](https://data.overheid.nl/dataset/basisregistratie-adressen-en-gebouwen--bag-). Apple Maps has not been launched for runtime QA.', '',
              '| ID | Official address matched to BAG | Latitude | Longitude |', '|---|---|---:|---:|']
    for c in coordinates:
        lines.append(f"| `{c['id']}` | {c['address']} | {c['coordinate']['latitude']} | {c['coordinate']['longitude']} |")
    lines += ['', '## Collections', '', '| ID | Members |', '|---|---|']
    for c in collections:
        lines.append(f"| `{c['id']}` | " + ', '.join('`'+eid+'`' for eid in c['entityIDs']) + ' |')
    lines += ['', '## Held material', '']
    for item in held + unresolved_coordinates:
        lines.append(f"- `{item['id']}`: {item['reason']}")
    lines += ['', 'Source checks still pending: ' + ', '.join('`'+eid+'`' for eid in selection['unresolvedSources']) + '.', '',
              '## Decision requested', '',
              f'Approve only this selection ({len(records)} records / {len(photos)} photos / {len(coordinates)} coordinates / {len(collections)} collections) bound to SHA-256 `{selection_hash}`, for subsequent governed integration into a local iOS candidate. Excluded material stays in review; production, TestFlight, App Store and automatic merging remain outside scope.', '',
              'A separate approval receipt must cite the actual human decision and exact hash. This generator never supplies a reviewer identity or publication permission.']
    document = '\n'.join(lines) + '\n'
    if check:
        assert REVIEW.read_text() == document, 'Stale review document'
    else:
        REVIEW.write_text(document)
    print(json.dumps(selection['counts']), selection_hash)

def fetch_coordinates():
    out=OUT
    rows={r['id']:r for r in csv.DictReader((p.DIR/'curated.tsv').open(),delimiter='\t')}
    for a in csv.DictReader((out/'addresses.tsv').open(),delimiter='\t'):
     path=out/'coordinates'/f"{a['id']}.json"
     if path.exists():continue
     src=rows[a['id']]['url'];sourcefile=p.DIR/'sources'/f'{p.sha(src.encode())}.json'
     e={'id':a['id'],'status':'needs_review','publicationAuthorized':False,'checkedAt':p.TODAY,'officialAddress':a,'officialSourceURL':src,'officialSourceEvidenceFile':str(sourcefile.relative_to(p.ROOT)),'officialSourceEvidenceSHA256':p.sha(sourcefile.read_bytes()),'method':'Exact official address matched to BAG address centroid; not a surveyed entrance','coordinate':None}
     url='https://api.pdok.nl/bzk/locatieserver/search/v3_1/free?'+urllib.parse.urlencode({'q':f"{a['street']} {a['house']} {a['postcode']} {a['locality']}",'fq':'type:adres','rows':5})
     e['url']=url
     try:
      allowed,rhash,_=p.permission(url);e['robotsSHA256']=rhash;assert allowed,'robots unavailable or disallowed'
      b,st,final,ct=p.request(url);e['responseSHA256']=p.sha(b);raw=json.loads(b);docs=raw['response']['docs']
      def norm(x):return re.sub(r'[^a-z0-9]','',str(x).lower())
      matches=[d for d in docs if norm(d.get('straatnaam'))==norm(a['street']) and norm(d.get('huis_nlt'))==norm(a['house']) and norm(d.get('woonplaatsnaam'))==norm(a['locality']) and (not a['postcode'] or norm(d.get('postcode'))==norm(a['postcode']))]
      e['candidateAddresses']=[d['weergavenaam'] for d in docs]
      assert len(matches)==1,f'Expected one exact address; found {len(matches)}'
      d=matches[0];lon,lat=map(float,re.fullmatch(r'POINT\(([-\d.]+) ([-\d.]+)\)',d['centroide_ll']).groups());assert 50.7<=lat<=53.7 and 3.2<=lon<=7.3
      e['coordinate']={'latitude':lat,'longitude':lon};e['bag']={k:d[k] for k in ['bron','weergavenaam','straatnaam','huis_nlt','postcode','woonplaatsnaam','nummeraanduiding_id','adresseerbaarobject_id','centroide_ll'] if k in d};e['addressMatched']=True
     except Exception as ex:e['limitation']=str(ex)[:200]
     p.write(path,e);print(e['id'],e.get('coordinate'),e.get('limitation',''),flush=True);time.sleep(.3)


def fetch_media():
    out=OUT
    for f in sorted((p.DIR/'media-evidence').glob('*.json')):
     m=json.loads(f.read_text())
     if not m['files']:continue
     dest=out/'media-source-checks'/f.name
     if dest.exists():continue
     e={'id':m['id'],'sourceURL':m['url'],'checkedAt':p.TODAY,'publicationAuthorized':False,'status':'needs_review','priorEvidenceFile':str(f.relative_to(p.ROOT)),'priorEvidenceSHA256':p.sha(f.read_bytes())}
     try:
      allowed,h,_=p.permission(m['url']);assert allowed,'robots unavailable or disallowed'
      b,st,url,ct=p.request(m['url']);e['sourcePageSHA256']=p.sha(b);e['robotsSHA256']=h;s=html.unescape(b.decode());t=p.Text();t.feed(s);text=' '.join(t.parts)
      tmp=Path('/tmp/younew-approval-media');tmp.mkdir(exist_ok=True);(tmp/(m['id']+'.txt')).write_text(text)
      license_links=re.findall(r'<span class="licensetpl_link"[^>]*>(.*?)</span>',s,re.S)
      e['licenseURLs']=list(dict.fromkeys(re.findall(r'https?://creativecommons.org/[^\s<>"\']+', ' '.join(license_links))))
      e['authorFromPriorReview']=m.get('author');e['sourceRead']=True
      e['descriptionExcerpt']=' '.join(text[text.find('Description'):].split()[:20])
      if m['id']=='museum.van-gogh-museum':e['correctedAuthor']='Minke Wagenaar';e['authorCorrectionBasis']='Photograph section, rather than the Artist field of the depicted painting. Commons Flickr review by Multichill on 2009-08-24.'
      if m['id']=='museum.foam':e['rejected']=True;e['reason']='Source describes scanned soap foam, not Foam photography museum.'
     except Exception as ex:e['limitation']=str(ex)[:180]
     p.write(dest,e);print(e['id'],e.get('licenseURLs'),e.get('descriptionExcerpt'),e.get('limitation',''),flush=True);time.sleep(.25)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fetch-coordinates', action='store_true')
    parser.add_argument('--fetch-media', action='store_true')
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if args.fetch_coordinates:
        fetch_coordinates()
    if args.fetch_media:
        fetch_media()
    if args.write or args.check:
        build(check=args.check)
