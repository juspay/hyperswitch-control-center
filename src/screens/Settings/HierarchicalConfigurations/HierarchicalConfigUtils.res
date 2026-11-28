open LogicUtils
open HierarchicalConfigTypes

let applePayCertificateResourceType = (ApplePay :> string)
let googlePayResourceType = (GooglePay :> string)

let getResourceTypeLabel = (resourceType: resourceType) =>
  switch resourceType {
  | ApplePay => "Apple Pay"
  | GooglePay => "Google Pay"
  }

let resourceTypes = [ApplePay, GooglePay]

let getResourceTypeTabIndex = resourceType =>
  resourceTypes->Array.findIndex(item => item == resourceType)->Math.Int.max(0)

let getResourceTypeFromTabIndex = index => resourceTypes->Array.get(index)->Option.getOr(ApplePay)

let getCredentialName = (resourceType: resourceType) =>
  switch resourceType {
  | ApplePay => "certificate"
  | GooglePay => "key"
  }

let itemToObjectMapper = (dict: Dict.t<JSON.t>): resourceSummary => {
  id: dict->getString("id", ""),
  displaySchema: dict->getDictfromDict("display_schema"),
  displayData: dict->getDictfromDict("display_data"),
  createdAt: dict->getString("created_at", ""),
  isLinked: dict->getBool("is_linked", false),
}

let getResourcesFromResponse = response =>
  response
  ->getDictFromJsonObject
  ->getArrayFromDict("resources", [])
  ->getMappedValueFromArrayOfJson(itemToObjectMapper)

let getListPayload = (~resourceType: resourceType, ~scope=None) => {
  let base = [("type", (resourceType :> string)->JSON.Encode.string)]
  let scoped = switch scope {
  | Some((scopeType, scopeId)) => [
      ("scope_type", scopeType->JSON.Encode.string),
      ("scope_id", scopeId->JSON.Encode.string),
    ]
  | None => []
  }
  base->Array.concat(scoped)->getJsonFromArrayOfJson
}

let getGooglePayGeneratePayload = (~googleMerchantId) =>
  [
    ("type", googlePayResourceType->JSON.Encode.string),
    (
      "google_pay",
      [("google_merchant_id", googleMerchantId->JSON.Encode.string)]->getJsonFromArrayOfJson,
    ),
  ]->getJsonFromArrayOfJson

let getGooglePayPublicKey = (response: JSON.t) =>
  response
  ->getDictFromJsonObject
  ->getDictFromNestedDict("data", googlePayResourceType)
  ->getString("public_key", "")

let getDisplayValue = (resource: resourceSummary, key) => resource.displayData->getString(key, "")

let getMerchantIdentifier = (resource: resourceSummary) =>
  resource->getDisplayValue("apple_pay_merchant_identifier")

let getDropdownOptions = (resources: array<resourceSummary>): array<SelectBox.dropdownOption> =>
  resources->Array.map(resource => {
    let identifier = resource->getMerchantIdentifier
    let label = identifier->isNonEmptyString ? `${identifier} (${resource.id})` : resource.id
    let resourceOption: SelectBox.dropdownOption = {label, value: resource.id}
    resourceOption
  })

let resourceRequestorTypeToString = (requestorType: resourceRequestorType) =>
  (requestorType :> string)->camelToSnake

let getResourceRequestorId = (
  requestorType: resourceRequestorType,
  ~merchantId,
  ~profileId,
  ~merchantConnectorAccountId="",
) =>
  switch requestorType {
  | #MerchantAccount => merchantId
  | #Profile => profileId
  | #MerchantConnectorAccount => merchantConnectorAccountId
  }

let getRequestorTypeFromLinkScope = (scope: linkScope): resourceRequestorType =>
  switch scope {
  | Merchant => #MerchantAccount
  | Profile => #Profile
  }

let getLinkScopeTitle = (scope: linkScope, ~merchantId) =>
  switch scope {
  | Merchant => `Merchant (${merchantId})`
  | Profile => "Profile"
  }

let getLinkScopeDescription = (scope: linkScope) =>
  switch scope {
  | Merchant => "Used by every profile that does not have its own configuration."
  | Profile => "Applies only to the selected profile."
  }

let getLinkScopeLabel = (scope: linkScope) =>
  switch scope {
  | Merchant => "Merchant"
  | Profile => "Profile"
  }

let getLinkPayload = (~requestorType: resourceRequestorType, ~requestorId) =>
  [
    ("requestor_type", requestorType->resourceRequestorTypeToString->JSON.Encode.string),
    ("requestor_id", requestorId->JSON.Encode.string),
  ]->getJsonFromArrayOfJson

let getApiErrorMessage = (~error, ~fallback) => {
  let message =
    error
    ->Exn.message
    ->Option.getOr("")
    ->safeParse
    ->getDictFromJsonObject
    ->getString("message", "")
  getErrorMessage(~message, ~error="", ~fallback)
}
