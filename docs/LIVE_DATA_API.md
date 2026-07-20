# YouNew live data contract

The app reads `YOUNEW_API_BASE_URL` from the generated Info.plist. Set the Xcode build setting to an HTTPS origin, for example `https://api.younew.nl`. If it is empty, Home continues to use the curated on-device database.

## Public read endpoints

### Places

`GET /v1/cities/{city-slug}/places/summary`

```json
{
  "placeCount": 42,
  "restaurantCount": 12,
  "eventCount": 7,
  "updatedAt": "2026-07-14T10:00:00Z"
}
```

### Businesses

`GET /v1/cities/{city-slug}/businesses/summary`

```json
{
  "businessCount": 30,
  "verifiedCount": 24,
  "featuredCount": 6,
  "updatedAt": "2026-07-14T10:00:00Z"
}
```

Counts must be non-negative. `verifiedCount` and `featuredCount` may not exceed `businessCount`. The app caches valid responses for 24 hours and falls back to its curated database when the API is unavailable or returns invalid data.

Live weather is read from Open-Meteo with the `knmi_seamless` model. Leiden events are read from the official Visit Leiden event calendar. Both feeds retain cached content when their upstream service is temporarily unavailable.
