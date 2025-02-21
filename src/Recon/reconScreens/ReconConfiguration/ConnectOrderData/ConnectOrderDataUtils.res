open ConnectOrderDataTypes

let getSelectedStepName = step => {
  switch step {
  | ConnectYourOrderDataSource => "Connect your order data source"
  | UploadFile => "Upload File"
  }
}

let getSelectedStepDescription = step => {
  switch step {
  | ConnectYourOrderDataSource => "This feature is available in production only"
  | UploadFile => "Use data in a .csv file"
  }
}

let orderDataStepsArr: array<orderDataSteps> = [ConnectYourOrderDataSource, UploadFile]

let getIconName = step => {
  switch step {
  | ConnectYourOrderDataSource => "nd-connect-your-order-data-source"
  | UploadFile => "nd-upload-file"
  }
}
