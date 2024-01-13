// will be removed once the backend does the URl mapping
let nameToURLMapper = (urlName, ~payment_id, ~merchant_id="", ()) => {
  switch urlName {
  | "PaymentsCreate" => "/payments"
  | "PaymentsStart" => `/payments/redirect/${payment_id}/${merchant_id}`
  | "PaymentsCancel" => `/payments/${payment_id}/cancel`
  | "PaymentsUpdate" => `/payments/${payment_id}`
  | "PaymentsConfirm" => `/payments/${payment_id}/confirm`
  | "PaymentsCapture" => `/payments/${payment_id}/capture`
  | _ => urlName
  }
}
