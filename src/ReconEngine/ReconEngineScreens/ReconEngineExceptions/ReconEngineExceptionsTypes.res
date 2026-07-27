type modalLayout = CenterModal | SidePanelModal | ExpandedSidePanelModal

type buttonConfig = {
  text: string,
  icon: string,
  iconClass: string,
  condition: bool,
  onClick: unit => unit,
  buttonType: Button.buttonType,
}

type bottomBarConfig = {
  prompt: string,
  buttonText: string,
  buttonEnabled: bool,
  onClick: unit => unit,
}

type resolutionConfig = {
  heading: string,
  description?: string,
  layout: modalLayout,
  closeOnOutsideClick: bool,
}

type metadataRow = {
  id: string,
  key: string,
  displayKey: string,
  value: string,
}

type validationRule = (string, Dict.t<JSON.t> => option<string>)

@unboxed
type bulkActionStatusType =
  | @as("success") BulkActionSuccess
  | @as("failed") BulkActionFailed
  | @as("ineligible") BulkActionInEligible
  | @as("unknown") UnknownBulkActionStatus

type bulkActionResponse = {
  logical_id: option<string>,
  bulk_action_status: bulkActionStatusType,
  bulk_action_status_detail: option<string>,
}
