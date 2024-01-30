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
  paymentRead: Access,
  paymentWrite: Access,
  refundRead: Access,
  refundWrite: Access,
  apiKeyRead: Access,
  apiKeyWrite: Access,
  merchantAccountRead: Access,
  merchantAccountWrite: Access,
  merchantConnectorAccountRead: Access,
  merchantConnectorAccountWrite: Access,
  forexRead: Access,
  routingRead: Access,
  routingWrite: Access,
  disputeRead: Access,
  disputeWrite: Access,
  mandateRead: Access,
  mandateWrite: Access,
  customerRead: Access,
  customerWrite: Access,
  fileRead: Access,
  fileWrite: Access,
  analytics: Access,
  threeDsDecisionManagerWrite: Access,
  threeDsDecisionManagerRead: Access,
  surchargeDecisionManagerWrite: Access,
  surchargeDecisionManagerRead: Access,
  usersRead: Access,
  usersWrite: Access,
}

let getPermissionJson = permissionList => {
  let getAccessValueFromPermission = permissionValue =>
    getAccessValue(~permissionList, ~permissionValue)

  {
    paymentRead: PaymentRead->getAccessValueFromPermission,
    paymentWrite: PaymentWrite->getAccessValueFromPermission,
    refundRead: RefundRead->getAccessValueFromPermission,
    refundWrite: RefundWrite->getAccessValueFromPermission,
    apiKeyRead: ApiKeyRead->getAccessValueFromPermission,
    apiKeyWrite: ApiKeyWrite->getAccessValueFromPermission,
    merchantAccountRead: MerchantAccountRead->getAccessValueFromPermission,
    merchantAccountWrite: MerchantAccountWrite->getAccessValueFromPermission,
    merchantConnectorAccountRead: MerchantConnectorAccountRead->getAccessValueFromPermission,
    merchantConnectorAccountWrite: MerchantConnectorAccountWrite->getAccessValueFromPermission,
    forexRead: ForexRead->getAccessValueFromPermission,
    routingRead: RoutingRead->getAccessValueFromPermission,
    routingWrite: RoutingWrite->getAccessValueFromPermission,
    disputeRead: DisputeRead->getAccessValueFromPermission,
    disputeWrite: DisputeWrite->getAccessValueFromPermission,
    mandateRead: MandateRead->getAccessValueFromPermission,
    mandateWrite: MandateWrite->getAccessValueFromPermission,
    customerRead: CustomerRead->getAccessValueFromPermission,
    customerWrite: CustomerWrite->getAccessValueFromPermission,
    fileRead: FileRead->getAccessValueFromPermission,
    fileWrite: FileWrite->getAccessValueFromPermission,
    analytics: Analytics->getAccessValueFromPermission,
    threeDsDecisionManagerWrite: ThreeDsDecisionManagerWrite->getAccessValueFromPermission,
    threeDsDecisionManagerRead: ThreeDsDecisionManagerRead->getAccessValueFromPermission,
    surchargeDecisionManagerWrite: SurchargeDecisionManagerWrite->getAccessValueFromPermission,
    surchargeDecisionManagerRead: SurchargeDecisionManagerRead->getAccessValueFromPermission,
    usersRead: UsersRead->getAccessValueFromPermission,
    usersWrite: UsersWrite->getAccessValueFromPermission,
  }
}
