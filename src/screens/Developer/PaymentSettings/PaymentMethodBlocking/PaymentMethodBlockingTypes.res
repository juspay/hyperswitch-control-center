type paymentMethod = Card | ApplePay | GooglePay

type wasmOptions = {
  issuingCountry: array<SelectBox.dropdownOption>,
  cardTypes: array<SelectBox.dropdownOption>,
  cardNetworks: array<SelectBox.dropdownOption>,
  cardSubtypes: array<SelectBox.dropdownOption>,
  fundingSources: array<SelectBox.dropdownOption>,
  cardSegmentTypes: array<SelectBox.dropdownOption>,
}

type toggleField = {
  key: string,
  label: string,
  description: string,
}
