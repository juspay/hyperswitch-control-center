type section =
  | Local
  | PaymentIntents
  | PaymentAttempts
  | Refunds
  | Disputes
  | SessionizerPaymentAttempts
  | SessionizerPaymentIntents
  | SessionizerPaymentRefunds
  | SessionizerPaymentDisputes
  | Others
  | Default

type metadataType = {
  profileId: string,
  orgId: string,
  merchantId: string,
}
type element = {
  texts: array<JSON.t>,
  redirect_link: JSON.t,
}

type resultType = {
  section: section,
  results: array<element>,
  total_results: int,
}

let getSectionHeader = section => {
  switch section {
  | Local => "Go To"
  | PaymentIntents | SessionizerPaymentIntents => "Payment Intents"
  | PaymentAttempts | SessionizerPaymentAttempts => "Payment Attempts"
  | Refunds | SessionizerPaymentRefunds => "Refunds"
  | Disputes | SessionizerPaymentDisputes => "Disputes"
  | Others => "Others"
  | Default => ""
  }
}

let getSectionVariant = string => {
  switch string {
  | "payment_attempts" => PaymentAttempts
  | "payment_intents" => PaymentIntents
  | "refunds" => Refunds
  | "disputes" => Disputes
  | "sessionizer_payment_attempts" => SessionizerPaymentAttempts
  | "sessionizer_payment_intents" => SessionizerPaymentIntents
  | "sessionizer_refunds" => SessionizerPaymentRefunds
  | "sessionizer_disputes" => SessionizerPaymentDisputes
  | _ => Local
  }
}

let getSectionIndex = string => {
  switch string {
  | PaymentAttempts => "payment_attempts"
  | PaymentIntents => "payment_intents"
  | Refunds => "refunds"
  | Disputes => "disputes"
  | SessionizerPaymentAttempts => "sessionizer_payment_attempts"
  | SessionizerPaymentIntents => "sessionizer_payment_intents"
  | SessionizerPaymentRefunds => "sessionizer_refunds"
  | SessionizerPaymentDisputes => "sessionizer_disputes"
  | _ => ""
  }
}

type remoteResult = {
  count: int,
  hits: array<JSON.t>,
  index: string,
}

type defaultResult = {
  local_results: array<element>,
  remote_results: array<remoteResult>,
  searchText: string,
}

type state = Loading | Loaded | Idle

type category =
  | Payment_Method
  | Payment_Method_Type
  | Connector
  | Customer_Email
  | Card_Network
  | Card_Last_4
  | Date
  | Currency
  | Status
  | Payment_id
  | Amount

type categoryOption = {
  categoryType: category,
  options: array<string>,
  placeholder: string,
}

type viewType =
  | Load
  | Results
  | FiltersSugsestions
  | EmptyResult
