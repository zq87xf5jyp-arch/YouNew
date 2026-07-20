#!/usr/bin/env python3
import csv, hashlib, json, re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "YouNew"
TODAY = "2026-07-11"

EXTS = {".swift", ".strings", ".json"}
FILES = [p for p in SRC.rglob("*") if p.suffix in EXTS and "Assets.xcassets" not in str(p)]

def clean(s):
    return re.sub(r"\\[nrt]", " ", s).replace('\\"', '"').strip()

def norm(s):
    return " ".join("".join(ch if ch.isalnum() else " " for ch in s.casefold()).split())

def cid(path, line, text):
    return "txt-" + hashlib.sha1(f"{path}:{line}:{text}".encode()).hexdigest()[:12]

def category(path, text):
    hay = (path + " " + text).casefold()
    if "great dutch figures" in hay or any(x in hay for x in ["history", "museum", "culture", "heritage"]): return "explore/culture-and-history"
    if any(x in hay for x in ["health", "emergency", "112", "doctor", "insurance"]): return "health-and-safety"
    if any(x in hay for x in ["housing", "rent", "landlord", "home"]): return "housing"
    if any(x in hay for x in ["study", "student", "university", "learning", "dutch course"]): return "study"
    if any(x in hay for x in ["work", "salary", "tax", "money", "business"]): return "work-and-money"
    if any(x in hay for x in ["transport", "train", "tram", "bus", "cycling"]): return "transport"
    if any(x in hay for x in ["municipality", "government", "digi", "ind", "official"]): return "official-services"
    if any(x in hay for x in ["register", "document", "bsn", "arrival", "first step"]): return "getting-started"
    return "explore"

texts=[]
swift_string = re.compile(r'(?<!#)"((?:\\.|[^"\\])*)"')
strings_value = re.compile(r'^\s*"([^"]+)"\s*=\s*"((?:\\.|[^"\\])*)"\s*;')
for p in FILES:
    rel=str(p.relative_to(ROOT))
    try: lines=p.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError: continue
    for n,line in enumerate(lines,1):
        m=strings_value.match(line)
        vals=[m.group(2)] if m else [x.group(1) for x in swift_string.finditer(line)]
        for raw in vals:
            s=clean(raw)
            if len(s)<8 or s.startswith(("http://","https://","sf.symbol")): continue
            if re.fullmatch(r"[A-Za-z0-9_.:/{}$()\\-]+",s): continue
            texts.append({"path":rel,"line":n,"text":s,"norm":norm(s)})

groups=defaultdict(list)
for t in texts: groups[t["norm"]].append(t)

name_pairs={
 "North Holland":("Noord-Holland","canonical_name_conflict"), "South Holland":("Zuid-Holland","canonical_name_conflict"),
 "The Hague":("Den Haag","canonical_name_conflict"), "Kingdom of the Netherlands":("Kingdom of the Netherlands","scope_ambiguity"),
}
generic_patterns=[r"use this map to explore",r"useful places and practical information",r"services for (?:a |the )?(?:broad |diverse )?(?:local |regional )?population",r"local public services for residents"]
fact_words=re.compile(r"\b(population|inhabitants|residents|million|\d+(?:[.,]\d+)?[kKmM]\b|largest|smallest|founded|since \d{4}|\b\d{4}\b|mandatory|must|required)\b",re.I)
dutch_words=re.compile(r"\b(gemeente|inwoners|provincie|grachtenstad|binnenstad|huisarts|zorgverzekering|openbaar vervoer)\b",re.I)
english_words=re.compile(r"\b(city|residents|government|services|housing|transport|history|population|official)\b",re.I)

rows=[]; facts=[]; loc=[]; rewrites=[]
seen_rewrite=set()
for t in texts:
    problems=[]; recommended=t["text"]; source_required=False; source_url=""; verified=""
    if len(groups[t["norm"]])>1:
        problems.append("duplicate_exact_text")
        if len({category(x["path"], x["text"]) for x in groups[t["norm"]]}) > 1:
            problems.append("duplicate_cross_category")
    for old,(canon,ptype) in name_pairs.items():
        if old in t["text"]:
            brand_exception = old == "The Hague" and any(x in t["text"] for x in ["Rotterdam The Hague Airport", "The Hague University of Applied Sciences"])
            display_language = "/en.lproj/" in t["path"] or "english:" in t["text"].casefold()
            if not brand_exception:
                problems.append("localized_name_requires_canonical_link" if old in ("North Holland","South Holland","The Hague") else ptype)
            if old in ("North Holland","South Holland","The Hague") and not display_language and not brand_exception:
                recommended=recommended.replace(old,canon)
            source_url = {
                "North Holland":"https://www.noord-holland.nl/",
                "South Holland":"https://www.zuid-holland.nl/",
                "The Hague":"https://www.denhaag.nl/en/introducing-the-hague/",
                "Kingdom of the Netherlands":"https://www.government.nl/faq/what-are-the-different-parts-of-the-kingdom-of-the-netherlands",
            }[old]
            if t["text"] == old or (old == "Kingdom of the Netherlands" and "The Netherlands" in t["text"]):
                verified = TODAY
            loc.append({"content_id":cid(t['path'],t['line'],t['text']),"screen":t["path"],"language":"und","issue":ptype,"current_text":t["text"],"recommended_text":recommended,"canonical_name":canon,"notes":"Store canonical and localized display name separately."})
    if any(re.search(p,t["text"],re.I) for p in generic_patterns): problems.append("generic_city_description")
    if dutch_words.search(t["text"]) and english_words.search(t["text"]):
        problems.append("mixed_english_dutch")
        loc.append({"content_id":cid(t['path'],t['line'],t['text']),"screen":t["path"],"language":"mixed","issue":"mixed_english_dutch","current_text":t["text"],"recommended_text":"Rewrite fully in the active interface language; keep Dutch terms in parentheses only when operationally useful.","canonical_name":"","notes":"Do not translate canonical IDs."})
    if t["text"].endswith(("...","…")): problems.append("possibly_truncated_text")
    if fact_words.search(t["text"]):
        source_required=True; problems.append("fact_requires_verification")
        if re.search(r"\b(population|inhabitants|residents|million|[0-9]+(?:[.,][0-9]+)?[kKmM])\b",t["text"],re.I): problems.append("statistic_missing_date_or_source")
        facts.append({"content_id":cid(t['path'],t['line'],t['text']),"current_screen":f"{t['path']}:{t['line']}","claim":t["text"],"verification_status":"verification_required","required_source_type":"official authority or official statistics","source_url":"","last_checked_at":"","notes":"Not marked verified: no claim-specific official page was opened during this audit."})
    if not problems: continue
    if "generic_city_description" in problems: recommended="Replace with a city-specific, task-oriented description supported by an official municipal or provincial source."
    if "duplicate_exact_text" in problems and len(groups[t["norm"]])>1: recommended="Reference canonical item " + cid(groups[t['norm']][0]['path'],groups[t['norm']][0]['line'],groups[t['norm']][0]['text']) + "; do not store another copy."
    rid=cid(t['path'],t['line'],t['text'])
    rows.append({"content_id":rid,"current_screen":f"{t['path']}:{t['line']}","current_text":t["text"],"problem_type":"|".join(sorted(set(problems))),"recommended_category":category(t["path"],t["text"]),"recommended_text":recommended,"source_required":str(source_required).lower(),"source_url":source_url,"last_verified_at":verified,"notes":f"Duplicate occurrences: {len(groups[t['norm']])}." if len(groups[t['norm']])>1 else ""})
    if rid not in seen_rewrite:
        rewrites.append({"content_id":rid,"canonical_item_id":cid(groups[t['norm']][0]['path'],groups[t['norm']][0]['line'],groups[t['norm']][0]['text']),"recommended_category":category(t["path"],t["text"]),"current_text":t["text"],"recommended_text":recommended,"status":"ready" if not source_required else "blocked_by_verification","source_required":source_required})
        seen_rewrite.add(rid)

def write_csv(name, data, fields):
    with (ROOT/name).open("w",newline="",encoding="utf-8") as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader(); w.writerows(data)

write_csv("content_audit.csv",rows,["content_id","current_screen","current_text","problem_type","recommended_category","recommended_text","source_required","source_url","last_verified_at","notes"])
write_csv("facts_requiring_verification.csv",facts,["content_id","current_screen","claim","verification_status","required_source_type","source_url","last_checked_at","notes"])
write_csv("localization_issues.csv",loc,["content_id","screen","language","issue","current_text","recommended_text","canonical_name","notes"])

canonical={
 "schema_version":"1.0","policy":{"canonical_storage_language":"nl-NL for Dutch geography","localized_names_separate":True},
 "names":[
  {"id":"country-nl","type":"country","canonical_name":"Nederland","local_names":{"en":"The Netherlands","nl":"Nederland","ru":"Нидерланды"},"do_not_substitute":"Kingdom of the Netherlands","verified_source_id":"government-kingdom-parts"},
  {"id":"kingdom-nl","type":"kingdom","canonical_name":"Koninkrijk der Nederlanden","local_names":{"en":"Kingdom of the Netherlands","nl":"Koninkrijk der Nederlanden","ru":"Королевство Нидерландов"},"scope_note":"Not interchangeable with the country The Netherlands.","verified_source_id":"government-kingdom-parts"},
  {"id":"province-noord-holland","type":"province","canonical_name":"Noord-Holland","local_names":{"en":"North Holland","nl":"Noord-Holland","ru":"Северная Голландия"},"verified_source_id":"province-noord-holland"},
  {"id":"province-zuid-holland","type":"province","canonical_name":"Zuid-Holland","local_names":{"en":"South Holland","nl":"Zuid-Holland","ru":"Южная Голландия"},"verified_source_id":"province-zuid-holland"},
  {"id":"city-den-haag","type":"city","canonical_name":"Den Haag","official_name":"'s-Gravenhage","local_names":{"en":"The Hague","nl":"Den Haag","ru":"Гаага"},"verified_source_id":"municipality-den-haag"}
 ]}
(ROOT/"canonical_names.json").write_text(json.dumps(canonical,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
(ROOT/"rewritten_content.json").write_text(json.dumps({"generated_at":TODAY,"policy":{"historical_content":"retain","great_dutch_figures_category":"explore/culture-and-history","duplicates":"reference canonical_item_id"},"items":rewrites},ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
registry={"generated_at":TODAY,"verification_rule":"verified only after the exact official page was opened during this audit","sources":[
 {"id":"government-kingdom-parts","authority":"Government of the Netherlands","url":"https://www.government.nl/faq/what-are-the-different-parts-of-the-kingdom-of-the-netherlands","status":"verified_opened","last_verified_at":TODAY,"supports":["Kingdom vs country scope","Caribbean constitutional structure"]},
 {"id":"province-noord-holland","authority":"Provincie Noord-Holland","url":"https://www.noord-holland.nl/","status":"verified_opened","last_verified_at":TODAY,"supports":["Canonical Dutch province name Noord-Holland"]},
 {"id":"province-zuid-holland","authority":"Provincie Zuid-Holland","url":"https://www.zuid-holland.nl/","status":"verified_opened","last_verified_at":TODAY,"supports":["Canonical Dutch province name Zuid-Holland"]},
 {"id":"municipality-den-haag","authority":"Gemeente Den Haag","url":"https://www.denhaag.nl/en/introducing-the-hague/","status":"verified_opened","last_verified_at":TODAY,"supports":["English display name The Hague","Dutch/municipal name Den Haag","official name 's-Gravenhage","560,000 inhabitants (2023) only"]}
]}
(ROOT/"source_registry.json").write_text(json.dumps(registry,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print(json.dumps({"texts_scanned":len(texts),"audit_rows":len(rows),"duplicate_groups":sum(1 for v in groups.values() if len(v)>1),"facts_pending":len(facts),"localization_issues":len(loc),"rewrites":len(rewrites)},indent=2))
