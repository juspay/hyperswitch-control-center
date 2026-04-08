let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

type prodFormColumnType =
  | POCemail
  | IsCompleted
  | BusinessName
  | Country
  | Website
  | POCName
  | Designation
  | MonthlyPaymentVolume
  | Industry
  | SelectedProducts

let getStringFromVariant = key => {
  switch key {
  | POCemail => "poc_email"
  | IsCompleted => "is_completed"
  | BusinessName => "legal_business_name"
  | Country => "business_location"
  | Website => "business_website"
  | POCName => "poc_name"
  | Designation => "designation"
  | MonthlyPaymentVolume => "monthly_payment_volume"
  | Industry => "industry"
  | SelectedProducts => "requested_products"
  }
}

let businessName = FormRenderer.makeFieldInfo(
  ~label="Organization Name",
  ~name=BusinessName->getStringFromVariant,
  ~placeholder="Eg: HyperSwitch Pvt Ltd",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let website = FormRenderer.makeFieldInfo(
  ~label="Organization Website",
  ~name=Website->getStringFromVariant,
  ~placeholder="Enter a website",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let pocName = FormRenderer.makeFieldInfo(
  ~label="Your Full Name",
  ~name=POCName->getStringFromVariant,
  ~placeholder="Eg: Jack Ryan",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let pocEmail = FormRenderer.makeFieldInfo(
  ~label="Email ID",
  ~name=POCemail->getStringFromVariant,
  ~placeholder="Eg: jackryan@hyperswitch.io",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let designation = FormRenderer.makeFieldInfo(
  ~label="Designation",
  ~name=Designation->getStringFromVariant,
  ~placeholder="Eg: CTO",
  ~customInput=InputFields.textInput(),
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

let monthlyPaymentVolumeOptions = [
  ("< $10K", "Less than $10,000"),
  ("$10K - $50K", "$10,000 - $50,000"),
  ("$50K - $100K", "$50,000 - $100,000"),
  ("$100K - $500K", "$100,000 - $500,000"),
  ("$500K - $1M", "$500,000 - $1,000,000"),
  ("> $1M", "More than $1,000,000"),
]

let industryOptions = [
  ("E-commerce", "E-commerce"),
  ("SaaS", "SaaS"),
  ("Retail", "Retail"),
  ("Gaming", "Gaming"),
  ("Financial Services", "Financial Services"),
  ("Healthcare", "Healthcare"),
  ("Education", "Education"),
  ("Travel & Hospitality", "Travel & Hospitality"),
  ("Food & Beverage", "Food & Beverage"),
  ("Technology", "Technology"),
  ("Other", "Other"),
]

let monthlyVolumeFieldInput = () => (props: ReactFinalForm.fieldRenderProps) => {
  let input = props.input

  let selectInput: ReactFinalForm.fieldRenderPropsInput = {
    name: input.name,
    onBlur: _ => (),
    onChange: ev => {
      let stringVal = ev->Identity.formReactEventToString
      input.onChange(stringVal->Identity.anyTypeToReactEvent)
    },
    onFocus: _ => (),
    value: input.value,
    checked: true,
  }

  <SelectBox.BaseDropdown
    allowMultiSelect=false
    buttonText="Select Monthly Volume"
    customButtonStyle="!rounded-md !py-5"
    input={selectInput}
    options={monthlyPaymentVolumeOptions->Array.map(((value, label)) => {
      SelectBox.dropdownOption(~value, ~label, ())
    })}
    hideMultiSelectButtons=true
    fullLength=true
    dropdownClassName={`h-64 overflow-scroll`}
    dropdownCustomWidth="!w-full"
    addButton=false
    deselectDisable=true
  />
}

let monthlyVolumeField = FormRenderer.makeFieldInfo(
  ~label="Monthly Payment Volume",
  ~name=MonthlyPaymentVolume->getStringFromVariant,
  ~customInput=monthlyVolumeFieldInput(),
  ~isRequired=true,
)

let industryFieldInput = () => (props: ReactFinalForm.fieldRenderProps) => {
  let input = props.input

  let selectInput: ReactFinalForm.fieldRenderPropsInput = {
    name: input.name,
    onBlur: _ => (),
    onChange: ev => {
      let stringVal = ev->Identity.formReactEventToString
      input.onChange(stringVal->Identity.anyTypeToReactEvent)
    },
    onFocus: _ => (),
    value: input.value,
    checked: true,
  }

  <SelectBox.BaseDropdown
    allowMultiSelect=false
    buttonText="Select Industry"
    customButtonStyle="!rounded-md !py-5"
    input={selectInput}
    options={industryOptions->Array.map(((value, label)) => {
      SelectBox.dropdownOption(~value, ~label, ())
    })}
    hideMultiSelectButtons=true
    fullLength=true
    dropdownClassName={`h-64 overflow-scroll`}
    dropdownCustomWidth="!w-full"
    addButton=false
    deselectDisable=true
  />
}

let industryField = FormRenderer.makeFieldInfo(
  ~label="Your Industry",
  ~name=Industry->getStringFromVariant,
  ~customInput=industryFieldInput(),
  ~isRequired=true,
)

let validateEmptyValue = (key, errors) => {
  switch key {
  | POCemail =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your Email ID"->JSON.Encode.string,
    )
  | BusinessName =>
    Dict.set(errors, key->getStringFromVariant, "Please enter your Organization Name"->JSON.Encode.string)
  | Country =>
    Dict.set(errors, key->getStringFromVariant, "Please select a Country"->JSON.Encode.string)
  | Website =>
    Dict.set(errors, key->getStringFromVariant, "Please enter your Organization Website"->JSON.Encode.string)
  | POCName =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your Full Name"->JSON.Encode.string,
    )
  | Designation =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please enter your Designation"->JSON.Encode.string,
    )
  | MonthlyPaymentVolume =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please select your Monthly Payment Volume"->JSON.Encode.string,
    )
  | Industry =>
    Dict.set(
      errors,
      key->getStringFromVariant,
      "Please select your Industry"->JSON.Encode.string,
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
  | MonthlyPaymentVolume => monthlyVolumeField
  | Industry => industryField
  | _ => countryField
  }
}

let formFields = [POCName, POCemail, Designation, BusinessName, Website, Country, MonthlyPaymentVolume, Industry]

let formFieldsForQuickStart = [POCName, POCemail, Designation, BusinessName, Website, Country, MonthlyPaymentVolume, Industry]

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
    let value = LogicUtils.getString(valuesDict, key->getStringFromVariant, "")

    value->String.length < 1 ? key->validateEmptyValue(errors) : key->validateCustom(errors, value)
  })

  errors->JSON.Encode.object
}

let getJsonString = (valueDict, key) => {
  open LogicUtils
  valueDict->getString(key->getStringFromVariant, "")->JSON.Encode.string
}

let getBody = (values: JSON.t, ~selectedProducts: array<ProductTypes.productTypes>) => {
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

  let productStrings = selectedProducts->Array.map(ProductUtils.getProductStringName)
  prodOnboardingpayload->Dict.set(
    SelectedProducts->getStringFromVariant,
    productStrings->JSON.Encode.array,
  )

  prodOnboardingpayload
}
