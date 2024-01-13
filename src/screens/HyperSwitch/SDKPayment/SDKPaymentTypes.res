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
  amount: int,
}
type metadata = {order_details: orderDetails}

type paymentType = {
  amount: int,
  mutable currency: string,
  profile_id: string,
  customer_id: string,
  description: string,
  capture_method: string,
  amount_to_capture: int,
  email: string,
  name: string,
  phone: string,
  phone_country_code: string,
  authentication_type: string,
  shipping: shipping,
  billing: billing,
  metadata: metadata,
  return_url: string,
}
