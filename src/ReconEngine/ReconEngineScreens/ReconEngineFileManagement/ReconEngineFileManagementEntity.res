open ReconEngineFileManagementTypes
open ReconEngineFileManagementUtils

type ingestionHistoryColType =
  | FileName
  | IngestionName
  | IngestionHistoryId
  | Status
  | UploadType
  | UploadedAt

type transformationHistoryColType =
  | TransformationName
  | Status
  | CreatedAt
  | ProcessedAt

let ingestionHistoryDefaultColumns = [FileName, IngestionName, Status, UploadType, UploadedAt]
let transformationHistoryDefaultColumns = [TransformationName, Status, CreatedAt, ProcessedAt]

let getIngestionHistoryHeading = colType => {
  switch colType {
  | FileName => Table.makeHeaderInfo(~key="file_name", ~title="File Name")
  | IngestionName => Table.makeHeaderInfo(~key="ingestion_name", ~title="Ingestion Name")
  | IngestionHistoryId =>
    Table.makeHeaderInfo(~key="ingestion_history_id", ~title="Ingestion History ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | UploadType => Table.makeHeaderInfo(~key="upload_type", ~title="Upload Type")
  | UploadedAt => Table.makeHeaderInfo(~key="uploaded_at", ~title="Uploaded At")
  }
}

let getTransformationHistoryHeading = colType => {
  switch colType {
  | TransformationName =>
    Table.makeHeaderInfo(~key="transformation_name", ~title="Transformation Name")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | ProcessedAt => Table.makeHeaderInfo(~key="processed_at", ~title="Processed At")
  }
}

let getIngestionHistoryCell = (data: ingestionHistoryType, colType): Table.cell => {
  switch colType {
  | FileName => Text(data.file_name)
  | IngestionName => Text(data.ingestion_name)
  | IngestionHistoryId => Text(data.ingestion_history_id)
  | Status =>
    Label({
      title: data.status,
      color: switch data.status->statusMapper {
      | Pending => LabelGray
      | Processing => LabelOrange
      | Processed => LabelGreen
      | Failed => LabelRed
      | StatusNone => LabelLightGray
      },
    })
  | UploadType => Text(data.upload_type)
  | UploadedAt => Text(data.created_at)
  }
}

let getTransformationHistoryCell = (data: transformationHistoryType, colType): Table.cell => {
  switch colType {
  | TransformationName => Text(data.transformation_name)
  | Status =>
    Label({
      title: data.status,
      color: switch data.status->statusMapper {
      | Pending => LabelGray
      | Processing => LabelOrange
      | Processed => LabelGreen
      | Failed => LabelRed
      | StatusNone => LabelLightGray
      },
    })
  | CreatedAt => Text(data.created_at)
  | ProcessedAt => Text(data.processed_at)
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
          ~url=GlobalVars.appendDashboardPath(~url=`/${path}/${connec.ingestion_history_id}`),
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
