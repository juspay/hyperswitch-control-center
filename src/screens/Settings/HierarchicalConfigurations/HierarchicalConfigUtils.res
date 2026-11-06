open LogicUtils
open HierarchicalConfigTypes

let applePayCertificateResourceType = "apple_pay_certificate"

let itemToObjectMapper = (dict: Dict.t<JSON.t>): resourceSummary => {
  id: dict->getString("id", ""),
  displaySchema: dict->getDictfromDict("display_schema"),
  displayData: dict->getDictfromDict("display_data"),
  createdAt: dict->getString("created_at", ""),
  isLinked: dict->getBool("is_linked", false),
}

let getMerchantIdentifier = (resource: resourceSummary) =>
  resource.displayData->getString("apple_pay_merchant_identifier", "")

let getDropdownOptions = (resources: array<resourceSummary>): array<SelectBox.dropdownOption> =>
  resources->Array.map(resource => {
    let identifier = resource->getMerchantIdentifier
    let label = identifier->isNonEmptyString ? `${identifier} (${resource.id})` : resource.id
    let resourceOption: SelectBox.dropdownOption = {label, value: resource.id}
    resourceOption
  })

let resourceRequestorTypeToString = (requestorType: resourceRequestorType) =>
  (requestorType :> string)->camelToSnake

let getResourceRequestorTypeFromEntity = (entity: UserInfoTypes.entity): resourceRequestorType =>
  switch entity {
  | #Profile => #Profile
  | #Merchant | #Organization | #Tenant => #MerchantAccount
  }

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
