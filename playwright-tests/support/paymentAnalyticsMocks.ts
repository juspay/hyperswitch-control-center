import type { Page, Route } from "@playwright/test";

// ---------------------------------------------------------------------------
// Legacy Payments Analytics API mocks (/dashboard/analytics-payments)
//
// A freshly signed-up org has no transactions, so every KPI card / chart on the
// page renders empty ("0", "0.00%", "No Data"). These helpers intercept every
// endpoint the page fires on load and return canned, non-zero data so each
// section shows realistic, VISIBLE values.
//
// Endpoints fired on page open (scope = org | merchant | profile):
//   GET  /payments/list?limit=100                      -> order list (gates the
//                                                         page's Custom state)
//   GET  /analytics/v1/{scope}/payments/info           -> metric + dimension list
//   POST /analytics/v1/{scope}/filters/payments        -> dimension filter values
//   POST /analytics/v1/{scope}/metrics/payments        -> overview / amount /
//                                                         status / connector stats
//   POST /analytics/v2/{scope}/metrics/payments        -> smart-retry stats
//
// Each metrics request is a single-element array `[{ timeRange, metrics,
// groupByNames, timeSeries, delta, distribution, ... }]`; the handler dispatches
// on `metrics` / `groupByNames` to return the matching canned rows. Both the
// delta query (the big number) and the timeSeries query (the sparkline) are
// served — the delta rows drive the values the tests assert on.
// ---------------------------------------------------------------------------

// Frozen "now" for deterministic analytics. Tests pin the browser clock to this
// instant (page.clock.setFixedTime) so the app's default date range ends on the
// same fixed day.
export const FROZEN_NOW = "2026-05-15T12:00:00.000Z";
// Day-aligned bucket for single-point grouped responses.
const FROZEN_BUCKET = "2026-05-15 00:00:00";

// USD is TwoDecimal, so amounts are in minor units (cents); the UI divides by
// 100 before formatting. 5_234_000 -> $52,340, 8_750 -> $87.50, etc.
const CURRENCY = "USD";

const json = (route: Route, body: unknown) =>
  route.fulfill({
    status: 200,
    contentType: "application/json",
    body: JSON.stringify(body),
  });

// Shape of a single analytics metrics query (the dispatchers only read these
// keys off the request body to decide which canned rows to return).
interface AnalyticsQuery {
  metrics?: string[];
  groupByNames?: string[];
  timeSeries?: unknown;
  granularity?: unknown;
}

// Returns the first element of an analytics request body (the body is a
// single-element array `[{ ... }]`); falls back to the raw object.
function firstQuery(route: Route): AnalyticsQuery {
  let body: AnalyticsQuery | AnalyticsQuery[] | undefined;
  try {
    body = route.request().postDataJSON();
  } catch {
    body = undefined;
  }
  if (Array.isArray(body)) return body[0] ?? {};
  return body ?? {};
}

const CONNECTORS = ["stripe", "adyen", "checkout"];

// Every calendar day in a wide window around the frozen clock, as the exact
// G_ONEDAY bucket string the app plots ("YYYY-MM-DD 00:00:00"). Covering every
// day guarantees a non-zero point for whatever range the page requests.
function dayBuckets(): string[] {
  const out: string[] = [];
  const start = Date.UTC(2026, 3, 1); // 2026-04-01
  const end = Date.UTC(2026, 5, 30); // 2026-06-30
  for (let t = start; t <= end; t += 86400000) {
    out.push(`${new Date(t).toISOString().slice(0, 10)} 00:00:00`);
  }
  return out;
}

// ===========================================================================
// Canned responses
// ===========================================================================

// GET /analytics/v1/{scope}/payments/info — the metric + dimension catalogue
// that drives the dimension tabs and the "Add Filters" popup options.
const PAYMENTS_INFO = {
  metrics: [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
    "payment_processed_amount",
    "avg_ticket_size",
    "retries_count",
    "connector_success_rate",
    "payments_distribution",
    "failure_reasons",
  ].map((name) => ({ name, desc: "" })),
  downloadDimensions: null,
  dimensions: [
    "connector",
    "payment_method",
    "payment_method_type",
    "currency",
    "authentication_type",
    "status",
    "client_source",
    "client_version",
    "profile_id",
    "card_network",
    "merchant_id",
    "routing_approach",
  ].map((name) => ({ name, desc: "" })),
};

// POST /analytics/v1/{scope}/filters/payments — selectable values per dimension,
// surfaced in the expanded "Add Filters" sub-dropdowns.
const FILTER_VALUES = {
  queryData: [
    { dimension: "connector", values: CONNECTORS },
    { dimension: "payment_method", values: ["card", "wallet"] },
    { dimension: "payment_method_type", values: ["credit", "debit"] },
    { dimension: "currency", values: ["USD", "EUR"] },
    { dimension: "authentication_type", values: ["no_three_ds", "three_ds"] },
    { dimension: "status", values: ["charged", "failure", "authorized"] },
    { dimension: "client_source", values: ["Payment"] },
    { dimension: "client_version", values: ["0.131.0"] },
    { dimension: "profile_id", values: ["pro_playwright_test"] },
    { dimension: "card_network", values: ["Visa", "Mastercard"] },
    { dimension: "merchant_id", values: ["merchant_playwright"] },
    { dimension: "routing_approach", values: ["default_fallback"] },
  ],
};

// Non-zero metaData totals (consumed by the Payments Trends summary table).
const V1_META = [
  {
    total_payment_processed_amount: 5234000,
    total_payment_processed_amount_in_usd: 52340,
    total_payment_processed_amount_without_smart_retries: 4980000,
    total_payment_processed_amount_without_smart_retries_usd: 49800,
    total_payment_processed_count: 1184,
    total_payment_processed_count_without_smart_retries: 1100,
    total_failure_reasons_count: 96,
    total_failure_reasons_count_without_smart_retries: 88,
  },
];

const V2_META = [
  {
    total_success_rate: 92.5,
    total_success_rate_without_smart_retries: 86.4,
    total_smart_retried_amount: 1845000,
    total_smart_retried_amount_without_smart_retries: 0,
    total_payment_processed_amount: 5234000,
    total_payment_processed_amount_without_smart_retries: 4980000,
    total_smart_retried_amount_in_usd: 18450,
    total_smart_retried_amount_without_smart_retries_in_usd: 0,
    total_payment_processed_amount_in_usd: 52340,
    total_payment_processed_amount_without_smart_retries_in_usd: 49800,
    total_payment_processed_count: 1184,
    total_payment_processed_count_without_smart_retries: 1100,
  },
];

// ---------------------------------------------------------------------------
// Row builders
// ---------------------------------------------------------------------------

// General-metrics aggregate (Payments Overview cards).
const OVERVIEW_ROW = {
  payment_success_rate: 92.5,
  payment_count: 1280,
  payment_success_count: 1184,
  connector_success_rate: 95.3,
};

// Amount-metrics aggregate (Processed Amount / Avg Ticket Size cards).
const AMOUNT_ROW = {
  currency: CURRENCY,
  payment_success_rate: 92.5,
  avg_ticket_size: 8750,
  payment_processed_amount: 5234000,
};

// Smart-retry aggregate (Smart Retries section cards).
const SMART_RETRY_ROW = {
  successful_smart_retries: 312,
  total_smart_retries: 480,
  smart_retried_amount: 1845000,
};

// Authorised-uncaptured count is read off the status-grouped "authorized" row.
function statusRows(withBucket: boolean): Array<Record<string, unknown>> {
  const rows = [
    { status: "authorized", payment_count: 42 },
    { status: "charged", payment_count: 1184 },
    { status: "failure", payment_count: 96 },
  ];
  return withBucket
    ? rows.map((r) => ({ ...r, time_bucket: FROZEN_BUCKET }))
    : rows;
}

// Per-connector rows for the Payments Trends chart + summary table.
function connectorRows(withBucket: boolean): Array<Record<string, unknown>> {
  const rows = CONNECTORS.map((connector, i) => ({
    connector,
    payment_success_rate: 94.2 - i * 3,
    payment_count: 820 - i * 180,
    payment_success_count: 772 - i * 170,
  }));
  return withBucket
    ? rows.map((r) => ({ ...r, time_bucket: FROZEN_BUCKET }))
    : rows;
}

// Sample values per groupable dimension, used to render the Payments Trends
// summary table whenever a Trends tab other than Connector is selected.
const DIMENSION_SAMPLES: Record<string, string[]> = {
  payment_method: ["card", "wallet"],
  payment_method_type: ["credit", "debit"],
  currency: ["USD", "EUR"],
  authentication_type: ["three_ds", "no_three_ds"],
  status: ["charged", "failure"],
  client_source: ["payment"],
  client_version: ["0.131.0"],
  profile_id: ["pro_playwright_test"],
  card_network: ["visa", "mastercard"],
  merchant_id: ["merchant_playwright"],
  routing_approach: ["default_fallback"],
};

// Per-dimension rows (the dimension column + the metric columns) for the
// Payments Trends summary table when grouped by `dim`.
function dimensionRows(
  dim: string,
  withBucket: boolean,
): Array<Record<string, unknown>> {
  const rows = (DIMENSION_SAMPLES[dim] ?? ["sample"]).map((value, i) => ({
    [dim]: value,
    payment_success_rate: 94.2 - i * 3,
    payment_count: 820 - i * 180,
    payment_success_count: 772 - i * 170,
  }));
  return withBucket
    ? rows.map((r) => ({ ...r, time_bucket: FROZEN_BUCKET }))
    : rows;
}

// Spread an aggregate row across every day bucket for the timeSeries query.
function asSeries(
  row: Record<string, unknown>,
): Array<Record<string, unknown>> {
  return dayBuckets().map((time_bucket) => ({ ...row, time_bucket }));
}

const wrap = (
  queryData: Array<Record<string, unknown>>,
  metaData = V1_META,
) => ({
  queryData,
  metaData,
});

// ---------------------------------------------------------------------------
// Dispatchers
// ---------------------------------------------------------------------------

function v1MetricsResponse(q: AnalyticsQuery) {
  const metrics: string[] = q.metrics ?? [];
  const groupBy: string[] = q.groupByNames ?? [];
  const isSeries = !!q.timeSeries;

  // Authorised Uncaptured card (payment_count grouped by status).
  if (groupBy.includes("status")) {
    return wrap(statusRows(isSeries));
  }

  // Amount Metrics cards (currency-grouped processed amount / avg ticket size).
  if (
    metrics.includes("payment_processed_amount") ||
    metrics.includes("avg_ticket_size")
  ) {
    return wrap(isSeries ? asSeries(AMOUNT_ROW) : [AMOUNT_ROW]);
  }

  // Payments Trends chart + summary table (connector-grouped).
  if (groupBy.includes("connector")) {
    return wrap(connectorRows(isSeries));
  }

  // Secondary payment_count-by-currency queries.
  if (metrics.length === 1 && metrics[0] === "payment_count") {
    const row = { currency: CURRENCY, payment_count: 1280 };
    return wrap(isSeries ? asSeries(row) : [row]);
  }

  // Payments Trends summary table / chart grouped by any other single dimension
  // (Payment Method, Currency, Authentication Type, …) — when a Trends tab is
  // switched. Keyed so the table's first column renders the dimension values.
  if (groupBy.length === 1 && DIMENSION_SAMPLES[groupBy[0]]) {
    return wrap(dimensionRows(groupBy[0], isSeries));
  }

  // General Metrics cards (Payments Overview, no groupBy).
  return wrap(isSeries ? asSeries(OVERVIEW_ROW) : [OVERVIEW_ROW]);
}

function v2MetricsResponse(q: AnalyticsQuery) {
  const groupBy: string[] = q.groupByNames ?? [];
  const isSeries = !!q.timeSeries;
  const row = groupBy.includes("currency")
    ? { currency: CURRENCY, ...SMART_RETRY_ROW }
    : SMART_RETRY_ROW;
  return {
    queryData: isSeries
      ? asSeries({ currency: CURRENCY, ...SMART_RETRY_ROW })
      : [row],
    metaData: V2_META,
  };
}

// ===========================================================================
// Route registration
// ===========================================================================

// Intercepts and overrides every API the Payments Analytics page calls on load
// so the whole page renders with canned, non-zero data. Register before the
// page navigates (i.e. before loginAndVisit opens the analytics route).
export async function mockPaymentAnalytics(page: Page): Promise<void> {
  // Order list — return a non-empty list so the page never drops to its Custom
  // (no-data) screen state.
  await page.route(/\/payments\/list/, (route) =>
    json(route, {
      size: 1,
      data: [{ payment_id: "pay_playwright_mock", status: "succeeded" }],
    }),
  );

  // Metric + dimension catalogue.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/payments\/info/,
    (route) => json(route, PAYMENTS_INFO),
  );

  // Dimension filter values.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/payments/,
    (route) => json(route, FILTER_VALUES),
  );

  // v2 metrics (smart retries) — register before the v1 catch-all so the more
  // specific path wins.
  await page.route(
    /\/analytics\/v2\/(org|merchant|profile)\/metrics\/payments/,
    (route) => json(route, v2MetricsResponse(firstQuery(route))),
  );

  // v1 metrics (overview / amount / status / connector).
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/payments/,
    (route) => json(route, v1MetricsResponse(firstQuery(route))),
  );
}

// Fails every analytics endpoint with HTTP 500 so the page's getPaymetsDetails
// catch block flips PageLoaderWrapper to its Error state (the DefaultLandingPage
// "Oops, we hit a little bump on the road!" view). The order-list call is the
// first request the page makes, so failing it short-circuits straight to Error.
export async function mockPaymentAnalyticsError(page: Page): Promise<void> {
  const fail = (route: Route) =>
    route.fulfill({
      status: 500,
      contentType: "application/json",
      body: JSON.stringify({
        error: { type: "server_error", message: "Internal Server Error" },
      }),
    });

  await page.route(/\/payments\/list/, fail);
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/payments\/info/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/payments/,
    fail,
  );
  await page.route(
    /\/analytics\/v2\/(org|merchant|profile)\/metrics\/payments/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/payments/,
    fail,
  );
}

export default mockPaymentAnalytics;
