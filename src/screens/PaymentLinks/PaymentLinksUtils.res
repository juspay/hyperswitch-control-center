open LogicUtils

let getPaymentLinksList = async (
  filterValueJson,
  ~updateDetails: (string, JSON.t, Fetch.requestMethod) => promise<JSON.t>,
  ~setPaymentLinksData,
  ~setScreenState,
  ~offset,
  ~setTotalCount,
  ~setOffset,
  ~getURL: APIUtilsTypes.getUrlTypes,
) => {
  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let paymentLinksUrl = getURL(~entityName=V1(PAYMENT_LINKS), ~methodType=Post)
    let res = await updateDetails(paymentLinksUrl, filterValueJson->JSON.Encode.object, Post)
    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    let arr = Array.make(~length=offset, Dict.make())
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let dataArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let paymentLinksData =
        arr->Array.concat(dataArr)->Array.map(PaymentLinksEntity.itemToObjMapper)
      let list = paymentLinksData->Array.map(Nullable.make)
      setPaymentLinksData(_ => list)
      setTotalCount(_ => total)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => Custom)
    }
  } catch {
  | _ => setScreenState(_ => Error("Failed to fetch"))
  }
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let initialFixedFilter = _ => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey,
          ~endKey=endTimeFilterKey,
          ~format="YYYY-MM-DDTHH:mm:ss[Z]",
          ~showTime=true,
          ~disablePastDates={false},
          ~disableFutureDates={true},
          ~predefinedDays=[Hour(0.5), Hour(1.0), Hour(6.0), Today, Yesterday, Day(7.0), Day(30.0)],
          ~numMonths=2,
          ~disableApply=false,
          ~dateRangeLimit=90,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let currencyOptions = CurrencyUtils.currencyList->Array.map(currency => {
  let code = currency->CurrencyUtils.getCurrencyCodeStringFromVariant
  ({SelectBox.label: code, value: code}: SelectBox.dropdownOption)
})

let setupFutureUsageOptions =
  ([#on_session, #off_session]: array<PaymentLinksTypes.setupFutureUsage>)
  ->Array.map(value => (value :> string))
  ->SelectBox.makeOptions

let authenticationTypeOptions =
  ([#three_ds, #no_three_ds]: array<PaymentLinksTypes.authenticationType>)
  ->Array.map(value => (value :> string))
  ->SelectBox.makeOptions

let getProfileOptions = (profileList: array<OMPSwitchTypes.ompListTypes>) =>
  profileList->Array.map((profile): SelectBox.dropdownOption => {
    SelectBox.label: profile.name,
    value: profile.id,
  })

let amountField = FormRenderer.makeFieldInfo(
  ~label="Amount",
  ~name="amount",
  ~placeholder="Enter amount",
  ~customInput=InputFields.textInput(~type_="number"),
  ~isRequired=true,
)

let currencyField = FormRenderer.makeFieldInfo(
  ~label="Currency",
  ~name="currency",
  ~customInput=InputFields.selectInput(~options=currencyOptions, ~buttonText="Select currency"),
  ~isRequired=true,
)

let returnUrlField = FormRenderer.makeFieldInfo(
  ~label="Return URL",
  ~name="return_url",
  ~placeholder="https://example.com/redirect",
  ~isRequired=true,
)

let customerIdField = FormRenderer.makeFieldInfo(
  ~label="Customer ID",
  ~name="customer_id",
  ~placeholder="Enter customer ID",
)
let customerEmailField = FormRenderer.makeFieldInfo(
  ~label="Customer Email ID",
  ~name="customer_email",
  ~placeholder="Enter customer email",
)
let customerPhoneField = FormRenderer.makeFieldInfo(
  ~label="Customer Phone Number",
  ~name="customer_phone",
  ~placeholder="Enter customer phone number",
)
let descriptionField = FormRenderer.makeFieldInfo(
  ~label="Payment Description",
  ~name="description",
  ~placeholder="Enter a description",
)
let setupFutureUsageField = FormRenderer.makeFieldInfo(
  ~label="Setup Future Usage",
  ~name="setup_future_usage",
  ~customInput=InputFields.selectInput(
    ~options=setupFutureUsageOptions,
    ~buttonText="Select an option",
    ~deselectDisable=false,
  ),
)
let authenticationTypeField = FormRenderer.makeFieldInfo(
  ~label="Authentication Type",
  ~name="authentication_type",
  ~customInput=InputFields.selectInput(
    ~options=authenticationTypeOptions,
    ~buttonText="Select an option",
    ~deselectDisable=false,
  ),
)
let getProfileIdField = profileOptions =>
  FormRenderer.makeFieldInfo(
    ~label="Profile ID",
    ~name="profile_id",
    ~customInput=InputFields.selectInput(~options=profileOptions, ~buttonText="Select profile"),
    ~isRequired=true,
  )

let getCreatePaymentLinkPayload = (values: JSON.t) => {
  let valuesDict = values->getDictFromJsonObject
  let currency = valuesDict->getString("currency", "")
  let amount =
    CurrencyUtils.convertCurrencyToLowestDenomination(
      ~amount=valuesDict->getFloat("amount", 0.0),
      ~currency,
    )->Math.round

  let body = Dict.make()
  body->Dict.set("amount", amount->JSON.Encode.float)
  body->Dict.set("currency", currency->JSON.Encode.string)
  body->Dict.set("profile_id", valuesDict->getString("profile_id", "")->JSON.Encode.string)
  body->Dict.set(
    "return_url",
    valuesDict->getString("return_url", "")->String.trim->JSON.Encode.string,
  )

  let description = valuesDict->getString("description", "")->String.trim
  if description->isNonEmptyString {
    body->Dict.set("description", description->JSON.Encode.string)
  }

  let setupFutureUsage = valuesDict->getString("setup_future_usage", "")
  if setupFutureUsage->isNonEmptyString {
    body->Dict.set("setup_future_usage", setupFutureUsage->JSON.Encode.string)
  }

  let authenticationType = valuesDict->getString("authentication_type", "")
  if authenticationType->isNonEmptyString {
    body->Dict.set("authentication_type", authenticationType->JSON.Encode.string)
  }

  let customerId = valuesDict->getString("customer_id", "")->String.trim
  let customerEmail = valuesDict->getString("customer_email", "")->String.trim
  let customerPhone = valuesDict->getString("customer_phone", "")->String.trim
  let customer = Dict.make()
  if customerId->isNonEmptyString {
    customer->Dict.set("id", customerId->JSON.Encode.string)
  }
  if customerEmail->isNonEmptyString {
    customer->Dict.set("email", customerEmail->JSON.Encode.string)
  }
  if customerPhone->isNonEmptyString {
    customer->Dict.set("phone", customerPhone->JSON.Encode.string)
  }
  if customer->Dict.keysToArray->Array.length > 0 {
    body->Dict.set("customer", customer->JSON.Encode.object)
  }

  body->JSON.Encode.object
}

let validateForm = (values: JSON.t) => {
  let errors = Dict.make()
  let valuesDict = values->getDictFromJsonObject
  if valuesDict->getFloat("amount", 0.0) <= 0.0 {
    Dict.set(errors, "amount", "Enter a valid amount"->JSON.Encode.string)
  }
  if valuesDict->getString("currency", "")->isEmptyString {
    Dict.set(errors, "currency", "Select a currency"->JSON.Encode.string)
  }
  if valuesDict->getString("profile_id", "")->isEmptyString {
    Dict.set(errors, "profile_id", "Select a profile"->JSON.Encode.string)
  }
  if valuesDict->getString("return_url", "")->String.trim->isEmptyString {
    Dict.set(errors, "return_url", "Enter a return URL"->JSON.Encode.string)
  }
  errors->JSON.Encode.object
}
