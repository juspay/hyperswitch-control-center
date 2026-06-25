import type { Page, Route } from "@playwright/test";

// ---------------------------------------------------------------------------
// Routing Analytics (New Analytics) API mocks (/dashboard/analytics-routing)
//
// The Routing Analytics page is feature-flag gated (`routing_analytics`) and
// renders four KPI cards, two distribution pie charts, a routing-logic summary
// table and two trend line charts. A freshly signed-up org has no transactions,
// so every widget renders empty / "No Data". These helpers intercept every
// endpoint the page fires on load and return canned, non-zero data so each
// section shows realistic, VISIBLE values (or, when a failing setup is supplied,
// the page's Error state).
//
// Endpoints fired on page open (scope = org | merchant | profile):
//   GET  analytics/v1/{scope}/routing/info       -> dimension catalogue (drives
//                                                   the TopFilterUI tabs/filters)
//   POST analytics/v1/{scope}/filters/routing    -> dimension filter values
//   POST analytics/v1/{scope}/metrics/routing    -> KPI cards / distribution /
//                                                   summary / trends (dispatched
//                                                   on metrics + groupByNames +
//                                                   timeSeries)
//   POST analytics/v2/{scope}/metrics/payments   -> First Attempt Authorization
//                                                   Rate card (reads metaData)
//   POST analytics/v1/{scope}/metrics/payments   -> Total Failure card (two
//                                                   calls: status=failure + total)
//
// Each metrics request is a single-element array `[{ timeRange, metrics,
// groupByNames, timeSeries, filters, ... }]`; the routing handler dispatches on
// those keys to return the matching canned rows.
// ---------------------------------------------------------------------------

// Frozen "now" for deterministic analytics. Tests pin the browser clock to this
// instant (page.clock.setFixedTime) so the app's default date range ends on the
// same fixed day the canned day-wise buckets are derived from.
export const FROZEN_NOW = "2026-05-15T12:00:00.000Z";

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
const ROUTING_APPROACHES = ["default_fallback", "rule_based", "volume_split"];
const CARD_NETWORKS = ["Visa", "Mastercard"];

// Every calendar day in a wide window around the frozen clock, as the exact
// G_ONEDAY bucket prefix the trend charts plot ("YYYY-MM-DD"). Covering every
// day guarantees a non-zero point for whatever range the page requests.
function dayBuckets(): string[] {
  const out: string[] = [];
  const start = Date.UTC(2026, 3, 1); // 2026-04-01
  const end = Date.UTC(2026, 5, 30); // 2026-06-30
  for (let t = start; t <= end; t += 86400000) {
    out.push(new Date(t).toISOString().slice(0, 10));
  }
  return out;
}

// ===========================================================================
// Canned responses
// ===========================================================================

// GET analytics/v1/{scope}/routing/info — the dimension catalogue. The page
// drops "currency" from the dimensions (filterCurrencyFromDimensions); the rest
// become the TopFilterUI tabs and the "Add Filters" popup options.
const ROUTING_INFO = {
  metrics: [
    "payment_success_rate",
    "payment_count",
    "payment_success_count",
    "payment_processed_amount",
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

// POST analytics/v1/{scope}/filters/routing — selectable values per dimension,
// surfaced in the expanded "Add Filters" sub-dropdowns.
const FILTER_VALUES = {
  queryData: [
    { dimension: "connector", values: CONNECTORS },
    { dimension: "payment_method", values: ["card", "wallet"] },
    { dimension: "payment_method_type", values: ["credit", "debit"] },
    { dimension: "authentication_type", values: ["no_three_ds", "three_ds"] },
    { dimension: "status", values: ["charged", "failure", "authorized"] },
    { dimension: "client_source", values: ["Payment"] },
    { dimension: "client_version", values: ["0.131.0"] },
    { dimension: "profile_id", values: ["pro_playwright_test"] },
    { dimension: "card_network", values: ["Visa", "Mastercard"] },
    { dimension: "merchant_id", values: ["merchant_playwright"] },
    { dimension: "routing_approach", values: ROUTING_APPROACHES },
  ],
};

const wrap = (
  queryData: Array<Record<string, unknown>>,
  metaData: Array<Record<string, unknown>> = [{}],
) => ({
  queryData,
  metaData,
});

// ---------------------------------------------------------------------------
// Row builders
// ---------------------------------------------------------------------------

// Connector Volume Distribution pie (payment_count grouped by connector).
function connectorVolumeRows(): Array<Record<string, unknown>> {
  return CONNECTORS.map((connector, i) => ({
    connector,
    payment_count: 820 - i * 180,
  }));
}

// Routing Logic Distribution pie (payment_count grouped by routing_approach).
function routingApproachDistRows(): Array<Record<string, unknown>> {
  return ROUTING_APPROACHES.map((routing_approach, i) => ({
    routing_approach,
    payment_count: 900 - i * 250,
  }));
}

// Summary table — connector + routing_approach grouping (drives the expandable
// per-connector detail rows). Amounts are minor units (÷100 on display).
function summaryConnectorRoutingRows(): Array<Record<string, unknown>> {
  const rows: Array<Record<string, unknown>> = [];
  ROUTING_APPROACHES.forEach((routing_approach, ri) => {
    CONNECTORS.forEach((connector, ci) => {
      const count = 300 - ri * 60 - ci * 40;
      rows.push({
        routing_approach,
        connector,
        payment_count: count,
        payment_processed_amount: count * 10000,
        payment_processed_amount_in_usd: count * 10000,
        payment_success_rate: 94.2 - ci * 3,
      });
    });
  });
  return rows;
}

// Summary table — routing_approach grouping (the top-level summary rows).
function summaryRoutingRows(): Array<Record<string, unknown>> {
  return ROUTING_APPROACHES.map((routing_approach, i) => {
    const count = 700 - i * 150;
    return {
      routing_approach,
      payment_count: count,
      payment_processed_amount: count * 10000,
      payment_processed_amount_in_usd: count * 10000,
      payment_success_rate: 92.5 - i * 4,
    };
  });
}

// Trends — "Success Over Time" line (payment_success_rate grouped by connector,
// one row per connector per day bucket).
function routingSuccessSeries() {
  const queryData: Array<Record<string, unknown>> = [];
  dayBuckets().forEach((day, i) => {
    CONNECTORS.forEach((connector, ci) => {
      queryData.push({
        connector,
        payment_success_rate: 85 + ((i + ci * 5) % 12),
        time_bucket: `${day} 00:00:00`,
      });
    });
  });
  return wrap(queryData);
}

// Trends — "Volume Over Time" line (payment_count grouped by connector).
function routingVolumeSeries() {
  const queryData: Array<Record<string, unknown>> = [];
  dayBuckets().forEach((day, i) => {
    CONNECTORS.forEach((connector, ci) => {
      queryData.push({
        connector,
        payment_count: 100 + ((i + ci * 7) % 20) * 5,
        time_bucket: `${day} 00:00:00`,
      });
    });
  });
  return wrap(queryData);
}

// ---------------------------------------------------------------------------
// Least Cost Routing tab row builders (sessionized_debit_routing metric)
// ---------------------------------------------------------------------------

// Basic metrics card — "Total Savings" + "Debit Routed Transactions" (no
// groupBy; the page sums these fields). Amount is minor units (÷100 on display).
function leastCostBasicRows(): Array<Record<string, unknown>> {
  return [
    {
      debit_routing_savings_in_usd: 1845000,
      debit_routed_transaction_count: 920,
    },
  ];
}

// Regulation card — "Regulated / Unregulated Transactions Percentage" (grouped
// by is_issuer_regulated).
function leastCostRegulationRows(): Array<Record<string, unknown>> {
  return [
    { is_issuer_regulated: true, debit_routed_transaction_count: 600 },
    { is_issuer_regulated: false, debit_routed_transaction_count: 320 },
  ];
}

// Volume Distribution pie (grouped by card_network).
function leastCostDistributionRows(): Array<Record<string, unknown>> {
  return CARD_NETWORKS.map((card_network, i) => {
    const count = 600 - i * 280;
    return {
      card_network,
      debit_routed_transaction_count: count,
      debit_routing_savings_in_usd: count * 2000,
    };
  });
}

// Summary table (grouped by card_network, signature_network, is_issuer_regulated).
function leastCostSummaryRows(): Array<Record<string, unknown>> {
  const rows: Array<Record<string, unknown>> = [];
  CARD_NETWORKS.forEach((card_network, i) => {
    [true, false].forEach((isRegulated) => {
      const count = isRegulated ? 200 - i * 80 : 100 - i * 40;
      rows.push({
        card_network,
        signature_network: card_network,
        is_issuer_regulated: isRegulated,
        debit_routed_transaction_count: count,
        debit_routing_savings_in_usd: count * 2000,
      });
    });
  });
  return rows;
}

// "Savings over time" line (granularity; one point per day bucket).
function leastCostSavingsSeries() {
  const queryData = dayBuckets().map((day, i) => ({
    time_bucket: `${day} 00:00:00`,
    debit_routing_savings_in_usd: 50000 + (i % 14) * 12000,
  }));
  return wrap(queryData);
}

// ---------------------------------------------------------------------------
// Dispatchers
// ---------------------------------------------------------------------------

// POST analytics/v1/{scope}/metrics/routing — every routing widget hits this
// endpoint; dispatch on the request shape.
function routingMetricsResponse(route: Route) {
  const q = firstQuery(route);
  const metrics: string[] = q.metrics ?? [];
  const groupBy: string[] = q.groupByNames ?? [];
  const hasGranularity = q.timeSeries != null || q.granularity != null;

  // Trend line charts (granularity). Success-rate vs volume differ only by metric.
  if (hasGranularity) {
    return metrics.includes("payment_success_rate")
      ? routingSuccessSeries()
      : routingVolumeSeries();
    return metrics.includes("payment_success_rate")
      ? routingSuccessSeries()
      : routingVolumeSeries();
  }

  // Summary table — connector + routing_approach grouping (the expandable detail).
  if (groupBy.includes("connector") && groupBy.includes("routing_approach")) {
    return wrap(summaryConnectorRoutingRows());
  }

  // routing_approach grouping — summary rows (with processed amount) vs the
  // Routing Logic Distribution pie (payment_count only).
  if (groupBy.includes("routing_approach")) {
    return metrics.includes("payment_processed_amount")
      ? wrap(summaryRoutingRows())
      : wrap(routingApproachDistRows());
  }

  // Connector Volume Distribution pie (payment_count grouped by connector).
  if (groupBy.includes("connector")) {
    return wrap(connectorVolumeRows());
  }

  // Total Successful card (payment_success_count + payment_count, no groupBy).
  if (metrics.includes("payment_success_count")) {
    return wrap([{ payment_success_count: 1184, payment_count: 1280 }]);
  }

  // Overall Authorization Rate card (payment_success_rate, no groupBy).
  return wrap([{ payment_success_rate: 92.5 }]);
}

// POST analytics/v2/{scope}/metrics/payments — First Attempt Authorization Rate
// card reads metaData[0].total_success_rate_without_smart_retries.
function routingPaymentsV2Response() {
  return {
    queryData: [],
    metaData: [{ total_success_rate_without_smart_retries: 86.4 }],
  };
  return {
    queryData: [],
    metaData: [{ total_success_rate_without_smart_retries: 86.4 }],
  };
}

// POST analytics/v1/{scope}/metrics/payments — serves both the Overall Routing
// Total Failure card and the entire Least Cost Routing tab (which queries this
// endpoint with the sessionized_debit_routing metric).
function routingPaymentsV1Response(route: Route) {
  const q = firstQuery(route);
  const metrics: string[] = q.metrics ?? [];
  const groupBy: string[] = q.groupByNames ?? [];
  const hasGranularity = q.timeSeries != null || q.granularity != null;

  // Least Cost Routing tab — debit-routing widgets.
  if (metrics.includes("sessionized_debit_routing")) {
    if (hasGranularity) return leastCostSavingsSeries();
    if (groupBy.includes("signature_network"))
      return wrap(leastCostSummaryRows());
    if (groupBy.includes("is_issuer_regulated"))
      return wrap(leastCostRegulationRows());
    if (groupBy.includes("card_network"))
      return wrap(leastCostDistributionRows());
    if (groupBy.includes("signature_network"))
      return wrap(leastCostSummaryRows());
    if (groupBy.includes("is_issuer_regulated"))
      return wrap(leastCostRegulationRows());
    if (groupBy.includes("card_network"))
      return wrap(leastCostDistributionRows());
    return wrap(leastCostBasicRows());
  }

  // Overall Routing tab — Total Failure card fires two calls: one filtered to
  // status=failure (the failed count) and one for the total transaction count.
  const raw = route.request().postData() ?? "";
  const isFailure = raw.includes("failure");
  return wrap([{ payment_count: isFailure ? 96 : 1280 }]);
}

// ===========================================================================
// Route registration
// ===========================================================================

// Intercepts and overrides every API the Routing Analytics page calls on load
// so the whole page renders with canned, non-zero data. Register before the
// page navigates (i.e. before loginAndVisit opens the analytics route).
export async function mockRoutingAnalytics(page: Page): Promise<void> {
  // Dimension catalogue.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/routing\/info/,
    (route) => json(route, ROUTING_INFO),
    await page.route(
      /\/analytics\/v1\/(org|merchant|profile)\/routing\/info/,
      (route) => json(route, ROUTING_INFO),
    );

  // Dimension filter values.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/routing/,
    (route) => json(route, FILTER_VALUES),
    await page.route(
      /\/analytics\/v1\/(org|merchant|profile)\/filters\/routing/,
      (route) => json(route, FILTER_VALUES),
    );

  // v2 payments metrics (FAAR card).
  await page.route(
    /\/analytics\/v2\/(org|merchant|profile)\/metrics\/payments/,
    (route) => json(route, routingPaymentsV2Response()),
    await page.route(
      /\/analytics\/v2\/(org|merchant|profile)\/metrics\/payments/,
      (route) => json(route, routingPaymentsV2Response()),
    );

  // v1 payments metrics (Total Failure card).
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/payments/,
    (route) => json(route, routingPaymentsV1Response(route)),
    await page.route(
      /\/analytics\/v1\/(org|merchant|profile)\/metrics\/payments/,
      (route) => json(route, routingPaymentsV1Response(route)),
    );

  // v1 routing metrics (cards / distribution / summary / trends).
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/routing/,
    (route) => json(route, routingMetricsResponse(route)),
    await page.route(
      /\/analytics\/v1\/(org|merchant|profile)\/metrics\/routing/,
      (route) => json(route, routingMetricsResponse(route)),
    );
}

// Fails the routing info endpoint (and every metric endpoint) with HTTP 500 so
// OverallRoutingAnalytics's loadInfo catch block flips PageLoaderWrapper to its
// Error state (the DefaultLandingPage "Oops, we hit a little bump on the road!"
// view), rather than rendering the metric sections.
export async function mockRoutingAnalyticsError(page: Page): Promise<void> {
  const fail = (route: Route) =>
    route.fulfill({
      status: 500,
      contentType: "application/json",
      body: JSON.stringify({
        error: { type: "server_error", message: "Internal Server Error" },
      }),
      body: JSON.stringify({
        error: { type: "server_error", message: "Internal Server Error" },
      }),
    });

  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/routing\/info/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/routing/,
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
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/routing/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/routing\/info/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/routing/,
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
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/routing/,
    fail,
  );
}

export default mockRoutingAnalytics;
