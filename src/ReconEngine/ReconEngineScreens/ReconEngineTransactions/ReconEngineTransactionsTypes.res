open ReconEngineTypes

type transactionFlowType =
  | InFlow
  | OutFlow
  | UnknownTransactionFlowType

type transactionSearchType =
  | @as("transaction_id") SearchTransactionId
  | @as("order_id") SearchOrderId
  | @as("unknown") UnknownTransactionSearchType

type transactionSortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type transactionsV2CursorPayload = {
  limit: int,
  direction: cursorDirection,
  order: transactionSortOrder,
  @as("sort_by") sortBy: cursor,
}

type entriesMetadataKeysToExclude = Amount | Currency

type accountGroup = {
  accountId: string,
  accountName: string,
  entries: array<entryType>,
}

type lineageFieldType = {
  lineageFieldLabel: string,
  lineageFieldValue: string,
  lineageFileCopyable: bool,
}

type lineageSectionType = {
  lineageSectionTitle: string,
  lineageSectionFields: array<lineageFieldType>,
}

@unboxed
type actionType =
  | @as("bulk_post") BulkTransactionPost
  | @as("bulk_void") BulkTransactionVoid
  | @as("unknown") UnknownBulkTransactionActionType

type iconType = {
  bulkActionIconName: string,
  bulkActionIconClass: string,
}

type modalType = {
  modalHeading: string,
  modalDescription: string,
  modalConfirmButtonText: string,
  modalConfirmButtonType: Button.buttonType,
  modalLoadingText: string,
}

type bulkActionModalConfig = {
  bulkActionIcon?: iconType,
  bulkActionModal: modalType,
}
