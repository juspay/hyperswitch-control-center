import type { Page, Route } from "@playwright/test";

// ---------------------------------------------------------------------------
// Insights (New Analytics) API mocks
//
// The Insights page (/dashboard/new-analytics) renders Payments / Smart Retries
// / Refunds tabs. In the Playwright environment a freshly signed-up org has no
// transactions, so every widget renders empty / "0 USD". These helpers
// intercept the analytics endpoints and return canned data so every section
// shows realistic, VISIBLE values.
//
//   GET/POST analytics/v1/{scope}/filters/payments  -> dimension filters (CAPTURED_FILTERS)
//   POST     analytics/v2/{scope}/metrics/payments  (ANALYTICS_PAYMENTS_V2)
//        - Overview cards            metrics:[sessionized_*], delta:true, no granularity -> CAPTURED_OVERVIEW
//        - Authorised/Uncaptured     metrics:[sessionized_payment_intent_count], groupBy:status -> CAPTURED_STATUS_COUNTS
//        - Payments Processed (line) metrics:[sessionized_payment_processed_amount], timeSeries -> paymentsProcessedSeries()
//        - Payments Success Rate     metrics:[sessionized_payments_success_rate], timeSeries    -> paymentsSuccessRateSeries()
//   POST     analytics/v1/{scope}/metrics/payments  (ANALYTICS_PAYMENTS)
//        - Successful/Failed Distrib metrics:[payments_distribution], groupBy:connector -> paymentsDistributionData()
//        - Failure Reasons (table)   metrics:[failure_reasons], groupBy:error_reason     -> CAPTURED_FAILURE_REASONS
//   POST     analytics/v1/{scope}/metrics/refunds   (ANALYTICS_REFUNDS) -> CAPTURED_REFUNDS_OVERVIEW / synthetic
//   POST     analytics/v1/{scope}/metrics/disputes  (ANALYTICS_DISPUTES) -> CAPTURED_DISPUTES
//   POST     analytics/v1/{scope}/metrics/sankey    (ANALYTICS_SANKEY)   -> CAPTURED_SANKEY (BARE ARRAY)
//
// WHY THE LINE CHARTS ARE GENERATED (not a fixed captured row):
//   The line tiles request granularity G_ONEDAY and, when the `granularity`
//   feature flag is OFF (as in tests), key each row by its raw `time_bucket`
//   and back-fill EVERY bucket in the selected date range with the exact string
//   `YYYY-MM-DD 00:00:00` (see NewAnalyticsUtils.fillForMissingTimeRange +
//   getFormat). A row only contributes a non-zero point if its `time_bucket`
//   matches one of those generated strings. A single fixed-date capture (e.g.
//   2026-05-31) falls outside the frozen 2026-05-15 window, so every point is
//   back-filled to 0 and the line looks empty. We therefore emit one row per
//   calendar day across a wide window in that exact format, so whatever range
//   the page requests, every plotted bucket finds a non-zero match.
//
// {scope} is one of org | merchant | profile depending on the user's
// analyticsEntity, so every route uses a regex covering all three.
// ---------------------------------------------------------------------------

// Frozen "now" for deterministic analytics. Tests pin the browser clock to this
// instant (page.clock.setFixedTime) so the app's default date range ends on the
// same fixed day.
export const FROZEN_NOW = "2026-05-15T12:00:00.000Z";
// Day-aligned bucket for single-point grouped responses (distribution / reasons).
const FROZEN_BUCKET = "2026-05-15 00:00:00";

const json = (route: Route, body: unknown) =>
  route.fulfill({
    status: 200,
    contentType: "application/json",
    body: JSON.stringify(body),
  });

// Returns the first element of the analytics request body (the body is a
// single-element array `[{ timeRange, metrics, groupByNames, timeSeries, ... }]`).
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

const CONNECTORS = ["stripe", "adyen", "checkout", "cybersource"];

// ===========================================================================
// Time-series buckets for the line tiles
// ===========================================================================

// Every calendar day in a wide window around the frozen clock, expressed as the
// EXACT G_ONEDAY bucket string the app generates ("YYYY-MM-DD 00:00:00"). The
// app keys rows by this string (granularity flag off) and back-fills the
// selected range — covering every day guarantees a match for whatever range the
// page requests, so the whole line plots non-zero.
function dayBuckets(): Array<{ day: string; i: number }> {
  const out: Array<{ day: string; i: number }> = [];
  const start = Date.UTC(2026, 3, 1); // 2026-04-01
  const end = Date.UTC(2026, 5, 30); // 2026-06-30
  let i = 0;
  for (let t = start; t <= end; t += 86400000, i++) {
    const day = new Date(t).toISOString().slice(0, 10); // YYYY-MM-DD
    out.push({ day, i });
  }
  return out;
}

// ===========================================================================
// Captured / canned responses
// ===========================================================================

// GET/POST analytics/v1/org/filters/payments
const CAPTURED_FILTERS = {
  queryData: [
    { dimension: "connector", values: ["stripe"] },
    { dimension: "payment_method", values: ["card"] },
    { dimension: "payment_method_type", values: ["credit"] },
    { dimension: "currency", values: ["USD"] },
    { dimension: "authentication_type", values: ["no_three_ds", "three_ds"] },
    {
      dimension: "status",
      values: ["failure", "charged", "payment_method_awaited", "authorized"],
    },
    { dimension: "client_source", values: ["Payment"] },
    { dimension: "client_version", values: ["0.131.0"] },
    { dimension: "profile_id", values: ["pro_EnYdFVZ02nQ5R03pB8Ao"] },
    { dimension: "card_network", values: ["Visa", ""] },
    { dimension: "merchant_id", values: ["merchant_1715600622"] },
    { dimension: "routing_approach", values: ["default_fallback"] },
  ],
};

// GET analytics/v1/org/payments/info — dimensions list consumed by the
// flag-gated InsightsAnalyticsFilters component (new_analytics_filters). The
// component only fires its filter request once dimensions is non-empty, so this
// must resolve for the currency dropdown to leave its loading state.
const CAPTURED_PAYMENTS_INFO = {
  dimensions: [
    { name: "connector" },
    { name: "payment_method" },
    { name: "payment_method_type" },
    { name: "authentication_type" },
    { name: "currency" },
    { name: "status" },
  ],
};

// POST analytics/v2/org/metrics/payments — overview (delta, no granularity).
// Overview cards read metaData[0]; amounts are cents (÷100 on display).
const CAPTURED_OVERVIEW = {
  queryData: [],
  metaData: [
    {
      total_success_rate: 88.0,
      total_success_rate_without_smart_retries: 82.0,
      // Total Payment Savings card -> total_smart_retried_amount_in_usd (=> USD 18,500).
      total_smart_retried_amount: 1850000,
      total_smart_retried_amount_without_smart_retries: 1850000,
      total_smart_retried_amount_in_usd: 1850000,
      total_smart_retried_amount_without_smart_retries_in_usd: 1850000,
      // Total Payments Processed card -> total_payment_processed_amount_in_usd (=> USD 524,000).
      total_payment_processed_amount: 52400000,
      total_payment_processed_amount_without_smart_retries: 47000000,
      total_payment_processed_amount_in_usd: 52400000,
      total_payment_processed_amount_without_smart_retries_in_usd: 47000000,
      total_payment_processed_count: 5200,
      total_payment_processed_count_without_smart_retries: 4700,
    },
  ],
};

// POST analytics/v2/org/metrics/payments — "Payments Processed" line tile.
// Chart reads queryData rows: Y = payment_processed_amount_in_usd (default
// currency all_currencies, smart-retry on; amount ÷100 on display), X = time_bucket.
function paymentsProcessedSeries() {
  const queryData = dayBuckets().map(({ day, i }) => {
    const amount = 4000000 + (i % 14) * 850000; // cents -> ~$40k..$150k
    const count = 120 + (i % 14) * 18;
    const noRetryAmount = Math.round(amount * 0.9);
    return {
      time_bucket: `${day} 00:00:00`,
      time_range: {
        start_time: `${day}T12:00:00.000Z`,
        end_time: `${day}T12:00:00.000Z`,
      },
      currency: "USD",
      payment_processed_amount: amount,
      payment_processed_amount_in_usd: amount,
      payment_processed_count: count,
      payment_processed_amount_without_smart_retries: noRetryAmount,
      payment_processed_amount_without_smart_retries_in_usd: noRetryAmount,
      payment_processed_count_without_smart_retries: Math.round(count * 0.9),
    };
  });
  return {
    queryData,
    metaData: [
      {
        total_success_rate: null,
        total_smart_retried_amount: 1850000,
        total_smart_retried_amount_in_usd: 1850000,
        total_payment_processed_amount: 52400000,
        total_payment_processed_amount_in_usd: 52400000,
        total_payment_processed_amount_without_smart_retries: 47000000,
        total_payment_processed_amount_without_smart_retries_in_usd: 47000000,
        total_payment_processed_count: 5200,
        total_payment_processed_count_without_smart_retries: 4700,
      },
    ],
  };
}

// POST analytics/v2/org/metrics/payments — "Payments Success Rate" line tile.
// Chart reads queryData rows: Y = payments_success_rate (percentage, NOT an
// amount so no ÷100), X = time_bucket.
function paymentsSuccessRateSeries() {
  const queryData = dayBuckets().map(({ day, i }) => {
    const rate = 80 + ((i * 7) % 18); // 80..97 %
    const count = 120 + (i % 14) * 18;
    return {
      time_bucket: `${day} 00:00:00`,
      time_range: {
        start_time: `${day}T12:00:00.000Z`,
        end_time: `${day}T12:00:00.000Z`,
      },
      currency: null,
      payments_success_rate: rate,
      payments_success_rate_without_smart_retries: Math.max(0, rate - 6),
      successful_payments: Math.round((count * rate) / 100),
      successful_payments_without_smart_retries: Math.round(
        (count * (rate - 6)) / 100,
      ),
      total_payments: count,
    };
  });
  return {
    queryData,
    metaData: [
      {
        total_success_rate: 88.0,
        total_success_rate_without_smart_retries: 82.0,
        total_payment_processed_amount: 0,
        total_payment_processed_count: 0,
      },
    ],
  };
}

// POST analytics/v1/org/metrics/payments — payments_distribution (groupBy connector).
// Successful bar reads payments_success_rate_distribution; Failed bar reads
// payments_failure_rate_distribution; X category = connector. Rows with an empty
// groupBy value are dropped by the app, so every connector here is non-empty.
function paymentsDistributionData() {
  // Successful and Failed are SEPARATE charts reading independent keys, so both
  // sets of bars are made large & clearly varied (no 100-x complement, which
  // left the failure bars tiny). All values sit on the chart's 0–100 axis.
  const queryData = CONNECTORS.map((connector, i) => {
    const success = 95 - i * 12; // 95, 83, 71, 59  (Payments: Successful Distribution)
    const successNoRetry = 88 - i * 12; // 88, 76, 64, 52
    const successOnlyRetries = 90 - i * 10; // 90, 80, 70, 60  (Smart Retries: Successful)
    const failure = 82 - i * 14; // 82, 68, 54, 40  (Payments: Failed Distribution)
    const failureNoRetry = 76 - i * 14; // 76, 62, 48, 34
    const failureOnlyRetries = 70 - i * 12; // 70, 58, 46, 34  (Smart Retries: Failed)
    const count = 1200 - i * 220;
    return {
      connector,
      payment_method: "card",
      payment_method_type: "credit",
      authentication_type: "three_ds",
      payment_count: count,
      payment_success_count: Math.round((count * success) / 100),
      payments_success_rate_distribution: success,
      payments_success_rate_distribution_without_smart_retries: successNoRetry,
      payments_success_rate_distribution_with_only_retries: successOnlyRetries,
      payments_failure_rate_distribution: failure,
      payments_failure_rate_distribution_without_smart_retries: failureNoRetry,
      payments_failure_rate_distribution_with_only_retries: failureOnlyRetries,
      payment_processed_amount: 0,
      time_bucket: FROZEN_BUCKET,
    };
  });
  return {
    queryData,
    metaData: [
      {
        total_payment_processed_amount: 0,
        total_payment_processed_count: 0,
        total_failure_reasons_count: 0,
        total_failure_reasons_count_without_smart_retries: 0,
      },
    ],
  };
}

// POST analytics/v1/org/metrics/payments — failure_reasons (groupBy error_reason, connector)
const CAPTURED_FAILURE_REASONS = {
  queryData: [
    {
      failure_reason_count: 80,
      failure_reason_count_without_smart_retries: 80,
      connector: "stripe",
      error_reason: "Insufficient funds",
      total_failure_reasons_count: 180,
      time_bucket: FROZEN_BUCKET,
    },
    {
      failure_reason_count: 55,
      failure_reason_count_without_smart_retries: 55,
      connector: "adyen",
      error_reason: "Card declined",
      total_failure_reasons_count: 180,
      time_bucket: FROZEN_BUCKET,
    },
    {
      failure_reason_count: 45,
      failure_reason_count_without_smart_retries: 45,
      connector: "checkout",
      error_reason: "Expired card",
      total_failure_reasons_count: 180,
      time_bucket: FROZEN_BUCKET,
    },
  ],
  metaData: [
    {
      total_failure_reasons_count: 180,
      total_failure_reasons_count_without_smart_retries: 180,
    },
    {
      total_failure_reasons_count: 162,
      total_failure_reasons_count_without_smart_retries: 162,
    },
  ],
};

// POST analytics/v2/org/metrics/payments — intent count (groupBy status).
// Authorised/Uncaptured card reads the requires_capture row's payment_intent_count.
const CAPTURED_STATUS_COUNTS = {
  queryData: [
    {
      payment_intent_count: 4200,
      status: "succeeded",
      time_bucket: FROZEN_BUCKET,
    },
    {
      payment_intent_count: 320,
      status: "requires_capture",
      time_bucket: FROZEN_BUCKET,
    },
    { payment_intent_count: 600, status: "failed", time_bucket: FROZEN_BUCKET },
    {
      payment_intent_count: 180,
      status: "requires_payment_method",
      time_bucket: FROZEN_BUCKET,
    },
  ],
  metaData: [
    {
      total_success_rate: null,
      total_smart_retried_amount: 1850000,
      total_payment_processed_amount: 0,
      total_payment_processed_count: 0,
    },
  ],
};

// POST analytics/v1/org/metrics/refunds — overview (refund_processed_amount, no granularity)
const CAPTURED_REFUNDS_OVERVIEW = {
  queryData: [
    {
      refund_processed_amount: 2640000,
      refund_processed_amount_in_usd: 2640000,
      refund_reason_count: 0,
      refund_error_message_count: 0,
      currency: "USD",
      time_bucket: FROZEN_BUCKET,
    },
  ],
  metaData: [
    {
      total_refund_success_rate: 84.2,
      total_refund_processed_amount: 2640000,
      total_refund_processed_amount_in_usd: 2640000,
      total_refund_processed_count: 210,
      total_refund_reason_count: 0,
      total_refund_error_message_count: 0,
    },
  ],
};

// POST analytics/v1/org/metrics/disputes — time fields anchored to the frozen
// test clock (FROZEN_NOW) so the row lands inside the test's default date range.
const CAPTURED_DISPUTES = {
  queryData: [
    {
      disputes_challenged: 0,
      disputes_won: 0,
      disputes_lost: 0,
      disputed_amount: null,
      dispute_lost_amount: null,
      total_dispute: 6,
      dispute_stage: null,
      connector: null,
      currency: null,
      time_range: {
        start_time: "2026-05-01T18:30:00.000Z",
        end_time: FROZEN_NOW,
      },
      time_bucket: "2026-05-01 18:30:00",
    },
  ],
  metaData: [{ total_disputed_amount: 10, total_dispute_lost_amount: 10 }],
};

// POST analytics/v1/org/metrics/sankey — Payments Lifecycle funnel (BARE ARRAY).
// getTotalPayments must be > 0; links render only when their value > 0, so we
// supply positive counts across every lifecycle path (first_attempt 1 = normal,
// 0 = smart-retried; succeeded+refund/dispute drives the downstream nodes).
const CAPTURED_SANKEY = [
  {
    count: 60,
    status: "succeeded",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 18,
    status: "succeeded",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 0,
  },
  {
    count: 22,
    status: "failed",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 9,
    status: "failed",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 0,
  },
  {
    count: 14,
    status: "requires_payment_method",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 11,
    status: "requires_capture",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 7,
    status: "cancelled",
    refunds_status: null,
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 8,
    status: "succeeded",
    refunds_status: "partial_refunded",
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 5,
    status: "succeeded",
    refunds_status: "full_refunded",
    dispute_status: null,
    first_attempt: 1,
  },
  {
    count: 3,
    status: "succeeded",
    refunds_status: null,
    dispute_status: "dispute_present",
    first_attempt: 1,
  },
];

// ===========================================================================
// Synthetic fallback — Refunds tab line/bar charts + reasons table (not the
// focus of this change). Kept so the Refunds tab renders populated.
// ===========================================================================

function refundsMeta() {
  const primary = {
    total_refund_processed_amount: 2640000,
    total_refund_processed_amount_in_usd: 2640000,
    total_refund_processed_count: 210,
    total_refund_success_rate: 84.2,
  };
  const comparison = Object.fromEntries(
    Object.entries(primary).map(([k, v]) => [
      k,
      Math.round((v as number) * 0.9),
    ]),
  );
  return [primary, comparison];
}

function refundsTimeSeries() {
  const queryData = dayBuckets().map(({ day, i }) => {
    const amount = 120000 + (i % 14) * 30000;
    const count = 30 + (i % 14) * 6;
    const successRate = 78 + ((i * 5) % 20);
    return {
      time_bucket: `${day} 00:00:00`,
      time_range: {
        start_time: `${day}T12:00:00.000Z`,
        end_time: `${day}T12:00:00.000Z`,
      },
      currency: "USD",
      refund_processed_amount: amount,
      refund_processed_amount_in_usd: amount,
      refund_processed_count: count,
      refund_success_rate: successRate,
      successful_refunds: Math.round((count * successRate) / 100),
      total_refunds: count,
    };
  });
  return { queryData, metaData: refundsMeta() };
}

function refundsDistribution() {
  const queryData = CONNECTORS.map((connector, i) => ({
    connector,
    refund_success_rate_distribution: 92 - i * 5,
    refund_count: 90 - i * 12,
    refund_success_count: 80 - i * 12,
    time_bucket: FROZEN_BUCKET,
  }));
  return { queryData, metaData: refundsMeta() };
}

function refundsReasons() {
  const reasons = ["customer_request", "duplicate", "fraudulent", "other"];
  const queryData = reasons.map((reason, i) => ({
    refund_reason: reason,
    refund_error_message: [
      "processor_declined",
      "network_error",
      "timeout",
      "other",
    ][i % 4],
    connector: CONNECTORS[i % CONNECTORS.length],
    refund_reason_count: 40 - i * 8,
    total_refund_reason_count: 120,
    time_bucket: FROZEN_BUCKET,
  }));
  return { queryData, metaData: refundsMeta() };
}

// ===========================================================================
// Route handlers
// ===========================================================================

function handlePayments(route: Route) {
  const q = firstQuery(route);
  const metrics: string[] = q?.metrics ?? [];
  const groupBy: string[] = q?.groupByNames ?? [];
  // A true line-tile request carries timeSeries.granularity. The overview (delta)
  // request also lists the sessionized_* time-series metrics but has NO timeSeries,
  // so we must NOT key off metric names here.
  const hasGranularity = q?.timeSeries != null || q?.granularity != null;

  // v1 payments — distribution / failure reasons tables.
  if (metrics.includes("payments_distribution"))
    return json(route, paymentsDistributionData());
  if (metrics.includes("failure_reasons"))
    return json(route, CAPTURED_FAILURE_REASONS);

  // v2 payments — line tiles. Success-rate vs processed differ only by metric.
  if (hasGranularity) {
    const isSuccessRate = metrics.some(
      (m) =>
        m === "sessionized_payments_success_rate" ||
        m === "payments_success_rate",
    );
    return json(
      route,
      isSuccessRate ? paymentsSuccessRateSeries() : paymentsProcessedSeries(),
    );
  }

  // v2 payments — Authorised / Uncaptured intent count grouped by status.
  if (groupBy.includes("status")) return json(route, CAPTURED_STATUS_COUNTS);

  // v2 payments — overview totals (delta, no granularity).
  return json(route, CAPTURED_OVERVIEW);
}

function handleRefunds(route: Route) {
  const q = firstQuery(route);
  const groupBy: string[] = q?.groupByNames ?? [];
  const hasGranularity = q?.timeSeries != null || q?.granularity != null;

  if (hasGranularity) return json(route, refundsTimeSeries());
  if (
    groupBy.includes("refund_reason") ||
    groupBy.includes("refund_error_message")
  )
    return json(route, refundsReasons());
  if (groupBy.includes("connector")) return json(route, refundsDistribution());

  return json(route, CAPTURED_REFUNDS_OVERVIEW);
}

// ---------------------------------------------------------------------------
// Public helper — register all Insights analytics routes. Call BEFORE
// navigating to the page (routes must be in place before requests fire).
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Empty-data variant — every analytics endpoint returns no rows. Each line/bar
// tile checks `queryData.length > 0` and otherwise flips its screenState to
// Custom, rendering NewAnalyticsHelper.NoData ("No entries in the selected time
// period."). Used by the empty-state test.
// ---------------------------------------------------------------------------
const EMPTY_RESPONSE = { queryData: [], metaData: [{}] };

export async function mockInsightsEmptyAnalytics(page: Page): Promise<void> {
  // payments/info + filters still resolve so the page shell (filters, tabs)
  // renders normally; only the metric responses are empty.
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/payments\/info(\?|$)/,
    (route) => json(route, CAPTURED_PAYMENTS_INFO),
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/payments(\?|$)/,
    (route) => json(route, CAPTURED_FILTERS),
  );
  await page.route(
    /\/analytics\/v[12]\/(org|merchant|profile)\/metrics\/(payments|refunds|disputes)(\?|$)/,
    (route) => json(route, EMPTY_RESPONSE),
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/sankey(\?|$)/,
    (route) => json(route, []),
  );
}

// ---------------------------------------------------------------------------
// Error variant — every analytics metric endpoint fails with HTTP 500. The
// tiles catch the fetch error and degrade to their Custom/NoData state (the
// Insights tiles map API failures to NoData rather than a dedicated error
// screen), so the shell stays usable. Used by the error-state test.
// ---------------------------------------------------------------------------
export async function mockInsightsErrorAnalytics(page: Page): Promise<void> {
  const fail = (route: Route) =>
    route.fulfill({
      status: 500,
      contentType: "application/json",
      body: JSON.stringify({
        error: { type: "server_error", message: "Internal Server Error" },
      }),
    });
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/payments\/info(\?|$)/,
    (route) => json(route, CAPTURED_PAYMENTS_INFO),
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/payments(\?|$)/,
    (route) => json(route, CAPTURED_FILTERS),
  );
  await page.route(
    /\/analytics\/v[12]\/(org|merchant|profile)\/metrics\/(payments|refunds|disputes)(\?|$)/,
    fail,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/sankey(\?|$)/,
    fail,
  );
}

export async function mockInsightsAnalytics(page: Page): Promise<void> {
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/payments\/info(\?|$)/,
    (route) => json(route, CAPTURED_PAYMENTS_INFO),
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/filters\/payments(\?|$)/,
    (route) => json(route, CAPTURED_FILTERS),
  );
  await page.route(
    /\/analytics\/v2\/(org|merchant|profile)\/metrics\/payments(\?|$)/,
    handlePayments,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/payments(\?|$)/,
    handlePayments,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/refunds(\?|$)/,
    handleRefunds,
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/disputes(\?|$)/,
    (route) => json(route, CAPTURED_DISPUTES),
  );
  await page.route(
    /\/analytics\/v1\/(org|merchant|profile)\/metrics\/sankey(\?|$)/,
    (route) => json(route, CAPTURED_SANKEY),
  );
}

export default mockInsightsAnalytics;
