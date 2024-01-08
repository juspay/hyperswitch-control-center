type questionsType = {
  question: string,
  options: array<SelectBox.dropdownOption>,
  key: string,
}
let defaultValueForQuestions: questionsType = {
  question: "",
  options: [],
  key: "",
}
let userRoleQuestions: questionsType = {
  question: `What role fits you well?`,
  options: [
    {label: "Product", value: "product"},
    {label: "Engineering", value: "engineering"},
    {label: "Finance", value: "finance"},
    {label: "Partnerships", value: "partnerships"},
  ],
  key: "best_fit_role",
}
let paymentProcessorQuestions: questionsType = {
  question: "How many Payment Processors do you currently use?",
  options: [
    {label: "Only 1", value: "only 1"},
    {label: "2-3", value: "2-3"},
    {label: "4 or more", value: "4 or more"},
    {label: "Not accepting digital payments yet", value: "not accepting digital payments yet"},
  ],
  key: "integrated_processors",
}
let requirementsQuestion: questionsType = {
  question: "What brings you to Hyperswitch?",
  options: [
    {label: "Improve Conversion", value: "improve conversions"},
    {label: "Reduce Costs", value: "reduce costs"},
    {label: "Market Expansion", value: "market expansion"},
    {label: "Reduce Dev Effort", value: "reduce dev efforts"},
    {label: "Mitigate Processor Risk", value: "mitigate processor risk"},
  ],
  key: "dashboard_purpose",
}
let questionForSurvey = [userRoleQuestions, paymentProcessorQuestions, requirementsQuestion]

let getBrowswerDetailsPayload = () => {
  open CountryUtils
  let browserDetails = HSwitchUtils.getBrowswerDetails()
  let clientCountry = browserDetails.clientCountry
  let clientCountryDict = Dict.fromArray([
    ("isoAlpha3", clientCountry.isoAlpha3->Js.Json.string),
    ("countryName", clientCountry.countryName->getCountryNameFromVarient->Js.Json.string),
    ("isoAlpha2", clientCountry.isoAlpha2->getCountryCodeStringFromVarient->Js.Json.string),
    ("timeZones", clientCountry.timeZones->Array.map(ele => ele->Js.Json.string)->Js.Json.array),
  ])
  [
    ("userAgent", browserDetails.userAgent->Js.Json.string),
    ("browserVersion", browserDetails.browserVersion->Js.Json.string),
    ("platform", browserDetails.platform->Js.Json.string),
    ("browserName", browserDetails.browserName->Js.Json.string),
    ("browserLanguage", browserDetails.browserLanguage->Js.Json.string),
    ("screenHeight", browserDetails.screenHeight->Js.Json.string),
    ("screenWidth", browserDetails.screenWidth->Js.Json.string),
    ("timeZoneOffset", browserDetails.timeZoneOffset->Js.Json.string),
    ("clientCountry", clientCountryDict->Js.Json.object_),
  ]
  ->Dict.fromArray
  ->Js.Json.object_
}

let generateSurveyJson = values => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let survey_json =
    questionForSurvey
    ->Array.map(value => {
      (value.key, valuesDict->getString(value.key, "")->Js.Json.string)
    })
    ->Dict.fromArray
  let browserDetailsPayload = getBrowswerDetailsPayload()
  [
    ("signin_survey", survey_json->Js.Json.object_),
    ("browser_details", browserDetailsPayload),
  ]->Dict.fromArray
}

let initialValueDict =
  questionForSurvey
  ->Array.map(value => {
    (value.key, ""->Js.Json.string)
  })
  ->Dict.fromArray
  ->Js.Json.object_
