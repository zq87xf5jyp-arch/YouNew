# Подключение iOS-приложения к админке YouNew.nl

Этот документ описывает планируемый контракт backend-control-panel. Текущее production-состояние:

- `/api/mobile/sync` локально реализован поверх published-only governed runtime, но ещё не разрешён для production-приложения до live-проверок;
- `/api/mobile/analytics/events` работает только при настроенных server-only переменных и токене ingest;
- домен `admin.younew.nl`, production-развёртывание, rate limiting, мониторинг и доставка событий — **NOT VERIFIED**;
- production-приложение, public website и admin sync build используют один управляемый runtime-артефакт и одинаковый dataset fingerprint.

## 1. Базовый URL

Для локального теста:

```swift
let baseURL = URL(string: "http://127.0.0.1:3000")!
```

Планируемый production URL (не использовать до отдельной проверки DNS, TLS и deploy):

```swift
let baseURL = URL(string: "https://admin.younew.nl")!
```

## 2. Получить опубликованный контент

```http
GET /api/mobile/sync
```

Локальный endpoint отвечает HTTP 200 и содержит:

- `schema_version`
- `content_version`
- `generated_at`
- `entity_count`
- `published_release_ids`
- `artifact` — полный governed runtime в исходной production-схеме.

`ETag` равен `content_version`; запрос с совпадающим `If-None-Match` получает HTTP 304 без тела. iOS-клиент нельзя включать до live-проверки DNS/TLS, rate limiting, мониторинга, rollback и интеграционного теста против реально развёрнутого endpoint.

## 3. Отправить аналитику

```http
POST /api/mobile/analytics/events
Content-Type: application/json
```

Пример payload:

```json
{
  "events": [
    {
      "app_instance_id": "device-or-install-id",
      "session_id": "session-id",
      "event_name": "screen_view",
      "screen": "Главная",
      "platform": "iOS",
      "app_version": "1.0.0",
      "language": "ru",
      "city": "Amsterdam",
      "properties": {
        "source": "tab_bar"
      }
    }
  ]
}
```

## 4. Рекомендуемые события

- `app_opened`
- `session_started`
- `screen_view`
- `category_opened`
- `article_opened`
- `city_opened`
- `map_point_opened`
- `search_submitted`
- `search_result_opened`
- `ai_question_sent`
- `resource_opened`
- `favorite_added`
- `visual_error_reported`
- `sync_started`
- `sync_finished`
- `sync_failed`

## 5. Черновой Swift-клиент — не production

```swift
import Foundation

struct YouNewAdminClient {
    let baseURL: URL
    let session: URLSession = .shared

    func syncContent() async throws -> MobileSyncPayload {
        let url = baseURL.appending(path: "/api/mobile/sync")
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(MobileSyncPayload.self, from: data)
    }

    func send(events: [AnalyticsEvent]) async throws {
        let url = baseURL.appending(path: "/api/mobile/analytics/events")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["events": events])

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

struct MobileSyncPayload: Decodable {
    let schemaVersion: Int
    let contentVersion: String

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contentVersion = "content_version"
    }
}

struct AnalyticsEvent: Encodable {
    let appInstanceId: String
    let sessionId: String?
    let eventName: String
    let screen: String?
    let platform: String
    let appVersion: String?
    let language: String?
    let city: String?
    let properties: [String: String]

    enum CodingKeys: String, CodingKey {
        case appInstanceId = "app_instance_id"
        case sessionId = "session_id"
        case eventName = "event_name"
        case screen
        case platform
        case appVersion = "app_version"
        case language
        case city
        case properties
    }
}
```

## 6. Что смотреть в админке

- **Аналитика**: активные пользователи, сессии, popular screens, search queries, AI questions.
- **Синхронизация**: версии наборов данных, endpoint-ы для iOS, последние sync jobs.
- **Контент**: административные записи; попадание в `/api/mobile/sync` пока не реализовано.
- **Ссылки**: official source status.
- **Ошибки**: баги, созданные по данным QA или пользовательским событиям.
