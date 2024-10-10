let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

let inviteEmail = FormRenderer.makeFieldInfo(
  ~label="Enter email",
  ~name="emailList",
  ~customInput=(
    (~input, ~placeholder as _) => {
      let showPlaceHolder = input.value->LogicUtils.getArrayFromJson([])->Array.length === 0
      InputFields.textTagInput(
        ~input,
        ~placeholder=showPlaceHolder ? "Eg: mehak.sam@wise.com, deepak.ven@wise.com" : "",
        ~customButtonStyle="!rounded-full !px-4",
        ~seperateByComma=true,
      )
    }
  )->InputFields.iconFieldWithMessageDes(~description="Press Enter to add more"),
  ~isRequired=true,
)

let createCustomRole = FormRenderer.makeFieldInfo(
  ~label="Enter custom role name",
  ~name="role_name",
  ~customInput=InputFields.textInput(~autoComplete="off", ~autoFocus=false),
  ~isRequired=true,
)

let roleScope = userRole => {
  let roleScopeArray = ["Merchant", "Organization"]->Array.map(item => {
    let option: SelectBox.dropdownOption = {
      label: item,
      value: item->String.toLowerCase,
    }
    option
  })

  FormRenderer.makeFieldInfo(
    ~label="Role Scope",
    ~name="role_scope",
    ~customInput=InputFields.selectInput(
      ~options=roleScopeArray,
      ~buttonText="Select Option",
      ~deselectDisable=true,
      ~disableSelect=userRole === "org_admin" ? false : true,
    ),
    ~isRequired=true,
  )
}

let validateEmptyValue = (key, errors) => {
  switch key {
  | "emailList" => Dict.set(errors, "email", "Please enter Invite mails"->JSON.Encode.string)
  | _ => Dict.set(errors, key, `Please enter a ${key->LogicUtils.snakeToTitle}`->JSON.Encode.string)
  }
}

let validateForm = (values, ~fieldsToValidate: array<string>) => {
  let errors = Dict.make()
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject

  fieldsToValidate->Array.forEach(key => {
    let value = LogicUtils.getArrayFromDict(valuesDict, key, [])
    if value->Array.length === 0 {
      key->validateEmptyValue(errors)
    } else {
      value->Array.forEach(ele => {
        if ele->JSON.Decode.string->Option.getOr("")->HSwitchUtils.isValidEmail {
          errors->Dict.set("email", "Please enter a valid email"->JSON.Encode.string)
        }
      })
      ()
    }
  })

  errors->JSON.Encode.object
}
let validateFormForRoles = values => {
  let errors = Dict.make()
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  if valuesDict->getString("role_scope", "")->isEmptyString {
    Dict.set(errors, "role_scope", "Role scope is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->isEmptyString {
    Dict.set(errors, "role_name", "Role name is required"->JSON.Encode.string)
  }
  if valuesDict->getString("role_name", "")->String.length > 64 {
    Dict.set(errors, "role_name", "Role name should be less than 64 characters"->JSON.Encode.string)
  }
  if valuesDict->getArrayFromDict("groups", [])->Array.length === 0 {
    Dict.set(errors, "groups", "Roles required"->JSON.Encode.string)
  }
  errors->JSON.Encode.object
}

let tabIndeToVariantMapper = index => {
  open UserManagementTypes
  switch index {
  | 0 => UsersTab
  | _ => RolesTab
  }
}

let getUserManagementViewValues = (~checkUserEntity) => {
  open UserManagementTypes

  let org = {
    label: "Organization",
    entity: #Organization,
  }
  let merchant = {
    label: "Merchant",
    entity: #Merchant,
  }
  let profile = {
    label: "Profile",
    entity: #Profile,
  }
  let default = {
    label: "My Team",
    entity: #Default,
  }

  if checkUserEntity([#Organization]) {
    [default, org, merchant, profile]
  } else if checkUserEntity([#Merchant]) {
    [default, merchant, profile]
  } else {
    [default]
  }
}

let stringToVariantMapper = roleId => {
  open UserManagementTypes
  switch roleId {
  | "internal_view_only" => InternalViewOnly
  | "internal_admin" => InternalAdmin
  | _ => NonInternal
  }
}
