open HSwitchSettingTypes
open CountryUtils
let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

type modalFields = ProfileName

let getStringFromVariant = key => {
  switch key {
  | ProfileName => "profile_name"
  }
}

let defaultCountry = "UnitedStatesOfAmerica"
let defaultLabel = "default"

let getFormatedCountryName = countryCode => {
  countryCode->getCountryCodeFromString->getCountryFromCountryCode->splitCountryNameWithSpace
}

let labelField = FormRenderer.makeFieldInfo(
  ~label="Profile Name",
  ~name="profile_name",
  ~placeholder="Enter profile name",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

type modalState = Loading | Edit

let validateEmptyValue = (key, errors) => {
  switch key {
  | ProfileName =>
    errors->Js.Dict.set(key->getStringFromVariant, "Please enter a profile name"->Js.Json.string)
  }
}

let validateCustom = (key, errors, value) => {
  switch key {
  | ProfileName =>
    if !Js.Re.test_(%re("/^[a-zA-Z][a-zA-Z0-9]*$/"), value) {
      errors->Js.Dict.set(key->getStringFromVariant, "Please enter a profile name"->Js.Json.string)
    }
  }
}

let getUserEnteredProfileDetails = valueDict => {
  let profileName = valueDict->LogicUtils.getString(ProfileName->getStringFromVariant, "")

  profileName
}

let validateForm = (
  values: Js.Json.t,
  ~fieldsToValidate: array<modalFields>,
  ~list: array<profileEntity>,
) => {
  let errors = Js.Dict.empty()
  let valuesDict = values->LogicUtils.getDictFromJsonObject

  fieldsToValidate->Js.Array2.forEach(key => {
    let value = valuesDict->LogicUtils.getString(key->getStringFromVariant, "")

    value->Js.String2.length <= 0
      ? key->validateEmptyValue(errors) // empty check
      : key->validateCustom(errors, value) // custom validations
  })

  // duplicate entry check
  if (
    list
    ->Js.Array2.find(item => {
      let profileName = valuesDict->getUserEnteredProfileDetails
      item.profile_name === profileName
    })
    ->Belt.Option.isSome
  ) {
    errors->Js.Dict.set(
      "profile_name",
      "The entry you are trying to add already exists."->Js.Json.string,
    )
  }

  errors->Js.Json.object_
}
