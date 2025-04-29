@react.component
let make = (
  ~isSDKOpen,
  ~clientSecret,
  ~themeInitialValues,
  ~paymentResponse,
  ~paymentStatus,
  ~setPaymentStatus,
  ~setErrorMessage,
  ~returnUrl,
) => {
  open LogicUtils

  let paymentResponseDict = paymentResponse->getDictFromJsonObject

  let publishableKey = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  ).publishable_key

  <div className="w-3/4 flex flex-col p-5 overflow-auto bg-[rgba(124,255,112,0.54)]">
    {switch (isSDKOpen, clientSecret) {
    | (false, None) =>
      <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    | _ =>
      <WebSDK
        publishableKey
        paymentStatus
        currency={paymentResponseDict->getString("currency", "USD")}
        setPaymentStatus
        setErrorMessage
        clientSecret
        themeInitialValues
        returnUrl
      />
    }}
  </div>
}
