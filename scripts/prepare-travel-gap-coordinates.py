#!/usr/bin/env python3
"""Ten missing coordinates from existing approved addresses; review-only BAG evidence."""
import importlib.util
import json
import re
import urllib.parse
from pathlib import Path
spec=importlib.util.spec_from_file_location('prep',Path(__file__).with_name('prepare-travel-expansion.py'))
p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
out=p.ROOT/'DataProject/research/travel-gap-review-20261115/coordinates'
artifact=p.ROOT/'YouNew/Resources/Data/younew-approved-local-test.json'
records=json.loads(artifact.read_text())['entities']
ids=['restaurant.leiden-bikini','restaurant.leiden-in-den-doofpot','restaurant.leiden-verboden-toegang',
     'restaurant.leiden-prentenkabinet','restaurant.leiden-oudt-leyden','museum.rotterdam-chabot',
     'museum.den-haag-fotomuseum','museum.utrecht-sonnenborgh','place.leiden-vvv','place.leiden-cafe-laken']
norm=lambda v:re.sub('[^a-z0-9]','',str(v).lower())
for eid in ids:
    target=out/(eid+'.json')
    if target.exists():print(eid,'cached');continue
    r=next(r for r in records if r['id']==eid);a=r['attributes']
    assert r['coordinate'] is None,'Do not redo an existing coordinate'
    e=dict(id=eid,status='needs_review',publicationAuthorized=False,reviewerId=None,
        checkedAt=p.TODAY,coordinate=None,addressMatched=False,
        approvedAddress=a.get('address'),officialSourceURL=a.get('address_source_url'),
        addressCheckedAt=a.get('address_checked_at'),
        sourceArtifact={'path':str(artifact.relative_to(p.ROOT)),'sha256':p.sha(artifact.read_bytes())},
        method='Existing approved official address matched exactly to BAG centroid; not a surveyed entrance',
        license='CC0 1.0',licenseEvidence='DataProject/research/travel-approval-20261115/coordinate-license.json')
    try:
        assert e['approvedAddress'] and e['officialSourceURL'] and e['addressCheckedAt']
        match=re.fullmatch(r'(.+?)\s+(\d+[^,]*),\s*(\d{4}\s*[A-Za-z]{2})\s+(.+)',a['address'])
        assert match,'Address format needs editorial review'
        street,house,postcode,city=match.groups()
        url='https://api.pdok.nl/bzk/locatieserver/search/v3_1/free?'+urllib.parse.urlencode({'q':a['address'],'fq':'type:adres','rows':5})
        e['url']=url;allowed,h,_=p.permission(url);e['robotsSHA256']=h
        assert allowed,'robots disallowed or unavailable'
        data,_,_,_=p.request(url);e['responseSHA256']=p.sha(data)
        docs=json.loads(data)['response']['docs'];e['candidateAddresses']=[d['weergavenaam'] for d in docs]
        matches=[d for d in docs if all(norm(d.get(k))==norm(v) for k,v in [('straatnaam',street),('huis_nlt',house),('postcode',postcode),('woonplaatsnaam',city)])]
        assert len(matches)==1,'No unique exact BAG address; no approximate substitution'
        bag=matches[0];assert bag['bron']=='BAG'
        lon,lat=map(float,re.fullmatch(r'POINT\(([-\d.]+) ([-\d.]+)\)',bag['centroide_ll']).groups())
        assert 50.7<=lat<=53.7 and 3.2<=lon<=7.3
        e.update(bag=bag,coordinate={'latitude':lat,'longitude':lon},addressMatched=True)
    except Exception as error:e['limitation']=str(error)[:220]
    p.write(target,e);print(eid,e['coordinate'] or e['limitation'],flush=True)
