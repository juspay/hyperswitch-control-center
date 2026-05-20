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
