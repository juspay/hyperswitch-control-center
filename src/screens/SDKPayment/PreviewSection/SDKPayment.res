module BasicAccountSetupSuccessfulPage = {
  @react.component
  let make = (
    ~iconName,
    ~statusText,
    ~buttonText,
    ~buttonOnClick,
    ~errorMessage="",
    ~customWidth="w-full",
    ~bgColor="bg-green-success_page_bg",
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    let headerTextStyle = "text-xl font-semibold text-grey-700"
    <div className={`flex flex-col gap-4 p-9 h-full ${customWidth} justify-between rounded shadow`}>
      <div className={`p-4 h-5/6 ${bgColor} flex flex-col justify-center items-center gap-8`}>
        <Icon name=iconName size=120 />
        <AddDataAttributes attributes=[("data-testid", "paymentSuccess")]>
          <p className=headerTextStyle> {statusText->React.string} </p>
        </AddDataAttributes>
        <RenderIf condition={statusText == "Payment Failed"}>
          <p className="text-center"> {errorMessage->React.string} </p>
        </RenderIf>
      </div>
      <RenderIf condition={isButtonVisible}>
        <Button
          text=buttonText
          buttonSize={Large}
          buttonType={Primary}
          customButtonStyle="w-full"
          onClick={_ => buttonOnClick()}
          buttonState
        />
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~isSDKOpen, ~themeInitialValues, ~paymentResult, ~paymentStatus, ~setPaymentStatus) => {
  open ReactHyperJs

  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let successButtonText = "Proceed"

  let onProceed = (~paymentId) => {
    // Logic to handle the proceed action
    Js.log("Proceeding with payment ID: " ++ paymentId)
    Promise.resolve()
  }

  let paymentId =
    paymentResult->LogicUtils.getDictFromJsonObject->LogicUtils.getString("payment_id", "")

  let customWidth = "w-full"

  <div className="w-3/4 flex flex-col p-5 overflow-auto bg-[rgba(124,255,112,0.54)]">
    {switch isSDKOpen {
    | false => <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    | _ =>
      <>
        {switch paymentStatus {
        | SUCCESS =>
          <BasicAccountSetupSuccessfulPage
            iconName="account-setup-completed"
            statusText="Payment Successful"
            buttonText=successButtonText
            buttonOnClick={_ => onProceed(~paymentId)->ignore}
            customWidth
            bgColor="bg-green-success_page_bg"
            isButtonVisible={paymentId !== ""}
          />

        | FAILED(_) =>
          <BasicAccountSetupSuccessfulPage
            iconName="account-setup-failed"
            statusText="Payment Failed"
            buttonText=successButtonText
            buttonOnClick={_ => onProceed(~paymentId)->ignore}
            errorMessage
            customWidth
            bgColor="bg-red-failed_page_bg"
            isButtonVisible={paymentId !== ""}
          />
        | CHECKCONFIGURATION =>
          <BasicAccountSetupSuccessfulPage
            iconName="processing"
            statusText="Check your Configurations"
            buttonText=successButtonText
            buttonOnClick={_ => onProceed(~paymentId)->ignore}
            customWidth
            bgColor="bg-yellow-pending_page_bg"
            isButtonVisible={paymentId !== ""}
          />

        | PROCESSING =>
          <BasicAccountSetupSuccessfulPage
            iconName="processing"
            statusText="Payment Pending"
            buttonText=successButtonText
            buttonOnClick={_ => onProceed(~paymentId)->ignore}
            customWidth
            bgColor="bg-yellow-pending_page_bg"
            isButtonVisible={paymentId !== ""}
          />
        | _ => React.null
        }}
        <WebSDK paymentStatus setPaymentStatus setErrorMessage themeInitialValues paymentResult />
      </>
    }}
  </div>
}
