@react.component
let make = (~onClick) => {
  open AuthProviderTypes
  open APIUtils
  open LogicUtils
  open PreLoginUtils
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
        ~queryParamerters=Some("status_check=true"),
      )
      let res = await updateDetails(url, body, Post)

      let status = res->getStringFromJson("")
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
        ~userType={#TERMINATE_ACCEPT_INVITE},
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
      let _ = await acceptInviteWithStatusCheck(body)

      if errorMessage->isEmptyString {
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

  let handleInviteFlow = () => {
    open CommonAuthUtils
    open TwoFaUtils
    open GlobalVars
    RescriptReactRouter.replace(appendDashboardPath(~url="/accept_invite_from_email"))
    let emailToken = authStatus->getEmailToken

    switch emailToken {
    | Some(token) => token->generateBodyForEmailRedirection->processInviteFlow->ignore
    | None => setErrorMessage(_ => "Token not received")
    }
  }

  React.useEffect(() => {
    handleInviteFlow()
    None
  }, [])

  <EmailVerifyScreen
    errorMessage
    onClick
    trasitionMessage={isProcessingToken
      ? "Accepting invite... You will be redirected to the Dashboard.."
      : "Processing invitation... Please wait..."}
  />
}
