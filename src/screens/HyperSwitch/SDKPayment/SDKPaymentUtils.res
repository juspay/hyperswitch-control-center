let initialValueForForm: HSwitchSettingTypes.profileEntity => SDKPaymentTypes.paymentType = defaultBusinessProfile => {
  {
    amount: 100,
    currency: "United States-USD",
    profile_id: defaultBusinessProfile.profile_id,
    description: "Default value",
    customer_id: "hyperswitch_sdk_demo_id",
  }
}

let getTypedValueForPayment: Js.Json.t => SDKPaymentTypes.paymentType = values => {
  open LogicUtils
  let dictOfValues = values->getDictFromJsonObject
  {
    amount: dictOfValues->getInt("amount", 100),
    currency: dictOfValues->getString("currency", "United States-USD"),
    profile_id: dictOfValues->getString("profile_id", ""),
    customer_id: dictOfValues->getString("customer_id", ""),
    description: dictOfValues->getString("description", "Default value"),
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
