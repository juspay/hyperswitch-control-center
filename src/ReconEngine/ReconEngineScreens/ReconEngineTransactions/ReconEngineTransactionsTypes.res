type transactionFlowType =
  | InFlow
  | OutFlow
  | UnknownTransactionFlowType

type cursorDirection = [#next | #previous]

type transactionSearchType =
  | @as("transaction_id") TransactionId
  | @as("order_id") OrderId
  | @as("unknown") UnknownTransactionSearchType

// Cursor sort field (the tagged `sort_field` in the V2 request). Its `@as` value is sent as-is.
@unboxed
type transactionSortField =
  | @as("effective_at") EffectiveAt
  | @as("id") Id

// Sort order for the cursor query.
@unboxed
type transactionSortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type transactionsV2Page = {
  transactions: array<ReconEngineTypes.transactionType>,
  nextCursor: option<JSON.t>,
  prevCursor: option<JSON.t>,
}

type transactionCursors = {
  next: option<JSON.t>,
  prev: option<JSON.t>,
}

type entriesMetadataKeysToExclude = Amount | Currency

type accountGroup = {
  accountId: string,
  accountName: string,
  entries: array<ReconEngineTypes.entryType>,
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
