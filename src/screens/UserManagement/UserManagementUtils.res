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
        (),
      )
    }
  )->InputFields.iconFieldWithMessageDes(~description="Press Enter to add more", ()),
  ~isRequired=true,
  (),
)

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

let roleListDataMapper: UserRoleEntity.roleListResponse => SelectBox.dropdownOption = ele => {
  let roleNameToDisplay = switch ele.role_name {
  | "iam" => ele.role_name->String.toLocaleUpperCase
  | _ => ele.role_name->LogicUtils.snakeToTitle
  }

  {
    label: roleNameToDisplay,
    value: ele.role_id,
  }
}

let roleOptions: array<UserRoleEntity.roleListResponse> => array<
  SelectBox.dropdownOption,
> = roleListData => roleListData->Array.map(roleListDataMapper)

let roleType = roleListData =>
  FormRenderer.makeFieldInfo(
    ~label="Choose a role",
    ~name="roleType",
    ~customInput=InputFields.infraSelectInput(
      ~options=roleOptions(roleListData),
      ~allowMultiSelect=false,
      ~selectedClass="border border-blue-750",
      (),
    ),
    ~isRequired=true,
    (),
  )

let getArrayOfPermissionData = json => {
  json
  ->LogicUtils.getDictFromJsonObject
  ->LogicUtils.getArrayFromDict("groups", [])
  ->Array.map(i => i->JSON.Decode.string->Option.getOr(""))
}

let updatePresentInInfoList = (infoData, permissionsData) => {
  let copyOfInfoData = infoData->Array.copy
  let copyOfPermissionsData = permissionsData->Array.copy

  copyOfInfoData->Array.map((infoValItem: UserManagementTypes.getInfoType) => {
    if copyOfPermissionsData->Array.includes(infoValItem.module_) {
      infoValItem.isPermissionAllowed = true
    } else {
      infoValItem.isPermissionAllowed = false
    }
    infoValItem
  })
}

let defaultPresentInInfoList = infoData => {
  let copyOfInfoData = infoData->Array.copy

  copyOfInfoData->Array.map((infoValItem: UserManagementTypes.getInfoType) => {
    infoValItem.permissions->Array.forEach((enumValue: UserManagementTypes.permissions) => {
      enumValue.isPermissionAllowed = false
    })
    infoValItem
  })
}

module RolePermissionValueRenderer = {
  @react.component
  let make = (
    ~heading: string,
    ~description: string,
    ~readWriteValues as _: array<UserManagementTypes.permissions>,
    ~isPermissionAllowed: bool=false,
  ) => {
    <div className="flex justify-between">
      <div className="flex flex-col gap-3 items-start col-span-1">
        <div className="font-semibold"> {heading->React.string} </div>
        <div className="text-base text-hyperswitch_black opacity-50 flex-1">
          {description->React.string}
        </div>
      </div>
      <Icon size=22 name={isPermissionAllowed ? "permitted" : "not-permitted"} />
    </div>
  }
}

let roleListResponseMapper: Dict.t<JSON.t> => UserRoleEntity.roleListResponse = dict => {
  open LogicUtils
  {
    role_id: dict->getString("role_id", ""),
    role_name: dict->getString("role_name", ""),
  }
}
