# Изменения YouNew 2.0

## 15.11.2026 · SPRINT 0 + маленький шаг SPRINT 1

- `docs/younew-upgrade/*`: единая карта функций, архитектурный индекс, история,
  решения, источники и проверка; существующие исторические release-документы сохранены.
- `admin-dashboard/public-site/src/components/discovery-home.tsx`: общий массив категорий
  даёт четыре быстрых EN/NL-перехода под поиском; Local services → наполненная категория;
  нейтральная подпись Practical tasks.
- `admin-dashboard/public-site/src/app/discovery.css`: компактная сетка, переносы,
  минимальная высота ссылок 44 px, цвета темы и существующий focus.
- `admin-dashboard/public-site/tests/user-first-homepage.test.ts`: существующее ожидание
  исправлено с пустого organizations на local-services; тест не удалён/не пропущен.
- `admin-dashboard/public-site/public/sw.js`: штатно сгенерирована новая версия кэша.
- `.github/workflows/admin-ci.yml`: повторно использован уже проверенный CI fix PR59,
  без копирования остальных изменений SEO/редакционного пакета.
- Не изменяются БД, зависимости, API, источники и даты контента, права фото, iOS,
  production, одобрения Г01 или настройки тарифа.

Итоговые результаты и rollback: [QA_REPORT](QA_REPORT.md). Это один законченный шаг,
не статус «готов весь YouNew 2.0».
