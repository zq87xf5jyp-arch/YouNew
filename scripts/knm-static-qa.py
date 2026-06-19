#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def fail(message):
    print(f"KNM QA failed: {message}")
    sys.exit(1)


def main():
    data = read("YouNew/Data/KNMGuideData.swift")
    models = read("YouNew/Models/KNMModels.swift")
    view = read("YouNew/Views/KNMGuideView.swift")
    root_menu = read("YouNew/App/AppTabView.swift")
    destinations = read("YouNew/App/Navigation/AppDestinationView.swift")
    app_destination = read("YouNew/App/Navigation/AppDestination.swift")
    search = read("YouNew/Views/SearchView.swift")
    first_steps = read("YouNew/Views/FirstStepsView.swift")
    hub = read("YouNew/Views/InformationHubView.swift")
    l10n_files = [
        read("YouNew/en.lproj/Localizable.strings"),
        read("YouNew/ru.lproj/Localizable.strings"),
        read("YouNew/nl.lproj/Localizable.strings"),
    ]

    required_models = [
        "struct KNMModule",
        "struct KNMLesson",
        "struct KNMPracticeQuestion",
        "let isOfficial: Bool",
        "let sourceIds: [String]",
        "let verified: Bool",
        "let sourceType: String",
        "let language: String",
        "let everydaySituations: [KNMLocalizedString]",
        "let rememberItems: [KNMLocalizedString]",
    ]
    for needle in required_models:
        if needle not in models:
            fail(f"model missing {needle}")

    module_count = len(re.findall(r'\n\s*module\(\s*id:', data))
    if module_count < 10:
        fail(f"expected at least 10 KNM modules, found {module_count}")
    lesson_count = len(re.findall(r'(?:lesson|compactLesson)\(', data))
    if lesson_count < 10:
        fail(f"expected at least 10 KNM lessons, found {lesson_count}")
    question_factories = len(re.findall(r'question\(', data))
    if question_factories < 3:
        fail("expected KNM practice question factories/content")
    if "knowledgePack(for:" not in data:
        fail("KNM lessons are missing expanded situation/remember knowledge packs")
    if "Everyday situations" not in view or "Бытовые ситуации" not in view:
        fail("KNM lesson screen does not render everyday situations")
    if "rememberBlock" not in view:
        fail("KNM lesson screen does not render structured remember items")
    if ".prefix(8)" not in data:
        fail("KNM practice depth should allow up to 8 questions per lesson")
    if "isOfficial: false" not in data:
        fail("app-created practice questions are not explicitly unofficial")
    if 'sourceIds: ["duo-knowledge"]' not in data:
        fail("practice questions do not carry sourceIds")
    if 'verified: true' not in data or 'retrievedAt = "2026-06-01"' not in data:
        fail("source verification metadata missing")
    for source_id in ["duo-knowledge", "duo-practice", "duo-register", "belastingdienst", "zorgverzekering", "ns", "ovpay", "9292", "politie", "112"]:
        if source_id not in data:
            fail(f"required official source missing: {source_id}")
    for url in re.findall(r'"(https://[^"]+)"', data):
        if not url.startswith("https://"):
            fail(f"source URL is not HTTPS: {url}")

    forbidden = ["TODO", "debug", "official DUO exam question"]
    for needle in forbidden:
        if needle.lower() in (data + view).lower():
            fail(f"forbidden KNM text found: {needle}")

    if "case knm" not in app_destination or "case knmModule" not in app_destination:
        fail("KNM route is missing from AppDestination")
    if "KNMGuideView()" not in destinations or "KNMGuideView(initialModuleID:" not in destinations:
        fail("KNM destination view is not wired")
    if 'SideMenuItemModel(id: "knm"' not in root_menu or "case .knm: return .knm" not in root_menu:
        fail("side menu KNM route is not wired")
    if "destination: .knm" not in hub or "destination: .knm" not in first_steps:
        fail("Information Hub or First Steps KNM entry is missing")
    for alias in ["knm", "kennis van de nederlandse maatschappij", "знание нидерландского общества", "huisarts", "toeslagen", "gemeente", "112"]:
        if alias not in search.lower():
            fail(f"search alias missing: {alias}")
    if ".knmModule(module.id)" not in search:
        fail("search module result does not open KNM module")

    for locale in l10n_files:
        if "knm.disclaimer" not in locale or "sideMenu.knm" not in locale:
            fail("KNM localization/disclaimer missing from a locale")
    if 'L10n.t("knm.' in view or "Text(\"knm." in view:
        fail("KNM view should not expose raw localization keys")
    if "Раздел помогает подготовиться" not in view or "This section helps you study" not in view or "Dit onderdeel helpt" not in view:
        fail("visible KNM disclaimer missing in all supported languages")

    long_textbook_like = re.findall(r'"([^"]{2000,})"', data)
    if long_textbook_like:
        fail("detected unusually long embedded passages")

    print("KNM static QA passed")


if __name__ == "__main__":
    main()
