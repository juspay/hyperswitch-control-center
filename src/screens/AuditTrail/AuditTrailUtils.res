open LogicUtils

type activityLogEntry = {
  userId: string,
  userEmail: string,
  userName: string,
  apiFlow: string,
  urlPath: string,
  httpMethod: string,
  statusCode: int,
  merchantId: string,
  createdAt: string,
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let actionLabel = apiFlow =>
  switch apiFlow {
  | "MerchantConnectorsCreate" => "Connector created"
  | "MerchantConnectorsUpdate" => "Connector updated"
  | "MerchantConnectorsDelete" => "Connector deleted"
  | "MerchantsAccountUpdate" => "Merchant account updated"
  | "ProfileCreate" => "Profile created"
  | "ProfileUpdate" => "Profile updated"
  | "ProfileDelete" => "Profile deleted"
  | "RoutingCreateConfig" => "Routing configuration created"
  | "RoutingLinkConfig" => "Routing configuration activated"
  | "RoutingUnlinkConfig" => "Routing configuration deactivated"
  | "ApiKeyCreate" => "API key created"
  | "ApiKeyUpdate" => "API key updated"
  | "ApiKeyRevoke" => "API key revoked"
  | "InviteMultipleUser" => "User(s) invited"
  | "UpdateUserRole" => "User role updated"
  | "DeleteUserRole" => "User removed from team"
  | "CreateRole"
  | "CreateRoleV2" => "Custom role created"
  | "UpdateRole" => "Custom role updated"
  | "DecisionManagerUpsertConfig" => "3DS decision rule updated"
  | "DecisionManagerDeleteConfig" => "3DS decision rule deleted"
  | other => other
  }

let itemToObjMapper = dict => {
  userId: dict->getString("userId", ""),
  userEmail: dict->getString("userEmail", ""),
  userName: dict->getString("userName", ""),
  apiFlow: dict->getString("apiFlow", ""),
  urlPath: dict->getString("urlPath", ""),
  httpMethod: dict->getString("httpMethod", ""),
  statusCode: dict->getInt("statusCode", 0),
  merchantId: dict->getString("merchantId", ""),
  createdAt: dict->getString("createdAt", ""),
}

let initialFixedFilter = () => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
          ~startKey=startTimeFilterKey,
          ~endKey=endTimeFilterKey,
          ~format="YYYY-MM-DDTHH:mm:ss[Z]",
          ~showTime=true,
          ~disablePastDates={false},
          ~disableFutureDates={true},
          ~predefinedDays=[Today, Yesterday, Day(2.0), Day(7.0), Day(30.0), ThisMonth, LastMonth],
          ~numMonths=2,
          ~disableApply=false,
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]
