open ConnectOrderDataTypes

let getSelectedStepName = step => {
  switch step {
  | Hyperswitch => "Hyperswitch"
  | OrderManagementSystem => "Order Management System"
  | Dummy => "Dummy"
  }
}

let getSelectedStepDescription = step => {
  switch step {
  | Hyperswitch => "Hyperswitch order data integration"
  | OrderManagementSystem => "In-house order management system"
  | Dummy => "Dummy work flow"
  }
}

let orderDataStepsArr: array<orderDataSteps> = [Hyperswitch, OrderManagementSystem, Dummy]

let getIconName = step => {
  switch step {
  | OrderManagementSystem => "ORDERMANAGEMENTSYSTEM"
  | Hyperswitch => "HYPERSWITCH"
  | Dummy => "BIGQUERY"
  }
}
