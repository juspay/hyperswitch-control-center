@react.component
let make = (~connectorAdditionalMerchantData) => {
  open LogicUtils
  <>
    <PlaidAdditionalMerchantData connectorAdditionalMerchantData />
  </>
}
