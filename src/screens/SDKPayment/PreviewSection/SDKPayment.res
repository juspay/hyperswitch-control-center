module BasicAccountSetupSuccessfulPage = {
  @react.component
  let make = (
    ~iconName,
    ~statusText,
    ~buttonText,
    ~buttonOnClick,
    ~bgColor="bg-green-success_page_bg",
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    let {errorMessage} = React.useContext(SDKProvider.defaultContext)
    let headerTextStyle = "text-xl font-semibold text-grey-700"

    <div className={`w-4/5 flex flex-col gap-4 p-9 h-full w-full justify-between rounded shadow`}>
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
          onClick={buttonOnClick}
          buttonState
        />
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~isSDKOpen) => {
  open ReactHyperJs

  let {paymentResult, paymentStatus} = React.useContext(SDKProvider.defaultContext)

  let paymentId =
    paymentResult->LogicUtils.getDictFromJsonObject->LogicUtils.getOptionString("payment_id")

  let successButtonText = "Go to Payment Operations"

  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let onProceed = async () => {
    switch paymentId {
    | Some(val) =>
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/payments/${val}/${profileId}/${merchantId}/${orgId}`),
      )
    | None => ()
    }
  }

  <div className="w-full h-full flex items-center justify-center p-5 overflow-auto">
    {switch isSDKOpen {
    | true =>
      switch paymentStatus {
      | SUCCESS =>
        <BasicAccountSetupSuccessfulPage
          iconName="account-setup-completed"
          statusText="Payment Successful"
          buttonText=successButtonText
          buttonOnClick={_ => onProceed()->ignore}
          bgColor="bg-green-success_page_bg"
          isButtonVisible={paymentId->Option.isSome}
        />

      | FAILED(_) =>
        <BasicAccountSetupSuccessfulPage
          iconName="account-setup-failed"
          statusText="Payment Failed"
          buttonText=successButtonText
          buttonOnClick={_ => onProceed()->ignore}
          bgColor="bg-red-failed_page_bg"
          isButtonVisible={paymentId->Option.isSome}
        />
      | CHECKCONFIGURATION =>
        <BasicAccountSetupSuccessfulPage
          iconName="processing"
          statusText="Check your Configurations"
          buttonText=successButtonText
          buttonOnClick={_ => onProceed()->ignore}
          bgColor="bg-yellow-pending_page_bg"
          isButtonVisible={paymentId->Option.isSome}
        />

      | PROCESSING =>
        <BasicAccountSetupSuccessfulPage
          iconName="processing"
          statusText="Payment Pending"
          buttonText=successButtonText
          buttonOnClick={_ => onProceed()->ignore}
          bgColor="bg-yellow-pending_page_bg"
          isButtonVisible={paymentId->Option.isSome}
        />
      | INCOMPLETE => <WebSDK />
      | _ => React.null
      }
    | false => <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    }}
  </div>
}
