"""Checks for a proposed field-scoped selection, not an approval mechanism."""
import copy
import importlib.util
import json
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('selection', ROOT / 'scripts/prepare-travel-selection.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SelectionTests(unittest.TestCase):
    def setUp(self):
        self.selection = module.read(module.SELECTION)

    def test_every_file_binding_matches(self):
        def walk(value):
            if isinstance(value, dict):
                if 'path' in value and 'sha256' in value:
                    path = (ROOT / value['path']).resolve()
                    self.assertTrue(path.is_relative_to(ROOT))
                    self.assertEqual(module.p.sha(path.read_bytes()), value['sha256'])
                for child in value.values():
                    walk(child)
            elif isinstance(value, list):
                for child in value:
                    walk(child)
        walk(self.selection)

    def test_exact_scope_and_no_approval(self):
        self.assertEqual(self.selection['counts'], {'records': 57, 'photos': 32,
            'coordinates': 33, 'collections': 6, 'newRuntimeItems': 0})
        self.assertIs(self.selection['publicationAuthorized'], False)
        self.assertIsNone(self.selection['reviewerId'])
        self.assertIsNone(self.selection['approvedAt'])
        fields = {'id', 'entity_type', 'category', 'city_id', 'province_id', 'title',
                  'description', 'description_nl', 'official_source', 'website',
                  'last_checked', 'review_frequency_days', 'search_keywords'}
        for record in self.selection['records']:
            self.assertEqual(set(record['fields']), fields)
            self.assertEqual(record['fields']['official_source']['status'], 'verified_opened')
            self.assertNotIn(record['id'], self.selection['unresolvedSources'])

    def test_wrong_subject_and_author_regressions(self):
        photos = {p['id']: p for p in self.selection['photos']}
        self.assertEqual(photos['museum.van-gogh-museum']['author'], 'Minke Wagenaar')
        for rejected in ['museum.foam', 'place.rotterdam-markthal',
                         'museum.eindhoven-prehistorisch-dorp', 'place.eindhoven-park-theatre']:
            self.assertNotIn(rejected, photos)
        for photo in photos.values():
            self.assertEqual({f['width'] for f in photo['files']}, {480, 800, 1200})
            self.assertEqual(photo['shareAlike'], 'BY-SA' in photo['license'])
            self.assertTrue(photo['author'] and photo['attribution'] and photo['sourceURL'])

    def test_exact_coordinates_and_negative_cases(self):
        for selected in self.selection['coordinates']:
            evidence = module.read(ROOT / selected['evidence']['path'])
            module.validate_coordinate(evidence)
            self.assertEqual(selected['coordinate'], evidence['coordinate'])
            for field in ['street', 'house', 'postcode', 'locality']:
                bad = copy.deepcopy(evidence)
                bad['officialAddress'][field] = 'wrong'
                with self.assertRaises(AssertionError):
                    module.validate_coordinate(bad)
            bad = copy.deepcopy(evidence)
            bad['coordinate']['latitude'] += 0.1
            with self.assertRaises(AssertionError):
                module.validate_coordinate(bad)
        self.assertEqual({r['id'] for r in self.selection['unresolvedCoordinates']},
            {'museum.dutch-resistance-museum', 'place.eindhoven-muziekgebouw'})

    def test_ids_and_collections_resolve_without_unverified_records(self):
        index = module.read(module.ROOT / self.selection['index']['path'])
        eligible = {r['id'] for r in index['records'] if r['sourceContentChecked']}
        for section in ['records', 'photos', 'coordinates']:
            ids = [r['id'] for r in self.selection[section]]
            self.assertEqual(len(ids), len(set(ids)))
            self.assertTrue(set(ids) <= eligible)
        for collection in self.selection['collections']['items']:
            self.assertIs(collection['publicationAuthorized'], False)
            self.assertTrue(set(collection['entityIDs']) <= eligible)

    def test_no_runtime_or_historical_evidence_mutation(self):
        result = subprocess.run(['git', 'diff', '--exit-code', 'f03657e', '--',
            'YouNew', 'YouNew.xcodeproj', 'DataProject/editorial',
            'DataProject/research/travel-expansion-20261115',
            'DataProject/staging/travel-expansion-20261115'], cwd=ROOT, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout.decode())

    def test_offline_reproduction(self):
        result = subprocess.run(['python3', 'scripts/prepare-travel-selection.py', '--check'],
            cwd=ROOT, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr.decode())


if __name__ == '__main__':
    unittest.main()
