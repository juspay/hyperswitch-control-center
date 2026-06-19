open ReconEngineRevampedPipelinesTypes

let pipelineIngestionItemFromHistory = (
  history: ReconEngineTypes.ingestionHistoryType,
  accountMap: Dict.t<string>,
): pipelineIngestionItem => {
  {
    id: history.id,
    ingestion_history_id: history.ingestion_history_id,
    ingestion_name: history.ingestion_name,
    file_name: history.file_name,
    account_id: history.account_id,
    account_name: accountMap->Dict.get(history.account_id)->Option.getOr(history.account_id),
    upload_type: history.upload_type,
    status: history.status,
    created_at: history.created_at,
  }
}

let getConnectedStatCards = (historyData: array<ReconEngineTypes.ingestionHistoryType>): array<
  connectedStatCardData,
> => {
  let active =
    historyData->Array.filter(h =>
      h.status == ReconEngineTypes.Processed ||
      h.status == ReconEngineTypes.Processing ||
      h.status == ReconEngineTypes.Failed ||
      h.status == ReconEngineTypes.Pending
    )
  let total = active->Array.length
  let processedCount =
    active->Array.filter(h => h.status == ReconEngineTypes.Processed)->Array.length
  let processingCount =
    active->Array.filter(h => h.status == ReconEngineTypes.Processing)->Array.length
  let failedCount = active->Array.filter(h => h.status == ReconEngineTypes.Failed)->Array.length
  let processedPct =
    total > 0
      ? (processedCount->Int.toFloat /. total->Int.toFloat *. 100.0)
          ->Float.toFixedWithPrecision(~digits=1)
      : "0.0"

  let seen: Dict.t<bool> = Dict.make()
  historyData->Array.forEach(h => seen->Dict.set(h.ingestion_id, true))
  let sourcesCount = seen->Dict.keysToArray->Array.length

  [
    {
      title: IngestionRuns,
      value: Number(total),
      description: `${processingCount->Int.toString} processing now`,
      cardType: Info,
      icon: CustomIcon(<Icon name="nd-graph-chart-gantt" size=14 className="text-nd_gray-500" />),
    },
    {
      title: Processed,
      value: Number(processedCount),
      description: `${processedPct}% of runs`,
      cardType: Info,
      icon: CustomIcon(<Icon name="nd-check-circle" size=14 className="text-nd_gray-500" />),
    },
    {
      title: Failed,
      value: Number(failedCount),
      description: "Click to filter",
      cardType: failedCount > 0 ? Attention : Info,
      icon: CustomIcon(
        <Icon
          name="nd-alert-triangle"
          size=14
          className={failedCount > 0 ? "text-nd_red-500" : "text-nd_gray-500"}
        />,
      ),
    },
    {
      title: TotalSources,
      value: Number(sourcesCount),
      description: "Unique ingestion sources",
      cardType: Info,
      icon: CustomIcon(<Icon name="nd-connectors" size=14 className="text-nd_gray-500" />),
    },
  ]
}

let getUploadTypeIcon = (uploadType: string) => {
  switch uploadType->String.toLowerCase {
  | "sftp" => "nd-bank"
  | "webhook" => "nd-webhook"
  | _ => "nd-file"
  }
}

let getUploadTypeLabel = (uploadType: string) => {
  switch uploadType->String.toLowerCase {
  | "manual" => "Manual upload"
  | "sftp" => "SFTP"
  | "webhook" => "Webhook"
  | s => s
  }
}

let getPipelineColHeading = (colType: pipelineColType) => {
  switch colType {
  | Account => Table.makeHeaderInfo(~key="account_name", ~title="Account")
  | Feed => Table.makeHeaderInfo(~key="ingestion_name", ~title="Feed")
  | File => Table.makeHeaderInfo(~key="file_name", ~title="File")
  | Connector => Table.makeHeaderInfo(~key="upload_type", ~title="Connector")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Created => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  | Staging => Table.makeHeaderInfo(~key="staging", ~title="Staging")
  }
}

let getPipelineColCell = (item: pipelineIngestionItem, colType: pipelineColType): Table.cell => {
  switch colType {
  | Account => EllipsisText(item.account_name, "max-w-[160px]")
  | Feed =>
    CustomCell(
      <div className="flex items-center gap-2 whitespace-nowrap">
        <Icon
          name={getUploadTypeIcon(item.upload_type)}
          size=14
          className="text-nd_gray-400 flex-shrink-0"
        />
        <span className="truncate max-w-[180px]"> {item.ingestion_name->React.string} </span>
      </div>,
      item.ingestion_name,
    )
  | File => EllipsisText(item.file_name, "max-w-[160px]")
  | Connector =>
    CustomCell(
      <span className="whitespace-nowrap">
        {getUploadTypeLabel(item.upload_type)->React.string}
      </span>,
      getUploadTypeLabel(item.upload_type),
    )
  | Status =>
    Table.Label({
      title: (item.status :> string)->LogicUtils.capitalizeString,
      color: switch item.status {
      | ReconEngineTypes.Pending => LabelYellow
      | ReconEngineTypes.Processing => LabelOrange
      | ReconEngineTypes.Processed => LabelGreen
      | ReconEngineTypes.Failed => LabelRed
      | ReconEngineTypes.Discarded => LabelGray
      | ReconEngineTypes.UnknownIngestionTransformationStatus => LabelLightGray
      },
    })
  | Created => Date(item.created_at)
  | Staging => Text("—")
  }
}

let defaultPipelineCols: array<pipelineColType> = [
  Account,
  Feed,
  File,
  Connector,
  Status,
  Created,
  Staging,
]

let pipelineTableEntity = (~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=defaultPipelineCols,
    ~getHeading=getPipelineColHeading,
    ~getCell=getPipelineColCell,
    ~dataKey="",
    ~getShowLink={
      _ => GroupAccessUtils.linkForGetShowLinkViaAccess(~url="", ~authorization)
    },
  )
}
