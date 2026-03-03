type entriesMetadataKeysToExclude = Amount | Currency

type accountGroup = {
  accountId: string,
  accountName: string,
  entries: array<ReconEngineTypes.entryType>,
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

@unboxed
type bulkActionStatusType =
  | @as("success") BulkActionSuccess
  | @as("failed") BulkActionFailed
  | @as("ineligible") BulkActionSkipped
  | @as("unknown") UnknownBulkActionStatus

type bulkActionResponse = {
  logical_id: option<string>,
  bulk_action_status: bulkActionStatusType,
  bulk_action_status_detail: option<string>,
}
