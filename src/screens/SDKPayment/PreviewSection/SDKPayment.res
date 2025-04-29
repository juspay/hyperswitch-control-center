@react.component
let make = (
  ~isSDKOpen,
  ~themeInitialValues,
  ~paymentResult,
  ~paymentStatus,
  ~setPaymentStatus,
  ~setErrorMessage,
) => {
  <div className="w-3/4 flex flex-col p-5 overflow-auto bg-[rgba(124,255,112,0.54)]">
    {switch isSDKOpen {
    | false => <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    | _ =>
      <WebSDK paymentStatus setPaymentStatus setErrorMessage themeInitialValues paymentResult />
    }}
  </div>
}
