open ConnectOrderDataTypes

let getStepName = step => {
  switch step {
  | OrderManagementSystem => "Order Management System"
  | Hyperswitch => "Hyperswitch"
  | BigQuery => "Big Query"
  | GoogleDrive => "Google Drive"
  }
}

let orderDataStepsArr: array<orderDataSteps> = [OrderManagementSystem, Hyperswitch, BigQuery, GoogleDrive]

let getIconName = step => {
  switch step {
  | OrderManagementSystem => "ORDERMANAGEMENTSYSTEM"
  | Hyperswitch => "HYPERSWITCH"
  | BigQuery => "BIGQUERY"
  | GoogleDrive => "GOOGLEDRIVE"
  }
}

let flowTypeList = [SFTPSetup, APIBased, WebHooks, ManualUpload]

let getFlowTypeVariantFromString = flowTypeString => {
  switch flowTypeString {
  | "sftp_setup" => SFTPSetup
  | "api_based" => APIBased
  | "web_hooks" => WebHooks
  | _ => ManualUpload
  }
}

let getFlowTypeLabel = flowType => {
  switch flowType->getFlowTypeVariantFromString {
  | SFTPSetup => "SFTP Setup"
  | APIBased => "API Based"
  | WebHooks => "Web Hooks"
  | ManualUpload => "Manual Upload"
  }
}

let getFlowTypeNameString = flowType => {
  switch flowType {
  | SFTPSetup => "sftp_setup"
  | APIBased => "api_based"
  | WebHooks => "web_hooks"
  | ManualUpload => "manual_upload"
  }
}

let connectOrderDataFlowOptions = flowTypeList->Array.map(getFlowTypeNameString)

