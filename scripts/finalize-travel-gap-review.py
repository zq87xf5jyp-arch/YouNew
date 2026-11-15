#!/usr/bin/env python3
"""Record bounded editorial follow-up; never changes runtime or human approvals."""
import importlib.util
import json
import re
import urllib.parse
from pathlib import Path

spec = importlib.util.spec_from_file_location('prep', Path(__file__).with_name('prepare-travel-expansion.py'))
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)
out = p.ROOT / 'DataProject/research/travel-gap-review-20261115'
followup = json.loads((out/'source-followup.json').read_text())
refs = {r['id']: r for r in followup['records']}
index = json.loads((p.DIR/'index.json').read_text())
notes = {
    'place.leiden-oude-sterrewacht': 'Hortus operator page supports historic observatory and visiting programme. Exhibition access via Hortus differs from private-tour entrance; do not substitute either entrance for all visits.',
    'museum.artis-micropia': 'ARTIS operator page supports existing EN/NL microbe-museum description. No prices, opening hours or ticket URLs selected.',
    'place.eindhoven-strijp-s': 'District operator history supports former Philips industry and current creative/cultural uses. A district is not a single building or entrance.'
}
decisions=[]
for eid, note in notes.items():
    ref=refs[eid]
    assert ref['fetchStatus']=='opened'
    original=next(r for r in index['records'] if r['id']==eid)
    file=p.ROOT/original['recordFile']
    record=next(r for r in json.loads(file.read_text())['records'] if r['id']==eid)
    assert record['description'] and record['attributes']['description_nl']
    decisions.append(dict(id=eid,status='needs_review',publicationAuthorized=False,reviewerId=None,
        contentChecked=True,checkedAt=p.TODAY,reviewNote=note,
        existingRecord={'path':original['recordFile'],'sha256':p.sha(file.read_bytes())},
        reusedFields=['id','title','description','attributes.description_nl'],
        proposedSource=ref['sourceURL'],sourceEvidence={'path':ref['evidenceFile'],'sha256':ref['evidenceSHA256']}))
p.write(out/'editorial-decisions.json',{'schemaVersion':1,'publicationAuthorized':False,'records':decisions})

# The property operator explicitly identifies this venue at Heuvel Galerie 140.
# This is additional identity evidence, not a fuzzy match of the old street name.
eid='place.eindhoven-muziekgebouw'
target=out/'coordinates'/(eid+'.json')
if not target.exists():
    ref=refs[eid]
    e=dict(id=eid,status='needs_review',publicationAuthorized=False,reviewerId=None,
        checkedAt=p.TODAY,coordinate=None,addressMatched=False,
        officialAddress={'street':'Heuvel Galerie','house':'140','postcode':'5611DK','locality':'Eindhoven'},
        officialSourceURL=ref['sourceURL'],officialSourceEvidenceFile=ref['evidenceFile'],
        officialSourceEvidenceSHA256=ref['evidenceSHA256'],
        sourceRole='Property operator venue directory; supplements venue site Heuvel 140',
        method='Exact property-operator address matched to BAG centroid, not a surveyed entrance',
        license='CC0 1.0',licenseEvidence='DataProject/research/travel-approval-20261115/coordinate-license.json')
    try:
        assert ref['fetchStatus']=='opened'
        url='https://api.pdok.nl/bzk/locatieserver/search/v3_1/free?'+urllib.parse.urlencode({'q':'Heuvel Galerie 140 5611DK Eindhoven','fq':'type:adres','rows':5})
        e['url']=url
        allowed,h,_=p.permission(url);e['robotsSHA256']=h
        assert allowed,'robots disallowed or unavailable'
        data,_,_,_=p.request(url);e['responseSHA256']=p.sha(data)
        normalize=lambda x:re.sub('[^a-z0-9]','',str(x).lower())
        matches=[d for d in json.loads(data)['response']['docs'] if all(normalize(d.get(k))==normalize(v) for k,v in [('straatnaam','Heuvel Galerie'),('huis_nlt','140'),('postcode','5611DK'),('woonplaatsnaam','Eindhoven')])]
        assert len(matches)==1,'Ambiguous or absent exact BAG address'
        bag=matches[0];assert bag['bron']=='BAG'
        lon,lat=map(float,re.fullmatch(r'POINT\(([-\d.]+) ([-\d.]+)\)',bag['centroide_ll']).groups())
        assert 50.7<=lat<=53.7 and 3.2<=lon<=7.3
        e.update(bag=bag,coordinate={'latitude':lat,'longitude':lon},addressMatched=True)
    except Exception as error:e['limitation']=str(error)[:220]
    p.write(target,e)
print('3 existing EN/NL pairs supported by new sources; coordinate:',json.loads(target.read_text())['coordinate'])
