type transactionFlowType =
  | InFlow
  | OutFlow
  | UnknownTransactionFlowType

type cursorDirection = [#next | #previous]

type transactionSearchType =
  | @as("transaction_id") TransactionId
  | @as("order_id") OrderId
  | @as("unknown") UnknownTransactionSearchType

@unboxed
type transactionSortOrder =
  | @as("asc") Asc
  | @as("desc") Desc

type transactionCursorValue = {
  @as("effective_at") effectiveAt: string,
  @as("id") cursorId: string,
}

type transactionCursor = {
  @as("sort_field") sortField: string,
  @as("cursor_value") cursorValue: option<transactionCursorValue>,
}

type transactionCursors = {
  next: option<transactionCursor>,
  prev: option<transactionCursor>,
}

type transactionsV2Page = {
  transactions: array<ReconEngineTypes.transactionType>,
  cursors: transactionCursors,
}

type transactionsV2CursorPayload = {
  limit: int,
  direction: cursorDirection,
  order: transactionSortOrder,
  @as("sort_by") sortBy: transactionCursor,
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
