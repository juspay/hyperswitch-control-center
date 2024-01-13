open HyperSwitchTypes

@module("@juspay-tech/hyper-js")
external loadHyper: string => hyperPromise = "loadHyper"

@module("@juspay-tech/react-hyper-js")
external useHyper: unit => hyperType = "useHyper"
@module("@juspay-tech/react-hyper-js")
external useElements: unit => hyperType = "useElements"

module Elements = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (
    ~options: options,
    ~stripe: hyperPromise,
    ~children: React.element,
  ) => React.element = "Elements"
}

module PaymentElement = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "PaymentElement"
}

module CardWidget = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "CardWidget"
}

module ElementsTest = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (
    ~options: optionsTest,
    ~stripe: hyperPromise,
    ~children: React.element,
  ) => React.element = "Elements"
}

module PaymentElementTest = {
  @module("@juspay-tech/react-hyper-js") @react.component
  external make: (~id: string, ~options: options2) => React.element = "PaymentElement"
}
