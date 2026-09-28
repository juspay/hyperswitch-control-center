open HierarchicalConfigTypes
open HierarchicalConfigUtils
open LogicUtils

type colType = ResourceId | MerchantIdentifier | CreatedAt

let defaultColumns = [ResourceId, MerchantIdentifier, CreatedAt]

let getHeading = colType =>
  switch colType {
  | ResourceId => Table.makeHeaderInfo(~key="id", ~title="Resource ID")
  | MerchantIdentifier =>
    Table.makeHeaderInfo(~key="merchant_identifier", ~title="Merchant Identifier")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  }

let getCell = (resource: resourceSummary, colType): Table.cell =>
  switch colType {
  | ResourceId => DisplayCopyCell(resource.id)
  | MerchantIdentifier =>
    let identifier = resource->getMerchantIdentifier
    Text(identifier->isNonEmptyString ? identifier : "-")
  | CreatedAt => Date(resource.createdAt)
  }

let hierarchicalConfigEntity = () =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
  )
