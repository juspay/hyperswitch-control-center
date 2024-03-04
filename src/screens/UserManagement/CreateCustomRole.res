module RenderCustomRoles = {
  @react.component
  let make = (~heading, ~description, ~groupName, ~groupsAdded, ~setGroupsAdded) => {
    // TODO : Refactor to use in the same form
    let (checkboxSelected, setCheckboxSelected) = React.useState(_ =>
      groupsAdded->Array.includes(groupName)
    )

    let handleRemoveOrAdd = () => {
      if !(groupsAdded->Array.includes(groupName)) {
        groupsAdded->Array.push(groupName)
        setGroupsAdded(_ => groupsAdded)
      } else {
        let filteredValue = groupsAdded->Array.filter(value => {value !== groupName})
        setGroupsAdded(_ => filteredValue)
      }
    }

    <div className="flex gap-6 items-start">
      <div onClick={_ => handleRemoveOrAdd()} className="mt-1">
        <CheckBoxIcon
          isSelected={checkboxSelected}
          setIsSelected={_ => setCheckboxSelected(prev => !prev)}
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

  let initialValuesForForm = [("role_scope", "merchant"->JSON.Encode.string)]->Dict.fromArray

  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let paddingClass = isInviteUserFlow ? "p-10" : ""
  let marginClass = isInviteUserFlow ? "mt-5" : ""

  let (groupsAdded, setGroupsAdded) = React.useState(_ => [])

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#CREATE_CUSTOM_ROLE, ~methodType=Post, ())
      let body = values->LogicUtils.getDictFromJsonObject
      let arrayVal = groupsAdded->Array.map(JSON.Encode.string)
      body->Dict.set("groups", arrayVal->JSON.Encode.array)
      let _ = await updateDetails(url, body->JSON.Encode.object, Post, ())
      RescriptReactRouter.replace("/users")
      setScreenState(_ => PageLoaderWrapper.Success)
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
        </Form>
        <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
          {permissionInfo
          ->Array.mapWithIndex((ele, index) => {
            <RenderCustomRoles
              key={index->Int.toString}
              heading={`${ele.module_->LogicUtils.snakeToTitle} module`}
              description={ele.description}
              groupName={ele.module_}
              groupsAdded
              setGroupsAdded
            />
          })
          ->React.array}
        </div>
      </PageLoaderWrapper>
    </div>
  </div>
}
