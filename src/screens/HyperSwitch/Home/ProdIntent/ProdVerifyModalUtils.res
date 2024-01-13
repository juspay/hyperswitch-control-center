let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

type prodFormColumnType =
  | POCemail
  | IsCompleted
  | BusinessName
  | Country
  | Website
  | POCName
  | BusinessTAN

let getStringFromVariant = key => {
  switch key {
  | POCemail => "poc_email"
  | IsCompleted => "is_completed"
  | BusinessName => "legal_business_name"
  | Country => "business_location"
  | Website => "business_website"
  | POCName => "poc_name"
  | BusinessTAN => "comments"
  }
}

let businessName = FormRenderer.makeFieldInfo(
  ~label="Legal Business Name",
  ~name=BusinessName->getStringFromVariant,
  ~placeholder="Eg: HyperSwitch Pvt Ltd",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let website = FormRenderer.makeFieldInfo(
  ~label="Business Website",
  ~name=Website->getStringFromVariant,
  ~placeholder="Enter a website",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let pocName = FormRenderer.makeFieldInfo(
  ~label="Contact Name",
  ~name=POCName->getStringFromVariant,
  ~placeholder="Eg: Jack Ryan",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let pocEmail = FormRenderer.makeFieldInfo(
  ~label="Contact Email",
  ~name=POCemail->getStringFromVariant,
  ~placeholder="Eg: jackryan@hyperswitch.io",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let businessTAN = FormRenderer.makeFieldInfo(
  ~label="Tax Identification Number",
  ~name=BusinessTAN->getStringFromVariant,
  ~placeholder="Eg. Enter EIN No. for US, VAT No. for EU, etc",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let countryField = FormRenderer.makeFieldInfo(
  ~label="Business Country",
  ~isRequired=true,
  ~name=Country->getStringFromVariant,
  ~customInput=InputFields.selectInput(
    ~deselectDisable=true,
    ~fullLength=true,
    ~customStyle="max-h-48",
    ~customButtonStyle="pr-3",
    ~options=CountryUtils.countriesList->Array.map(CountryUtils.getCountryOption),
    ~buttonText="Select Country",
    (),
  ),
  (),
)

let validateEmptyValue = (key, errors) => {
  switch key {
  | POCemail =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter a Point of Contact Email"->Js.Json.string,
    )
  | BusinessName =>
    Dict.set(errors, key->getStringFromVariant, "Please enter a Business Name"->Js.Json.string)
  | Country =>
    Dict.set(errors, key->getStringFromVariant, "Please select a Country"->Js.Json.string)
  | Website => Dict.set(errors, key->getStringFromVariant, "Please enter a Website"->Js.Json.string)
  | POCName =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter a Point of Contact Name"->Js.Json.string,
    )
  | BusinessTAN =>
    Dict.set(errors, key->getStringFromVariant, "Please enter a Business TAN"->Js.Json.string)
  | _ => ()
  }
}

let getFormField = columnType => {
  switch columnType {
  | POCemail => pocEmail
  | BusinessName => businessName
  | Website => website
  | POCName => pocName
  | BusinessTAN => businessTAN
  | _ => countryField
  }
}

let formFields = [BusinessName, Country, Website, POCName, POCemail, BusinessTAN]

let validateCustom = (key, errors, value) => {
  switch key {
  | POCemail =>
    if value->HSwitchUtils.isValidEmail {
      Dict.set(errors, key->getStringFromVariant, "Please enter valid email id"->Js.Json.string)
    }
  | Website =>
    if !Js.Re.test_(%re("/^https:\/\//i"), value) || value->String.includes("localhost") {
      Dict.set(errors, key->getStringFromVariant, "Please Enter Valid URL"->Js.Json.string)
    }
  | _ => ()
  }
}

let validateForm = (values, ~fieldsToValidate: array<prodFormColumnType>, ~setIsDisabled) => {
  open LogicUtils
  let errors = Dict.make()
  let valuesDict = values->getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    let value = LogicUtils.getString(valuesDict, key->getStringFromVariant, "")

    value->String.length < 1 ? key->validateEmptyValue(errors) : key->validateCustom(errors, value)
  })

  errors->Dict.keysToArray->Array.length > 0 ? setIsDisabled(_ => true) : setIsDisabled(_ => false)

  errors->Js.Json.object_
}

let getJsonString = (valueDict, key) => {
  open LogicUtils
  valueDict->getString(key->getStringFromVariant, "")->Js.Json.string
}

let getBody = (values: Js.Json.t) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  [
    (POCemail->getStringFromVariant, valuesDict->getJsonString(POCemail)),
    (IsCompleted->getStringFromVariant, true->Js.Json.boolean),
    (BusinessName->getStringFromVariant, valuesDict->getJsonString(BusinessName)),
    (Country->getStringFromVariant, valuesDict->getJsonString(Country)),
    (Website->getStringFromVariant, valuesDict->getJsonString(Website)),
    (POCName->getStringFromVariant, valuesDict->getJsonString(POCName)),
    (BusinessTAN->getStringFromVariant, valuesDict->getJsonString(BusinessTAN)),
  ]->Dict.fromArray
}
