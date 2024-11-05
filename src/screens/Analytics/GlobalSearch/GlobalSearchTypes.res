type section =
  | Local
  | PaymentIntents
  | PaymentAttempts
  | Refunds
  | SessionizerPaymentAttempts
  | SessionizerPaymentIntents
  | SessionizerPaymentRefunds
  | SessionizerPaymentDisputes
  | Disputes
  | Others
  | Default

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
  | PaymentIntents => "Payment Intents"
  | PaymentAttempts => "Payment Attempts"
  | Refunds => "Refunds"
  | Others => "Others"
  | Disputes => "Disputes"
  | Default
  | SessionizerPaymentAttempts
  | SessionizerPaymentIntents
  | SessionizerPaymentRefunds
  | SessionizerPaymentDisputes => ""
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

type state = Loading | Loaded | Failed | Idle

type category =
  | Payment_Method
  | Payment_Method_Type
  | Connector
  | Customer_Email
  | Card_Network
  | Last_4
  | Date

type categoryOption = {
  categoryType: category,
  options: array<string>,
  placeholder: string,
}
