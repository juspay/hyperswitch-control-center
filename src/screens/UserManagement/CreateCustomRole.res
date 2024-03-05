module RenderCustomRoles = {
  @react.component
  let make = (~heading, ~description, ~groupName) => {
    let groupsInput = ReactFinalForm.useField(`groups`).input
    let groupsAdded = groupsInput.value->LogicUtils.getStrArryFromJson
    let (checkboxSelected, setCheckboxSelected) = React.useState(_ =>
      groupsAdded->Array.includes(groupName)
    )
    let onClickGroup = groupName => {
      if !(groupsAdded->Array.includes(groupName)) {
        let _ = groupsAdded->Array.push(groupName)
        groupsInput.onChange(groupsAdded->Identity.arrayOfGenericTypeToFormReactEvent)
      } else {
        let arr = groupsInput.value->LogicUtils.getStrArryFromJson

        let filteredValue = arr->Array.filter(value => {value !== groupName})
        groupsInput.onChange(filteredValue->Identity.arrayOfGenericTypeToFormReactEvent)
      }
      setCheckboxSelected(prev => !prev)
    }

    <div className="flex gap-6 items-start">
      <div className="mt-1">
        <CheckBoxIcon
          isSelected={checkboxSelected}
          setIsSelected={_ => {
            onClickGroup(groupName)
          }}
          size={Large}
        />
      </div>
      <div className="flex flex-col gap-3 items-start">
        <div className="font-semibold"> {heading->React.string} </div>
        <div className="text-base text-hyperswitch_black opacity-50 flex-1">
          {description->React.string}
        </div>
      </div>
    </div>
  }
}

module NewCustomRoleInputFields = {
  open UserManagementUtils
  @react.component
  let make = () => {
    let userRole = HSLocalStorage.getFromUserDetails("user_role")
    <div className="flex justify-between">
      <div className="flex flex-col gap-4 w-full">
        <FormRenderer.FieldRenderer
          field={userRole->roleScope}
          fieldWrapperClass="w-4/5"
          labelClass="!text-black !text-base !-ml-[0.5px]"
        />
        <FormRenderer.FieldRenderer
          field=createCustomRole
          fieldWrapperClass="w-4/5"
          labelClass="!text-black !text-base !-ml-[0.5px]"
        />
      </div>
      <div className="absolute top-10 right-5">
        <FormRenderer.SubmitButton text="Create role" loadingText="Loading..." />
      </div>
    </div>
  }
}

@react.component
let make = (~isInviteUserFlow=true, ~setNewRoleSelected=_ => ()) => {
  open APIUtils
  open LogicUtils
  open UIUtils
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let initialValuesForForm =
    [
      ("role_scope", "merchant"->JSON.Encode.string),
      ("groups", []->JSON.Encode.array),
    ]->Dict.fromArray

  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let paddingClass = isInviteUserFlow ? "p-10" : ""
  let marginClass = isInviteUserFlow ? "mt-5" : ""

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#CREATE_CUSTOM_ROLE, ~methodType=Post, ())
      let body = values->getDictFromJsonObject
      let _ = await updateDetails(url, body->JSON.Encode.object, Post, ())
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.replace("/users")
    } catch {
    | _ =>
      setScreenState(_ => PageLoaderWrapper.Error("Error Occured! Failed to create custom role."))
    }
    Nullable.null
  }

  let getPermissionInfo = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#PERMISSION_INFO, ~methodType=Get, ())
      let res = await fetchDetails(`${url}?groups=true`)
      let permissionInfoValue = res->getArrayDataFromJson(ProviderHelper.itemToObjMapperForGetInfo)
      setPermissionInfo(_ => permissionInfoValue)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect0(() => {
    if permissionInfo->Array.length === 0 {
      getPermissionInfo()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  })

  <div className="flex flex-col overflow-y-scroll h-full">
    <RenderIf condition={isInviteUserFlow}>
      <BreadCrumbNavigation
        path=[{title: "Users", link: "/users"}] currentPageTitle="Create custom roles"
      />
      <PageUtils.PageHeading
        title="Create custom roles" subTitle="A new custom role will be created"
      />
    </RenderIf>
    <div
      className={`h-4/5 bg-white relative overflow-y-scroll flex flex-col gap-10 ${paddingClass} ${marginClass}`}>
      <PageLoaderWrapper screenState>
        <Form
          key="invite-user-management"
          initialValues={initialValuesForForm->JSON.Encode.object}
          validate={values => values->UserManagementUtils.validateFormForRoles}
          onSubmit
          formClass="flex flex-col gap-8">
          <NewCustomRoleInputFields />
          <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
            {permissionInfo
            ->Array.mapWithIndex((ele, index) => {
              <RenderCustomRoles
                key={index->Int.toString}
                heading={`${ele.module_->snakeToTitle} module`}
                description={ele.description}
                groupName={ele.module_}
              />
            })
            ->React.array}
          </div>
          <FormValuesSpy />
        </Form>
      </PageLoaderWrapper>
    </div>
  </div>
}
