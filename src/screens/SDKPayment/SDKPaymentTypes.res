type address = {
  line1: string,
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

type paymentType = {
  amount: float,
  currency: string,
  profile_id: string,
  customer_id: string,
  description: string,
  capture_method: string,
  email: string,
  authentication_type: string,
  shipping: shipping,
  billing: billing,
  setup_future_usage: string,
  country_currency?: string,
  request_external_three_ds_authentication: bool,
  theme?: string,
  locale?: string,
  innerLayout?: string,
  labels?: string,
}
