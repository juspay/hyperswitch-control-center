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
let make = (~isEnabled, ~acl=?, ~children) => {
  // let permissionList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let permissionList = [
    PaymentRead,
    PaymentWrite,
    RefundRead,
    RefundWrite,
    ApiKeyRead,
    ApiKeyWrite,
    MerchantAccountRead,
    MerchantAccountWrite,
    // MerchantConnectorAccountRead,
    ForexRead,
    MerchantConnectorAccountWrite,
    RoutingRead,
    RoutingWrite,
    ThreeDsDecisionManagerWrite,
    ThreeDsDecisionManagerRead,
    SurchargeDecisionManagerWrite,
    SurchargeDecisionManagerRead,
    DisputeRead,
    DisputeWrite,
    MandateRead,
    MandateWrite,
    CustomerRead,
    CustomerWrite,
    FileRead,
    FileWrite,
    Analytics,
    UsersRead,
    UsersWrite,
  ]
  let isAllowed = isAccessAllowed(
    acl->Option.getWithDefault(UnknownPermission("")),
    ~permissionList,
  )
  isEnabled && isAllowed ? children : <UnauthorizedPage />
}
