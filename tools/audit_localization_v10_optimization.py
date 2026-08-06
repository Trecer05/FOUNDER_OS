#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESENTATION_ROOTS = [ROOT / "lib" / "presentation", ROOT / "lib" / "app"]
EXCLUDED = {
    ROOT / "lib" / "application" / "localization" / "app_text.dart",
}

errors: list[str] = []
text_pattern = re.compile(r"(?<![A-Za-z0-9_])(Text\.rich|Text|RichText)\s*\(")
builder_pattern = re.compile(
    r"(?<![A-Za-z0-9_])(ListenableBuilder|AnimatedBuilder)\s*\("
)

for base in PRESENTATION_ROOTS:
    for path in base.rglob("*.dart"):
        if path in EXCLUDED:
            continue
        content = path.read_text(encoding="utf-8")
        scanned = re.sub(r"//.*|/\*[\s\S]*?\*/", "", content)
        scanned = re.sub(
            r"'''[\s\S]*?'''|\"\"\"[\s\S]*?\"\"\"|'(?:\\.|[^'\\])*'|\"(?:\\.|[^\"\\])*\"",
            "",
            scanned,
        )
        match = text_pattern.search(scanned)
        if match:
            line = scanned.count("\n", 0, match.start()) + 1
            errors.append(
                f"{path.relative_to(ROOT)}:{line}: direct {match.group(1)} bypasses AppText"
            )
        if path.name != "scoped_listenable_builder.dart":
            builder_match = builder_pattern.search(scanned)
            if builder_match:
                line = scanned.count("\n", 0, builder_match.start()) + 1
                errors.append(
                    f"{path.relative_to(ROOT)}:{line}: direct "
                    f"{builder_match.group(1)} bypasses inactive-tab gating"
                )

localizer = (ROOT / "lib/application/localization/app_localizer.dart").read_text(
    encoding="utf-8"
)
for required in (
    "Development capacity': 'Скорость разработки",
    "Stack coherence': 'Совместимость стека",
    "provider lock-in': 'зависимость от провайдера",
    "_transliterateRemainingCyrillic",
    "glossaryEnglish[source]",
):
    if required not in localizer:
        errors.append(f"localizer missing required normalization: {required}")

for path in (
    ROOT / "ios/Runner/AppDelegate.swift",
    ROOT / "android/app/src/main/kotlin/com/example/founder_os/MainActivity.kt",
):
    content = path.read_text(encoding="utf-8")
    if "founder_os/native_performance" not in content:
        errors.append(f"{path.relative_to(ROOT)}: native channel is missing")

if errors:
    print("localization/native audit failed:")
    for error in errors:
        print(f"- {error}")
    raise SystemExit(1)

print("localization/native audit: ok")
