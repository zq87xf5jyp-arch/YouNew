#!/usr/bin/env python3
from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    print(f"Report honesty static QA failed: {message}")
    sys.exit(1)


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8", errors="ignore")


def main() -> None:
    ai_release_audit = read("AI_RELEASE_AUDIT.md")
    appstore_readiness = read("APPSTORE_READINESS.md")
    final_release = read("FINAL_RELEASE_REPORT.md")

    forbidden_ai_claims = [
        "passes all release criteria. No blockers remain",
        "AI assistant passes all release criteria",
    ]
    for claim in forbidden_ai_claims:
        if claim in ai_release_audit:
            fail(f"AI_RELEASE_AUDIT.md still contains unverified release claim: {claim}")

    if "LIVE AI RUNTIME UNVERIFIED" not in ai_release_audit:
        fail("AI_RELEASE_AUDIT.md must state live AI runtime remains unverified")

    if "| Builds without errors | PASS | 0 errors, 0 warnings |" in appstore_readiness:
        fail("APPSTORE_READINESS.md still claims current build success without runtime verification")

    if "| Builds without errors | BLOCKED |" not in appstore_readiness:
        fail("APPSTORE_READINESS.md must mark current build execution as blocked in this environment")

    required_final_markers = [
        "NOT READY TO CLAIM APP STORE READY",
        "live walkthrough, build archive, AI send/stop/retry, and FPS profiling remain required",
    ]
    for marker in required_final_markers:
        if marker not in final_release:
            fail(f"FINAL_RELEASE_REPORT.md missing release-limitation marker: {marker}")

    forbidden_final_claims = [
        "Main app binary is TestFlight and App Store ready",
        "Application is TestFlight Ready",
        "Application is App Store Ready",
        "0 App Store blockers in main app target",
    ]
    for claim in forbidden_final_claims:
        if claim in final_release:
            fail(f"FINAL_RELEASE_REPORT.md contains unverified release-ready claim: {claim}")

    print("Report honesty static QA passed")


if __name__ == "__main__":
    main()
