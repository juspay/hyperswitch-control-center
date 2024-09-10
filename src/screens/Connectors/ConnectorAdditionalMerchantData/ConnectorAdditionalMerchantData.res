@react.component
let make = (~connector, ~connectorAdditionalMerchantData) => {
  open ConnectorTypes

  {
    switch connector {
    | Processors(PLAID) => <PlaidAdditionalMerchantData connectorAdditionalMerchantData />
    | _ => React.null
    }
  }
}
