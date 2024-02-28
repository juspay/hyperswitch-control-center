open AuthTypes

type permissionType =
  | PaymentRead
  | PaymentWrite
  | RefundRead
  | RefundWrite
  | ApiKeyRead
  | ApiKeyWrite
  | MerchantAccountRead
  | MerchantAccountWrite
  | MerchantConnectorAccountRead
  | MerchantConnectorAccountWrite
  | ForexRead
  | RoutingRead
  | RoutingWrite
  | DisputeRead
  | DisputeWrite
  | MandateRead
  | MandateWrite
  | CustomerRead
  | CustomerWrite
  | FileRead
  | FileWrite
  | Analytics
  | ThreeDsDecisionManagerWrite
  | ThreeDsDecisionManagerRead
  | SurchargeDecisionManagerWrite
  | SurchargeDecisionManagerRead
  | UsersRead
  | UsersWrite
  | UnknownPermission(string)

type permissionJson = {
  paymentRead: authorization,
  paymentWrite: authorization,
  refundRead: authorization,
  refundWrite: authorization,
  apiKeyRead: authorization,
  apiKeyWrite: authorization,
  merchantAccountRead: authorization,
  merchantAccountWrite: authorization,
  merchantConnectorAccountRead: authorization,
  merchantConnectorAccountWrite: authorization,
  forexRead: authorization,
  routingRead: authorization,
  routingWrite: authorization,
  disputeRead: authorization,
  disputeWrite: authorization,
  mandateRead: authorization,
  mandateWrite: authorization,
  customerRead: authorization,
  customerWrite: authorization,
  fileRead: authorization,
  fileWrite: authorization,
  analytics: authorization,
  threeDsDecisionManagerWrite: authorization,
  threeDsDecisionManagerRead: authorization,
  surchargeDecisionManagerWrite: authorization,
  surchargeDecisionManagerRead: authorization,
  usersRead: authorization,
  usersWrite: authorization,
}

let mapPermissionTypeToString = permissionType => {
  switch permissionType {
  | PaymentRead => "PaymentRead"
  | PaymentWrite => "PaymentWrite"
  | RefundRead => "RefundRead"
  | RefundWrite => "RefundWrite"
  | ApiKeyRead => "ApiKeyRead"
  | ApiKeyWrite => "ApiKeyWrite"
  | MerchantAccountRead => "MerchantAccountRead"
  | MerchantAccountWrite => "MerchantAccountWrite"
  | MerchantConnectorAccountRead => "MerchantConnectorAccountRead"
  | MerchantConnectorAccountWrite => "MerchantConnectorAccountWrite"
  | ForexRead => "ForexRead"
  | RoutingRead => "RoutingRead"
  | RoutingWrite => "RoutingWrite"
  | DisputeRead => "DisputeRead"
  | DisputeWrite => "DisputeWrite"
  | MandateRead => "MandateRead"
  | MandateWrite => "MandateWrite"
  | CustomerRead => "CustomerRead"
  | CustomerWrite => "CustomerWrite"
  | FileRead => "FileRead"
  | FileWrite => "FileWrite"
  | Analytics => "Analytics"
  | ThreeDsDecisionManagerWrite => "ThreeDsDecisionManagerWrite"
  | ThreeDsDecisionManagerRead => "ThreeDsDecisionManagerRead"
  | SurchargeDecisionManagerWrite => "SurchargeDecisionManagerWrite"
  | SurchargeDecisionManagerRead => "SurchargeDecisionManagerRead"
  | UsersRead => "UsersRead"
  | UsersWrite => "UsersWrite"
  | UnknownPermission(val) => val
  }
}

let mapStringToPermissionType = val => {
  switch val {
  | "PaymentRead" => PaymentRead
  | "PaymentWrite" => PaymentWrite
  | "RefundRead" => RefundRead
  | "RefundWrite" => RefundWrite
  | "ApiKeyRead" => ApiKeyRead
  | "ApiKeyWrite" => ApiKeyWrite
  | "MerchantAccountRead" => MerchantAccountRead
  | "MerchantAccountWrite" => MerchantAccountWrite
  | "MerchantConnectorAccountRead" => MerchantConnectorAccountRead
  | "MerchantConnectorAccountWrite" => MerchantConnectorAccountWrite
  | "ForexRead" => ForexRead
  | "RoutingRead" => RoutingRead
  | "RoutingWrite" => RoutingWrite
  | "DisputeRead" => DisputeRead
  | "DisputeWrite" => DisputeWrite
  | "MandateRead" => MandateRead
  | "MandateWrite" => MandateWrite
  | "CustomerRead" => CustomerRead
  | "CustomerWrite" => CustomerWrite
  | "FileRead" => FileRead
  | "FileWrite" => FileWrite
  | "Analytics" => Analytics
  | "ThreeDsDecisionManagerWrite" => ThreeDsDecisionManagerWrite
  | "ThreeDsDecisionManagerRead" => ThreeDsDecisionManagerRead
  | "SurchargeDecisionManagerWrite" => SurchargeDecisionManagerWrite
  | "SurchargeDecisionManagerRead" => SurchargeDecisionManagerRead
  | "UsersRead" => UsersRead
  | "UsersWrite" => UsersWrite
  | val => UnknownPermission(val)
  }
}

let getAccessValue = (~permissionValue: permissionType, ~permissionList) => {
  let isPermissionFound = permissionList->Array.find(ele => {
    ele === permissionValue
  })

  isPermissionFound->Option.isSome ? Access : NoAccess
}

let defaultValueForPermission = {
  paymentRead: NoAccess,
  paymentWrite: NoAccess,
  refundRead: NoAccess,
  refundWrite: NoAccess,
  apiKeyRead: NoAccess,
  apiKeyWrite: NoAccess,
  merchantAccountRead: NoAccess,
  merchantAccountWrite: NoAccess,
  merchantConnectorAccountRead: NoAccess,
  merchantConnectorAccountWrite: NoAccess,
  forexRead: NoAccess,
  routingRead: NoAccess,
  routingWrite: NoAccess,
  disputeRead: NoAccess,
  disputeWrite: NoAccess,
  mandateRead: NoAccess,
  mandateWrite: NoAccess,
  customerRead: NoAccess,
  customerWrite: NoAccess,
  fileRead: NoAccess,
  fileWrite: NoAccess,
  analytics: NoAccess,
  threeDsDecisionManagerWrite: NoAccess,
  threeDsDecisionManagerRead: NoAccess,
  surchargeDecisionManagerWrite: NoAccess,
  surchargeDecisionManagerRead: NoAccess,
  usersRead: NoAccess,
  usersWrite: NoAccess,
}

// TODO: Refactor to not call function for every permission
let getPermissionJson = permissionList => {
  {
    paymentRead: getAccessValue(~permissionValue=PaymentRead, ~permissionList),
    paymentWrite: getAccessValue(~permissionValue=PaymentWrite, ~permissionList),
    refundRead: getAccessValue(~permissionValue=RefundRead, ~permissionList),
    refundWrite: getAccessValue(~permissionValue=RefundWrite, ~permissionList),
    apiKeyRead: getAccessValue(~permissionValue=ApiKeyRead, ~permissionList),
    apiKeyWrite: getAccessValue(~permissionValue=ApiKeyWrite, ~permissionList),
    merchantAccountRead: getAccessValue(~permissionValue=MerchantAccountRead, ~permissionList),
    merchantAccountWrite: getAccessValue(~permissionValue=MerchantAccountWrite, ~permissionList),
    merchantConnectorAccountRead: getAccessValue(
      ~permissionValue=MerchantConnectorAccountRead,
      ~permissionList,
    ),
    merchantConnectorAccountWrite: getAccessValue(
      ~permissionValue=MerchantConnectorAccountWrite,
      ~permissionList,
    ),
    forexRead: getAccessValue(~permissionValue=ForexRead, ~permissionList),
    routingRead: getAccessValue(~permissionValue=RoutingRead, ~permissionList),
    routingWrite: getAccessValue(~permissionValue=RoutingWrite, ~permissionList),
    disputeRead: getAccessValue(~permissionValue=DisputeRead, ~permissionList),
    disputeWrite: getAccessValue(~permissionValue=DisputeWrite, ~permissionList),
    mandateRead: getAccessValue(~permissionValue=MandateRead, ~permissionList),
    mandateWrite: getAccessValue(~permissionValue=MandateWrite, ~permissionList),
    customerRead: getAccessValue(~permissionValue=CustomerRead, ~permissionList),
    customerWrite: getAccessValue(~permissionValue=CustomerWrite, ~permissionList),
    fileRead: getAccessValue(~permissionValue=FileRead, ~permissionList),
    fileWrite: getAccessValue(~permissionValue=FileWrite, ~permissionList),
    analytics: getAccessValue(~permissionValue=Analytics, ~permissionList),
    threeDsDecisionManagerWrite: getAccessValue(
      ~permissionValue=ThreeDsDecisionManagerWrite,
      ~permissionList,
    ),
    threeDsDecisionManagerRead: getAccessValue(
      ~permissionValue=ThreeDsDecisionManagerRead,
      ~permissionList,
    ),
    surchargeDecisionManagerWrite: getAccessValue(
      ~permissionValue=SurchargeDecisionManagerWrite,
      ~permissionList,
    ),
    surchargeDecisionManagerRead: getAccessValue(
      ~permissionValue=SurchargeDecisionManagerRead,
      ~permissionList,
    ),
    usersRead: getAccessValue(~permissionValue=UsersRead, ~permissionList),
    usersWrite: getAccessValue(~permissionValue=UsersWrite, ~permissionList),
  }
}

let linkForGetShowLinkViaAccess = (~permission, ~url) => {
  permission === Access ? url : ``
}

let cursorStyles = permission => permission === Access ? "cursor-pointer" : "cursor-not-allowed"
