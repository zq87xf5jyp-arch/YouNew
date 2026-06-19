#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
SWIFT_ROOT = ROOT / "YouNew"
LANGUAGES = {
    "en": "english",
    "nl": "dutch",
    "ru": "russian",
}


def fail(message: str) -> None:
    print(f"Localization key static QA failed: {message}")
    sys.exit(1)


def swift_files() -> list[Path]:
    return sorted(SWIFT_ROOT.rglob("*.swift"))


def literal_l10n_keys() -> set[str]:
    keys: set[str] = set()
    pattern = re.compile(r'L10n\.t\(\s*"([^"]+)"')
    for path in swift_files():
        text = path.read_text(encoding="utf-8", errors="ignore")
        for key in pattern.findall(text):
            if r"\(" not in key:
                keys.add(key)
    return keys


def strings_file_keys(language: str) -> set[str]:
    path = SWIFT_ROOT / f"{language}.lproj" / "Localizable.strings"
    if not path.exists():
        fail(f"missing localization file: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8", errors="ignore")
    return set(re.findall(r'^\s*"((?:[^"\\]|\\.)+)"\s*=', text, flags=re.MULTILINE))


def fallback_keys(language_name: str) -> set[str]:
    path = SWIFT_ROOT / "Core" / "Localization" / "L10n.swift"
    text = path.read_text(encoding="utf-8", errors="ignore")
    symbol = {"english": "_en", "dutch": "_nl", "russian": "_ru"}[language_name]
    match = re.search(rf"static\s+let\s+{symbol}\s*:\s*\[String:\s*String\]\s*=\s*\[", text)
    if not match:
        fail(f"missing fallback dictionary {symbol}")
    open_index = match.end() - 1
    depth = 0
    for index in range(open_index, len(text)):
        char = text[index]
        if char == "[":
            depth += 1
        elif char == "]":
            depth -= 1
            if depth == 0:
                body = text[open_index + 1:index]
                return set(re.findall(r'^\s*"((?:[^"\\]|\\.)+)"\s*:', body, flags=re.MULTILINE))
    fail(f"unterminated fallback dictionary {symbol}")
    return set()


def swift_language_switch_gaps() -> list[str]:
    gaps: list[str] = []
    switch_pattern = re.compile(r"switch\s+(?:lang|language|languageManager\.appLanguage)\s*\{")
    for path in swift_files():
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in switch_pattern.finditer(text):
            open_index = match.end() - 1
            depth = 0
            end_index = None
            for index in range(open_index, len(text)):
                char = text[index]
                if char == "{":
                    depth += 1
                elif char == "}":
                    depth -= 1
                    if depth == 0:
                        end_index = index + 1
                        break
            if end_index is None:
                continue
            block = text[match.start():end_index]
            cases = {language for language in ["english", "dutch", "russian"] if f"case .{language}" in block}
            if cases and cases != {"english", "dutch", "russian"}:
                line = text[:match.start()].count("\n") + 1
                gaps.append(f"{path.relative_to(ROOT)}:{line} has language cases {sorted(cases)}")
    return gaps


def main() -> None:
    used_keys = literal_l10n_keys()
    if not used_keys:
        fail("no literal L10n keys found")

    language_switch_gaps = swift_language_switch_gaps()
    if language_switch_gaps:
        for gap in language_switch_gaps[:80]:
            print(f"  - {gap}")
        if len(language_switch_gaps) > 80:
            print(f"  ... {len(language_switch_gaps) - 80} more")
        fail("some Swift language switches omit one or more supported languages")

    missing_by_language: dict[str, list[str]] = {}
    coverage_counts: dict[str, int] = {}
    for language, language_name in LANGUAGES.items():
        available = strings_file_keys(language) | fallback_keys(language_name)
        missing = sorted(used_keys - available)
        if missing:
            missing_by_language[language] = missing
        coverage_counts[language] = len(available & used_keys)

    if missing_by_language:
        for language, missing in missing_by_language.items():
            print(f"{language}: missing {len(missing)} literal UI keys")
            for key in missing[:80]:
                print(f"  - {key}")
            if len(missing) > 80:
                print(f"  ... {len(missing) - 80} more")
        fail("literal L10n keys are not covered in every supported language")

    print("Localization key static QA passed")
    print(f"- Literal UI keys checked: {len(used_keys)}")
    for language in LANGUAGES:
        print(f"- {language} coverage: {coverage_counts[language]} keys")


if __name__ == "__main__":
    main()
