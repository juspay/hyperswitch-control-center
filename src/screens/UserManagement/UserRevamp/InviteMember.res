@react.component
let make = (~isInviteUserFlow=true, ~setNewRoleSelected=_ => ()) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {email} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (loaderForInviteUsers, setLoaderForInviteUsers) = React.useState(_ => false)
  let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id")
  let {getCommonSessionDetails, getResolvedUserInfo} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {userEntity} = getResolvedUserInfo()
  let {orgId, merchantId, profileId} = getCommonSessionDetails()

  let invitationFormInitialValues = React.useMemo(() => {
    /*
     INFO: For user_entity the default values (Organisation , Merchant , Profile) will be 

    Organization -> (Current orgId , All Merchants, All Profiles)
    Merchant -> (Current orgId , Current merchantId , All Profiles)
    Profile -> (Current orgId , Current merchantId , Current profileId) 
 */

    let initialvalue = [("org_value", orgId->JSON.Encode.string)]

    if userEntity == #Tenant {
      initialvalue->Array.pushMany([
        ("merchant_value", merchantId->JSON.Encode.string),
        ("profile_value", profileId->JSON.Encode.string),
      ])
    } else if userEntity == #Organization {
      initialvalue->Array.pushMany([
        ("merchant_value", merchantId->JSON.Encode.string),
        ("profile_value", profileId->JSON.Encode.string),
      ])
    } else if userEntity == #Merchant {
      initialvalue->Array.pushMany([
        ("merchant_value", merchantId->JSON.Encode.string),
        ("profile_value", profileId->JSON.Encode.string),
      ])
    } else if userEntity == #Profile {
      initialvalue->Array.pushMany([
        ("merchant_value", merchantId->JSON.Encode.string),
        ("profile_value", profileId->JSON.Encode.string),
      ])
    }
    initialvalue->getJsonFromArrayOfJson
  }, [userEntity])

  let inviteListOfUsersWithInviteMultiple = async values => {
    let url = getURL(
      ~entityName=V1(USERS),
      ~userType=#INVITE_MULTIPLE,
      ~methodType=Post,
      ~queryParameters=Some(`auth_id=${authId}`),
    )

    if !email {
      setLoaderForInviteUsers(_ => true)
    }
    let valDict = values->getDictFromJsonObject
    let role = valDict->getString("role_id", "")
    let emailList = valDict->getStrArray("email_list")

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

    let response = await updateDetails(url, body, Post)
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
        "Error sending emails or creating users. Please check if the user already exists and try again.",
        ToastState.ToastError,
      )
    } else if (
      decodedResponse->Array.some(ele => {
        let error = ele->getDictFromJsonObject->getOptionString("error")
        error->Option.isSome && error->Option.getExn->String.includes("account already exists")
      })
    ) {
      ("Some users already exist. Please check the details and try again.", ToastState.ToastWarning)
    } else {
      (
        email
          ? `Invite(s) sent successfully via Email`
          : `The user accounts have been successfully created. The file with their credentials has been downloaded.`,
        ToastState.ToastSuccess,
      )
    }

    showToast(~message, ~toastType)

    RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/users"))
    Nullable.null
  }

  let onSubmit = (values, _) => {
    mixpanelEvent(~eventName="send_invite", ~metadata=values)
    inviteListOfUsersWithInviteMultiple(values)
  }

  <div className="flex flex-col overflow-y-scroll gap-4 h-85-vh">
    <PageUtils.PageHeading title="Invite New Users" />
    <BreadCrumbNavigation
      path=[{title: "Team management", link: "/users"}] currentPageTitle="Invite new users"
    />
    <Form
      formClass="h-4/5 bg-white relative overflow-y-scroll flex flex-col gap-10 border rounded-md"
      key="invite-user-management"
      initialValues={invitationFormInitialValues}
      validate={values =>
        values->UserUtils.validateForm(~fieldsToValidate=["email_list", "role_id"])}
      onSubmit>
      <NewUserInvitationForm />
    </Form>
    <RenderIf condition={!email}>
      <LoaderModal
        showModal={loaderForInviteUsers}
        setShowModal={setLoaderForInviteUsers}
        text="Inviting Users"
      />
    </RenderIf>
  </div>
}
