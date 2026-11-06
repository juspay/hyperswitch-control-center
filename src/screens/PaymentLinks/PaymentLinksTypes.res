type paymentLink = {
  payment_link_id: string,
  payment_id: string,
  merchant_id: string,
  processor_merchant_id: string,
  profile_id: string,
  link_to_pay: string,
  amount: float,
  currency: string,
  description: string,
  status: string,
  created_at: string,
  expiry: string,
  secure_link: string,
}

type setupFutureUsage = [#on_session | #off_session]
type authenticationType = [#three_ds | #no_three_ds]
