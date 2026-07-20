#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
python3 scripts/static-qa.py
python3 scripts/localization-key-static-qa.py
python3 scripts/route-action-static-qa.py
python3 scripts/button-action-static-qa.py
python3 scripts/url-source-safety-static-qa.py
python3 scripts/apple-review-static-qa.py
python3 scripts/accessibility-static-qa.py
python3 scripts/performance-static-qa.py
python3 scripts/search-static-qa.py
python3 scripts/route-id-stability-static-qa.py
python3 scripts/report-honesty-static-qa.py
python3 scripts/zero-compromise-report-static-qa.py
scripts/validate-app-icons.sh
python3 scripts/visible-image-remote-qa.py --offline
python3 scripts/image-runtime-data-qa.py
python3 scripts/image-render-static-qa.py
python3 scripts/visual-system-static-qa.py
python3 scripts/generate-visual-audit-gallery.py
python3 scripts/visual-report-static-qa.py
python3 scripts/ai-subsystem-static-qa.py
python3 scripts/persona-ia-static-qa.py
python3 scripts/content-static-qa.py
python3 scripts/data-project-qa.py
python3 scripts/generate-data-observability.py
python3 scripts/data-project-import-static-qa.py
python3 scripts/generate-data-dashboard.py
python3 scripts/data-dashboard-static-qa.py
python3 scripts/data-observability-static-qa.py
python3 scripts/generate-data-operations.py
python3 scripts/data-operations-static-qa.py
python3 scripts/data-health-gate.py
python3 scripts/data-project-workflow-static-qa.py
python3 scripts/knm-static-qa.py
python3 scripts/dutch-course-static-qa.py
python3 scripts/user-visible-completeness-static-qa.py
python3 scripts/public-site-static-qa.py
python3 scripts/media-static-qa.py
python3 scripts/place-media-static-qa.py
python3 scripts/history-media-static-qa.py
python3 scripts/brand-static-qa.py
