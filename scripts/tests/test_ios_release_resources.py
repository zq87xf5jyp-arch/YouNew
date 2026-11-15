import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / 'scripts/check-ios-release-resources.sh'

class ReleaseResourcesTests(unittest.TestCase):
    def check_bundle(self, configuration='Release', blocked=None, corrupt=False, missing=False):
        with tempfile.TemporaryDirectory(prefix='younew-release-guard-') as temp:
            bundle = Path(temp)/'YouNew.app'; bundle.mkdir()
            if not missing:
                shutil.copyfile(ROOT/'YouNew/Resources/Data/younew-approved-places.json', bundle/'younew-approved-places.json')
            if blocked:
                (bundle/blocked).write_text('{}')
            if corrupt:
                (bundle/'younew-approved-places.json').write_text('{}')
            return subprocess.run(['/bin/sh', str(SCRIPT)], env={**os.environ,
                'CONFIGURATION':configuration, 'SRCROOT':str(ROOT), 'TARGET_BUILD_DIR':temp,
                'UNLOCALIZED_RESOURCES_FOLDER_PATH':'YouNew.app'}, capture_output=True)

    def test_valid_release(self):
        self.assertEqual(self.check_bundle().returncode, 0)

    def test_release_rejects_local_json_and_photographs(self):
        for filename in ['younew-approved-local-test.json','approved-travel-museum.foam-1200.webp']:
            with self.subTest(filename=filename):
                self.assertNotEqual(self.check_bundle(blocked=filename).returncode, 0)

    def test_release_rejects_missing_or_modified_production(self):
        self.assertNotEqual(self.check_bundle(missing=True).returncode, 0)
        self.assertNotEqual(self.check_bundle(corrupt=True).returncode, 0)

    def test_debug_keeps_candidate(self):
        self.assertEqual(self.check_bundle(configuration='Debug',blocked='younew-approved-local-test.json').returncode, 0)

    def test_project_only_changes_release_exclusion_and_post_resource_guard(self):
        def decode(data):
            return json.loads(subprocess.run(['plutil','-convert','json','-o','-','-'],input=data,
                capture_output=True,check=True).stdout)
        previous=decode(subprocess.check_output(['git','show','512abc1:YouNew.xcodeproj/project.pbxproj'],cwd=ROOT))
        current=decode((ROOT/'YouNew.xcodeproj/project.pbxproj').read_bytes())
        objects=current['objects']
        release=objects['D82833452FBF2CC4007504D3']['buildSettings']
        self.assertEqual(release.pop('EXCLUDED_SOURCE_FILE_NAMES'),['$(inherited)','younew-approved-local-test.json','approved-travel-*.webp'])
        phase=objects.pop('A73111500000000000000001')
        self.assertEqual(phase['shellScript'],'/bin/sh "$SRCROOT/scripts/check-ios-release-resources.sh"')
        phases=objects['D828331F2FBF2CC2007504D3']['buildPhases']
        self.assertEqual(phases[-2: ],['D828331E2FBF2CC2007504D3','A73111500000000000000001'])
        phases.pop()
        self.assertEqual(current,previous)

if __name__=='__main__': unittest.main()
