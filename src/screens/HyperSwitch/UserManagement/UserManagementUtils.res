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
  | "emailList" => Dict.set(errors, "email", "Please enter Invite mails"->Js.Json.string)
  | _ => Dict.set(errors, key, `Please enter a ${key->LogicUtils.snakeToTitle}`->Js.Json.string)
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
        if ele->Js.Json.decodeString->Belt.Option.getWithDefault("")->HSwitchUtils.isValidEmail {
          errors->Dict.set("email", "Please enter a valid email"->Js.Json.string)
        }
      })
      ()
    }
  })

  errors->Js.Json.object_
}

let roleListDataMapper: UserRoleEntity.roleListResponse => SelectBox.dropdownOption = ele => {
  {
    label: ele.role_name,
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
  ->LogicUtils.getArrayFromDict("permissions", [])
  ->Array.map(i => i->Js.Json.decodeString->Belt.Option.getWithDefault(""))
}

let updatePresentInInfoList = (infoData, permissionsData) => {
  let copyOfInfoData = infoData->Array.copy
  let copyOfPermissionsData = permissionsData->Array.copy

  copyOfInfoData->Array.map((infoValItem: ProviderTypes.getInfoType) => {
    infoValItem.permissions->Array.forEachWithIndex((
      enumValue: ProviderTypes.permissions,
      index,
    ) => {
      if copyOfPermissionsData->Array.includes(enumValue.enum_name) {
        enumValue.isPermissionAllowed = true
      }
      infoValItem.permissions[index] = enumValue
    })
    infoValItem
  })
}

let defaultPresentInInfoList = infoData => {
  let copyOfInfoData = infoData->Array.copy

  copyOfInfoData->Array.map((infoValItem: ProviderTypes.getInfoType) => {
    infoValItem.permissions->Array.forEach((enumValue: ProviderTypes.permissions) => {
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
    ~readWriteValues: array<ProviderTypes.permissions>,
  ) => {
    let getReadWriteValue = index => {
      readWriteValues->LogicUtils.getValueFromArray(index, ProviderHelper.getDefaultValueOfEnum)
    }
    let readValue = getReadWriteValue(0).description
    let writeValue = getReadWriteValue(1).description
    let isPermissionAllowedForRead = getReadWriteValue(0).isPermissionAllowed
    let isPermissionAllowedForWrite = getReadWriteValue(1).isPermissionAllowed

    <div className="flex flex-col gap-1">
      <div className="flex items-center gap-3">
        <div className="font-semibold w-1/2"> {heading->React.string} </div>
        <div className="flex items-center gap-3 w-1/2">
          <Icon size=14 name={isPermissionAllowedForRead ? "permitted" : "not-permitted"} />
          <div className="text-base text-hyperswitch_black opacity-50">
            {readValue->React.string}
          </div>
        </div>
      </div>
      <div className="flex items-center gap-3">
        <div className="mt-2 text-base text-hyperswitch_black opacity-50 w-1/2">
          {description->React.string}
        </div>
        <UIUtils.RenderIf condition={writeValue->String.length > 0}>
          <div className="flex items-center gap-3 w-1/2">
            <Icon size=14 name={isPermissionAllowedForWrite ? "permitted" : "not-permitted"} />
            <div className="text-base text-hyperswitch_black opacity-50">
              {writeValue->React.string}
            </div>
          </div>
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}

let roleListResponseMapper: Js.Dict.t<Js.Json.t> => UserRoleEntity.roleListResponse = dict => {
  open LogicUtils
  {
    role_id: dict->getString("role_id", ""),
    role_name: dict->getString("role_name", ""),
  }
}
