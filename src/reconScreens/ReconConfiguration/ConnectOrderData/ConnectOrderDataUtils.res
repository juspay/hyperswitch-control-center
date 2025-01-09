open ConnectOrderDataTypes

let getSelectedStepName = step => {
  switch step {
  | Hyperswitch => "Hyperswitch"
  | OrderManagementSystem => "Order Management System"
  | BigQuery => "Big Query"
  }
}

let orderDataStepsArr: array<orderDataSteps> = [Hyperswitch, OrderManagementSystem, BigQuery]

let getIconName = step => {
  switch step {
  | OrderManagementSystem => "ORDERMANAGEMENTSYSTEM"
  | Hyperswitch => "HYPERSWITCH"
  | BigQuery => "BIGQUERY"
  }
}
