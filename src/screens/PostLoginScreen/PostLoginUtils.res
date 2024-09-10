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
    ("isoAlpha3", clientCountry.isoAlpha3->JSON.Encode.string),
    ("countryName", clientCountry.countryName->getCountryNameFromVarient->JSON.Encode.string),
    ("isoAlpha2", clientCountry.isoAlpha2->getCountryCodeStringFromVarient->JSON.Encode.string),
    ("timeZones", clientCountry.timeZones->LogicUtils.getJsonFromArrayOfString),
  ])
  [
    ("userAgent", browserDetails.userAgent->JSON.Encode.string),
    ("browserVersion", browserDetails.browserVersion->JSON.Encode.string),
    ("platform", browserDetails.platform->JSON.Encode.string),
    ("browserName", browserDetails.browserName->JSON.Encode.string),
    ("browserLanguage", browserDetails.browserLanguage->JSON.Encode.string),
    ("screenHeight", browserDetails.screenHeight->JSON.Encode.string),
    ("screenWidth", browserDetails.screenWidth->JSON.Encode.string),
    ("timeZoneOffset", browserDetails.timeZoneOffset->JSON.Encode.string),
    ("clientCountry", clientCountryDict->JSON.Encode.object),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let generateSurveyJson = values => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let survey_json =
    questionForSurvey
    ->Array.map(value => {
      (value.key, valuesDict->getString(value.key, "")->JSON.Encode.string)
    })
    ->Dict.fromArray
  let browserDetailsPayload = getBrowswerDetailsPayload()
  [
    ("signin_survey", survey_json->JSON.Encode.object),
    ("browser_details", browserDetailsPayload),
  ]->Dict.fromArray
}

let initialValueDict =
  questionForSurvey
  ->Array.map(value => {
    (value.key, ""->JSON.Encode.string)
  })
  ->Dict.fromArray
  ->JSON.Encode.object
