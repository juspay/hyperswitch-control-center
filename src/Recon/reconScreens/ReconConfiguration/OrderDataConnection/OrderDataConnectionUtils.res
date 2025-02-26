open OrderDataConnectionTypes

let getSelectedStepName = step => {
  switch step {
  | ConnectYourOrderDataSource => "Connect your order data source"
  | UploadFile => "Try with Sample Data"
  }
}

let getSelectedStepDescription = step => {
  switch step {
  | ConnectYourOrderDataSource => "This feature is available in production only"
  | UploadFile => "Explore with our pre-populated sample order data."
  }
}

let isDisabled = step => {
  switch step {
  | ConnectYourOrderDataSource => true
  | UploadFile => false
  }
}

let orderDataStepsArr: array<orderDataSteps> = [UploadFile, ConnectYourOrderDataSource]

let getIconName = step => {
  switch step {
  | ConnectYourOrderDataSource => "nd-connect-your-order-data-source"
  | UploadFile => "nd-upload-file"
  }
}
