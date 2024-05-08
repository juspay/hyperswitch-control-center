@react.component
let make = () => {
  open AuthProviderTypes
  open APIUtils
  //   open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let verifyEmail = async body => {
    try {
      Js.log("IMPLEMENT Verify Emila")
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    // Implement
    // verifyEmail()->ignore

    None
  })
  let onClick = () => {
    RescriptReactRouter.replace(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
  }

  <EmailVerifyScreen errorMessage onClick />
}
