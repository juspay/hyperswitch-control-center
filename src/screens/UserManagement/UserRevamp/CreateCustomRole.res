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

    <RenderIf
      condition={groupName->GroupACLMapper.mapStringToGroupAccessType !== OrganizationManage}>
      <div className="flex gap-6 items-start cursor-pointer" onClick={_ => onClickGroup(groupName)}>
        <div className="mt-1">
          <CheckBoxIcon isSelected={checkboxSelected} size={Large} />
        </div>
        <div className="flex flex-col gap-3 items-start">
          <div className="font-semibold"> {heading->React.string} </div>
          <div className="text-base text-hyperswitch_black opacity-50 flex-1">
            {description->React.string}
          </div>
        </div>
      </div>
    </RenderIf>
  }
}

module NewCustomRoleInputFields = {
  open UserManagementUtils
  open CommonAuthHooks
  @react.component
  let make = () => {
    let {userRole} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
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
let make = (~isInviteUserFlow=true, ~setNewRoleSelected=_ => (), ~baseUrl, ~breadCrumbHeader) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let initialValuesForForm =
    [
      ("role_scope", "merchant"->JSON.Encode.string),
      ("groups", []->JSON.Encode.array),
    ]->Dict.fromArray

  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initalValue, setInitialValues) = React.useState(_ => initialValuesForForm)

  let paddingClass = isInviteUserFlow ? "p-10" : ""
  let marginClass = isInviteUserFlow ? "mt-5" : ""
  let showToast = ToastState.useShowToast()
  let onSubmit = async (values, _) => {
    try {
      // TODO -  Seperate RoleName & RoleId in Backend. role_name as free text and role_id as snake_text
      setScreenState(_ => PageLoaderWrapper.Loading)
      let copiedJson = JSON.parseExn(JSON.stringify(values))
      let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_CUSTOM_ROLE, ~methodType=Post)

      let body = copiedJson->getDictFromJsonObject->JSON.Encode.object
      let roleNameValue =
        body->getDictFromJsonObject->getString("role_name", "")->String.trim->titleToSnake
      body->getDictFromJsonObject->Dict.set("role_name", roleNameValue->JSON.Encode.string)
      let _ = await updateDetails(url, body, Post)
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/${baseUrl}`))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "UR_35" {
          setInitialValues(_ => values->LogicUtils.getDictFromJsonObject)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let getPermissionInfo = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#GROUP_ACCESS_INFO,
        ~methodType=Get,
        ~queryParamerters=Some(`groups=true`),
      )
      let res = await fetchDetails(url)
      let permissionInfoValue = res->getArrayDataFromJson(ProviderHelper.itemToObjMapperForGetInfo)
      setPermissionInfo(_ => permissionInfoValue)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    if permissionInfo->Array.length === 0 {
      getPermissionInfo()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [])

  <div className="flex flex-col overflow-y-scroll h-full">
    <RenderIf condition={isInviteUserFlow}>
      <div className="flex flex-col gap-2">
        <PageUtils.PageHeading
          title="Create custom role"
          subTitle="Adjust permissions to create custom roles that match your requirement"
        />
        <BreadCrumbNavigation
          path=[{title: breadCrumbHeader, link: `/${baseUrl}`}]
          currentPageTitle="Create custom roles"
        />
      </div>
    </RenderIf>
    <div
      className={`h-4/5 bg-white relative overflow-y-scroll flex flex-col gap-10 ${paddingClass} ${marginClass}`}>
      <PageLoaderWrapper screenState>
        <Form
          key="invite-user-management"
          initialValues={initalValue->JSON.Encode.object}
          validate={values => values->UserManagementUtils.validateFormForRoles}
          onSubmit
          formClass="flex flex-col gap-8">
          <NewCustomRoleInputFields />
          <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
            {permissionInfo
            ->Array.mapWithIndex((ele, index) => {
              <RenderCustomRoles
                key={index->Int.toString}
                heading={`${ele.module_->snakeToTitle}`}
                description={ele.description}
                groupName={ele.module_}
              />
            })
            ->React.array}
          </div>
        </Form>
      </PageLoaderWrapper>
    </div>
  </div>
}
