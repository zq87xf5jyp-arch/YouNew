import importlib.util
import io
import unittest
import urllib.error
from pathlib import Path

spec = importlib.util.spec_from_file_location('hero_check', Path(__file__).parents[1] / 'check-priority-hero-urls.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


class HeroURLCheckTests(unittest.TestCase):
    def test_reads_exactly_the_eight_unit_test_registry_urls(self):
        self.assertEqual(len(m.registry_urls()), 8)
        self.assertIn('Amsterdam', m.registry_urls())

    def test_quality_rejects_errors_html_and_tiny_bodies(self):
        for status, mime, data in [(404, 'image/jpeg', b'\xff\xd8\xff' + b'x'*9000),
                                  (200, 'text/html', b'x'*9000),
                                  (200, 'image/jpeg', b'<html>' + b'x'*9000),
                                  (200, 'image/png', b'\x89PNG\r\n\x1a\n')]:
            with self.subTest(status=status, mime=mime, size=len(data)):
                with self.assertRaises(ValueError): m.validate_image(status, mime, data)

    def test_network_timeout_is_bounded_and_never_reported_as_pass(self):
        calls = []
        def timeout(*args, **kwargs):
            calls.append(1)
            raise TimeoutError('fixture timeout')
        result = m.check_url('fixture', 'https://example.test/image', opener=timeout, sleep=lambda _: None)
        self.assertEqual(len(calls), 3)
        self.assertEqual(result['result'], 'network_unconfirmed')

    def test_404_is_not_retried(self):
        def missing(*args, **kwargs):
            raise urllib.error.HTTPError('https://example.test/image', 404, 'missing', {}, None)
        result = m.check_url('fixture', 'https://example.test/image', opener=missing)
        self.assertEqual(result['result'], 'invalid')
        self.assertEqual(len(result['attempts']), 1)

    def test_recovers_from_transient_failure_but_preserves_attempt_history(self):
        calls = []
        def response(*args, **kwargs):
            calls.append(1)
            if len(calls) == 1: raise TimeoutError('fixture timeout')
            body = io.BytesIO(b'\xff\xd8\xff' + b'x'*9000)
            body.status = 200
            body.headers = {'Content-Type': 'image/jpeg'}
            body.url = 'https://example.test/final.jpg'
            return body
        result = m.check_url('fixture', 'https://example.test/image', opener=response, sleep=lambda _: None)
        self.assertEqual(result['result'], 'pass')
        self.assertEqual([r['result'] for r in result['attempts']], ['network_unconfirmed', 'pass'])


if __name__ == '__main__': unittest.main()
