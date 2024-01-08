module InviteEmailForm = {
  open UserManagementUtils
  @react.component
  let make = (~setRoleTypeValue) => {
    open LogicUtils
    open APIUtils
    let fetchDetails = useGetMethod()
    let (roleListData, setRoleListData) = React.useState(_ => [])

    let emailList =
      ReactFinalForm.useField("emailList").input.value->getArrayFromJson([])->Array.joinWith(",")
    let role =
      ReactFinalForm.useField(`roleType`).input.value
      ->getArrayFromJson([])
      ->LogicUtils.getValueFromArray(0, ""->Js.Json.string)
      ->getStringFromJson("")

    let getRolesList = async () => {
      try {
        let roleListUrl = getURL(
          ~entityName=USER_MANAGEMENT,
          ~userRoleTypes=ROLE_LIST,
          ~methodType=Get,
          (),
        )
        let response = await fetchDetails(roleListUrl)
        let typedResponse: array<UserRoleEntity.roleListResponse> =
          response->LogicUtils.getArrayDataFromJson(roleListResponseMapper)
        setRoleListData(_ => typedResponse)
      } catch {
      | _ => ()
      }
    }

    React.useEffect0(() => {
      getRolesList()->ignore
      None
    })

    React.useEffect1(() => {
      setRoleTypeValue(_ => role)
      None
    }, [role])

    <>
      <div className="flex justify-between">
        <div className="flex flex-col w-full">
          <FormRenderer.FieldRenderer
            field=inviteEmail
            fieldWrapperClass="w-4/5"
            labelClass="!text-black !text-base !-ml-[0.5px]"
          />
          <div className="text-sm text-grey-500"> {emailList->React.string} </div>
        </div>
        <div className="absolute top-10 right-5">
          <FormRenderer.SubmitButton text="Send Invite" />
        </div>
      </div>
      <FormRenderer.FieldRenderer
        fieldWrapperClass="w-full mt-5"
        field={roleType(roleListData)}
        errorClass
        labelClass="!text-black !font-semibold"
      />
    </>
  }
}

@react.component
let make = () => {
  open UserManagementUtils
  open APIUtils
  open LogicUtils
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (roleTypeValue, setRoleTypeValue) = React.useState(_ => "merchant_view_only")
  let (roleDict, setRoleDict) = React.useState(_ => Dict.make())

  let initialValues = React.useMemo0(() => {
    [("roleType", ["merchant_view_only"->Js.Json.string]->Js.Json.array)]
    ->Dict.fromArray
    ->Js.Json.object_
  })

  let inviteUserReq = async (body, index) => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#INVITE, ~methodType=Post, ())
      let _ = await updateDetails(url, body, Post)
      if index === 0 {
        showToast(~message=`Invite(s) sent successfully via Email`, ~toastType=ToastSuccess, ())
      }
    } catch {
    | _ => ()
    }
  }

  let inviteListOfUsers = async values => {
    let valDict = values->getDictFromJsonObject
    let role = valDict->getStrArray("roleType")->LogicUtils.getValueFromArray(0, "")

    valDict
    ->getStrArray("emailList")
    ->Array.forEachWithIndex((ele, index) => {
      let body =
        [
          ("email", ele->String.toLowerCase->Js.Json.string),
          ("name", ele->getNameFromEmail->Js.Json.string),
          ("role_id", role->Js.Json.string),
        ]
        ->Dict.fromArray
        ->Js.Json.object_
      let _ = inviteUserReq(body, index)
    })
    await HyperSwitchUtils.delay(400)
    RescriptReactRouter.push("/users")
    Js.Nullable.null
  }

  let onSubmit = (values, _) => {
    inviteListOfUsers(values)
  }

  let settingUpValues = (json, permissionInfoValue) => {
    let defaultList = defaultPresentInInfoList(permissionInfoValue)
    setPermissionInfo(_ => defaultList)
    let updatedPermissionListForGivenRole = updatePresentInInfoList(
      defaultList,
      json->getArrayOfPermissionData,
    )
    setPermissionInfo(_ => updatedPermissionListForGivenRole)
  }

  let getRoleForUser = async permissionInfoValue => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)

      let url = getURL(
        ~entityName=USER_MANAGEMENT,
        ~userRoleTypes=ROLE_ID,
        ~id=Some(roleTypeValue),
        ~methodType=Get,
        (),
      )
      let res = await fetchDetails(url)
      setRoleDict(prevDict => {
        prevDict->Dict.set(roleTypeValue, res)
        prevDict
      })
      settingUpValues(res, permissionInfoValue)
      await HyperSwitchUtils.delay(200)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let getRoleInfo = permissionInfoValue => {
    let roleTypeValue = roleDict->Dict.get(roleTypeValue)
    if roleTypeValue->Belt.Option.isNone {
      getRoleForUser(permissionInfoValue)->ignore
    } else {
      settingUpValues(roleTypeValue->Belt.Option.getWithDefault(Js.Json.null), permissionInfoValue)
    }
  }

  let getPermissionInfo = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#PERMISSION_INFO, ~methodType=Get, ())
      let res = await fetchDetails(url)
      let permissionInfoValue = res->getArrayDataFromJson(ProviderHelper.itemToObjMapperForGetInfo)

      setPermissionInfo(_ => permissionInfoValue)
      getRoleInfo(permissionInfoValue)
    } catch {
    | _ => ()
    }
  }

  React.useEffect1(() => {
    if permissionInfo->Array.length === 0 {
      getPermissionInfo()->ignore
    } else {
      getRoleInfo(permissionInfo)
    }
    None
  }, [roleTypeValue])

  <div className="flex flex-col overflow-y-scroll h-full">
    <BreadCrumbNavigation
      path=[{title: "Users", link: "/users"}] currentPageTitle="Invite new users"
    />
    <PageUtils.PageHeading
      title="Invite New Users"
      subTitle="An invite will be sent to the email addresses to set up a new account"
    />
    <div className="h-4/5 bg-white mt-5 p-10 relative overflow-y-scroll flex flex-col gap-10">
      <Form
        key="invite-user-management"
        initialValues={initialValues}
        validate={values => values->validateForm(~fieldsToValidate=["emailList"])}
        onSubmit>
        <InviteEmailForm setRoleTypeValue />
      </Form>
      <PageLoaderWrapper screenState={screenState}>
        <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
          {permissionInfo
          ->Array.mapWithIndex((ele, index) => {
            <RolePermissionValueRenderer
              key={index->string_of_int}
              heading={`${ele.module_} module`}
              description={ele.description}
              readWriteValues={ele.permissions}
            />
          })
          ->React.array}
        </div>
      </PageLoaderWrapper>
    </div>
  </div>
}
