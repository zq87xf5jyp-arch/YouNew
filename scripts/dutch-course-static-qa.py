#!/usr/bin/env python3
from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8")


def fail(message):
    print(f"Dutch course QA failed: {message}")
    sys.exit(1)


def main():
    models = read("YouNew/Models/DutchCourseModels.swift")
    data = read("YouNew/Data/DutchA1A2CourseData.swift")
    view = read("YouNew/Views/DutchA1A2View.swift")
    root_menu = read("YouNew/App/AppTabView.swift")
    destinations = read("YouNew/App/Navigation/AppDestinationView.swift")
    app_destination = read("YouNew/App/Navigation/AppDestination.swift")
    search = read("YouNew/Views/SearchView.swift")
    hub = read("YouNew/Views/InformationHubView.swift")
    first_steps = read("YouNew/Views/FirstStepsView.swift")
    knm_view = read("YouNew/Views/KNMGuideView.swift")
    l10n = read("YouNew/Core/Localization/L10n.swift")
    locale_files = [
        read("YouNew/en.lproj/Localizable.strings"),
        read("YouNew/ru.lproj/Localizable.strings"),
        read("YouNew/nl.lproj/Localizable.strings"),
    ]

    for needle in [
        "struct DutchCourseModule",
        "enum DutchLevel",
        "struct DutchLesson",
        "struct DutchVocabularyItem",
        "struct DutchPhrase",
        "struct DutchExercise",
        "case multipleChoice",
        "case grammarChoice",
    ]:
        if needle not in models:
            fail(f"model missing {needle}")

    if len(re.findall(r'\n\s*module\(', data)) < 10:
        fail("expected at least 10 Dutch course modules")
    if ".a1" not in data or ".a2" not in data:
        fail("A1 and A2 content must both exist")
    if len(re.findall(r'(?:lesson|practicalLesson|grammarLesson)\(', data)) < 18:
        fail("expected practical and grammar lessons")
    if len(re.findall(r'vocab\(', data)) < 3 or "telefoonnummer" not in data or "huisarts" not in data or "verhuurder" not in data:
        fail("expected vocabulary items")
    if len(re.findall(r'phrase\(', data)) < 2 or "Ik wil me inschrijven." not in data or "Ik wil een afspraak maken bij de huisarts." not in data:
        fail("expected phrase cards")
    if len(re.findall(r'exercise\(', data)) < 4:
        fail("expected practice exercises")
    for grammar in ["word-order", "questions", "present-tense", "hebben-zijn", "modal-verbs", "separable-verbs", "negation", "articles", "plural", "perfect-tense"]:
        if grammar not in data:
            fail(f"grammar lesson missing: {grammar}")

    if "correctAnswer" not in models or "explanation" not in models:
        fail("exercise correct answer/explanation fields missing")
    if "TODO" in data + view or "debug" in (data + view).lower():
        fail("TODO/debug string found")
    if "official DUO exam material" not in view:
        fail("unofficial exam disclaimer missing")
    if "sideMenu.dutchA1A2" not in l10n or "dutchA1A2.disclaimer" not in "".join(locale_files):
        fail("Dutch course localization/disclaimer missing")
    if 'L10n.t("dutchA1A2.' in view or 'Text("dutchA1A2.' in view:
        fail("raw Dutch course localization key can leak in UI")

    if "case dutchA1A2" not in app_destination or "case dutchA1A2Module" not in app_destination:
        fail("Dutch course routes missing")
    if "DutchA1A2View()" not in destinations or "DutchA1A2View(initialModuleID:" not in destinations:
        fail("Dutch course destination view missing")
    if 'SideMenuItemModel(id: "dutchA1A2"' not in root_menu or "case .dutchA1A2: return .dutchA1A2" not in root_menu:
        fail("right-side menu route missing")
    if "destination: .dutchA1A2" not in hub or "destination: .dutchA1A2" not in first_steps:
        fail("Information Hub or First Steps entry missing")
    if ".dutchA1A2Module(module.id)" not in search:
        fail("search does not open Dutch course module")
    for alias in ["afspraak", "gemeente", "huisarts", "trein", "ov-chipkaart", "de het", "hebben zijn", "отделяемые глаголы", "грамматика"]:
        if alias not in search.lower() and alias not in data.lower():
            fail(f"search alias missing: {alias}")
    if ".dutchA1A2Module(dutchModuleID)" not in knm_view:
        fail("KNM related Dutch vocabulary link missing")
    if "coe.int" not in data or "inburgeren.nl" not in data:
        fail("CEFR or DUO/Inburgeren source missing")

    print("Dutch course static QA passed")


if __name__ == "__main__":
    main()
