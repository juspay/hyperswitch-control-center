type invitationAcceptanceStatus =
  | AlreadyAccepted
  | SuccessfullyAccepted
  | Unknown

let parseInvitationStatus = (statusString: string) => {
  switch statusString {
  | "AlreadyAccepted" => AlreadyAccepted
  | "SuccessfullyAccepted" => SuccessfullyAccepted
  | _ => Unknown
  }
}

let getStatusMessage = (status: invitationAcceptanceStatus) => {
  switch status {
  | AlreadyAccepted => "Your invitation has already been accepted"
  | SuccessfullyAccepted => "Invitation accepted successfully!"
  | Unknown => "Invitation processed"
  }
}

@react.component
let make = (~onClick) => {
  open AuthProviderTypes
  open APIUtils
  let getURL = useGetURL()

  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (isProcessingToken, setIsProcessingToken) = React.useState(_ => false)
  let {authStatus, setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let acceptInviteWithStatusCheck = async body => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Post,
        ~userType={#ACCEPT_INVITE_FROM_EMAIL},
        ~queryParamerters=Some("validate_only=true"),
      )
      let res = await updateDetails(url, body, Post)

      let status = res->JSON.Decode.string->Option.getOr("")
      let parsedStatus = parseInvitationStatus(status)
      let statusMessage = getStatusMessage(parsedStatus)

      showToast(~message=statusMessage, ~toastType=ToastSuccess)

      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Status check failed")
        setErrorMessage(_ => err)
        JSON.Encode.null
      }
    }
  }

  let generateTokenForceSetPassword = async body => {
    try {
      open AuthUtils

      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Post,
        ~userType={#GENERATE_TOKEN_FORCE_SET_PASSWORD},
      )
      let res = await updateDetails(url, body, Post)
      setAuthStatus(PreLogin(getPreLoginInfo(res)))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Token generation failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  let processInviteFlow = async body => {
    try {
      let _statusResponse = await acceptInviteWithStatusCheck(body)

      if errorMessage === "" {
        setIsProcessingToken(_ => true)
        await generateTokenForceSetPassword(body)
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Invitation process failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect(() => {
    open CommonAuthUtils
    open TwoFaUtils
    open GlobalVars
    RescriptReactRouter.replace(appendDashboardPath(~url="/accept_invite_from_email"))
    let emailToken = authStatus->getEmailToken

    switch emailToken {
    | Some(token) => token->generateBodyForEmailRedirection->processInviteFlow->ignore
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  }, [])

  <EmailVerifyScreen
    errorMessage
    onClick
    trasitionMessage={if isProcessingToken {
      "Accepting invite... You will be redirected to the Dashboard.."
    } else {
      "Processing invitation... Please wait..."
    }}
  />
}
