let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

type prodFormColumnType =
  | POCemail
  | IsCompleted
  | BusinessName
  | Country
  | Website
  | POCName
  | SelectedProducts
  | Designation
  | MonthlyPaymentVolume
  | Industry

let getStringFromVariant = key => {
  switch key {
  | POCemail => "poc_email"
  | IsCompleted => "is_completed"
  | BusinessName => "legal_business_name"
  | Country => "business_location"
  | Website => "business_website"
  | POCName => "poc_name"
  | SelectedProducts => "selected_products"
  | Designation => "designation"
  | MonthlyPaymentVolume => "monthly_payment_volume"
  | Industry => "industry"
  }
}

let businessName = FormRenderer.makeFieldInfo(
  ~label="Organization Name",
  ~name=BusinessName->getStringFromVariant,
  ~placeholder="Eg: Hyperswitch",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let website = FormRenderer.makeFieldInfo(
  ~label="Organization Website",
  ~name=Website->getStringFromVariant,
  ~placeholder="Enter Website URL",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let pocName = FormRenderer.makeFieldInfo(
  ~label="Your Full Name",
  ~name=POCName->getStringFromVariant,
  ~placeholder="Eg: John Doe",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let pocEmail = FormRenderer.makeFieldInfo(
  ~label="Email ID",
  ~name=POCemail->getStringFromVariant,
  ~placeholder="john.doe+1@gmail.com",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let designation = FormRenderer.makeFieldInfo(
  ~label="Designation",
  ~name=Designation->getStringFromVariant,
  ~placeholder="Eg: Engineering Manager",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let monthlyPaymentVolume = FormRenderer.makeFieldInfo(
  ~label="Monthly Payment Volume (USD)",
  ~name=MonthlyPaymentVolume->getStringFromVariant,
  ~placeholder="Select Range",
  ~customInput=InputFields.selectInput(
    ~options=ProdIntentHelper.monthlyPaymentVolumeOptions->SelectBox.makeOptions,
    ~buttonText="Select Range",
    ~fullLength=true,
    ~customButtonStyle="!rounded-md",
    ~deselectDisable=true,
  ),
  ~isRequired=true,
)

let industry = FormRenderer.makeFieldInfo(
  ~label="Your Industry",
  ~name=Industry->getStringFromVariant,
  ~placeholder="Select Industry",
  ~customInput=InputFields.selectInput(
    ~options=ProdIntentHelper.industryOptions->SelectBox.makeOptions,
    ~buttonText="Select Industry",
    ~fullLength=true,
    ~customButtonStyle="!rounded-md",
    ~deselectDisable=true,
  ),
  ~isRequired=true,
)

let countryFieldInput = () => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <ProdIntentHelper.CountryField fieldsArray />
}

let countryField = FormRenderer.makeMultiInputFieldInfoOld(
  ~label="Organization Country",
  ~comboCustomInput=countryFieldInput(),
  ~inputFields=[
    FormRenderer.makeInputFieldInfo(~name=`business_location`),
    FormRenderer.makeInputFieldInfo(~name=`business_country_name`),
  ],
  ~isRequired=true,
  (),
)

let validateEmptyValue = (key, errors) => {
  switch key {
  | POCemail =>
    Dict.set(errors, key->getStringFromVariant, "Please enter your email"->JSON.Encode.string)
  | BusinessName =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your organization name"->JSON.Encode.string,
    )
  | Country =>
    Dict.set(errors, key->getStringFromVariant, "Please select your country"->JSON.Encode.string)
  | Website =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your organization website"->JSON.Encode.string,
    )
  | POCName =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your full name"->JSON.Encode.string,
    )
  | SelectedProducts =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please select at least one product"->JSON.Encode.string,
    )
  | Designation =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your designation"->JSON.Encode.string,
    )
  | MonthlyPaymentVolume =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please select a payment volume range"->JSON.Encode.string,
    )
  | Industry =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please select your industry"->JSON.Encode.string,
    )
  | _ => ()
  }
}

let getFormField = columnType => {
  switch columnType {
  | POCemail => pocEmail
  | BusinessName => businessName
  | Website => website
  | POCName => pocName
  | Designation => designation
  | MonthlyPaymentVolume => monthlyPaymentVolume
  | Industry => industry
  | _ => countryField
  }
}

// 2-column grid: fields are rendered in pairs (left, right) per row
let formFields = [
  SelectedProducts,
  POCName,
  POCemail,
  Designation,
  Country,
  Website,
  MonthlyPaymentVolume,
  BusinessName,
  Industry,
]

let formFieldsForQuickStart = [BusinessName, Country, Website, POCName, POCemail]

let validateCustom = (key, errors, value) => {
  switch key {
  | POCemail =>
    if value->HSwitchUtils.isValidEmail {
      Dict.set(errors, key->getStringFromVariant, "Please enter valid email id"->JSON.Encode.string)
    }
  | Website =>
    if (
      !RegExp.test(
        %re("/^(https?:\/\/)?([A-Za-z0-9-]+\.)*[A-Za-z0-9-]{1,63}\.[A-Za-z]{2,6}$/i"),
        value,
      ) ||
      value->String.includes("localhost")
    ) {
      Dict.set(errors, key->getStringFromVariant, "Please Enter Valid URL"->JSON.Encode.string)
    }
  | _ => ()
  }
}

let validateForm = (values, ~fieldsToValidate: array<prodFormColumnType>) => {
  open LogicUtils
  let errors = Dict.make()
  let valuesDict = values->getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    switch key {
    | SelectedProducts =>
      let products = LogicUtils.getStrArrayFromDict(valuesDict, key->getStringFromVariant, [])
      if products->Array.length < 1 {
        key->validateEmptyValue(errors)
      }
    | _ =>
      let value = LogicUtils.getString(valuesDict, key->getStringFromVariant, "")
      value->String.length < 1
        ? key->validateEmptyValue(errors)
        : key->validateCustom(errors, value)
    }
  })

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
    "business_country_name",
    valuesDict->getOptionString("business_country_name"),
  )

  prodOnboardingpayload->setOptionString(
    Designation->getStringFromVariant,
    valuesDict->getOptionString(Designation->getStringFromVariant),
  )
  prodOnboardingpayload->setOptionString(
    MonthlyPaymentVolume->getStringFromVariant,
    valuesDict->getOptionString(MonthlyPaymentVolume->getStringFromVariant),
  )
  prodOnboardingpayload->setOptionString(
    Industry->getStringFromVariant,
    valuesDict->getOptionString(Industry->getStringFromVariant),
  )

  let selectedProducts = valuesDict->getStrArrayFromDict(SelectedProducts->getStringFromVariant, [])
  if selectedProducts->Array.length > 0 {
    prodOnboardingpayload->Dict.set(
      SelectedProducts->getStringFromVariant,
      selectedProducts->Array.map(JSON.Encode.string)->JSON.Encode.array,
    )
  }

  prodOnboardingpayload
}
