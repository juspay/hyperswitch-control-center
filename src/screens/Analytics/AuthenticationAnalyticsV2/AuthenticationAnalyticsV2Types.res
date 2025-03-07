type timeRange = {
  start_time: string,
  end_time: string,
}

type queryDataType = {
  authentication_count: int,
  authentication_attempt_count: int,
  authentication_success_count: int,
  challenge_flow_count: int,
  challenge_attempt_count: int,
  challenge_success_count: int,
  frictionless_flow_count: int,
  frictionless_success_count: int,
  error_message_count: option<int>,
  authentication_funnel: option<string>,
  authentication_status: option<string>,
  trans_status: option<string>,
  error_message: option<string>,
  authentication_connector: option<string>,
  message_version: option<string>,
  time_range: timeRange,
  time_bucket: string,
}
type timeRangeType = {
  startTime: string,
  endTime: string,
}

type requestPayloadType = {
  timeRange: timeRangeType,
  mode: string,
  source: string,
  metrics: array<string>,
  delta: bool,
}

type secondFunnelPayloadType = {
  timeRange: timeRangeType,
  source: string,
  metrics: array<string>,
  delta: bool,
}

type filters = {authentication_status: array<string>}

type thirdFunnelPayloadType = {
  timeRange: timeRangeType,
  source: string,
  filters: filters,
  metrics: array<string>,
  delta: bool,
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
  payments_requiring_3ds_2_authentication: float,
  authentication_initiated: float,
  authentication_attemped: float,
  authentication_successful: float,
}
