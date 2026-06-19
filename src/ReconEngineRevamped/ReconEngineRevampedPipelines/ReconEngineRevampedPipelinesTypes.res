type valueType =
  | Percentage(float)
  | Float(float)
  | Number(int)
  | Amount(float, string)
  | OutOf(int, int)
  | SlashOutOf(int, int)

@unboxed
type connectedStatCardsTitle =
  | @as("Ingestion Runs") IngestionRuns
  | @as("Processed") Processed
  | @as("Failed") Failed
  | @as("Total Sources") TotalSources

type connectedStatCardType =
  | Info
  | Attention

type connectedStatCardData = {
  title: connectedStatCardsTitle,
  value: valueType,
  icon: Button.iconType,
  description: string,
  cardType: connectedStatCardType,
}

type pipelineIngestionItem = {
  id: string,
  ingestion_history_id: string,
  ingestion_name: string,
  file_name: string,
  account_id: string,
  account_name: string,
  upload_type: string,
  status: ReconEngineTypes.ingestionTransformationStatusType,
  created_at: string,
  version: int,
}

type pipelineColType =
  | Account
  | Feed
  | File
  | Connector
  | Status
  | Created
  | Actions
