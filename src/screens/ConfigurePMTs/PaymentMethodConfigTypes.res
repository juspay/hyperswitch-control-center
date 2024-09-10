type paymentMethodConfiguration = {
  payment_method_index: int,
  payment_method_types_index: int,
  merchant_connector_id: string,
  connector_name: string,
  profile_id: string,
  payment_method: string,
  payment_method_type: string,
  card_networks: array<string>,
  accepted_currencies: option<ConnectorTypes.advancedConfigurationList>,
  accepted_countries: option<ConnectorTypes.advancedConfigurationList>,
  minimum_amount: option<int>,
  maximum_amount: option<int>,
  recurring_enabled: option<bool>,
  installment_payment_enabled: option<bool>,
  payment_experience: option<string>,
}

type paymentMethodConfigFilters = {
  profileId: option<array<string>>,
  connectorId: option<array<string>>,
  paymentMethod: option<array<string>>,
  paymentMethodType: option<array<string>>,
}

type valueInput = {
  label: string,
  name1: string,
  name2: string,
  options: array<SelectBox.dropdownOption>,
}
