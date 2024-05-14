module InviteEmailForm = {
  open UserManagementUtils
  @react.component
  let make = (~setRoleTypeValue, ~isEmailTextInputVisible, ~setNewRoleSelected) => {
    open LogicUtils
    open APIUtils
    open UIUtils
    let getURL = useGetURL()
    let {globalUIConfig: {border: {borderColor}}} = React.useContext(ConfigContext.configContext)
    let fetchDetails = useGetMethod()
    let {email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let (roleListData, setRoleListData) = React.useState(_ => [])

    let role =
      ReactFinalForm.useField(`roleType`).input.value
      ->getArrayFromJson([])
      ->getValueFromArray(0, ""->JSON.Encode.string)
      ->getStringFromJson("")

    React.useEffect1(() => {
      setNewRoleSelected(_ => role)
      None
    }, [role])

    let getRolesList = async () => {
      try {
        let roleListUrl = getURL(
          ~entityName=USER_MANAGEMENT,
          ~userRoleTypes=ROLE_LIST,
          ~methodType=Get,
          (),
        )
        let response = await fetchDetails(`${roleListUrl}?groups=true`)
        let typedResponse: array<UserRoleEntity.roleListResponse> =
          response->getArrayDataFromJson(roleListResponseMapper)
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
      <RenderIf condition={isEmailTextInputVisible}>
        <div className="flex justify-between">
          <div className="flex flex-col w-full">
            <FormRenderer.FieldRenderer
              field=inviteEmail
              fieldWrapperClass="w-4/5"
              labelClass="!text-black !text-base !-ml-[0.5px]"
            />
          </div>
          <div className="absolute top-10 right-5">
            <FormRenderer.SubmitButton
              text={email ? "Send Invite" : "Add User"} loadingText="Loading..."
            />
          </div>
        </div>
      </RenderIf>
      <FormRenderer.FieldRenderer
        fieldWrapperClass={`w-full ${isEmailTextInputVisible ? "mt-5" : ""}`}
        field={roleType(roleListData, borderColor.primaryNormal)}
        errorClass
        labelClass="!text-black !font-semibold"
      />
    </>
  }
}

@react.component
let make = (~isInviteUserFlow=true, ~setNewRoleSelected=_ => (), ~currentRole=?) => {
  open UserManagementUtils
  open APIUtils
  open LogicUtils
  open UIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  let defaultRole = switch currentRole {
  | Some(val) => val
  | None => "merchant_view_only"
  }

  let {email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {permissionInfo, setPermissionInfo} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (roleTypeValue, setRoleTypeValue) = React.useState(_ => defaultRole)
  let (roleDict, setRoleDict) = React.useState(_ => Dict.make())
  let (loaderForInviteUsers, setLoaderForInviteUsers) = React.useState(_ => false)
  let paddingClass = isInviteUserFlow ? "p-10" : ""
  let marginClass = isInviteUserFlow ? "mt-5" : ""

  let initialValues = React.useMemo0(() => {
    [("roleType", [defaultRole->JSON.Encode.string]->JSON.Encode.array)]->getJsonFromArrayOfJson
  })

  let inviteListOfUsersWithInviteMultiple = async values => {
    let url = getURL(~entityName=USERS, ~userType=#INVITE_MULTIPLE, ~methodType=Post, ())
    if !email {
      setLoaderForInviteUsers(_ => true)
    }
    let valDict = values->getDictFromJsonObject
    let role = valDict->getStrArray("roleType")->getValueFromArray(0, "")
    let emailList = valDict->getStrArray("emailList")

    let body =
      emailList
      ->Array.map(ele =>
        [
          ("email", ele->String.toLowerCase->JSON.Encode.string),
          ("name", ele->getNameFromEmail->JSON.Encode.string),
          ("role_id", role->JSON.Encode.string),
        ]->getJsonFromArrayOfJson
      )
      ->JSON.Encode.array

    let response = await updateDetails(url, body, Post, ())
    let decodedResponse = response->getArrayFromJson([])

    if !email {
      let invitedUserData =
        decodedResponse
        ->Array.mapWithIndex((ele, index) => {
          let responseDict = ele->getDictFromJsonObject
          if (
            responseDict->getOptionString("error")->Option.isNone &&
              responseDict->getString("password", "")->String.length > 0
          ) {
            let passwordFromResponse = responseDict->getString("password", "")
            [
              ("email", emailList->getValueFromArray(index, "")->JSON.Encode.string),
              ("password", passwordFromResponse->JSON.Encode.string),
            ]->getJsonFromArrayOfJson
          } else {
            JSON.Encode.null
          }
        })
        ->Array.filter(ele => ele !== JSON.Encode.null)

      setLoaderForInviteUsers(_ => false)

      if invitedUserData->Array.length > 0 {
        DownloadUtils.download(
          ~fileName=`invited-users.txt`,
          ~content=invitedUserData->JSON.Encode.array->JSON.stringifyWithIndent(3),
          ~fileType="application/json",
        )
      }
    }

    let (message, toastType) = if (
      decodedResponse->Array.every(ele =>
        ele->getDictFromJsonObject->getOptionString("error")->Option.isSome
      )
    ) {
      (
        "We've faced some problem while sending emails or creating users. Please check and try again.",
        ToastState.ToastError,
      )
    } else if (
      decodedResponse->Array.some(ele =>
        ele->getDictFromJsonObject->getOptionString("error")->Option.isSome
      )
    ) {
      (
        "We faced difficulties sending some invitations. Please check and try again.",
        ToastState.ToastWarning,
      )
    } else {
      (
        email
          ? `Invite(s) sent successfully via Email`
          : `The user accounts have been successfully created. The file with their credentials has been downloaded.`,
        ToastState.ToastSuccess,
      )
    }

    showToast(~message, ~toastType, ())

    RescriptReactRouter.push(HSwitchGlobalVars.appendDashboardPath(~url="/users"))
    Nullable.null
  }

  let onSubmit = (values, _) => {
    inviteListOfUsersWithInviteMultiple(values)
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
      let res = await fetchDetails(`${url}?groups=true`)
      setRoleDict(prevDict => {
        prevDict->Dict.set(roleTypeValue, res)
        prevDict
      })
      settingUpValues(res, permissionInfoValue)
      await HyperSwitchUtils.delay(200)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let getRoleInfo = permissionInfoValue => {
    let roleTypeValue = roleDict->Dict.get(roleTypeValue)
    if roleTypeValue->Option.isNone {
      getRoleForUser(permissionInfoValue)->ignore
    } else {
      settingUpValues(roleTypeValue->Option.getOr(JSON.Encode.null), permissionInfoValue)
    }
  }

  let getPermissionInfo = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#PERMISSION_INFO, ~methodType=Get, ())
      let res = await fetchDetails(`${url}?groups=true`)
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
    <RenderIf condition={isInviteUserFlow}>
      <BreadCrumbNavigation
        path=[{title: "Users", link: "/users"}] currentPageTitle="Invite new users"
      />
      <PageUtils.PageHeading
        title="Invite New Users"
        subTitle="An invite will be sent to the email addresses to set up a new account"
      />
    </RenderIf>
    <div
      className={`h-4/5 bg-white relative overflow-y-scroll flex flex-col gap-10 ${paddingClass} ${marginClass}`}>
      <Form
        key="invite-user-management"
        initialValues={initialValues}
        validate={values => values->validateForm(~fieldsToValidate=["emailList"])}
        onSubmit>
        <InviteEmailForm
          setRoleTypeValue isEmailTextInputVisible=isInviteUserFlow setNewRoleSelected
        />
      </Form>
      <PageLoaderWrapper screenState={screenState}>
        <div className="flex flex-col justify-between gap-12 show-scrollbar overflow-scroll">
          {permissionInfo
          ->Array.mapWithIndex((ele, index) => {
            <RolePermissionValueRenderer
              key={index->Int.toString}
              heading={`${ele.module_->LogicUtils.snakeToTitle} module`}
              description={ele.description}
              isPermissionAllowed={ele.isPermissionAllowed}
            />
          })
          ->React.array}
        </div>
      </PageLoaderWrapper>
    </div>
    <RenderIf condition={!email}>
      <LoaderModal
        showModal={loaderForInviteUsers}
        setShowModal={setLoaderForInviteUsers}
        text="Inviting Users"
      />
    </RenderIf>
  </div>
}
