@react.component
let make = (~connector, ~connectorAdditionalMerchantData) => {
  open ConnectorTypes

  {
    switch connector {
    | Processors(PLAID) => <PlaidAdditionalMerchantData connectorAdditionalMerchantData />
    | Processors(TOKENIO) => <TokenioAdditionalMerchantData connectorAdditionalMerchantData />
    | _ => React.null
    }
  }
}
