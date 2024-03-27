type section = Local | PaymentIntents | PaymentAttempts | Refunds | Disputes | Others | Default

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
  | Default => ""
  }
}

let getSectionVariant = string => {
  switch string {
  | "payment_attempts" => PaymentAttempts
  | "payment_intents" => PaymentIntents
  | "refunds" => Refunds
  | "disputes" => Disputes
  | _ => Local
  }
}

type state = Loading | Loaded | Failed | Idle
