open PermissionUtils
let isAccessAllowed = permission =>
  getAccessValue(
    ~permissionValue=permission,
    ~permissionList=[
      PaymentRead,
      PaymentWrite,
      RefundRead,
      RefundWrite,
      ApiKeyRead,
      ApiKeyWrite,
      MerchantAccountRead,
      MerchantAccountWrite,
      MerchantConnectorAccountRead,
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
    ],
  ) === Access

module UnauthorizedPage = {
  @react.component
  let make = (
    ~message="You don't have access to this module. Contact admin for access",
    ~customReqMsg=`It appears that you do not currently have access to the  module. To obtain access, kindly request it from your administrator using the "Request Access" action provided below.`,
  ) => {
    React.useEffect0(() => {
      RescriptReactRouter.replace("/unauthorized")
      None
    })
    <NoDataFound message renderType={Locked} />
  }
}

@react.component
let make = (~isEnabled, ~acl=?, ~children) => {
  let isAllowed = isAccessAllowed(acl->Option.getWithDefault(UnknownPermission("")))
  isEnabled && isAllowed ? children : <UnauthorizedPage />
}
