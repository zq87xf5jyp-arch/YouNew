"""Generate an offline, non-publishing editorial review of the exact staged batch."""
from pathlib import Path
import hashlib, html, json
ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
files = sorted((ROOT/'DataProject/staging/content-20261109').glob('*.json'))
records = [e for p in files for e in json.loads(p.read_text())['records']]
manifest = {'batch':'leiden-20261109', 'records':len(records), 'files':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}, 'ids':sorted(e['id'] for e in records), 'approval':'pending'}
manifest['batchSha256'] = hashlib.sha256(json.dumps(manifest['files'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
(OUT/'CONTENT_BATCH.json').write_text(json.dumps(manifest,indent=2)+'\n')
def esc(v): return html.escape(str(v))
def guide(g):
    parts=['<h3>'+esc(g['title'])+'</h3>']
    for field in ('who_this_is_for','when_you_need_it'):
        if g.get(field): parts+=['<p>'+esc(g[field]['text'])+'</p>']
    parts+=['<ol>']
    for step in g['numbered_steps']: parts+=['<li>'+esc(step['body'])+'</li>']
    parts+=['</ol>']
    for item in g.get('required_documents',[])+g.get('warnings',[]): parts+=['<p>'+esc(item['text'])+'</p>']
    for item in g.get('sections',[]): parts+=['<h4>'+esc(item['title'])+'</h4><p>'+esc(item['body'])+'</p>']
    parts+=['<p><em>'+esc(g['disclaimer'])+'</em></p><ul>']
    for source in g['official_sources']: parts+=['<li><a href="'+esc(source['url'])+'">'+esc(source['publisher'])+'</a></li>']
    return ''.join(parts)+ '</ul>'
parts=['''<!doctype html><html lang="ru"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>YouNew — редакторская партия</title><style>body{font:16px/1.55 system-ui;max-width:1100px;margin:40px auto;padding:0 20px;color:#14283a}article{border:1px solid #ccd5dd;border-radius:12px;padding:22px;margin:20px 0}.languages{display:grid;grid-template-columns:1fr 1fr;gap:24px}pre{white-space:pre-wrap;overflow-wrap:anywhere;font-size:13px}a{color:#005b87}h1{line-height:1.15}.note{background:#fff3ce;padding:20px}@media(max-width:700px){.languages{grid-template-columns:1fr}}</style><h1>YouNew: партия на редакторское согласование</h1><p>54 места (40 Leiden, 14 других городов), 10 LIVE, 5 подборок, 2 BUSINESS. Все 71 записи пока черновики.</p><p class="note">Неподтверждённые часы, цены и координаты оставлены пустыми; фотографии не заимствованы. Только 3 места имеют подтверждённые координаты. Полные тексты EN/NL и источники ниже. Редакторское согласование не отменяет технические проверки перед публикацией.</p>''','<p>SHA-256: '+manifest['batchSha256']+'</p>']
for e in sorted(records,key=lambda e:(e['attributes']['content_section'],e['title'])):
    a=e['attributes'];parts+=['<article id="'+esc(e['id'])+'"><p>'+esc(a['content_section'])+' · '+esc(e['id'])+'</p><h2>'+esc(e['title'])+'</h2><div class="languages"><section><h3>English</h3><p>'+esc(e['description'])+'</p></section><section><h3>Nederlands</h3><p>'+esc(a.get('description_nl',''))+'</p></section></div>']
    if e.get('practical_guide'): parts+=['<div class="languages"><section>'+guide(e['practical_guide'])+'</section><section>'+guide(json.loads(a['practical_guide_nl']))+'</section></div>']
    for field in ('address','contact_phone','contact_email','opening_hours','prices'):
        if a.get(field): parts+=['<p>'+esc(field)+': '+esc(a[field])+'</p>']
    parts+=['<p><a href="'+esc(e['official_source']['url'])+'">Официальный источник</a> · Проверен '+esc(e['last_checked'])+'</p><details><summary>Все исходные поля и ссылки на источники</summary><pre>'+esc(json.dumps(e,ensure_ascii=False,indent=2))+'</pre></details></article>']
(OUT/'CONTENT_REVIEW.html').write_text('\n'.join(parts)+ '</html>\n')
print(json.dumps({'records':len(records),'sha256':manifest['batchSha256']}))
