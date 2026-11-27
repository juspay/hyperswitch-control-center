open HierarchicalConfigTypes
open HierarchicalConfigUtils
open LogicUtils

type colType =
  | ResourceId
  | ApplePayMerchantIdentifier
  | GoogleMerchantId
  | CreatedAt
  | Actions

let getColumns = (resourceType: resourceType) =>
  switch resourceType {
  | ApplePay => [ResourceId, ApplePayMerchantIdentifier, CreatedAt, Actions]
  | GooglePay => [ResourceId, GoogleMerchantId, CreatedAt, Actions]
  }

let getHeading = colType =>
  switch colType {
  | ResourceId => Table.makeHeaderInfo(~key="id", ~title="Resource ID")
  | ApplePayMerchantIdentifier =>
    Table.makeHeaderInfo(~key="merchant_identifier", ~title="Merchant Identifier")
  | GoogleMerchantId => Table.makeHeaderInfo(~key="google_merchant_id", ~title="Google Merchant ID")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }

let textOrNA = value => Table.Text(value->getNonEmptyString->Option.getOr("NA"))

let getCell = (~onLinkClick, ~authorization, resource: resourceSummary, colType): Table.cell =>
  switch colType {
  | ResourceId => DisplayCopyCell(resource.id)
  | ApplePayMerchantIdentifier => resource->getMerchantIdentifier->textOrNA
  | GoogleMerchantId => resource->getDisplayValue("google_merchant_id")->textOrNA
  | CreatedAt => Date(resource.createdAt)
  | Actions =>
    CustomCell(
      <ACLButton
        text="Link"
        buttonType=Secondary
        buttonSize=Small
        authorization
        onClick={ev => {
          ev->ReactEvent.Mouse.stopPropagation
          onLinkClick(resource)
        }}
      />,
      "",
    )
  }

let hierarchicalConfigEntity = (
  ~resourceType,
  ~onLinkClick,
  ~authorization: CommonAuthTypes.authorization,
) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=resourceType->getColumns,
    ~getHeading,
    ~getCell=getCell(~onLinkClick, ~authorization, ...),
    ~dataKey=""
  )
