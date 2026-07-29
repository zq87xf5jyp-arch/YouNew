-- LOCAL DEMO DATA ONLY. Never run this seed in production.
do $$
begin
  if current_setting('younew.allow_demo_seed', true) is distinct from 'on' then
    raise exception 'Demo seed refused. Set younew.allow_demo_seed=on explicitly in this non-production SQL session.';
  end if;
end $$;

-- YouNew initial categories, content, settings and demo analytics
insert into public.categories (title, slug, icon, color, status, priority) values
('Правила и штрафы','rules-fines','TriangleAlert','#f97316','published',1),
('Документы и сервисы','documents-services','ClipboardList','#38bdf8','published',2),
('Транспорт','transport','Train','#14b8a6','published',3),
('Работа и налоги','work-taxes','BriefcaseBusiness','#8b5cf6','published',4),
('Жилье','housing','House','#3b82f6','published',5),
('Здравоохранение','healthcare','HeartPulse','#ef4444','published',6),
('Государство','government','Landmark','#22c55e','published',7),
('Образование','education','GraduationCap','#eab308','published',8),
('Экстренная помощь','emergency','Siren','#dc2626','published',9),
('Библиотека','reference-library','Library','#06b6d4','published',10),
('Гид по Нидерландам','netherlands-guide','Map','#0ea5e9','published',11),
('AI-ассистент','ai-assistant','Sparkles','#a855f7','published',12)
on conflict (slug) do nothing;

insert into public.cities (name, slug, province, description, municipality_link, lat, lng, status) values
('Amsterdam','amsterdam','Noord-Holland','Гид по столице для новичков.','https://www.amsterdam.nl',52.367600,4.904100,'published'),
('Rotterdam','rotterdam','Zuid-Holland','Гид по портовому городу: работа, транспорт и повседневная жизнь.','https://www.rotterdam.nl',51.924400,4.477700,'published'),
('The Hague','the-hague','Zuid-Holland','Гид по городу правительства, муниципалитетам и посольствам.','https://www.denhaag.nl',52.070500,4.300700,'published'),
('Utrecht','utrecht','Utrecht','Гид по центральным Нидерландам для студентов, работников и жителей.','https://www.utrecht.nl',52.090700,5.121400,'published'),
('Leiden','leiden','Zuid-Holland','Гид по университетскому городу и местным базовым сервисам.','https://gemeente.leiden.nl',52.160100,4.497000,'published'),
('Eindhoven','eindhoven','Noord-Brabant','Гид по технологическому городу: работа и повседневная жизнь.','https://www.eindhoven.nl',51.441600,5.469700,'published'),
('Groningen','groningen','Groningen','Гид по северному городу для студентов и жителей.','https://gemeente.groningen.nl',53.219400,6.566500,'published'),
('Maastricht','maastricht','Limburg','Гид по южным Нидерландам, городским сервисам и культуре.','https://www.gemeentemaastricht.nl',50.851400,5.690900,'published')
on conflict (slug) do nothing;

insert into public.articles (title, slug, short_description, full_content, language, status, priority, source_url, official_source)
values
('Регистрация в муниципалитете','municipality-registration','Как зарегистрироваться после переезда в Нидерланды.','Запишитесь в муниципалитет и возьмите действительные документы.','ru','published',1,'https://www.government.nl',true),
('OVpay и общественный транспорт','ovpay-public-transport','Как использовать банковскую карту или устройство для check-in/check-out.','OVpay позволяет многим пассажирам входить и выходить из транспорта с бесконтактной оплатой.','ru','review',2,'https://www.ovpay.nl',true),
('Что делать с голландскими штрафами','dutch-fines','Как понимать дорожные и публичные штрафы.','Проверьте официальное письмо, срок оплаты и инструкции.','ru','draft',3,'https://www.cjib.nl',true)
on conflict (slug) do nothing;

insert into public.map_points (title, type, latitude, longitude, city, province, description, status, icon, color)
select name, 'city', lat, lng, name, province, description, 'published', 'MapPin', '#38bdf8'
from public.cities
on conflict do nothing;

insert into public.official_links (title, url, source_type, status, last_checked_date) values
('Government.nl','https://www.government.nl','government','active',current_date),
('Муниципалитет Amsterdam','https://www.amsterdam.nl','municipality','active',current_date),
('Планировщик NS','https://www.ns.nl','transport','needs review',current_date - interval '7 days')
on conflict do nothing;

insert into public.releases (version, platform, release_notes, status, release_date)
values ('1.0.0','iOS','Первый TestFlight-релиз с контентом, визуальными исправлениями и проверкой официальных источников.','testing',current_date + interval '14 days')
on conflict do nothing;

insert into public.app_settings (key, value, status) values
('app_name','"YouNew.nl"','published'),
('support_email','"support@younew.nl"','published'),
('default_city','"Amsterdam"','published'),
('default_language','"en"','published'),
('maintenance_mode','false','published')
on conflict (key) do update set value = excluded.value, updated_at = now();

insert into public.content_sync_state (dataset, version, records, last_sync, status) values
('categories', 12, 12, now(), 'synced'),
('articles', 34, 128, now(), 'synced'),
('cities', 8, 8, now(), 'synced'),
('map_points', 21, 84, now(), 'synced'),
('resources', 18, 58, now(), 'needs review'),
('settings', 5, 9, now(), 'synced')
on conflict (dataset) do update
set version = excluded.version, records = excluded.records, last_sync = excluded.last_sync, status = excluded.status, updated_at = now();

insert into public.sync_jobs (job, target, status, duration_ms, details) values
('Полная выгрузка контента', 'iOS', 'success', 1200, '{"endpoint":"/api/mobile/sync"}'),
('Обновление настроек', 'iOS', 'success', 400, '{"endpoint":"/api/public/settings"}'),
('Проверка официальных ссылок', 'Admin', 'warning', 8900, '{"broken":0,"needs_review":1}')
on conflict do nothing;

insert into public.app_events (app_instance_id, session_id, event_name, screen, platform, app_version, language, city, properties, occurred_at) values
('demo-device-1','demo-session-1','screen_view','Главная','iOS','1.0.0','ru','Amsterdam','{"source":"seed"}',now() - interval '20 minutes'),
('demo-device-1','demo-session-1','category_opened','Категории','iOS','1.0.0','ru','Amsterdam','{"category":"Транспорт"}',now() - interval '18 minutes'),
('demo-device-2','demo-session-2','search_submitted','Поиск','iOS','1.0.0','ru','Leiden','{"query":"DigiD"}',now() - interval '12 minutes'),
('demo-device-3','demo-session-3','ai_question_sent','AI-ассистент','iOS','1.0.0','en','Rotterdam','{"topic":"housing"}',now() - interval '8 minutes')
on conflict do nothing;
