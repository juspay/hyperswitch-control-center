type sliderVariant =
  | @as("primary") Primary
  | @as("secondary") Secondary

type sliderSize =
  | @as("sm") Small
  | @as("md") Medium
  | @as("lg") Large

type sliderValueType =
  | @as("number") Number
  | @as("percentage") Percentage
  | @as("decimal") Decimal

type sliderLabelPosition =
  | @as("top") Top
  | @as("bottom") Bottom
  | @as("inline") Inline

type sliderValueFormatConfig = {
  \"type": sliderValueType,
  decimalPlaces?: int,
  prefix?: string,
  suffix?: string,
  showLabels?: bool,
  formatter?: float => string,
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~variant: sliderVariant=?,
  ~size: sliderSize=?,
  ~valueFormat: sliderValueFormatConfig=?,
  ~showValueLabels: bool=?,
  ~labelPosition: sliderLabelPosition=?,
  ~value: array<float>=?,
  ~defaultValue: array<float>=?,
  ~min: float=?,
  ~max: float=?,
  ~step: float=?,
  ~onValueChange: array<float> => unit=?,
  ~onValueChangeComplete: array<float> => unit=?,
  ~disabled: bool=?,
  ~orientation: [#horizontal | #vertical]=?,
  ~label: string=?,
  ~name: string=?,
  ~id: string=?,
  ~className: string=?,
  ~style: JsxDOM.style=?,
  ~dataTestId: string=?,
  ~children: React.element=?,
) => React.element = "Slider"
