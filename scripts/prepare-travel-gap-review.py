#!/usr/bin/env python3
"""Bounded follow-up evidence, cached independently of immutable approved packages."""
import importlib.util
import json
from pathlib import Path
spec = importlib.util.spec_from_file_location('prep', Path(__file__).with_name('prepare-travel-expansion.py'))
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)
p.DIR = p.ROOT / 'DataProject/research/travel-gap-review-20261115'
rows = [
 ('place.leiden-oude-sterrewacht','https://hortusleiden.nl/zien-en-doen/ontdek-de-oude-sterrewacht'),
 ('museum.foam','https://www.foam.org/visit'),
 ('museum.artis-micropia','https://www.artis.nl/nl/artis-micropia'),
 ('museum.museum-van-loon','https://www.museumvanloon.nl/bezoek'),
 ('museum.den-haag-mauritshuis','https://www.mauritshuis.nl/bezoek'),
 ('museum.den-haag-kunstmuseum','https://www.kunstmuseum.nl/nl/bezoek'),
 ('place.den-haag-madurodam','https://www.madurodam.nl/nl/praktische-informatie/adres-en-route'),
 ('place.eindhoven-strijp-s','https://www.strijp-s.nl/historie'),
 ('place.eindhoven-park-theatre','https://www.parktheater.nl/contact-r2l7'),
 ('museum.dutch-resistance-museum','https://www.verzetsmuseum.org/en/address-and-opening-hours'),
 ('place.eindhoven-muziekgebouw','https://www.heuveleindhoven.nl/winkels/muziekgebouw/')
]
entries=[]
for entity_id, url in rows:
 evidence = p.fetch({'url':url})
 evidence_file = p.DIR/'sources'/(p.sha(url.encode())+'.json')
 entries.append(dict(id=entity_id, sourceURL=url, evidenceFile=str(evidence_file.relative_to(p.ROOT)),
                     evidenceSHA256=p.sha(evidence_file.read_bytes()), fetchStatus=evidence['status'],
                     status='needs_review', publicationAuthorized=False, reviewerId=None))
 print(entity_id,evidence['status'],evidence.get('error',''),flush=True)
p.write(p.DIR/'source-followup.json',dict(schemaVersion=1,checkedAt=p.TODAY,records=entries,
  publicationAuthorized=False,reviewerId=None,scope='Eleven source/address follow-ups; no content activated or previous evidence overwritten.'))
