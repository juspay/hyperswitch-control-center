type address = {
  line1: string,
  line2: string,
  line3: string,
  city: string,
  state: string,
  zip: string,
  country: string,
  firstName: string,
  lastName: string,
}

type phone = {
  number: string,
  countryCode: string,
}

type shipping = {
  address: address,
  phone: phone,
}

type billing = {
  address: address,
  phone: phone,
  email: string,
}
type orderDetails = {
  productName: string,
  quantity: int,
  amount: float,
}
type metadata = {orderDetails: orderDetails}

type online = {
  ipAddress: string,
  userAgent: string,
}

type customerAcceptance = {
  acceptanceType: string,
  acceptedAt: string,
  online: online,
}

type multiUse = {
  amount: int,
  currency: string,
}

type mandateType = {multiUse: multiUse}

type mandateData = {
  customerAcceptance: customerAcceptance,
  mandateType: mandateType,
}

type frmMetadata = {orderChannel: string}

type paymentType = {
  amount: float,
  mutable currency: string,
  profileId: string,
  customerId: string,
  description: string,
  captureMethod: string,
  amountToCapture: Nullable.t<float>,
  email: string,
  name: string,
  phone: string,
  phoneCountryCode: string,
  authenticationType: string,
  shipping: shipping,
  billing: billing,
  metadata: metadata,
  returnUrl: string,
  paymentType?: Nullable.t<string>,
  setupFutureUsage?: Nullable.t<string>,
  mandateData?: Nullable.t<mandateData>,
  countryCurrency: string,
  frmMetadata: frmMetadata,
}
