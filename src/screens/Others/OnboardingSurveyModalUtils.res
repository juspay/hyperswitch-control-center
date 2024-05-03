let keysToValidateForHyperswitch = [
  "designation",
  "business_website",
  "about_business",
  "major_markets",
  "business_size",
  "hyperswitch_req",
  "required_features",
  "required_processors",
  "planned_live_date",
  "miscellaneous",
]

let businessName = FormRenderer.makeFieldInfo(
  ~label="Business name",
  ~name="merchant_name",
  ~placeholder="Eg: HyperSwitch Pvt Ltd",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let userName = FormRenderer.makeFieldInfo(
  ~label="User name",
  ~name="user_name",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let designation = FormRenderer.makeFieldInfo(
  ~label="Designation",
  ~name="hyperswitch.designation",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let majorMarkets = FormRenderer.makeFieldInfo(
  ~label="Major markets",
  ~name="hyperswitch.major_markets",
  ~customInput=InputFields.checkboxInput(
    ~options=["North America", "Europe", "LATAM", "APAC", "Africa"]->SelectBox.makeOptions,
    ~buttonText="Major markets",
    (),
  ),
  ~isRequired=true,
  (),
)

let businessSize = FormRenderer.makeFieldInfo(
  ~label="Business size",
  ~name="hyperswitch.business_size",
  ~customInput=InputFields.radioInput(
    ~options=[
      "Yet to start processing payments",
      "< 30k transaction per month",
      "30k - 100k transactions per month",
      "100k - 1Mn transactions per month",
      "1Mn - 5Mn transactions per month",
      "5Mn+ transactions per month",
    ]->SelectBox.makeOptions,
    ~buttonText="Business Size",
    (),
  ),
  ~isRequired=true,
  (),
)

let businessWebsite = FormRenderer.makeFieldInfo(
  ~label="Business website",
  ~name="hyperswitch.business_website",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let aboutBusiness = FormRenderer.makeFieldInfo(
  ~label="About Business - Few words about your business and how you collect payments currently",
  ~name="hyperswitch.about_business",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let hyperswitchUsage = FormRenderer.makeFieldInfo(
  ~label="How are you planning to use Hyperswitch?",
  ~name="hyperswitch.hyperswitch_req",
  ~customInput=InputFields.radioInput(
    ~options=[
      "Looking to use Hyperswitch SaaS/Cloud hosted solution for payments",
      "Looking to self-host Hyperswitch's open-source version for payments",
      "Looking to resell Hyperswitch's open-source solution",
    ]->SelectBox.makeOptions,
    ~buttonText="Business Size",
    (),
  ),
  ~isRequired=true,
  (),
)

let hyperswitchFeatures = FormRenderer.makeFieldInfo(
  ~label="Hyperswitch features required",
  ~name="hyperswitch.required_features",
  ~customInput=InputFields.checkboxInput(
    ~options=[
      "Pay-ins",
      "Payouts",
      "FRM",
      "Subscriptions",
      "Recon",
      "Disputes/Chargebacks",
    ]->SelectBox.makeOptions,
    ~buttonText="Business Size",
    (),
  ),
  ~isRequired=true,
  (),
)

let processorRequired = FormRenderer.makeFieldInfo(
  ~label="Payment Processors Required",
  ~name="hyperswitch.required_processors",
  ~customInput=InputFields.checkboxInput(
    ~options=[
      "Stripe",
      "Adyen",
      "Cybersource",
      "Authorize.net",
      "Checkout",
      "Braintree",
      "Worldpay",
      "Fiserv",
      "NMI",
    ]->SelectBox.makeOptions,
    ~buttonText="Business Size",
    (),
  ),
  ~isRequired=true,
  (),
)

let plannedGoLiveDate = FormRenderer.makeFieldInfo(
  ~label="Planned go-live date with Hyperswitch",
  ~name="hyperswitch.planned_live_date",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let miscellaneousTextField = FormRenderer.makeFieldInfo(
  ~label="Anything else that you would like us to know",
  ~name="hyperswitch.miscellaneous",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let constructOnboardingSurveyBody = values => {
  open LogicUtils
  let dictFromJson = values->getDictFromJsonObject
  let hyperswitchValue = dictFromJson->getDictfromDict("hyperswitch")
  let filterOutOtherKeys =
    hyperswitchValue->Dict.keysToArray->Array.filter(value => value->String.includes("otherstring"))
  filterOutOtherKeys->Array.forEach(otherKey => hyperswitchValue->Dict.delete(otherKey))
  hyperswitchValue
}

let constructUserUpdateBody = values => {
  open LogicUtils
  let dictFromJson = values->getDictFromJsonObject
  [("name", dictFromJson->getString("user_name", "")->JSON.Encode.string)]->getJsonFromArrayOfJson
}
