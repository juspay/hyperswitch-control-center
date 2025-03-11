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
]

let allColumns = defaultColumns

let getHeading = colType => {
  switch colType {
  | CardHolderName => Table.makeHeaderInfo(~key="card_holder_name", ~title="Card Holder Name")
  | CardType => Table.makeHeaderInfo(~key="card_type", ~title="Card Type")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  | LastFourDigits => Table.makeHeaderInfo(~key="last_4_digits", ~title="Last Four Digits")
  | CardExpiryMonth => Table.makeHeaderInfo(~key="expiry_month", ~title="Card Expiry Month")
  | CardExpiryYear => Table.makeHeaderInfo(~key="expiry_year", ~title="Card Expiry Year")
  | CardIssuer => Table.makeHeaderInfo(~key="card_issuer", ~title="Card Issuer")
  | CardIssuingCountry => Table.makeHeaderInfo(~key="issuer_country", ~title="Card Issuing Country")
  | CardIsIn => Table.makeHeaderInfo(~key="card_isin", ~title="Card Is In")
  }
}

let getCell = (paymentMethodDetails, colType): Table.cell => {
  switch colType {
  | CardHolderName => Text(paymentMethodDetails.card_holder_name)
  | CardType => Text(paymentMethodDetails.card_type)
  | CardNetwork => Text(paymentMethodDetails.card_network)
  | LastFourDigits => Text(paymentMethodDetails.last4_digits)
  | CardExpiryMonth => Text(paymentMethodDetails.expiry_month)
  | CardExpiryYear => Text(paymentMethodDetails.expiry_year)
  | CardIssuer => Text(paymentMethodDetails.card_issuer)
  | CardIssuingCountry => Text(paymentMethodDetails.issuer_country)
  | CardIsIn => Text(paymentMethodDetails.card_isin)
  }
}
