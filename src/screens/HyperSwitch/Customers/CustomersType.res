type customers = {
  customer_id: string,
  name: string,
  email: string,
  phone: string,
  phone_country_code: string,
  description: string,
  address: string,
  created_at: string,
  metadata: Js.Json.t,
}

type customersColsType =
  | CustomerId
  | Name
  | Email
  | Phone
  | PhoneCountryCode
  | Description
  | Address
  | CreatedAt
