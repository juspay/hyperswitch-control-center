type section = Local | PaymentIntents | PaymentAttempts | Refunds | Disputes | Others

type element = {
  texts: array<JSON.t>,
  redirect_link: JSON.t,
}

type resultType = {
  section: section,
  results: array<element>,
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
