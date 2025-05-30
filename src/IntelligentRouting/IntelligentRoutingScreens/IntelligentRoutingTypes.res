type timeRange = {
  minDate: string,
  maxDate: string,
}

type sections = [#analyze | #review]

type dataType = Historical | Realtime
type file = Sample | Upload
type realtime = StreamLive

type reviewFieldsColsType =
  | NumberOfTransaction
  | TotalAmount
  | FileName
  | Processors
  | PaymentMethodTypes

type reviewFields = {
  total: int,
  total_amount: int,
  file_name: string,
  processors: array<string>,
  payment_method_types: array<string>,
}

type metadata = {file_name: string}

type transactionObj = {
  txn_no: int,
  payment_intent_id: string,
  payment_attempt_id: string,
  amount: float,
  payment_gateway: string,
  payment_status: bool,
  card_network: string,
  created_at: string,
  payment_method_type: string,
  order_currency: string,
  model_connector: string,
  suggested_uplift: float,
}

type transactionDetails = {
  total_payment_count: string,
  simulation_outcome_of_each_txn: array<transactionObj>,
}

type stats = {
  baseline: float,
  model: float,
}

type volDist = {
  success_rate: float,
  baseline_volume: int,
  model_volume: int,
}

type timeSeriesData = {
  time_stamp: string,
  success_rate: stats,
  revenue: stats,
  volume_distribution_as_per_sr: JSON.t,
}

type statistics = {
  file_name: string,
  overall_success_rate: stats,
  total_failed_payments: stats,
  total_revenue: stats,
  faar: stats,
  time_series_data: array<timeSeriesData>,
  overall_success_rate_improvement: float,
}

type fileData = {
  data: Js.TypedArray2.Uint8Array.t,
  stats: reviewFields,
}
