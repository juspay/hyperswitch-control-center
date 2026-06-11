type dateRange = {
  startDate: Date.t,
  endDate: option<Date.t>,
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
  id: string,
  label: string,
  getDateRange: unit => dateRange,
}

type customPresetConfig = {
  preset: string,
  visible: bool,
}

module PresetsConfig = {
  type t
  external fromCustomConfig: customPresetConfig => t = "%identity"
  external fromCustom: customPresetDefinition => t = "%identity"
  let fromPreset = (preset: string): t => fromCustomConfig({preset, visible: true})
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
  ~minDate: Date.t=?,
  ~maxDate: Date.t=?,
  ~isSingleDatePicker: bool=?,
  ~allowSingleDateSelection: bool=?,
  ~showPresets: bool=?,
) => React.element = "DateRangePicker"
