open LogicUtils
open RoutingUtils
open RoutingTypes

let allColumns: array<historyColType> = [
  Name,
  Type,
  ProfileId,
  ProfileName,
  Description,
  Created,
  LastUpdated,
  Status,
]

let itemToObjMapper = dict => {
  {
    id: getString(dict, "id", ""),
    name: getString(dict, "name", ""),
    profile_id: getString(dict, "profile_id", ""),
    kind: getString(dict, "kind", ""),
    description: getString(dict, "description", ""),
    modified_at: getString(dict, "modified_at", ""),
    created_at: getString(dict, "created_at", ""),
  }
}

let defaultColumns: array<historyColType> = [
  Name,
  ProfileId,
  ProfileName,
  Type,
  Description,
  Status,
]

let getHeading: historyColType => Table.header = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name of Control")
  | Type => Table.makeHeaderInfo(~key="kind", ~title="Type of Control")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile ID")
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~dataType=DropDown)
  | Created => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  | LastUpdated => Table.makeHeaderInfo(~key="modified_at", ~title="Last Updated")
  }
}
let getTableCell = activeRoutingIds => {
  let getCell = (historyData, colType: historyColType): Table.cell => {
    switch colType {
    | Name => Text(historyData.name)
    | Type =>
      Text(`${historyData.kind->routingTypeMapper->routingTypeName->capitalizeString} Based`)
    | ProfileId => Text(historyData.profile_id)
    | ProfileName =>
      Table.CustomCell(
        <HelperComponents.BusinessProfileComponent profile_id={historyData.profile_id} />,
        "",
      )
    | Description => Text(historyData.description)
    | Created => Text(historyData.created_at)
    | LastUpdated => Text(historyData.modified_at)
    | Status =>
      Label({
        title: activeRoutingIds->Array.includes(historyData.id)
          ? "ACTIVE"
          : "INACTIVE"->String.toUpperCase,
        color: switch activeRoutingIds->Array.includes(historyData.id) {
        | true => LabelGreen
        | false => LabelWhite
        },
      })
    }
  }
  getCell
}

let getHistoryRules: JSON.t => array<historyData> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let historyEntity = (
  activeRoutingIds: array<string>,
  ~authorization: CommonAuthTypes.authorization,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getHistoryRules,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=getTableCell(activeRoutingIds),
    ~dataKey="records",
    ~getShowLink={
      value => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(
            ~url=`/routing/${value.kind
              ->routingTypeMapper
              ->routingTypeName}?id=${value.id}${activeRoutingIds->Array.includes(value.id)
                ? "&isActive=true"
                : ""}`,
          ),
          ~authorization,
        )
      }
    },
  )
}
