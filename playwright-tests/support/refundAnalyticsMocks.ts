import type { Page, Route } from "@playwright/test";

// ---------------------------------------------------------------------------
// Refunds Analytics API mocks (/dashboard/analytics-refunds)
//
// The Refunds Analytics page is built on the shared Analytics.res component
// (KPI single-stat cards + dimension tabs + a line chart + the "Payments
// Summary" table). A freshly signed-up org has no refunds, so the page drops
// to its Custom (NoData) state and every card/chart renders empty. These
// helpers intercept every endpoint the page fires on load and return canned,
// non-zero data so each section shows realistic, VISIBLE values.
//
// Endpoints fired on page open (scope = org | merchant | profile):
//   POST /refunds/list                                  -> refund list (gates
//                                                          the page's Custom
//                                                          (no-data) state)
//   GET  /analytics/v1/{scope}/refunds/info             -> metric + dimension
//                                                          catalogue
//   POST /analytics/v1/{scope}/filters/refunds          -> dimension filter
//                                                          values
//   POST /analytics/v1/{scope}/metrics/refunds          -> single-stat cards /
//                                                          table / chart stats
//
// Each metrics request is a single-element array `[{ timeRange, metrics,
// groupByNames, timeSeries, delta, ... }]`; the handler dispatches on
// `groupByNames` / `timeSeries` to return the matching canned rows. Both the
// delta query (the big number) and the timeSeries query (the line chart) are
// served — the delta rows drive the values the tests assert on.
// ---------------------------------------------------------------------------

// Frozen "now" for deterministic analytics. Tests pin the browser clock to this
// instant (page.clock.setFixedTime) so the app's default date range ends on the
// same fixed day.
export const FROZEN_NOW = "2026-05-15T12:00:00.000Z";
// Day-aligned bucket for single-point grouped responses.
const FROZEN_BUCKET = "2026-05-15 00:00:00";

const json = (route: Route, body: unknown) =>
  route.fulfill({
    status: 200,
    contentType: "application/json",
    body: JSON.stringify(body),
  });

// Returns the first element of an analytics request body (the body is a
// single-element array `[{ ... }]`); falls back to the raw object.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function firstQuery(route: Route): Record<string, any> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let body: any;
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

// GET /analytics/v1/{scope}/refunds/info — the metric + dimension catalogue
// that drives the dimension tabs and the "Add Filters" popup options.
const REFUNDS_INFO = {
  metrics: [
    "refund_success_rate",
    "refund_count",
    "refund_success_count",
    "refund_processed_amount",
  ].map((name) => ({ name, desc: "" })),
  downloadDimensions: null,
  dimensions: ["connector", "refund_method", "currency", "refund_status"].map(
    (name) => ({ name, desc: "" }),
  ),
};

// POST /analytics/v1/{scope}/filters/refunds — selectable values per dimension,
// surfaced in the expanded "Add Filters" sub-dropdowns.
const FILTER_VALUES = {
  queryData: [
    { dimension: "connector", values: CONNECTORS },
    { dimension: "refund_method", values: ["card", "wallet"] },
    { dimension: "currency", values: ["USD", "EUR"] },
    { dimension: "refund_status", values: ["success", "failure", "pending"] },
  ],
};

// ---------------------------------------------------------------------------
// Row builders
// ---------------------------------------------------------------------------

// Refund-overview aggregate (the single-stat KPI cards). refund_processed_amount
// is read off the *_in_usd field and divided by 100 in the UI.
const OVERVIEW_ROW = {
  refund_success_rate: 92.5,
  refund_count: 1280,
  refund_success_count: 1184,
  refund_processed_amount_in_usd: 5234000,
  refund_processed_amount: 5234000,
};

// Per-connector rows for the Refunds chart + summary table.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function connectorRows(withBucket: boolean): Array<Record<string, any>> {
  const rows = CONNECTORS.map((connector, i) => ({
    connector,
    refund_success_rate: 94.2 - i * 3,
    refund_count: 820 - i * 180,
    refund_success_count: 772 - i * 170,
  }));
  return withBucket
    ? rows.map((r) => ({ ...r, time_bucket: FROZEN_BUCKET }))
    : rows;
}

// Sample values per groupable dimension, used to render the summary table
// whenever a Trends tab other than Connector is selected.
const DIMENSION_SAMPLES: Record<string, string[]> = {
  refund_method: ["card", "wallet"],
  currency: ["USD", "EUR"],
  refund_status: ["success", "failure"],
};

// Per-dimension rows (the dimension column + the metric columns) for the
// summary table when grouped by `dim`.
function dimensionRows(
  dim: string,
  withBucket: boolean,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
): Array<Record<string, any>> {
  const rows = (DIMENSION_SAMPLES[dim] ?? ["sample"]).map((value, i) => ({
    [dim]: value,
    refund_success_rate: 94.2 - i * 3,
    refund_count: 820 - i * 180,
    refund_success_count: 772 - i * 170,
  }));
  return withBucket
    ? rows.map((r) => ({ ...r, time_bucket: FROZEN_BUCKET }))
    : rows;
}

// Spread an aggregate row across every day bucket for the timeSeries query.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function asSeries(row: Record<string, any>): Array<Record<string, any>> {
  return dayBuckets().map((time_bucket) => ({ ...row, time_bucket }));
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const wrap = (queryData: Array<Record<string, any>>) => ({
  queryData,
  metaData: [],
});

// ---------------------------------------------------------------------------
// Dispatcher
// ---------------------------------------------------------------------------

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function metricsResponse(q: Record<string, any>) {
  const groupBy: string[] = q.groupByNames ?? [];
  const isSeries = !!q.timeSeries;

  // Refunds chart + summary table (connector-grouped).
  if (groupBy.includes("connector")) {
    return wrap(connectorRows(isSeries));
  }

  // Summary table / chart grouped by any other single dimension (Refund
  // Method, Currency, Refund Status) — when a Trends tab is switched.
  if (groupBy.length === 1 && DIMENSION_SAMPLES[groupBy[0]]) {
    return wrap(dimensionRows(groupBy[0], isSeries));
  }

  // Single-stat KPI cards (refund overview, no groupBy).
  return wrap(isSeries ? asSeries(OVERVIEW_ROW) : [OVERVIEW_ROW]);
}

// ===========================================================================
// Route registration
// ===========================================================================

// Intercepts and overrides every API the Refunds Analytics page calls on load
// so the whole page renders with canned, non-zero data. Register before the
// page navigates (i.e. before loginAndVisit opens the analytics route).
export async function mockRefundAnalytics(page: Page): Promise<void> {
  // Refund list — return a non-empty list so the page never drops to its
  // Custom (no-data) screen state.
  await page.route(/\/refunds\/(profile\/)?list/, (route) =>
    json(route, {
      data: [{ refund_id: "ref_playwright_mock", status: "success" }],
    }),
  );

  // Metric + dimension catalogue.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/refunds\/info/,
    (route) => json(route, REFUNDS_INFO),
  );

  // Dimension filter values.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/refunds/,
    (route) => json(route, FILTER_VALUES),
  );

  // Metrics (single-stat cards / table / chart).
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/refunds/,
    (route) => json(route, metricsResponse(firstQuery(route))),
  );
}

// Fails every analytics endpoint with HTTP 500 so the page's getRefundDetails
// catch block flips PageLoaderWrapper to its Error state (the DefaultLandingPage
// "Oops, we hit a little bump on the road!" view). The refund-list call is the
// first request the page makes, so failing it short-circuits straight to Error.
export async function mockRefundAnalyticsError(page: Page): Promise<void> {
  const fail = (route: Route) =>
    route.fulfill({
      status: 500,
      contentType: "application/json",
      body: JSON.stringify({
        error: { type: "server_error", message: "Internal Server Error" },
      }),
    });

  await page.route(/\/refunds\/(profile\/)?list/, fail);
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/refunds\/info/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/refunds/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/refunds/,
    fail,
  );
}

export default mockRefundAnalytics;
