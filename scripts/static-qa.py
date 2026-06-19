#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def run(command):
    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode != 0:
        sys.exit(result.returncode)


def main():
    run([
        "plutil",
        "-lint",
        "YouNew/en.lproj/Localizable.strings",
        "YouNew/nl.lproj/Localizable.strings",
        "YouNew/ru.lproj/Localizable.strings",
    ])
    run([sys.executable, "scripts/history-media-static-qa.py"])
    run([sys.executable, "scripts/brand-static-qa.py"])
    print("Static QA passed")


if __name__ == "__main__":
    main()
