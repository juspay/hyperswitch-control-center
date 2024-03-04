type section = Local | PaymentIntents | PaymentAttempts | Refunds | Disputes | Others

type resultType = {
  section: section,
  results: array<Dict.t<JSON.t>>,
}

let getSectionHeader = section => {
  switch section {
  | Local => "Go To"
  | PaymentIntents => "Payment Intents"
  | PaymentAttempts => "Payment Attempts"
  | Refunds => "Refunds"
  | Disputes => "Disputes"
  | Others => "Others"
  }
}
