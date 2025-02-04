@react.component
let make = (~initialValues, ~setInitialValues) => {
  <>
    <ConnectorAuthKeys initialValues setInitialValues />
    <ConnectorPaymentMethodV2 initialValues setInitialValues />
  </>
}
