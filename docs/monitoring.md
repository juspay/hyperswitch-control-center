# Monitoring

Monitoring lives in Orchestrator V1 alongside Alerts. Both the sidebar and direct
routes require `dev_alerts` and the existing internal-role predicate
(`internal_view_only` or `internal_admin`). Backend permissions remain the actual
access boundary; hiding navigation is not authorization.

## Destinations

| Sidebar               | Route under `/dashboard/monitoring/` | OP destination ID       |
| --------------------- | ------------------------------------ | ----------------------- |
| Explore               | `explore`                            | `explore`               |
| API Health            | `api-health`                         | `api_health`            |
| Connector Performance | `connector-performance`              | `connector_performance` |
| Business Metrics      | `business-metrics`                   | `business_metrics`      |
| System Health         | `system-health`                      | `system_health`         |

`/dashboard/monitoring` redirects to Explore. Unknown slugs render the existing
not-found screen and never become arbitrary backend destination IDs.

Configure complete URLs in OP using
`OBSERVABILITY__MONITORING__DESTINATIONS__<ID>`. Explore's URL must include the
Grafana Explore state selecting Loki. Users can still select other data sources
they are authorized to query. OP returns one URL per session request, not a list.

## Browser/session contract

CC sends a bodyless POST to
`/api/observability-plane/monitoring/grafana/session/{id}` with its existing Bearer
token and same-origin credentials. A successful response returns `embed_url` and
sets the Secure, HttpOnly, SameSite=Strict, host-only `grafana_token` cookie scoped
to `/api/observability-plane/grafana`. CC never reads the cookie or places the
token in the iframe URL. The returned URL must match the current CC origin and
Grafana gateway path. CC adds kiosk and its current light/dark theme; all time
ranges, filters and refresh controls remain Grafana-owned.

The gateway must authorize every protected request and strip the credential
before forwarding to Grafana. Router must enforce expiry, revocation and logout.
CC removes the iframe when its authenticated subtree unmounts and aborts pending
bootstrap requests on navigation or session changes. An iframe load event is
only document-load evidence, not proof that every panel/data-source query works.

Bootstrap errors distinguish 401 (existing CC logout), 403 (denied), 404
(unconfigured) and other failures (unavailable). Bootstrap/document loading has
a 30-second timeout with a scoped retry. A cookie-only GET probes the approved
Grafana document before embedding, and every 60 seconds while the view is open,
to notice idle-session expiry or gateway outages. This adds one initial document
request and one request per minute; it does not prove panel query success. Test
gateway failures and expiry after initial load as well as bootstrap failures.

## Local frontend against sandbox

The opt-in Webpack proxy keeps API and iframe requests on local HTTPS, preserving
cookie security attributes and verifying upstream TLS. It proxies only monitoring
session and Grafana paths, before the generic local Router proxy:

```sh
npm ci
npm run re:build
SANDBOX_MONITORING_ORIGIN=https://app.hyperswitch.io \
  default__endpoints__api_url=https://localhost:9000/api \
  default__features__dev_alerts=true \
  npm start
```

Open `https://localhost:9000/dashboard/monitoring`. Trust the local development
certificate (or configure Webpack with a locally trusted certificate). Use an
existing internal CC session; never put a token in a URL, checked-in file or
shell argument. Ordinary authentication and unrelated API routes retain their
existing local-backend configuration.

For the currently configured sandbox test destination only, add
`MONITORING_API_HEALTH_ID=api_inbound`. This aliases the dev proxy's `api_health`
request without changing frontend IDs or production behavior. Remove it once
sandbox has the agreed ID. The other four IDs must be provisioned in OP to test
them live; they are not silently aliased.

The proxy translates approved returned URLs, Grafana HTML root URLs, redirects,
and the sandbox origin in Grafana's framing header to the local origin. This is
dev-only adaptation, not a test of the deployed parent CSP. Test the final build
on the actual sandbox origin before rollout. WebSocket proxying is enabled.

## Validation

```sh
npm run re:build
npm run re:format:check
npm run format:check
npm run lint:hooks
npm run lint:tests
node --test scripts/monitoring-proxy.test.cjs
npx playwright test playwright-tests/e2e/monitoring/monitoring.spec.ts
```

The focused browser suite mocks user/session/dashboard responses and requires
no real user creation or backend writes. It checks route/role/flag gating,
bodyless authenticated requests, cookie attributes, all five IDs, kiosk,
bookmarks/history, denied/unconfigured/unavailable responses, retry, expired
sessions, and rejection of unapproved URLs. These mocks are not deployment
security evidence. Live sandbox validation must cover each configured view,
query responses, gateway denial, logout/revocation, both internal roles,
non-internal denial, supported browsers, themes, and responsive sizing.
