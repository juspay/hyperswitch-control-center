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
  ~placeholder="Eg: Product Manager",
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
  ("e_commerce", "E-commerce"),
  ("saas", "SaaS"),
  ("retail", "Retail"),
  ("gaming", "Gaming"),
  ("fintech", "Fintech"),
  ("healthcare", "Healthcare"),
  ("education", "Education"),
  ("travel", "Travel & Hospitality"),
  ("food", "Food & Beverage"),
  ("media", "Media & Entertainment"),
  ("other", "Other"),
]

let monthlyVolumeFieldInput = () => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  let field = fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "monthly_payment_volume",
    onBlur: _ => (),
    onChange: ev => {
      let stringVal = ev->Identity.formReactEventToString
      field.input.onChange(stringVal->Identity.anyTypeToReactEvent)
    },
    onFocus: _ => (),
    value: field.input.value,
    checked: true,
  }

  <SelectBox.BaseDropdown
    allowMultiSelect=false
    buttonText="Select Monthly Volume"
    customButtonStyle="!rounded-md !py-5"
    input
    options={monthlyPaymentVolumeOptions->Array.map(((value, label)) => {
      SelectBox.dropDownOption(~value, ~label)
    })}
    hideMultiSelectButtons=true
    fullLength=true
    dropdownClassName={`h-48 overflow-scroll`}
    dropdownCustomWidth="!w-full"
    addButton=false
    deselectDisable=true
  />
}

let monthlyVolumeField = FormRenderer.makeMultiInputFieldInfoOld(
  ~label="Monthly Payment Volume",
  ~comboCustomInput=monthlyVolumeFieldInput(),
  ~inputFields=[FormRenderer.makeInputFieldInfo(~name=`monthly_payment_volume`)],
  ~isRequired=true,
  (),
)

let industryFieldInput = () => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  let field = fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "industry",
    onBlur: _ => (),
    onChange: ev => {
      let stringVal = ev->Identity.formReactEventToString
      field.input.onChange(stringVal->Identity.anyTypeToReactEvent)
    },
    onFocus: _ => (),
    value: field.input.value,
    checked: true,
  }

  <SelectBox.BaseDropdown
    allowMultiSelect=false
    buttonText="Select Industry"
    customButtonStyle="!rounded-md !py-5"
    input
    options={industryOptions->Array.map(((value, label)) => {
      SelectBox.dropDownOption(~value, ~label)
    })}
    hideMultiSelectButtons=true
    fullLength=true
    dropdownClassName={`h-48 overflow-scroll`}
    dropdownCustomWidth="!w-full"
    addButton=false
    deselectDisable=true
  />
}

let industryField = FormRenderer.makeMultiInputFieldInfoOld(
  ~label="Your Industry",
  ~comboCustomInput=industryFieldInput(),
  ~inputFields=[FormRenderer.makeInputFieldInfo(~name=`industry`)],
  ~isRequired=true,
  (),
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
    Dict.set(errors, key->getStringFromVariant, "Please enter Organization Name"->JSON.Encode.string)
  | Country =>
    Dict.set(errors, key->getStringFromVariant, "Please select a Country"->JSON.Encode.string)
  | Website =>
    Dict.set(errors, key->getStringFromVariant, "Please enter Organization Website"->JSON.Encode.string)
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
      "Please select Monthly Payment Volume"->JSON.Encode.string,
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

let formFields = [POCName, POCemail, Designation, BusinessName, Country, Website, MonthlyPaymentVolume, Industry]

let formFieldsForQuickStart = [POCName, POCemail, Designation, BusinessName, Country, Website, MonthlyPaymentVolume, Industry]

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

let getBody = (values: JSON.t, ~selectedProducts: array<string>=[]) => {
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

  if selectedProducts->Array.length > 0 {
    prodOnboardingpayload->Dict.set(
      SelectedProducts->getStringFromVariant,
      selectedProducts->JSON.Encode.array,
    )
  }

  prodOnboardingpayload
}
