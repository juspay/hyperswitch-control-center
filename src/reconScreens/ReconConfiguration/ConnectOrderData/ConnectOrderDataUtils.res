open ConnectOrderDataTypes

let getSelectedStepName = step => {
  switch step {
  | Hyperswitch => "Hyperswitch"
  | OrderManagementSystem => "Order Management System"
  | BigQuery => "Big Query"
  }
}

let getSelectedStepDescription = step => {
  switch step {
  | Hyperswitch => "It is a payment gateway that allows you to accept payments online."
  | OrderManagementSystem => "It is a software that helps you manage your orders and inventory."
  | BigQuery => "It is a serverless, highly scalable, and cost-effective multi-cloud data warehouse."
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
