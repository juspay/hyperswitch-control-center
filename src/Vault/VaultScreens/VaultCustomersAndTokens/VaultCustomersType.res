type customers = {
  id: string,
  name: string,
  email: string,
  phone: string,
  phone_country_code: string,
  description: string,
  address: string,
  created_at: string,
  metadata: JSON.t,
}

type customersColsType =
  | CustomerId
  | Name
  | Email
  | Phone
  | PhoneCountryCode
  | Address
  | CreatedAt

type totalTokenCountComponentStateTypes =
  | Loading
  | Success
  | Error
