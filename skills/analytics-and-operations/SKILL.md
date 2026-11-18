---
name: analytics-and-operations
description: Analyse a merchant's Hyperswitch data and get insights using a JWT copied from the Hyperswitch Control Center. Use when the user wants to look up payments, refunds or disputes, or understand success rates, failures, connector or payment-method performance, or trends. Read-only; never performs actions like refunds, captures or cancellations.
---

# Hyperswitch Analytics & Operations

Help the user explore their Hyperswitch data and turn it into insights, using the same APIs the Control Center dashboard uses.

**Read-only.** Don't perform actions such as refunds, captures, cancels/voids, manual status updates, `force_sync`, dispute accept or evidence, report generation, or config changes. If the user asks for one, tell them to do it in the Control Center.

## Getting the JWT

Tell the user:

> Copy your JWT from the Control Center: go to **Account Settings → Profile** (`/account-settings/profile`) and click **Copy JWT**, then paste it here.
> The JWT is time-limited. If requests fail with 401 or "invalid/expired token", copy a fresh one from the same page.

The API base is the Control Center origin + `/api`:

- `https://app.hyperswitch.io/api` (sandbox)
- `https://live.hyperswitch.io/api` (production)
- `https://eu.hyperswitch.io/api` (EU)

Ask the user which one they use if it isn't clear.

Treat the JWT as a secret. Don't echo it back or write it into repo files.

## Making requests

```bash
curl -sS "$BASE/<path>" \
  -H "authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -H "X-Merchant-Id: <merchant_id>" \
  -H "X-Profile-Id: <profile_id>"
```

Start with `GET /user`. It returns `merchant_id`, `profile_id`, `org_id`, `entity_type` and `version`. You can also decode the JWT payload to get these and its `exp`.

- `{entity}` in analytics URLs is `org`, `merchant` or `profile`, matching `entity_type`.
- Profile-level users must use the `/profile/` variants of list endpoints (e.g. `payments/profile/list`).
- Data is scoped to the JWT's merchant/profile. To look at another one, the user switches in the Control Center and copies a new JWT.

Save large responses to a temp file and analyse them with `jq` or Python.

## Which API to use

| Need | API |
|---|---|
| Rates, totals, breakdowns, trends | **Analytics (ClickHouse)**: `POST /analytics/v1/{entity}/metrics/payments` (also `refunds`, `disputes`, `auth_events`) |
| Insights-style KPIs (per payment intent, which counts retries as one payment) | **Insights**: `POST /analytics/v2/{entity}/metrics/payments`, `POST /analytics/v1/{entity}/metrics/sankey` |
| Available metrics/dimensions | `GET /analytics/v1/{entity}/payments/info` |
| Available filter values | `POST /analytics/v1/{entity}/filters/payments` |
| Find specific payments | `POST /payments/list` |
| One payment in depth | `GET /payments/{id}?expand_attempts=true` |
| Quick status counts | `GET /payments/aggregate?start_time=..&end_time=..` |

Use analytics for anything that aggregates, and lists/details to drill into examples. Don't page through payments to compute metrics.

## Analytics

Body is a JSON array with **exactly one** query object:

```json
[{
  "timeRange": { "startTime": "2026-10-09T00:00:00Z", "endTime": "2026-10-16T00:00:00Z" },
  "groupByNames": ["connector", "currency"],
  "filters": { "payment_method": ["card"] },
  "metrics": ["payment_success_rate", "payment_count", "payment_processed_amount"],
  "timeSeries": { "granularity": "G_ONEDAY" },
  "delta": true,
  "source": "BATCH"
}]
```

- `granularity`: `G_FIFTEENMIN`, `G_THIRTYMIN`, `G_ONEHOUR`, `G_ONEDAY` (adds `time_bucket` to each row).
- `delta: true` also returns totals in `metaData`.
- Top-N distributions: `"distribution": { "distributionFor": "payment_error_message", "distributionCardinality": "TOP_5" }` with metric `failure_reasons` or `payments_distribution`.
- Response: `{ "queryData": [...rows], "metaData": [...totals] }`.

Common payment metrics:
- v1: `payment_success_rate`, `payment_count`, `payment_success_count`, `payment_processed_amount`, `avg_ticket_size`, `retries_count`, `connector_success_rate`, `failure_reasons`, `payments_distribution`.
- v2 (Insights): `sessionized_payments_success_rate`, `sessionized_payment_processed_amount`, `sessionized_payment_intent_count`, `sessionized_smart_retried_amount`.

Common dimensions: `connector`, `payment_method`, `payment_method_type`, `currency`, `status`, `authentication_type`, `card_network`, `error_reason`.

Check `payments/info` and `filters/payments` before querying. Don't guess names.

## Payments

**List**: `POST /payments/list`. All fields optional; amounts in minor units.
```json
{ "offset": 0, "limit": 50,
  "start_time": "2026-10-09T00:00:00Z", "end_time": "2026-10-16T00:00:00Z",
  "status": ["failed"], "connector": ["stripe"], "currency": ["USD"],
  "payment_method": ["card"], "customer_id": "cus_123",
  "amount_filter": { "start_amount": 50000, "end_amount": 100000 },
  "order": { "on": "created", "by": "desc" } }
```
Response: `{ count, total_count, data: [...] }`. Filter values: `GET /payments/v2/filter`.

**Detail**: `GET /payments/{id}?expand_attempts=true` returns status, connector, `error_code`/`error_message`, `attempts[]`, `refunds[]` and `disputes[]`. Never add `force_sync=true`.

**Logs for a payment**: `GET /analytics/v1/profile/api_event_logs?type=Payment&payment_id={id}` (also `connector_event_logs`, `outgoing_webhook_event_logs`, `routing_event_logs`).

Refunds and disputes follow the same pattern: `POST /refunds/list`, `GET /refunds/{id}`, `GET /disputes/list?limit=100`, `GET /disputes/{id}`, plus `/refunds/aggregate` and `/disputes/aggregate`.

## Doing the analysis

1. Clarify the question and time range. Default to the last 7 days and say so.
2. Amounts are in **minor units**. Never sum across currencies; group by `currency`.
3. Compare against the previous period of equal length before calling something a change. Flag small samples.
4. Drill into a few example payments for any interesting segment.
5. Lead with the key finding, back it with a compact table, and suggest next steps.

## Errors

- **401** (e.g. `IR_17` invalid JWT) or expired `exp`: ask the user to copy a fresh JWT from **Account Settings → Profile**.
- **403**: their role lacks access. Tell the user.
- **400**: usually an unknown metric/dimension or a bad body. Re-check `payments/info`.
- **Empty `queryData`**: widen the time range or filters, and check the merchant/profile.

## More context

- Control Center code (how the dashboard calls these APIs): https://github.com/juspay/hyperswitch-control-center. See `src/APIUtils/APIUtils.res` for endpoints, `src/screens/Analytics/` and `src/screens/NewAnalytics/Insights/` for analytics bodies, and `src/screens/Transaction/Order/` for payment list filters.
- Hyperswitch backend (what the APIs accept and return): https://github.com/juspay/hyperswitch. See `crates/api_models/src/analytics/` for metrics and dimensions, and `crates/api_models/src/payments.rs` for payment schemas.
