external objToJson: {..} => Js.Json.t = "%identity"

open HSwitchSDKTypes

@react.component
let make = (~options, ~selectedMenu, ~customerPaymentMethods, ~hyperPromise) => {
  <div>
    <HyperElements options={options->objToJson} hyper={hyperPromise}>
      <HSwitchCheckoutForm customerPaymentMethods={customerPaymentMethods} />
    </HyperElements>
  </div>
}
