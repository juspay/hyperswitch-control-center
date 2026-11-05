open SuperpositionTypes
open SuperpositionUtils
open SuperpositionHelper
open LogicUtils
open Typography

let customizableColumns = [KeyCol, ValueCol, StatusCol, ActionsCol]
let ownedColumns = [KeyCol, ValueCol, ActionsCol]

let getConfigHeading = colType =>
  switch colType {
  // Fixed widths keep the columns in place while switching between tabs. Name takes the rest,
  // and sits 24px closer to the checkbox than the table's padding allows; its cell matches.
  | KeyCol => Table.makeHeaderInfo(~key="key", ~title="Name", ~customWidth="!pl-2")
  | ValueCol => Table.makeHeaderInfo(~key="value", ~title="Value", ~customWidth="!w-[30%]")
  | StatusCol =>
    Table.makeHeaderInfo(~key="status", ~title="Status", ~dataType=LabelType, ~customWidth="!w-32")
  | ActionsCol => Table.makeHeaderInfo(~key="", ~title="", ~customWidth="!w-28")
  }

let getStatusColor = (status): TableUtils.labelColor =>
  switch status {
  | DefaultStatus => LabelLightGray
  | UpdatedStatus => LabelGray
  | CustomStatus => LabelBlue
  }

let getConfigCell = (
  ~labelDepth,
  ~onEdit,
  ~onReset,
  ~onExplain,
  ~canManage,
  row: configRow,
  colType,
): Table.cell => {
  let status = row->getValueStatus
  switch colType {
  | KeyCol =>
    CustomCell(
      <div className="flex flex-col gap-0.5 min-w-0 max-w-md -ml-6" title=row.key>
        {
          let location = row.key->getKeyLocationBelow(~depth=labelDepth)
          <RenderIf condition={location->isNonEmptyString}>
            <span className={`${body.sm.medium} text-nd_gray-500`}>
              {`${location} ›`->React.string}
            </span>
          </RenderIf>
        }
        <span className={`${body.md.medium} text-nd_gray-700 break-words`}>
          {row.key->getKeyLabel->React.string}
        </span>
        <RenderIf condition={row.description->isNonEmptyString}>
          <span className={`${body.sm.regular} text-nd_gray-500 line-clamp-1`}>
            {row.description->React.string}
          </span>
        </RenderIf>
      </div>,
      row.key,
    )
  | ValueCol =>
    CustomCell(
      <div className="flex items-center gap-2 min-w-0">
        <RenderIf condition={row.ownership == Managed}>
          <div className="shrink-0">
            <ActionIcon
              iconName="nd-info-circle"
              description="Explain how this value is resolved"
              onClick={() => onExplain(row)}
            />
          </div>
        </RenderIf>
        <ValueText value=row.value />
      </div>,
      row.value->formatValue,
    )
  | StatusCol => Label({title: status->getValueStatusLabel, color: status->getStatusColor})
  | ActionsCol =>
    CustomCell(
      <div className="flex items-center gap-4">
        // Customizable keys keep a slot for reset on every row, so Edit never moves. Only a
        // custom value has something to go back to.
        <RenderIf condition={row.ownership == Managed}>
          <div className="w-4 shrink-0">
            <RenderIf condition={status == CustomStatus}>
              <ActionIcon
                iconName="nd-reset"
                description="Reset to previous level"
                isDisabled={!canManage}
                onClick={() => onReset(row)}
              />
            </RenderIf>
          </div>
        </RenderIf>
        <ActionIcon
          iconName="nd-edit"
          description="Edit value"
          isDisabled={!canManage}
          onClick={() => onEdit(row)}
        />
      </div>,
      "",
    )
  }
}

let configEntity = (~columns, ~labelDepth, ~onEdit, ~onReset, ~onExplain, ~canManage) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=columns,
    ~getHeading=getConfigHeading,
    ~getCell=(row, colType) =>
      getConfigCell(~labelDepth, ~onEdit, ~onReset, ~onExplain, ~canManage, row, colType),
    ~dataKey="",
  )

let specializationColumns = [
  RankCol,
  ConditionsCol,
  SpecializedValueCol,
  LastModifiedCol,
  SpecializationActionsCol,
]

let getSpecializationHeading = colType =>
  switch colType {
  | RankCol => Table.makeHeaderInfo(~key="rank", ~title="Priority")
  | ConditionsCol => Table.makeHeaderInfo(~key="conditions", ~title="Extra conditions")
  | SpecializedValueCol => Table.makeHeaderInfo(~key="value", ~title="Value")
  | LastModifiedCol => Table.makeHeaderInfo(~key="last_modified", ~title="Last modified")
  | SpecializationActionsCol => Table.makeHeaderInfo(~key="", ~title="")
  }

let getSpecializationCell = (
  ~onEdit,
  ~onRemove,
  ~canManage,
  entry: specializationEntry,
  colType,
): Table.cell => {
  let {entryRow: row, spec, rank} = entry
  switch colType {
  | RankCol => Text(rank->Int.toString)
  | ConditionsCol =>
    CustomCell(
      <div className="max-w-md">
        <ConditionChips condition=spec.extraConditions />
      </div>,
      spec.extraConditions->describeConditions,
    )
  | SpecializedValueCol => {
      let value = spec.context.override->Dict.get(row.key)->Option.getOr(JSON.Encode.null)
      CustomCell(<ValueText value />, value->formatValue)
    }
  | LastModifiedCol =>
    Text(
      spec.context.lastModifiedAt->isNonEmptyString
        ? `${spec.context.lastModifiedAt->getAuditTimestamp} · ${spec.context.lastModifiedBy}`
        : "-",
    )
  | SpecializationActionsCol =>
    CustomCell(
      <div className="flex items-center justify-end gap-4">
        <ActionIcon
          iconName="nd-edit"
          description="Edit specialization"
          isDisabled={!canManage}
          onClick={() => onEdit(entry)}
        />
        <ActionIcon
          iconName="nd-delete-dustbin-02"
          description="Remove specialization"
          isDisabled={!canManage}
          onClick={() => onRemove(entry)}
        />
      </div>,
      "",
    )
  }
}

let specializationEntity = (~columns, ~onEdit, ~onRemove, ~canManage) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=columns,
    ~getHeading=getSpecializationHeading,
    ~getCell=(entry, colType) =>
      getSpecializationCell(~onEdit, ~onRemove, ~canManage, entry, colType),
    ~dataKey="",
  )

let auditColumns = [TimestampCol, AuditActionCol, AuditTableCol, ChangedKeysCol, UserCol]

let getAuditHeading = colType =>
  switch colType {
  | TimestampCol => Table.makeHeaderInfo(~key="timestamp", ~title="Time")
  | AuditActionCol => Table.makeHeaderInfo(~key="action", ~title="Action", ~dataType=LabelType)
  | AuditTableCol => Table.makeHeaderInfo(~key="table", ~title="Changed")
  | ChangedKeysCol => Table.makeHeaderInfo(~key="keys", ~title="Keys")
  | UserCol => Table.makeHeaderInfo(~key="user", ~title="By")
  }

let getAuditActionColor = (action): TableUtils.labelColor =>
  switch action->String.toUpperCase {
  | "INSERT" => LabelGreen
  | "DELETE" => LabelRed
  | _ => LabelBlue
  }

let getAuditCell = (log: auditLog, colType): Table.cell =>
  switch colType {
  | TimestampCol => Text(log.timestamp->getAuditTimestamp)
  | AuditActionCol =>
    Label({title: log.action->String.toUpperCase, color: log.action->getAuditActionColor})
  | AuditTableCol => Text(log.tableName->getAuditTableLabel)
  | ChangedKeysCol => {
      let keys = log->getAuditChangedKeys
      CustomCell(
        <span className={`${code.md.regular} text-nd_gray-700 break-all line-clamp-2`}>
          {(keys->isNonEmptyArray ? keys->Array.joinWith(", ") : "-")->React.string}
        </span>,
        keys->Array.joinWith(", "),
      )
    }
  | UserCol => Text(log->getAuditAuthor)
  }

let auditEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=_ => [],
  ~defaultColumns=auditColumns,
  ~getHeading=getAuditHeading,
  ~getCell=getAuditCell,
  ~dataKey="",
)
