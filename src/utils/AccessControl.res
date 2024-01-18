open PermissionUtils
let isAccessAllowed = (permission, ~permissionList) =>
  getAccessValue(~permissionValue=permission, ~permissionList) === Access

module UnauthorizedPage = {
  @react.component
  let make = (~message="You don't have access to this module. Contact admin for access") => {
    let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
    React.useEffect0(() => {
      RescriptReactRouter.replace("/unauthorized")
      None
    })
    <NoDataFound message renderType={Locked}>
      <Button
        text={"Go to Home"}
        buttonType=Primary
        onClick={_ => {
          setDashboardPageState(_ => #HOME)
          RescriptReactRouter.replace("/home")
        }}
        customButtonStyle="mt-4 !p-2"
      />
    </NoDataFound>
  }
}

@react.component
let make = (~isEnabled=true, ~permissions=?, ~children) => {
  let permissionList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let isAllowed = isAccessAllowed(permissions->Option.getWithDefault([]), ~permissionList)
  isEnabled && isAllowed ? children : <UnauthorizedPage />
}
