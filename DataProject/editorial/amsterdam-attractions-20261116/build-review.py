# coding: utf-8
"""Regenerate the local approval package from the two private, hash-bound batches."""
import json,html
from pathlib import Path
D=Path(__file__).resolve().parent
def read(p):return json.loads(p.read_text())
def esc(s):return html.escape(str(s),quote=True)
parts=['''<!doctype html><html lang="ru"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow,noarchive"><link rel="icon" href="data:,"><title>YouNew — пакет на одобрение, 16.11.2026</title><style>
*{box-sizing:border-box}body{font:16px/1.55 system-ui,sans-serif;background:#f4f5f7;color:#14252e;margin:0;padding:24px}main{max-width:1180px;margin:auto}h1{line-height:1.2}a{color:#065e6b;overflow-wrap:anywhere}article,section.notice{background:white;padding:24px;border:1px solid #ccd6dc;border-radius:12px;margin:24px 0}code{overflow-wrap:anywhere;font-size:13px}img{display:block;max-width:100%;height:auto;max-height:600px;margin:auto;object-fit:contain}.locales{display:grid;grid-template-columns:1fr 1fr;gap:24px}.sources{font-size:14px}figcaption{font-size:14px;overflow-wrap:anywhere;margin-top:12px}.badge{display:inline-block;background:#fff0c2;padding:5px 12px;border-radius:6px}.new{border-left:4px solid #16807e;padding-left:12px}h3{margin-bottom:8px}figure{margin:18px 0}li{margin:8px 0}details{padding:12px 0;border-top:1px solid #ddd}@media(max-width:650px){body{padding:12px}.locales{grid-template-columns:1fr}article,section.notice{padding:16px}}
</style><main><h1>YouNew — следующий пакет на одобрение</h1><p class="badge">REVIEW · 16 ноября 2026 · публикация не разрешена</p>
<p>Продолжение Draft PR №75 от <code>63024764d029a1c26f3a71405a96ef44baba0bb0</code>. 10 прежних амстердамских карточек получили фото и редакционные уточнения; ещё 10 существующих карточек четырёх городов получили по два новых блока EN/NL. Это не 20 новых объектов в production.</p>
<section class="notice"><h2>Решения по ограничениям</h2><ul><li><b>Nieuwe Kerk:</b> области применимости конфликтующих расписаний не подтверждены. Числовые часы убраны из карточки. Сохранены официальные ссылки; варианты расписания находятся только в <a href="review-issues.json">редакционном реестре</a>.</li><li><b>OBA Oosterdok:</b> официальный сайт открыт 16.11.2026 в обычном видимом Chrome, HTTP 200; часы, адрес и доступность прочитаны непосредственно. Старый поисковый снимок оставлен в истории, не выдан за эту проверку.</li><li><b>Westbroekpark:</b> новые абзацы об истории и ландшафте используют сохранённую официальную страницу от 15.11.2026. Свежие запросы получили 403; обход не выполнялся и дата не обновлена.</li></ul></section>
<section class="notice"><h2>Пять прежних фото сохранены отдельно</h2><p><a href="../missing-photos-20261116/PHOTO_REVIEW.html">Открыть неизменённый пакет пяти фотографий</a>. Все 32 файла побайтно сохранены: Rembrandtpark — архив 1986, Kazerne — прежняя вывеска Benz, Supernova — временный декор 2022 и естественные 1024 px; City Hotel Rembrandt — архив, ibis — условный главный снимок с датой.</p><p>Четыре прежних пропуска: Kaafi, Koffie Leute, The Collector, The Nox. Четыре отдельные замены главных фото: Rembrandtpark, City Hotel Rembrandt, Kazerne, Supernova. <a href="media-followup.json">Имеющиеся причины и источники</a> сохранены без повторных скачиваний. Запросы правообладателям не отправлены.</p></section>
<p>Лицензия разрешает коммерческое использование фотографии при соблюдении указанных условий. Для CC BY/CC BY-SA нужны автор, ссылка на источник и лицензию, указание изменений; ShareAlike сохраняется. CC не означает поддержку YouNew объектом съёмки, наличие model release или передачу прав на товарные знаки. Снимки датированы и не доказывают состояние объекта сегодня.</p>
<nav><a href="#amsterdam">Амстердам: 10 фото</a> · <a href="#followup">Четыре города: 10 обновлений</a> · <a href="QA_REPORT_RU.md">Проверки и ограничения</a></nav>''']
for key,folder,label in [('amsterdam',D,'Амстердам — фото и точечные исправления'),('followup',D.parent/'priority-cities-followup-20261116','Rotterdam, Den Haag, Utrecht, Eindhoven — новые детали')]:
 records=read(folder/'records.json')['records'];manifest=read(folder/'manifest.json');media=read(folder/'media-sources.json');prefix='' if folder==D else '../'+folder.name+'/'
 parts.append(f'<h2 id="{key}">{label}</h2><p>Записи: <code>{manifest["recordsSha256"]}</code>. <a href="{prefix}manifest.json">Манифест</a> · <a href="{prefix}source-checks.json">Реестр источников</a> · <a href="{prefix}media-sources.json">Права и происхождение фото</a>.</p>')
 for r in records:
  p=json.loads(r['attributes']['place_enrichment']);parts.append(f'<article id="{esc(r["id"])}"><h2>{esc(r["title"])}</h2><p><code>{r["id"]}</code> · {r["city_id"]} · REVIEW</p>')
  if key=='followup':parts.append('<p class="badge">Новые два блока в каждой языковой версии отмечены полосой. Прежние пять блоков и фото сохранены.</p>')
  if r['images']:
   i=r['images'][0];m=media[r['id']];file=i['public_asset_path'].split('/')[-1];placement=m.get('recommendedPlacement','existing_approved_photo_unchanged')
   parts.append(f'<figure><img loading="lazy" src="{prefix}media/{file}" alt="{esc(i["alt"])}"><figcaption><b>{esc(placement)}</b><br>{esc(i["attribution"])}<br><a href="{esc(i["source_page_url"])}">Страница автора и источника</a> · <a href="{esc(i["license_url"])}">{esc(i["license"])}</a><br>SHA-256 WebP: <code>{manifest["media"][file]["sha256"]}</code></figcaption></figure>')
   if placement=='archive_gallery_only':parts.append('<p class="badge">Только архивная галерея. Для главной фотографии нужна замена; техническое превью не является одобрением такого размещения.</p>')
  else:parts.append('<p>Прежний пустой слот фото сохранён. Отдельный кандидат находится в неизменённом пакете пяти фотографий выше.</p>')
  parts.append('<div class="locales">')
  for locale in ['en','nl']:
   summary=r['description'] if locale=='en' else r['attributes']['description_nl'];parts.append(f'<section lang="{locale}"><h3>{locale.upper()}</h3><p>{esc(summary)}</p>')
   for n,b in enumerate(p['locales'][locale]['blocks']):
    cls=' class="new"' if key=='followup' and n>=5 else '';parts.append(f'<div{cls}><h3>{esc(b["title"])}</h3><p>{esc(b["text"])}</p><p class="sources">')
    for sid in b['source_ids']:
     s=next(s for s in p['sources'] if s['id']==sid);parts.append(f'<a href="{esc(s["url"])}">{esc(s["publisher"])}</a> · {s["checked_at"]} ')
    parts.append('</p></div>')
   parts.append('</section>')
  parts.append('</div><details><summary>Координаты и тематические связи</summary>')
  parts.append(f'<p>{esc(r.get("coordinates"))} — {esc(p["coordinateEvidence"]["method"])}. <a href="{esc(p["coordinateEvidence"]["url"])}">Существующее официальное доказательство</a>.</p><p>{esc(", ".join(r["related_entity_ids"]))}</p>')
  parts.append(f'<p>{esc(r["attributes"].get("related_entities_editorial_basis",""))}</p></details></article>')
parts.append('<footer><p>Production, merge, TestFlight и App Store не затронуты. Одобрение текста и пригодности размещения фото остаётся за владельцем. Перед будущим выпуском нужны актуальная проверка изменчивых фактов и отдельное разрешение.</p></footer></main></html>')
(D/'REVIEW.html').write_text('\n'.join(part.rstrip() for part in parts)+'\n')
print('Generated 20-card review package')
