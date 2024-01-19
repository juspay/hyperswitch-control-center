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

let getAccessValue = (~permissionValue: permissionType, permissionList) => {
  open AuthTypes
  let isPermissionFound = permissionList->Array.find(ele => {
    ele === permissionValue
  })

  isPermissionFound->Option.isSome ? Access : NoAccess
}
