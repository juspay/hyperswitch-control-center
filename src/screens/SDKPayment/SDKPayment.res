@react.component
let make = (~isLoading, ~clientSecretKey, ~initialValues: SDKPaymentTypes.paymentType) => {
  open ReactHyperJs

  let merchantDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantDetailsValueAtom)
  Js.log2("themeInitialValues", initialValues)

  let elementOptions: optionsForElements = {
    clientSecret: clientSecretKey,
    appearance: {
      theme: initialValues.theme->Option.getOr("default"),
      labels: initialValues.labels->Option.getOr("above"),
      innerLayout: initialValues.innerLayout->Option.getOr("accordion"),
      // variables: {
      //   colorPrimary: themeInitialValuesDict->getString("colorPrimary", "#fd1717"),
      // },
    },
    locale: initialValues.locale->Option.getOr("en-GB"),
  }
  Js.log2("elementOptions", elementOptions)

  let publishablekeyMerchant = merchantDetails.publishable_key
  let hyperPromise = loadHyper(publishablekeyMerchant)
  isLoading && clientSecretKey === ""
    ? <img alt="blurry-sdk" src={`/assets/BlurrySDK.svg`} />
    : <Elements options={elementOptions} stripe=hyperPromise>
        <PaymentElement id="paymentElement" options={} />
      </Elements>
}
