import hashlib
import json
from pathlib import Path
import re
import subprocess
import unittest

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'DataProject/research/travel-gap-review-20261115'
read=lambda p:json.loads(p.read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

class GapReviewTests(unittest.TestCase):
    def test_source_and_editorial_bindings(self):
        records=read(OUT/'source-followup.json')['records']
        self.assertEqual(len(records),11)
        self.assertEqual(len({r['id'] for r in records}),11)
        for r in records:
            self.assertEqual(sha(ROOT/r['evidenceFile']),r['evidenceSHA256'])
            self.assertFalse(r['publicationAuthorized'])
        edits=read(OUT/'editorial-decisions.json')['records']
        self.assertEqual(len(edits),3)
        for e in edits:
            self.assertIsNone(e['reviewerId'])
            self.assertFalse(e['publicationAuthorized'])
            for key in ['existingRecord','sourceEvidence']:
                self.assertEqual(sha(ROOT/e[key]['path']),e[key]['sha256'])
            self.assertEqual(read(ROOT/e['sourceEvidence']['path'])['status'],'opened')

    def test_new_coordinates_are_exact_address_centroids(self):
        entries=[read(p) for p in (OUT/'coordinates').glob('*.json')]
        self.assertEqual(len(entries),11)
        self.assertEqual(sum(bool(e['coordinate']) for e in entries),10)
        norm=lambda v:re.sub('[^a-z0-9]','',str(v).lower())
        for e in entries:
            self.assertFalse(e['publicationAuthorized'])
            self.assertIsNone(e['reviewerId'])
            if 'sourceArtifact' in e:
                self.assertEqual(sha(ROOT/e['sourceArtifact']['path']),e['sourceArtifact']['sha256'])
            if not e['coordinate']:
                self.assertFalse(e['addressMatched']);continue
            self.assertTrue(e['addressMatched'])
            bag=e['bag'];self.assertEqual(bag['bron'],'BAG')
            lon,lat=map(float,re.fullmatch(r'POINT\(([-\d.]+) ([-\d.]+)\)',bag['centroide_ll']).groups())
            self.assertEqual(e['coordinate'],dict(latitude=lat,longitude=lon))
            if 'approvedAddress' in e:
                address=re.fullmatch(r'(.+?)\s+(\d+[^,]*),\s*(\d{4}\s*[A-Za-z]{2})\s+(.+)',e['approvedAddress']).groups()
            else:
                a=e['officialAddress'];address=(a['street'],a['house'],a['postcode'],a['locality'])
                self.assertEqual(sha(ROOT/e['officialSourceEvidenceFile']),e['officialSourceEvidenceSHA256'])
            for field,value in zip(['straatnaam','huis_nlt','postcode','woonplaatsnaam'],address):
                self.assertEqual(norm(bag[field]),norm(value))

    def test_media_review_and_bytes(self):
        entries=[read(p) for p in (OUT/'media-evidence').glob('*.json')]
        self.assertEqual(len(entries),5)
        self.assertEqual(sum(len(e['files']) for e in entries),4)
        hashes=set()
        for e in entries:
            self.assertFalse(e['publicationAuthorized']);self.assertIsNone(e['reviewerId'])
            self.assertEqual(sha(ROOT/e['previousEvidence']['path']),e['previousEvidence']['sha256'])
            self.assertTrue(e['author']);self.assertTrue(e['licenseURL'].startswith('https://creativecommons.org/licenses/'))
            for f in e['files']:
                self.assertEqual(sha(ROOT/f['path']),f['sha256'])
                self.assertNotIn(f['sha256'],hashes);hashes.add(f['sha256'])
        vonk=next(e for e in entries if 'prehistorisch' in e['id'])
        self.assertEqual(vonk['files'],[])
        visual=read(OUT/'visual-review.json')
        self.assertEqual(len(visual['photos']),4)
        self.assertTrue(all(p['visualIdentityChecked'] and not p['publicationAuthorized'] for p in visual['photos']))

    def test_approved_and_runtime_bytes_unchanged(self):
        result=subprocess.run(['git','diff','--exit-code','512abc1','--','YouNew','DataProject/editorial',
            'DataProject/research/travel-approval-20261115','DataProject/research/travel-expansion-20261115',
            'DataProject/research/travel-media-followup-20261115','DataProject/staging',
            'docs/younew-upgrade/TRAVEL_APPROVAL_SELECTION_2026-11-15.json'],cwd=ROOT,capture_output=True)
        self.assertEqual(result.returncode,0,result.stdout.decode())

if __name__=='__main__':unittest.main()
