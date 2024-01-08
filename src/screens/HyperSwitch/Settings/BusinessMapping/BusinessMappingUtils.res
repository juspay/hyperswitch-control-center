open HSwitchSettingTypes

type modalFields = ProfileName

let getStringFromVariant = key => {
  switch key {
  | ProfileName => "profile_name"
  }
}

let labelField = FormRenderer.makeFieldInfo(
  ~label="Profile Name",
  ~name="profile_name",
  ~placeholder="Enter profile name",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

type modalState = Loading | Edit | Successful

let validateEmptyValue = (key, errors) => {
  switch key {
  | ProfileName =>
    errors->Dict.set(key->getStringFromVariant, "Please enter a profile name"->Js.Json.string)
  }
}

let validateCustom = (key, errors, value) => {
  switch key {
  | ProfileName =>
    if !Js.Re.test_(%re("/^[a-zA-Z][a-zA-Z0-9]*$/"), value) {
      errors->Dict.set(key->getStringFromVariant, "Please enter a profile name"->Js.Json.string)
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
  let errors = Dict.make()
  let valuesDict = values->LogicUtils.getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    let value = valuesDict->LogicUtils.getString(key->getStringFromVariant, "")

    value->String.length <= 0 ? key->validateEmptyValue(errors) : key->validateCustom(errors, value) // empty check // custom validations
  })

  // duplicate entry check
  if (
    list
    ->Array.find(item => {
      let profileName = valuesDict->getUserEnteredProfileDetails
      item.profile_name === profileName
    })
    ->Belt.Option.isSome
  ) {
    errors->Dict.set(
      "profile_name",
      "The entry you are trying to add already exists."->Js.Json.string,
    )
  }

  errors->Js.Json.object_
}
