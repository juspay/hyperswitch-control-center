type timeRange = {
  start_time: string,
  end_time: string,
}

type queryDataType = {
  authentication_count: int,
  authentication_attempt_count: int,
  authentication_success_count: int,
  authentication_exemption_approved_count: option<int>,
  authentication_exemption_requested_count: option<int>,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  error_message_count: int,
  authentication_funnel: int,
  authentication_status: option<string>,
  trans_status: option<string>,
  error_message: string,
  authentication_connector: option<string>,
  message_version: option<string>,
  time_range: timeRange,
  time_bucket: string,
}
type timeRangeType = {
  startTime: string,
  endTime: string,
}

type secondFunnelDataType = {
  authentication_count: int,
  authentication_attempt_count: int,
  authentication_success_count: int,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  error_message_count: option<int>,
  authentication_funnel: int,
  authentication_status: option<string>,
  trans_status: option<string>,
  error_message: option<string>,
  authentication_connector: option<string>,
  message_version: option<string>,
  time_range: timeRange,
  time_bucket: string,
}

type funnelDataType = {
  mutable payments_requiring_3ds_2_authentication: int,
  mutable authentication_initiated: int,
  mutable authentication_attempted: int,
  mutable authentication_successful: int,
}

type metaDataType = {total_error_message_count: int}

type insightsDataType = {
  queryData: array<queryDataType>,
  metaData: array<metaDataType>,
}

type metricsData = {
  title: string,
  name: string,
  value: float,
  valueType: LogicUtilsTypes.valueType,
  tooltip_description: string,
}
