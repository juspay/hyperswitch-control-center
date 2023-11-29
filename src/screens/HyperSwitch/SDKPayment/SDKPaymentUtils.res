let initialValueForForm: string => SDKPaymentTypes.paymentType = profileId => {
  amount: 100,
  currency: "United States-USD",
  profile_id: profileId,
}

let getTypedValueForPayment: Js.Json.t => SDKPaymentTypes.paymentType = values => {
  open LogicUtils
  let dictOfValues = values->getDictFromJsonObject
  {
    amount: dictOfValues->getInt("amount", 100),
    currency: dictOfValues->getString("currency", "United States-USD"),
    profile_id: dictOfValues->getString("profile_id", ""),
  }
}

let convertAmountToCents = (amount: int) => {
  amount * 100
}

let getCurrencyValue = (countryCurrency: string) => {
  countryCurrency
  ->Js.String2.split("-")
  ->Belt.Array.get(1)
  ->Belt.Option.getWithDefault("USD")
  ->Js.String2.trim
}
