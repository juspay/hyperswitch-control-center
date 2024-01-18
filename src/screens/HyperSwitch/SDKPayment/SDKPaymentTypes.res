type address = {
  line1: string,
  line2: string,
  line3: string,
  city: string,
  state: string,
  zip: string,
  country: string,
  first_name: string,
  last_name: string,
}

type phone = {
  number: string,
  country_code: string,
}

type shipping = {
  address: address,
  phone: phone,
}

type billing = {
  address: address,
  phone: phone,
}
type orderDetails = {
  product_name: string,
  quantity: int,
  amount: float,
}
type metadata = {order_details: orderDetails}

type online = {
  ip_address: string,
  user_agent: string,
}

type customer_acceptance = {
  acceptance_type: string,
  accepted_at: string,
  online: online,
}

type multi_use = {
  amount: int,
  currency: string,
}

type mandate_type = {multi_use: multi_use}

type mandateData = {
  customer_acceptance: customer_acceptance,
  mandate_type: mandate_type,
}

type paymentType = {
  amount: float,
  mutable currency: string,
  profile_id: string,
  customer_id: string,
  description: string,
  capture_method: string,
  amount_to_capture: Js.Nullable.t<float>,
  email: string,
  name: string,
  phone: string,
  phone_country_code: string,
  authentication_type: string,
  shipping: shipping,
  billing: billing,
  metadata: metadata,
  return_url: string,
  payment_type?: Js.Nullable.t<string>,
  setup_future_usage?: Js.Nullable.t<string>,
  mandate_data?: Js.Nullable.t<mandateData>,
}
