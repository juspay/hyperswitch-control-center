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
      "Please enter a Point of Contact Email"->JSON.Encode.string,
    )
  | BusinessName =>
    Dict.set(errors, key->getStringFromVariant, "Please enter a Business Name"->JSON.Encode.string)
  | Country =>
    Dict.set(errors, key->getStringFromVariant, "Please select a Country"->JSON.Encode.string)
  | Website =>
    Dict.set(errors, key->getStringFromVariant, "Please enter a Website"->JSON.Encode.string)
  | POCName =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter a Point of Contact Name"->JSON.Encode.string,
    )
  | BusinessTAN =>
    Dict.set(errors, key->getStringFromVariant, "Please enter a Business TAN"->JSON.Encode.string)
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

let formFieldsForQuickStart = [BusinessName, Country, Website, POCName, POCemail, BusinessTAN]

let validateCustom = (key, errors, value) => {
  switch key {
  | POCemail =>
    if value->HSwitchUtils.isValidEmail {
      Dict.set(errors, key->getStringFromVariant, "Please enter valid email id"->JSON.Encode.string)
    }
  | Website =>
    if !Js.Re.test_(%re("/^https:\/\//i"), value) || value->String.includes("localhost") {
      Dict.set(errors, key->getStringFromVariant, "Please Enter Valid URL"->JSON.Encode.string)
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

  errors->JSON.Encode.object
}

let getJsonString = (valueDict, key) => {
  open LogicUtils
  valueDict->getString(key->getStringFromVariant, "")->JSON.Encode.string
}

let getBody = (values: JSON.t) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  let prodOnboardingpayload = Dict.make()

  prodOnboardingpayload->setOptionString(
    POCemail->getStringFromVariant,
    valuesDict->getOptionString(POCemail->getStringFromVariant),
  )
  prodOnboardingpayload->setOptionBool(IsCompleted->getStringFromVariant, Some(true))

  prodOnboardingpayload->setOptionString(
    BusinessName->getStringFromVariant,
    valuesDict->getOptionString(BusinessName->getStringFromVariant),
  )

  prodOnboardingpayload->setOptionString(
    Country->getStringFromVariant,
    valuesDict->getOptionString(Country->getStringFromVariant),
  )
  prodOnboardingpayload->setOptionString(
    Website->getStringFromVariant,
    valuesDict->getOptionString(Website->getStringFromVariant),
  )

  prodOnboardingpayload->setOptionString(
    POCName->getStringFromVariant,
    valuesDict->getOptionString(POCName->getStringFromVariant),
  )
  prodOnboardingpayload->setOptionString(
    BusinessTAN->getStringFromVariant,
    valuesDict->getOptionString(BusinessTAN->getStringFromVariant),
  )
  prodOnboardingpayload
}
