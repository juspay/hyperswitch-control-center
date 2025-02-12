open VaultPaymentMethodDetailsTypes

let defaultColumns = [
  CardHolderName,
  CardType,
  CardNetwork,
  LastFourDigits,
  CardExpiryMonth,
  CardExpiryYear,
  CardIssuer,
  CardIssuingCountry,
  CardIsIn,
  CardExtendedBin,
  PaymentChecks,
  AuthenticationData,
]

let allColumns = defaultColumns

let getHeading = colType => {
  switch colType {
  | CardHolderName => Table.makeHeaderInfo(~key="card_holder_name", ~title="Card Holder Name")
  | CardType => Table.makeHeaderInfo(~key="card_type", ~title="Card Type")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  | LastFourDigits => Table.makeHeaderInfo(~key="last_four_digits", ~title="Last Four Digits")
  | CardExpiryMonth => Table.makeHeaderInfo(~key="card_expiry_month", ~title="Card Expiry Month")
  | CardExpiryYear => Table.makeHeaderInfo(~key="card_expiry_year", ~title="Card Expiry Year")
  | CardIssuer => Table.makeHeaderInfo(~key="card_issuer", ~title="Card Issuer")
  | CardIssuingCountry =>
    Table.makeHeaderInfo(~key="card_issuing_country", ~title="Card Issuing Country")
  | CardIsIn => Table.makeHeaderInfo(~key="card_is_in", ~title="Card Is In")
  | CardExtendedBin => Table.makeHeaderInfo(~key="card_extended_bin", ~title="Card Extended Bin")
  | PaymentChecks => Table.makeHeaderInfo(~key="payment_checks", ~title="Payment Checks")
  | AuthenticationData =>
    Table.makeHeaderInfo(~key="authentication_data", ~title="Authentication Data")
  }
}

let getCell = (paymentMethodDetails, colType): Table.cell => {
  switch colType {
  | CardHolderName => Text(paymentMethodDetails.card_holder_name)
  | CardType => Text(paymentMethodDetails.card_type)
  | CardNetwork => Text(paymentMethodDetails.card_network)
  | LastFourDigits => Text(paymentMethodDetails.last_four_digits)
  | CardExpiryMonth => Text(paymentMethodDetails.card_expiry_month)
  | CardExpiryYear => Text(paymentMethodDetails.card_expiry_year)
  | CardIssuer => Text(paymentMethodDetails.card_issuer)
  | CardIssuingCountry => Text(paymentMethodDetails.card_issuing_country)
  | CardIsIn => Text(paymentMethodDetails.card_is_in)
  | CardExtendedBin => Text(paymentMethodDetails.card_extended_bin)
  | PaymentChecks => Text(paymentMethodDetails.payment_checks)
  | AuthenticationData => Text(paymentMethodDetails.authentication_data)
  }
}
