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

type addressAndPhone = {
  address: address,
  phone: phone,
}

type paymentType = {
  amount: float,
  currency: string,
  profile_id: string,
  customer_id: option<string>,
  description: string,
  capture_method: string,
  email: string,
  authentication_type: string,
  shipping: option<addressAndPhone>,
  billing: option<addressAndPhone>,
  setup_future_usage: string,
  country_currency?: string,
  request_external_three_ds_authentication: bool,
}
