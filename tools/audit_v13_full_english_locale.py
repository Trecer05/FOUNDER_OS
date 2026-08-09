#!/usr/bin/env python3
"""Fail when authored Dart UI copy can leak Cyrillic in the English locale."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re
import sys


CYRILLIC = re.compile(r"[А-Яа-яЁё]")
IDENTIFIER_START = re.compile(r"[A-Za-z_]")
IDENTIFIER_PART = re.compile(r"[A-Za-z0-9_]")


@dataclass(frozen=True)
class DartString:
    segments: tuple[str, ...]

    @property
    def dynamic(self) -> bool:
        return len(self.segments) > 1

    @property
    def value(self) -> str:
        return "".join(
            segment + (f"ZXQPH{index}QXZ" if index < len(self.segments) - 1 else "")
            for index, segment in enumerate(self.segments)
        )


class DartStringScanner:
    """Small Dart-aware scanner, including strings nested inside ${...}."""

    def __init__(self, text: str) -> None:
        self.text = text
        self.items: list[DartString] = []

    def scan(self) -> list[DartString]:
        self._scan_code(0, len(self.text))
        return self.items

    def _scan_code(self, start: int, end: int) -> int:
        index = start
        while index < end:
            if self.text.startswith("//", index):
                newline = self.text.find("\n", index + 2, end)
                index = end if newline < 0 else newline + 1
                continue
            if self.text.startswith("/*", index):
                close = self.text.find("*/", index + 2, end)
                index = end if close < 0 else close + 2
                continue
            char = self.text[index]
            if (
                char in "rR"
                and index + 1 < end
                and self.text[index + 1] in "'\""
                and (index == 0 or not IDENTIFIER_PART.match(self.text[index - 1]))
            ):
                index = self._parse_string(index + 1, end, raw=True)
            elif char in "'\"":
                index = self._parse_string(index, end, raw=False)
            else:
                index += 1
        return index

    def _parse_string(self, start: int, end: int, *, raw: bool) -> int:
        quote = self.text[start]
        delimiter = quote * (3 if self.text.startswith(quote * 3, start) else 1)
        index = start + len(delimiter)
        segments: list[list[str]] = [[]]

        while index < end:
            if self.text.startswith(delimiter, index):
                self.items.append(
                    DartString(tuple("".join(segment) for segment in segments))
                )
                return index + len(delimiter)

            char = self.text[index]
            if not raw and char == "\\" and index + 1 < end:
                escape = self.text[index + 1]
                segments[-1].append(
                    {
                        "n": "\n",
                        "r": "\r",
                        "t": "\t",
                        "b": "\b",
                        "f": "\f",
                        "v": "\v",
                    }.get(escape, escape)
                )
                index += 2
                continue

            if not raw and char == "$" and index + 1 < end:
                next_char = self.text[index + 1]
                if next_char == "{":
                    segments.append([])
                    index = self._scan_interpolation(index + 2, end)
                    continue
                if IDENTIFIER_START.match(next_char):
                    segments.append([])
                    index += 2
                    while index < end and IDENTIFIER_PART.match(self.text[index]):
                        index += 1
                    continue

            segments[-1].append(char)
            index += 1

        raise ValueError(f"Unterminated Dart string at byte {start}")

    def _scan_interpolation(self, start: int, end: int) -> int:
        index = start
        depth = 1
        while index < end and depth:
            if self.text.startswith("//", index):
                newline = self.text.find("\n", index + 2, end)
                index = end if newline < 0 else newline + 1
                continue
            if self.text.startswith("/*", index):
                close = self.text.find("*/", index + 2, end)
                index = end if close < 0 else close + 2
                continue
            char = self.text[index]
            if (
                char in "rR"
                and index + 1 < end
                and self.text[index + 1] in "'\""
                and (index == 0 or not IDENTIFIER_PART.match(self.text[index - 1]))
            ):
                index = self._parse_string(index + 1, end, raw=True)
                continue
            if char in "'\"":
                index = self._parse_string(index, end, raw=False)
                continue
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
            index += 1
        if depth:
            raise ValueError(f"Unterminated interpolation at byte {start}")
        return index


def authored_inventory(lib: Path) -> tuple[set[str], set[str]]:
    exact: set[str] = set()
    templates: set[str] = set()
    for path in lib.rglob("*.dart"):
        if "localization" in path.parts:
            continue
        for item in DartStringScanner(path.read_text(encoding="utf-8")).scan():
            if not any(CYRILLIC.search(segment) for segment in item.segments):
                continue
            (templates if item.dynamic else exact).add(item.value)
    return exact, templates


def section(text: str, start_marker: str, end_marker: str | None) -> str:
    start = text.index(start_marker) + len(start_marker)
    end = len(text) if end_marker is None else text.index(end_marker, start)
    return text[start:end]


def pairs(text: str) -> list[tuple[str, str]]:
    values = [item.value for item in DartStringScanner(text).scan()]
    if len(values) % 2:
        raise ValueError("Localization section contains an odd string count")
    return list(zip(values[::2], values[1::2]))


def normalize(value: str) -> str:
    return value.replace(r"\n", "\n").replace(r"\r", "\r").replace(r"\t", "\t")


def main() -> int:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
    lib = root / "lib"
    lexicon_path = lib / "application/localization/v13_english_lexicon.dart"
    localizer_path = lib / "application/localization/app_localizer.dart"
    failures: list[str] = []

    if not lexicon_path.is_file() or not localizer_path.is_file():
        print("FAIL: v13 English localization files are missing", file=sys.stderr)
        return 1

    lexicon = lexicon_path.read_text(encoding="utf-8")
    overrides = pairs(section(lexicon, "overrides = <String, String>{", "static const Map<String, String> exact"))
    exact = pairs(section(lexicon, "exact = <String, String>{", "static const List<V13EnglishTemplate> templates"))
    templates = pairs(section(lexicon, "templates = <V13EnglishTemplate>[", "static const Map<String, String> templateOverrides"))
    template_overrides = pairs(section(lexicon, "templateOverrides = <String, String>{", None))

    for group, entries in (
        ("override", overrides),
        ("exact", exact),
        ("template", templates),
        ("template override", template_overrides),
    ):
        for source, target in entries:
            if CYRILLIC.search(target):
                failures.append(f"Cyrillic in {group} target for {source!r}: {target!r}")

    source_exact, source_templates = authored_inventory(lib)
    covered_exact = {normalize(source) for source, _ in overrides + exact}
    covered_templates = {normalize(source) for source, _ in templates}
    for value in sorted(source_exact - covered_exact):
        failures.append(f"Missing exact English entry: {value!r}")
    for value in sorted(source_templates - covered_templates):
        failures.append(f"Missing dynamic English template: {value!r}")

    localizer = localizer_path.read_text(encoding="utf-8")
    for needle in (
        "import 'v13_english_lexicon.dart';",
        "V13EnglishLexicon.exact.entries",
        "V13EnglishLexicon.overrides.entries",
        "V13EnglishLexicon.templates",
        "_translateV13Template(source)",
    ):
        if needle not in localizer:
            failures.append(f"AppLocalizer integration is missing: {needle}")

    for path in (lib / "presentation").rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        if re.search(
            r"AppText\(\s*(['\"])(?:(?!\1).)*[А-Яа-яЁё](?:(?!\1).)*\1"
            r"(?:(?!\)).){0,200}translate:\s*false",
            text,
            flags=re.DOTALL,
        ):
            failures.append(f"Cyrillic AppText bypasses translation: {path.relative_to(root)}")
        if re.search(
            r"(?:tooltip|semanticLabel|hintText|helperText|errorText):\s*"
            r"(['\"])(?:(?!\1).)*[А-Яа-яЁё](?:(?!\1).)*\1",
            text,
            flags=re.DOTALL,
        ):
            failures.append(f"Raw localized property bypasses trContext: {path.relative_to(root)}")

    if failures:
        print("FULL ENGLISH LOCALE AUDIT: FAIL", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("FULL ENGLISH LOCALE AUDIT: PASS")
    print(f"Covered {len(source_exact)} exact strings and {len(source_templates)} dynamic templates.")
    print(f"Validated {sum(len(group) for group in (overrides, exact, templates, template_overrides))} English targets with zero Cyrillic.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
