type dateRange = {
  startDate: Js.Date.t,
  endDate: Js.Date.t,
}

module DateRangePreset = {
  let today = "today"
  let yesterday = "yesterday"
  let tomorrow = "tomorrow"
  let thisMonth = "thisMonth"
  let lastMonth = "lastMonth"
  let last30Minutes = "last30Minutes"
  let last1Hour = "last1Hour"
  let last7Days = "last7Days"
  let last30Days = "last30Days"
}

type customPresetDefinition = {
  label: string,
  startDate: Js.Date.t,
  endDate: Js.Date.t,
}

module PresetsConfig = {
  type t
  external fromPreset: string => t = "%identity"
  external fromCustom: customPresetDefinition => t = "%identity"
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~value: dateRange=?,
  ~onChange: dateRange => unit=?,
  ~showDateTimePicker: bool=?,
  ~isDisabled: bool=?,
  ~disableFutureDates: bool=?,
  ~disablePastDates: bool=?,
  ~customPresets: array<PresetsConfig.t>=?,
) => React.element = "DateRangePicker"
