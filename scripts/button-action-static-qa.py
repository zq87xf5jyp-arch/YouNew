#!/usr/bin/env python3
from pathlib import Path
import re
import sys
from typing import Optional


ROOT = Path(__file__).resolve().parents[1]
SWIFT_ROOT = ROOT / "YouNew"


def fail(message: str) -> None:
    print(f"Button/action static QA failed: {message}")
    sys.exit(1)


def matching_delimiter(text: str, start: int, open_char: str, close_char: str) -> Optional[int]:
    depth = 0
    in_string = False
    escaped = False
    index = start
    while index < len(text):
        char = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == "\"":
                in_string = False
        else:
            if char == "\"":
                in_string = True
            elif char == open_char:
                depth += 1
            elif char == close_char:
                depth -= 1
                if depth == 0:
                    return index
        index += 1
    return None


def skip_whitespace(text: str, index: int) -> int:
    while index < len(text) and text[index].isspace():
        index += 1
    return index


def control_label_ranges(text: str, control: str) -> list[tuple[int, int, int]]:
    ranges: list[tuple[int, int, int]] = []
    for match in re.finditer(rf"\b{re.escape(control)}\b", text):
        index = skip_whitespace(text, match.end())
        if index >= len(text):
            continue

        if text[index] == "(":
            close_paren = matching_delimiter(text, index, "(", ")")
            if close_paren is None:
                continue
            label_start = skip_whitespace(text, close_paren + 1)
            if label_start < len(text) and text[label_start] == "{":
                label_end = matching_delimiter(text, label_start, "{", "}")
                if label_end is not None:
                    ranges.append((label_start + 1, label_end, match.start()))
            continue

        if text[index] == "{":
            action_end = matching_delimiter(text, index, "{", "}")
            if action_end is None:
                continue
            label_keyword = skip_whitespace(text, action_end + 1)
            if not text.startswith("label:", label_keyword):
                continue
            label_start = skip_whitespace(text, label_keyword + len("label:"))
            if label_start < len(text) and text[label_start] == "{":
                label_end = matching_delimiter(text, label_start, "{", "}")
                if label_end is not None:
                    ranges.append((label_start + 1, label_end, match.start()))
    return ranges


def line_number(text: str, index: int) -> int:
    return text.count("\n", 0, index) + 1


def main() -> None:
    violations: list[str] = []
    nested_interactive_pattern = re.compile(r"\b(?:Button|NavigationLink)\b\s*(?:\(|\{)")
    for path in sorted(SWIFT_ROOT.rglob("*.swift")):
        text = path.read_text(encoding="utf-8", errors="ignore")
        for control in ("Button", "NavigationLink"):
            for start, end, control_start in control_label_ranges(text, control):
                label = text[start:end]
                if nested_interactive_pattern.search(label):
                    rel = path.relative_to(ROOT)
                    violations.append(f"{rel}:{line_number(text, control_start)}")

    if violations:
        fail("nested interactive controls found inside Button/NavigationLink labels: " + ", ".join(violations))

    print("Button/action static QA passed")
    print("- Nested Button/NavigationLink labels checked: none found")


if __name__ == "__main__":
    main()
