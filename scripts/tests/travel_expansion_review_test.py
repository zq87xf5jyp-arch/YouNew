"""Offline review checks; these do not grant publication approval."""
import importlib.util
import sys
import hashlib
import json
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REVIEW = ROOT / 'DataProject/research/travel-expansion-20261115'
STAGING = ROOT / 'DataProject/staging/travel-expansion-20261115'
SCHEMA = json.loads((ROOT / 'DataProject/schema/entity.schema.json').read_text())
sys.path.insert(0, str(ROOT / 'scripts'))
spec = importlib.util.spec_from_file_location('data_importer', ROOT / 'scripts/import-data-project.py')
importer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(importer)


def read(path):
    return json.loads(path.read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()




class ReviewTests(unittest.TestCase):
    def setUp(self):
        self.index = read(REVIEW / 'index.json')

    def test_canonical_schema_and_languages(self):
        for batch in self.index['batches']:
            for record in read(STAGING / (batch['city'] + '.json'))['records']:
                with self.subTest(id=record['id']):
                    importer.validate_schema(record, SCHEMA, SCHEMA, record['id'])
                    self.assertGreaterEqual(len(record['attributes']['description_nl']), 40)
                    self.assertEqual(record['city_id'], batch['city'])

    def test_ids_references_and_manifest_hashes(self):
        ids = [r['id'] for r in self.index['records']]
        self.assertEqual(len(ids), len(set(ids)))
        for ref in self.index['records']:
            file = ROOT / ref['recordFile']
            self.assertEqual(digest(file), ref['fileSHA256'])
            self.assertEqual(sum(r['id'] == ref['id'] for r in read(file)['records']), 1)
        for batch in self.index['batches']:
            manifest = read(STAGING / (batch['city'] + '-manifest.json'))
            self.assertEqual(digest(STAGING / (batch['city'] + '.json')), manifest['recordsSHA256'])
            self.assertIsNone(manifest['reviewerId'])
            self.assertIsNone(manifest['approvedAt'])
            self.assertIs(manifest['publicationAuthorized'], False)

    def test_drafts_cannot_be_published(self):
        self.assertIs(self.index['publicationAuthorized'], False)
        for batch in self.index['batches']:
            payload = read(STAGING / (batch['city'] + '.json'))
            self.assertEqual(payload['publication_status'], 'draft')
            for record in payload['records']:
                self.assertEqual(record['lifecycle_status'], 'draft')
                self.assertEqual(record['verification_status'], 'needs_review')
                self.assertEqual(record['images'], [])
                self.assertIsNone(record['coordinates'])

    def test_source_proofs(self):
        checked = set(read(REVIEW / 'content-inspection.json')['contentCheckedIDs'])
        for batch in self.index['batches']:
            manifest = read(STAGING / (batch['city'] + '-manifest.json'))
            records = read(STAGING / (batch['city'] + '.json'))['records']
            for record, proof in zip(records, manifest['evidence']):
                source_file = ROOT / record['attributes']['source_evidence_file']
                self.assertEqual(digest(source_file), proof['sourceEvidenceSHA256'])
                if record['website']:
                    self.assertIn(record['id'], checked)
                    self.assertEqual(read(source_file)['status'], 'opened')
                    self.assertEqual(record['official_source']['status'], 'verified_opened')
                else:
                    self.assertIs(proof['contentChecked'], False)

    def test_media_hashes_and_review_boundary(self):
        hashes = set()
        for file in (REVIEW / 'media-evidence').glob('*.json'):
            media = read(file)
            self.assertIs(media['publicationAuthorized'], False)
            self.assertIs(media['rightsEvidenceChecked'], False)
            if media['files']:
                self.assertRegex(media['license'], r'^CC BY(?:-SA)? \d\.\d$')
                if media.get('blockingIssues'):
                    self.assertIsNone(media['author'])
                    self.assertIsNone(media['attribution'])
                else:
                    self.assertTrue(media['author'])
                    self.assertTrue(media['attribution'])
                self.assertTrue(media['url'].startswith('https://commons.wikimedia.org/wiki/File:'))
            for image in media['files']:
                self.assertEqual(digest(ROOT / image['path']), image['sha256'])
                self.assertNotIn(image['sha256'], hashes)
                hashes.add(image['sha256'])
        for ref in self.index['records']:
            if 'reviewMedia' in ref:
                media = ref['reviewMedia']
                self.assertEqual(digest(ROOT / media['evidenceFile']), media['sha256'])

    def test_collection_membership(self):
        refs = {r['id']: r for r in self.index['records']}
        for collection in read(STAGING / 'collections.json')['collections']:
            self.assertIs(collection['publicationAuthorized'], False)
            self.assertEqual(len(collection['entityIDs']), len(set(collection['entityIDs'])))
            for member in collection['entityIDs']:
                self.assertEqual(refs[member]['city'], collection['city'])
                self.assertTrue(refs[member]['sourceContentChecked'])

    def test_production_data_unchanged_from_pr69(self):
        result = subprocess.run(['git', 'diff', '--exit-code',
            'a56429fcc42a209324b51f29eda953684e043b0b', '--', 'YouNew/Resources/Data/younew-approved-places.json',
            'DataProject/editorial', ':(exclude)DataProject/editorial/travel-ios-local-20261115-approval.json', 'DataProject/approvals'],
            cwd=ROOT, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout.decode())

    def test_reproducible_outputs(self):
        result = subprocess.run(['python3', 'scripts/prepare-travel-expansion.py', '--check'],
            cwd=ROOT, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr.decode())


if __name__ == '__main__':
    unittest.main()
