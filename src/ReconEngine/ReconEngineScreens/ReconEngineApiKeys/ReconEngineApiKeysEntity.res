open ReconEngineApiKeysTypes

type column = Name | Description | Prefix | Status | CreatedAt | ExpiresAt | Actions

let columns = [Name, Description, Prefix, Status, CreatedAt, ExpiresAt]

let getHeading = column => {
  let (key, title) = switch column {
  | Name => ("name", "Name")
  | Description => ("description", "Description")
  | Prefix => ("prefix", "Key prefix")
  | Status => ("status", "Status")
  | CreatedAt => ("created_at", "Created at")
  | ExpiresAt => ("expires_at", "Expires at")
  | Actions => ("actions", "Actions")
  }
  Table.makeHeaderInfo(~key, ~title)
}

let getCell = (~onAction, item: apiKey, column): Table.cell => {
  switch column {
  | Name => EllipsisText(item.name, "max-w-xs")
  | Description => EllipsisText(item.description, "max-w-xs")
  | Prefix => Text(item.prefix->ReconEngineApiKeysUtils.getMaskedPrefix)
  | Status =>
    let isExpired = switch item.expiresAt {
    | Never => false
    | DateTime(value) => value->Date.fromString->Date.getTime <= Date.now()
    }
    let status = item.status === Active && isExpired ? Expired : item.status
    Label({
      title: (status :> string)->LogicUtils.getFirstLetterCaps,
      color: status === Active ? LabelGreen : LabelRed,
    })
  | CreatedAt => Date(item.createdAt)
  | ExpiresAt =>
    switch item.expiresAt {
    | Never => Text("Never")
    | DateTime(value) => Date(value)
    }
  | Actions => CustomCell(<ReconEngineApiKeysHelper.ActionsCell item onAction />, "")
  }
}

let tableEntity = (~canManage, ~onAction) => {
  let visibleColumns = canManage ? columns->Array.concat([Actions]) : columns
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=ReconEngineApiKeysUtils.getItems,
    ~defaultColumns=visibleColumns,
    ~allColumns=visibleColumns,
    ~getHeading,
    ~dataKey="api_keys",
    ~getCell=(item, column) => getCell(~onAction, item, column),
  )
}
