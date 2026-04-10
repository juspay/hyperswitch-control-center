open CustomDashboardTypes

type metricOption = {
  value: string,
  label: string,
  description: string,
  category: string,
}

type dimensionOption = {
  value: string,
  label: string,
}

type granularityOption = {
  value: string,
  label: string,
}

type chartTypeOption = {
  value: chartType,
  label: string,
  description: string,
  icon: string,
}

let chartTypeOptions: array<chartTypeOption> = [
  {value: LineChart, label: "Line", description: "Trends over time", icon: "chart-line"},
  {value: BarChart, label: "Bar", description: "Compare categories", icon: "chart-bar"},
  {value: ColumnChart, label: "Column", description: "Vertical bars", icon: "columns"},
  {value: PieChart, label: "Pie", description: "Distribution", icon: "chart-pie"},
  {value: StackedBarChart, label: "Stacked", description: "Composition", icon: "bars"},
  {value: FunnelChart, label: "Funnel", description: "Drop-off analysis", icon: "funnel-dollar"},
  {value: Table, label: "Table", description: "Tabular data view", icon: "table"},
  {value: StatNumber, label: "Number", description: "Single big stat value", icon: "stat-number"},
  {value: Gauge, label: "Gauge", description: "Percentage meter", icon: "gauge"},
]

let granularityOptions: array<granularityOption> = [
  {value: "G_ONEHOUR", label: "Hourly"},
  {value: "G_ONEDAY", label: "Daily"},
  {value: "G_ONEWEEK", label: "Weekly"},
]

// ════════════════════════════════════════
// PAYMENT METRICS
// ════════════════════════════════════════
let paymentMetrics: array<metricOption> = [
  {
    value: "sessionized_payment_processed_amount",
    label: "Payment Processed Amount",
    description: "Total amount of payments processed",
    category: "Volume",
  },
  {
    value: "sessionized_payment_count",
    label: "Payment Count",
    description: "Total number of payment attempts",
    category: "Volume",
  },
  {
    value: "sessionized_payment_success_count",
    label: "Payment Success Count",
    description: "Number of successful payments",
    category: "Volume",
  },
  {
    value: "sessionized_payment_success_rate",
    label: "Payment Success Rate",
    description: "Percentage of successful payments",
    category: "Performance",
  },
  {
    value: "sessionized_avg_ticket_size",
    label: "Avg Ticket Size",
    description: "Average payment amount per transaction",
    category: "Performance",
  },
  {
    value: "sessionized_connector_success_rate",
    label: "Connector Success Rate",
    description: "Success rate by connector",
    category: "Performance",
  },
  {
    value: "sessionized_retries_count",
    label: "Retries Count",
    description: "Number of payment retries",
    category: "Volume",
  },
  {
    value: "payment_success_rate",
    label: "Success Rate (Non-Sessionized)",
    description: "Raw success rate without session grouping",
    category: "Performance",
  },
  {
    value: "payment_count",
    label: "Payment Count (Non-Sessionized)",
    description: "Raw payment count",
    category: "Volume",
  },
  {
    value: "payment_processed_amount",
    label: "Processed Amount (Non-Sessionized)",
    description: "Raw processed amount",
    category: "Volume",
  },
  {
    value: "payment_success_count",
    label: "Success Count (Non-Sessionized)",
    description: "Raw success count",
    category: "Volume",
  },
  {
    value: "avg_ticket_size",
    label: "Avg Ticket Size (Non-Sessionized)",
    description: "Raw average ticket size",
    category: "Performance",
  },
  {
    value: "retries_count",
    label: "Retries Count (Non-Sessionized)",
    description: "Raw retries count",
    category: "Volume",
  },
  {
    value: "connector_success_rate",
    label: "Connector Success Rate (Non-Sessionized)",
    description: "Raw connector success rate",
    category: "Performance",
  },
  {
    value: "debit_routing",
    label: "Debit Routing (Non-Sessionized)",
    description: "Raw debit routing metric",
    category: "Routing",
  },
  {
    value: "payments_distribution",
    label: "Payments Distribution",
    description: "Distribution of payments by selected dimension",
    category: "Distribution",
  },
  {
    value: "failure_reasons",
    label: "Failure Reasons",
    description: "Top reasons for payment failures",
    category: "Failures",
  },
  // PaymentIntent metrics (V2 API — used by Insights overview)
  {
    value: "sessionized_payments_success_rate",
    label: "Payments Success Rate (V2)",
    description: "Success rate from payment intents (V2 API)",
    category: "Performance (V2)",
  },
  {
    value: "sessionized_payment_intent_count",
    label: "Payment Intent Count (V2)",
    description: "Total payment intents count (V2 API)",
    category: "Volume (V2)",
  },
  {
    value: "sessionized_payment_processed_amount",
    label: "Processed Amount (V2)",
    description: "Processed amount from payment intents (V2 API)",
    category: "Volume (V2)",
  },
  {
    value: "sessionized_smart_retried_amount",
    label: "Smart Retried Amount (V2)",
    description: "Amount recovered via smart retries (V2 API)",
    category: "Recovery (V2)",
  },
  {
    value: "sessionized_payments_distribution",
    label: "Payments Distribution (V2)",
    description: "Distribution from payment intents (V2 API)",
    category: "Distribution (V2)",
  },
]

// V2 (PaymentIntent) metrics — these must use ANALYTICS_PAYMENTS_V2 entity
let paymentIntentMetricValues = [
  "sessionized_payments_success_rate",
  "sessionized_payment_intent_count",
  "sessionized_smart_retried_amount",
  "sessionized_payments_distribution",
  "payments_success_rate",
  "payment_intent_count",
  "smart_retried_amount",
  "payment_processed_amount",  // exists in both, V2 is fine
  "sessionized_payment_processed_amount",  // exists in both, V2 is fine
]

let isPaymentIntentMetric = (metric: string): bool => {
  paymentIntentMetricValues->Array.includes(metric)
}

// ════════════════════════════════════════
// SMART RETRY METRICS (all V2 / PaymentIntent)
// ════════════════════════════════════════
let smartRetryMetrics: array<metricOption> = [
  {
    value: "sessionized_smart_retried_amount",
    label: "Smart Retried Amount",
    description: "Amount recovered via smart retries",
    category: "Recovery",
  },
  {
    value: "sessionized_payment_processed_amount",
    label: "Payment Processed Amount",
    description: "Total processed amount including retries",
    category: "Volume",
  },
  {
    value: "sessionized_payment_intent_count",
    label: "Payment Intent Count",
    description: "Total payment intents with retries",
    category: "Volume",
  },
  {
    value: "sessionized_payments_success_rate",
    label: "Success Rate (with Retries)",
    description: "Success rate including smart retries",
    category: "Performance",
  },
  {
    value: "sessionized_payments_distribution",
    label: "Payments Distribution",
    description: "Distribution of retried payments",
    category: "Distribution",
  },
]

// ════════════════════════════════════════
// REFUND METRICS
// ════════════════════════════════════════
let refundMetrics: array<metricOption> = [
  {
    value: "sessionized_refund_processed_amount",
    label: "Refund Processed Amount",
    description: "Total refund amount processed",
    category: "Volume",
  },
  {
    value: "sessionized_refund_count",
    label: "Refund Count",
    description: "Total number of refund attempts",
    category: "Volume",
  },
  {
    value: "sessionized_refund_success_count",
    label: "Refund Success Count",
    description: "Number of successful refunds",
    category: "Volume",
  },
  {
    value: "sessionized_refund_success_rate",
    label: "Refund Success Rate",
    description: "Percentage of successful refunds",
    category: "Performance",
  },
  {
    value: "sessionized_refund_error_message",
    label: "Refund Error Messages",
    description: "Distribution of refund error messages",
    category: "Failures",
  },
  {
    value: "sessionized_refund_reason",
    label: "Refund Reasons",
    description: "Distribution of refund reasons",
    category: "Analysis",
  },
  {
    value: "refund_success_rate",
    label: "Refund Success Rate (Non-Sessionized)",
    description: "Raw refund success rate",
    category: "Performance",
  },
  {
    value: "refund_count",
    label: "Refund Count (Non-Sessionized)",
    description: "Raw refund count",
    category: "Volume",
  },
  {
    value: "refund_success_count",
    label: "Refund Success Count (Non-Sessionized)",
    description: "Raw refund success count",
    category: "Volume",
  },
  {
    value: "refund_processed_amount",
    label: "Refund Processed Amount (Non-Sessionized)",
    description: "Raw refund processed amount",
    category: "Volume",
  },
]

// ════════════════════════════════════════
// DISPUTE METRICS
// ════════════════════════════════════════
let disputeMetrics: array<metricOption> = [
  {
    value: "dispute_status_metric",
    label: "Dispute Status",
    description: "Disputes breakdown by status",
    category: "Status",
  },
  {
    value: "total_amount_disputed",
    label: "Total Amount Disputed",
    description: "Total monetary amount of disputes",
    category: "Volume",
  },
  {
    value: "total_dispute_lost_amount",
    label: "Total Dispute Lost Amount",
    description: "Total amount lost in disputes",
    category: "Volume",
  },
  {
    value: "sessionized_dispute_status_metric",
    label: "Dispute Status (Sessionized)",
    description: "Sessionized dispute status breakdown",
    category: "Status",
  },
  {
    value: "sessionized_total_amount_disputed",
    label: "Total Amount Disputed (Sessionized)",
    description: "Sessionized total dispute amount",
    category: "Volume",
  },
  {
    value: "sessionized_total_dispute_lost_amount",
    label: "Total Dispute Lost (Sessionized)",
    description: "Sessionized total dispute lost amount",
    category: "Volume",
  },
]

// ════════════════════════════════════════
// AUTHENTICATION METRICS
// ════════════════════════════════════════
let authMetrics: array<metricOption> = [
  {
    value: "authentication_count",
    label: "Authentication Count",
    description: "Total 3DS authentication requests",
    category: "Volume",
  },
  {
    value: "authentication_attempt_count",
    label: "Attempt Count",
    description: "Number of authentication attempts",
    category: "Volume",
  },
  {
    value: "authentication_success_count",
    label: "Success Count",
    description: "Successful authentications",
    category: "Volume",
  },
  {
    value: "challenge_flow_count",
    label: "Challenge Flow Count",
    description: "Authentications that triggered 3DS challenge",
    category: "Flow",
  },
  {
    value: "challenge_attempt_count",
    label: "Challenge Attempt Count",
    description: "Attempts within challenge flow",
    category: "Flow",
  },
  {
    value: "challenge_success_count",
    label: "Challenge Success Count",
    description: "Successful challenge completions",
    category: "Flow",
  },
  {
    value: "frictionless_flow_count",
    label: "Frictionless Flow Count",
    description: "Authentications completed without challenge",
    category: "Flow",
  },
  {
    value: "frictionless_success_count",
    label: "Frictionless Success Count",
    description: "Successful frictionless authentications",
    category: "Flow",
  },
  {
    value: "authentication_funnel",
    label: "Authentication Funnel",
    description: "Full authentication flow funnel analysis",
    category: "Analysis",
  },
  {
    value: "authentication_error_message",
    label: "Authentication Errors",
    description: "Distribution of authentication error messages",
    category: "Failures",
  },
  {
    value: "authentication_exemption_requested_count",
    label: "Exemption Requested",
    description: "SCA exemptions requested",
    category: "Exemptions",
  },
  {
    value: "authentication_exemption_approved_count",
    label: "Exemption Approved",
    description: "SCA exemptions approved by issuer",
    category: "Exemptions",
  },
]

// ════════════════════════════════════════
// ROUTING METRICS
// ════════════════════════════════════════
let routingMetrics: array<metricOption> = [
  {
    value: "sessionized_payment_success_rate",
    label: "Authorization Rate",
    description: "Overall authorization/success rate",
    category: "Performance",
  },
  {
    value: "payment_success_rate",
    label: "First Attempt Auth Rate",
    description: "Success rate on first attempt",
    category: "Performance",
  },
  {
    value: "sessionized_payment_count",
    label: "Transaction Count",
    description: "Total transactions routed",
    category: "Volume",
  },
  {
    value: "sessionized_payment_processed_amount",
    label: "Transaction Amount",
    description: "Total amount routed",
    category: "Volume",
  },
  {
    value: "sessionized_connector_success_rate",
    label: "Connector Success Rate",
    description: "Success rate per connector",
    category: "Performance",
  },
  {
    value: "sessionized_debit_routing",
    label: "Debit Routing",
    description: "Debit routing metrics",
    category: "Routing",
  },
]

let getMetricsForDomain = (domain: analyticsDomain): array<metricOption> => {
  switch domain {
  | Payments => paymentMetrics
  | SmartRetries => smartRetryMetrics
  | Refunds => refundMetrics
  | Disputes => disputeMetrics
  | AuthEvents => authMetrics
  | Routing => routingMetrics
  }
}

// ════════════════════════════════════════
// DIMENSIONS PER DOMAIN
// ════════════════════════════════════════
let paymentDimensions: array<dimensionOption> = [
  {value: "connector", label: "Connector"},
  {value: "payment_method", label: "Payment Method"},
  {value: "payment_method_type", label: "Payment Method Type"},
  {value: "currency", label: "Currency"},
  {value: "authentication_type", label: "Authentication Type"},
  {value: "status", label: "Payment Status"},
  {value: "client_source", label: "Client Source"},
  {value: "client_version", label: "Client Version"},
  {value: "profile_id", label: "Profile ID"},
  {value: "card_network", label: "Card Network"},
  {value: "merchant_id", label: "Merchant ID"},
  {value: "card_last_4", label: "Card Last 4"},
  {value: "card_issuer", label: "Card Issuer"},
  {value: "error_reason", label: "Error Reason"},
  {value: "routing_approach", label: "Routing Approach"},
]

let refundDimensions: array<dimensionOption> = [
  {value: "currency", label: "Currency"},
  {value: "refund_status", label: "Refund Status"},
  {value: "connector", label: "Connector"},
  {value: "refund_type", label: "Refund Type"},
  {value: "profile_id", label: "Profile ID"},
  {value: "refund_reason", label: "Refund Reason"},
  {value: "refund_error_message", label: "Refund Error Message"},
]

let disputeDimensions: array<dimensionOption> = [
  {value: "connector", label: "Connector"},
  {value: "dispute_stage", label: "Dispute Stage"},
  {value: "currency", label: "Currency"},
]

let authDimensions: array<dimensionOption> = [
  {value: "authentication_status", label: "Authentication Status"},
  {value: "trans_status", label: "Transaction Status"},
  {value: "authentication_type", label: "Authentication Type"},
  {value: "error_message", label: "Error Message"},
  {value: "authentication_connector", label: "Authentication Connector"},
  {value: "message_version", label: "Message Version"},
  {value: "platform", label: "Platform"},
  {value: "currency", label: "Currency"},
  {value: "merchant_country", label: "Merchant Country"},
  {value: "billing_country", label: "Billing Country"},
]

let routingDimensions: array<dimensionOption> = [
  {value: "connector", label: "Connector"},
  {value: "payment_method", label: "Payment Method"},
  {value: "payment_method_type", label: "Payment Method Type"},
  {value: "card_network", label: "Card Network"},
  {value: "authentication_type", label: "Authentication Type"},
  {value: "currency", label: "Currency"},
  {value: "routing_approach", label: "Routing Approach"},
]

let getDimensionsForDomain = (domain: analyticsDomain): array<dimensionOption> => {
  switch domain {
  | Payments | SmartRetries => paymentDimensions
  | Refunds => refundDimensions
  | Disputes => disputeDimensions
  | AuthEvents => authDimensions
  | Routing => routingDimensions
  }
}

let needsTimeSeries = (chartType: chartType) => {
  switch chartType {
  | LineChart => true
  | _ => false
  }
}

let needsGroupBy = (chartType: chartType) => {
  switch chartType {
  | PieChart | BarChart | StackedBarChart | FunnelChart | SankeyChart => true
  | _ => false
  }
}

// Check if a metric is a distribution/category metric (returns categorical data)
let isDistributionMetric = (metric: string): bool => {
  switch metric {
  | "payments_distribution"
  | "sessionized_payments_distribution"
  | "failure_reasons"
  | "refund_error_message"
  | "sessionized_refund_error_message"
  | "authentication_error_message"
  | "refund_reason"
  | "sessionized_refund_reason"
  | "dispute_status_metric"
  | "sessionized_dispute_status_metric" => true
  | _ => false
  }
}

// Check if a metric is a funnel metric
let isFunnelMetric = (metric: string): bool => {
  switch metric {
  | "authentication_funnel" => true
  | _ => false
  }
}

// Check if a metric is numeric (can be plotted on line charts, aggregated)
let isNumericMetric = (metric: string): bool => {
  !isDistributionMetric(metric) && !isFunnelMetric(metric)
}

// Check if selected metrics support a given chart type
let doMetricsSupportChartType = (
  metrics: array<string>,
  chartType: chartType,
): bool => {
  if metrics->Array.length === 0 {
    true // No metrics selected yet, allow all
  } else {
    let hasDistributionMetric = metrics->Array.some(isDistributionMetric)
    let hasFunnelMetric = metrics->Array.some(isFunnelMetric)
    let hasNumericMetric = metrics->Array.some(isNumericMetric)

    switch chartType {
    | LineChart =>
      // Line charts need numeric metrics (time series)
      // Distribution metrics don't work well as trends
      !hasDistributionMetric && !hasFunnelMetric
    | FunnelChart =>
      // Funnel charts only work with funnel metrics
      hasFunnelMetric || (!hasDistributionMetric && !hasNumericMetric)
    | SankeyChart =>
      // Sankey charts need flow data - temporarily disable for most metrics
      // Only enable if specifically using routing/flow metrics
      false
    | _ =>
      // Bar, Column, Pie, Stacked work with distribution and numeric metrics
      !hasFunnelMetric
    }
  }
}

// Check if a chart type is compatible with the current config
let isChartTypeCompatible = (
  chartType: chartType,
  ~hasGroupBy: bool,
  ~selectedMetrics: array<string>=[],
): bool => {
  // If nothing is selected yet, all chart types are available
  if selectedMetrics->Array.length === 0 && !hasGroupBy {
    true
  } else {
    // Check if chart type needs groupBy (only enforce after user starts configuring)
    let needsGroupByCheck = switch chartType {
    | LineChart | ColumnChart => true
    | BarChart | PieChart | StackedBarChart | FunnelChart => hasGroupBy || selectedMetrics->Array.length === 0
    | SankeyChart => hasGroupBy
    | Table | StatNumber | Gauge => true
    }

    // Then check if selected metrics support this chart type
    let metricsSupportChart = doMetricsSupportChartType(selectedMetrics, chartType)

    needsGroupByCheck && metricsSupportChart
  }
}

// Get a reason why a chart type is disabled
let getChartTypeDisabledReason = (
  chartType: chartType,
  ~hasGroupBy: bool,
  ~selectedMetrics: array<string>=[],
): option<string> => {
  if isChartTypeCompatible(chartType, ~hasGroupBy, ~selectedMetrics) {
    None
  } else {
    let hasMetrics = selectedMetrics->Array.length > 0

    // Check if it's a groupBy issue
    let isGroupByIssue = switch chartType {
    | BarChart | PieChart | StackedBarChart | FunnelChart | SankeyChart => !hasGroupBy && hasMetrics
    | _ => false
    }

    let hasDistributionMetric = selectedMetrics->Array.some(isDistributionMetric)
    let hasFunnelMetric = selectedMetrics->Array.some(isFunnelMetric)

    if isGroupByIssue {
      Some("Select a Group By dimension first")
    } else if hasDistributionMetric && chartType === LineChart {
      Some("Distribution metrics don't support Line charts. Use Bar, Column, or Pie.")
    } else if hasFunnelMetric && chartType !== FunnelChart {
      Some("Funnel metrics only work with Funnel charts")
    } else if chartType === SankeyChart {
      Some("Sankey requires flow data (coming soon)")
    } else {
      Some("Not compatible with selected metrics")
    }
  }
}

// Map request metric name → response field name
// The BE uses different names in request vs response
let getResponseFieldName = (requestMetric: string): string => {
  switch requestMetric {
  // Sessionized payment metrics → response uses non-prefixed names
  | "sessionized_payment_success_rate" => "payment_success_rate"
  | "sessionized_payment_count" => "payment_count"
  | "sessionized_payment_success_count" => "payment_success_count"
  | "sessionized_payment_processed_amount" => "payment_processed_amount"
  | "sessionized_avg_ticket_size" => "avg_ticket_size"
  | "sessionized_retries_count" => "retries_count"
  | "sessionized_connector_success_rate" => "connector_success_rate"
  | "sessionized_debit_routing" => "debit_routed_transaction_count"
  // Sessionized refund metrics
  | "sessionized_refund_processed_amount" => "refund_processed_amount"
  | "sessionized_refund_count" => "refund_count"
  | "sessionized_refund_success_count" => "refund_success_count"
  | "sessionized_refund_success_rate" => "refund_success_rate"
  | "sessionized_refund_error_message" => "refund_error_message"
  | "sessionized_refund_reason" => "refund_reason"
  // Sessionized dispute metrics
  | "sessionized_dispute_status_metric" => "dispute_status_metric"
  | "sessionized_total_amount_disputed" => "total_amount_disputed"
  | "sessionized_total_dispute_lost_amount" => "total_dispute_lost_amount"
  // PaymentIntent V2 metrics
  | "sessionized_payments_success_rate" => "payments_success_rate"
  | "sessionized_payment_intent_count" => "payment_intent_count"
  | "sessionized_smart_retried_amount" => "smart_retried_amount"
  | "sessionized_payments_distribution" => "payments_distribution"
  // Non-sessionized and others — same name
  | other => other
  }
}

// Domain metadata for the selector
type domainOption = {
  value: analyticsDomain,
  label: string,
  description: string,
  icon: string,
  metricsCount: int,
}

let domainOptions: array<domainOption> = [
  {
    value: Payments,
    label: "Payments",
    description: "Payment transactions, success rates, failures",
    icon: "nd-wallet",
    metricsCount: paymentMetrics->Array.length,
  },
  {
    value: SmartRetries,
    label: "Smart Retries",
    description: "Automatic retry recovery and amounts",
    icon: "nd-swap-arrow-horizontal",
    metricsCount: smartRetryMetrics->Array.length,
  },
  {
    value: Refunds,
    label: "Refunds",
    description: "Refund processing, success, error analysis",
    icon: "refunds",
    metricsCount: refundMetrics->Array.length,
  },
  {
    value: Disputes,
    label: "Disputes",
    description: "Dispute cases and status tracking",
    icon: "nd-flag",
    metricsCount: disputeMetrics->Array.length,
  },
  {
    value: AuthEvents,
    label: "Authentication (3DS)",
    description: "3DS challenges, frictionless flows, exemptions",
    icon: "nd-shield",
    metricsCount: authMetrics->Array.length,
  },
  {
    value: Routing,
    label: "Routing Analytics",
    description: "Connector routing performance and optimization",
    icon: "nd-connectors",
    metricsCount: routingMetrics->Array.length,
  },
]
