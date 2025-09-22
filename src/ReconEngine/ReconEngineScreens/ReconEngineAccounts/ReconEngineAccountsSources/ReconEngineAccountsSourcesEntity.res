open LogicUtils
open ReconEngineTypes
open ReconEngineAccountsSourcesHelper

type ingestionConfigColType =
  | SourceConfigName
  | ConfigurationType
  | IngestionId
  | LastSyncAt

type transformationConfigColType =
  | TransformationId
  | IngestionId
  | Status
  | LastModifiedAt

type ingestionHistoryColType =
  | FileName
  | IngestionName
  | IngestionHistoryId
  | Status
  | IngestionType
  | ReceivedAt
  | Actions

type transformationHistoryColType =
  | TransformationId
  | TransformationHistoryId
  | TransformationName
  | Status
  | CreatedAt
  | TransformedAt
  | TransformationStats
  | TransformationComments
  | TotalRecords
  | ProcessedCount
  | IgnoredCount
  | ErrorCount
  | Actions

let ingestionHistoryDefaultColumns = [FileName, IngestionName, Status, IngestionType, ReceivedAt]
let transformationHistoryDefaultColumns = [TransformationName, Status, CreatedAt, TransformedAt]

let getIngestionHistoryHeading = colType => {
  switch colType {
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | IngestionName => Table.makeHeaderInfo(~key="ingestion_name", ~title="Ingestion Name")
  | IngestionHistoryId =>
    Table.makeHeaderInfo(~key="ingestion_history_id", ~title="Ingestion History ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | IngestionType => Table.makeHeaderInfo(~key="ingestion_type", ~title="Ingestion Type")
  | ReceivedAt => Table.makeHeaderInfo(~key="received_at", ~title="Received At")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getIngestionConfigHeading = colType => {
  switch colType {
  | SourceConfigName => Table.makeHeaderInfo(~key="source_config_name", ~title="Source Config Name")
  | ConfigurationType =>
    Table.makeHeaderInfo(~key="configuration_type", ~title="Configuration Type")
  | IngestionId => Table.makeHeaderInfo(~key="ingestion_id", ~title="Ingestion ID")
  | LastSyncAt => Table.makeHeaderInfo(~key="last_sync", ~title="Last Sync")
  }
}

let getTransformationConfigHeading = (colType: transformationConfigColType) => {
  switch colType {
  | TransformationId => Table.makeHeaderInfo(~key="transformation_id", ~title="Transformation ID")
  | IngestionId => Table.makeHeaderInfo(~key="ingestion_id", ~title="Ingestion ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | LastModifiedAt => Table.makeHeaderInfo(~key="last_modified", ~title="Last Modified")
  }
}

let getTransformationHistoryHeading = colType => {
  switch colType {
  | TransformationId => Table.makeHeaderInfo(~key="transformation_id", ~title="Transformation ID")
  | TransformationHistoryId =>
    Table.makeHeaderInfo(~key="transformation_history_id", ~title="Transformation History ID")
  | TransformationName =>
    Table.makeHeaderInfo(~key="transformation_name", ~title="Transformation Name")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | TransformedAt => Table.makeHeaderInfo(~key="transformed_at", ~title="Transformed At")
  | TransformationStats =>
    Table.makeHeaderInfo(~key="transformation_stats", ~title="Processed / Ignored / Error")
  | TransformationComments =>
    Table.makeHeaderInfo(~key="transformation_comments", ~title="Comments")
  | TotalRecords => Table.makeHeaderInfo(~key="total_records", ~title="Total Records")
  | ProcessedCount => Table.makeHeaderInfo(~key="processed_count", ~title="Processed Count")
  | IgnoredCount => Table.makeHeaderInfo(~key="ignored_count", ~title="Ignored Count")
  | ErrorCount => Table.makeHeaderInfo(~key="error_count", ~title="Error Count")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }
}

let getIngestionHistoryCell = (data: ingestionHistoryType, colType): Table.cell => {
  switch colType {
  | FileName => Text(data.file_name)
  | IngestionName => Text(data.ingestion_name)
  | IngestionHistoryId => Text(data.ingestion_history_id)
  | Status => ReconEngineAccountsUtils.getStatusLabel(data.status)
  | IngestionType => Text(data.upload_type)
  | ReceivedAt => Date(data.created_at)
  | Actions => CustomCell(<ReconEngineAccountSourceDetailsActions ingestionHistory={data} />, "")
  }
}

let getIngestionConfigCell = (data: ingestionConfigType, colType): Table.cell => {
  switch colType {
  | SourceConfigName => Text(data.name)
  | ConfigurationType =>
    Text(data.data->getDictFromJsonObject->getString("ingestion_type", "")->String.toUpperCase)
  | IngestionId => Text(data.ingestion_id)
  | LastSyncAt => Date(data.last_synced_at)
  }
}

let getTransformationConfigCell = (
  data: transformationConfigType,
  colType: transformationConfigColType,
): Table.cell => {
  switch colType {
  | TransformationId => Text(data.id)
  | IngestionId => Text(data.ingestion_id)
  | Status =>
    Label({
      title: data.is_active ? "Active" : "Inactive",
      color: if data.is_active {
        LabelGreen
      } else {
        LabelRed
      },
    })
  | LastModifiedAt => Date(data.last_modified_at)
  }
}

let getTransformationHistoryCell = (
  transformationHistoryData: transformationHistoryType,
  colType,
): Table.cell => {
  switch colType {
  | TransformationId => EllipsisText(transformationHistoryData.transformation_id, "")
  | TransformationHistoryId => Text(transformationHistoryData.transformation_history_id)
  | TransformationName => Text(transformationHistoryData.transformation_name)
  | Status => ReconEngineAccountsUtils.getStatusLabel(transformationHistoryData.status)
  | CreatedAt => Date(transformationHistoryData.created_at)
  | TransformedAt => Date(transformationHistoryData.processed_at)
  | TransformationStats =>
    CustomCell(<TransformationStats stats={transformationHistoryData.data} />, "")
  | TransformationComments =>
    EllipsisText(transformationHistoryData.data.errors->Array.joinWith(", "), "max-w-xl")
  | TotalRecords => Text(transformationHistoryData.data.total_count->Int.toString)
  | ProcessedCount => Text(transformationHistoryData.data.transformed_count->Int.toString)
  | IgnoredCount => Text(transformationHistoryData.data.ignored_count->Int.toString)
  | ErrorCount => Text(transformationHistoryData.data.errors->Array.length->Int.toString)
  | Actions => CustomCell(<TransformationHistoryActionsComponent transformationHistoryData />, "")
  }
}

let ingestionHistoryTableEntity = (path: string, ~authorization: CommonAuthTypes.authorization) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=ingestionHistoryDefaultColumns,
    ~getHeading=getIngestionHistoryHeading,
    ~getCell=getIngestionHistoryCell,
    ~dataKey="",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.id}`),
          ~authorization,
        )
      }
    },
  )
}

let transformationHistoryTableEntity = (
  path: string,
  ~authorization: CommonAuthTypes.authorization,
) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=transformationHistoryDefaultColumns,
    ~getHeading=getTransformationHistoryHeading,
    ~getCell=getTransformationHistoryCell,
    ~dataKey="",
    ~getShowLink={
      connec => {
        GroupAccessUtils.linkForGetShowLinkViaAccess(
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.ingestion_history_id}`),
          ~authorization,
        )
      }
    },
  )
}
