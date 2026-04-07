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
    value: "sessionized_payment_intent_count",
    label: "Payment Count",
    description: "Total number of payment attempts",
    category: "Volume",
  },
  {
    value: "sessionized_payments_success_rate",
    label: "Payment Success Rate",
    description: "Percentage of successful payments",
    category: "Performance",
  },
  {
    value: "payment_success_rate",
    label: "Success Rate (Non-Sessionized)",
    description: "Raw success rate without session grouping",
    category: "Performance",
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
]

// ════════════════════════════════════════
// SMART RETRY METRICS
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
    value: "payments_distribution",
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
    value: "sessionized_payments_success_rate",
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
    value: "sessionized_payment_intent_count",
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
  {value: "card_network", label: "Card Network"},
  {value: "authentication_type", label: "Authentication Type"},
  {value: "error_reason", label: "Error Reason"},
]

let refundDimensions: array<dimensionOption> = [
  {value: "connector", label: "Connector"},
  {value: "refund_error_message", label: "Refund Error Message"},
  {value: "refund_reason", label: "Refund Reason"},
]

let disputeDimensions: array<dimensionOption> = [
  {value: "connector", label: "Connector"},
]

let authDimensions: array<dimensionOption> = [
  {value: "authentication_connector", label: "Authentication Connector"},
  {value: "authentication_status", label: "Authentication Status"},
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
  | LineChart | ColumnChart => true
  | _ => false
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
