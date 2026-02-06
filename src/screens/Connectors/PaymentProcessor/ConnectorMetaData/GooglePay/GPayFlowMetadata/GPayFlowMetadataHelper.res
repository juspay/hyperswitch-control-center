open Typography
open AdditionalDetailsSidebarHelper

module PaymentGatewayFlowLandingCard = {
  @react.component
  let make = (~setGooglePayIntegrationType, ~googlePayIntegrationType) => {
    <div
      className="cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
      <Card heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway}>
        <div className={`${body.md.medium} mt-2 text-nd_gray-400`}>
          {"Integrate Google Pay with your payment gateway."->React.string}
        </div>
        <div className="flex gap-2 mt-4">
          <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
        </div>
      </Card>
    </div>
  }
}

module PaymentGatewayPreDecryptFlow = {
  @react.component
  let make = (~setGooglePayIntegrationType, ~googlePayIntegrationType) => {
    <div
      className="cursor-pointer"
      onClick={_ => {
        setGooglePayIntegrationType(_ => #predecrypt)
      }}>
      <Card heading="Pre-decrypt flow" isSelected={googlePayIntegrationType === #predecrypt}>
        <div className={`${body.md.medium} mt-2 text-nd_gray-400`}>
          {"Integrate Google Pay with your payment gateway."->React.string}
        </div>
        // <div className="flex gap-2 mt-4">
        //   <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
        //   <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
        // </div>
      </Card>
    </div>
  }
}
module Landing = {
  @react.component
  let make = (
    ~googlePayIntegrationType,
    ~closeModal,
    ~setGooglePayIntegrationStep,
    ~setGooglePayIntegrationType,
    ~update,
    ~closeAccordionFn,
  ) => {
    open GPayFlowTypes

    let form = ReactFinalForm.useForm()

    let handleConfirmClick = () => {
      if googlePayIntegrationType === #predecrypt {
        let connectorWalletDetails =
          [
            ("support_predecrypted_token", true->JSON.Encode.bool),
          ]->LogicUtils.getJsonFromArrayOfJson
        form.change("metadata.google_pay", connectorWalletDetails)
        let _ = update(connectorWalletDetails)
        closeAccordionFn()
      } else {
        setGooglePayIntegrationStep(_ => Configure)
      }
    }

    <div className="flex flex-col gap-6">
      <PaymentGatewayFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
      <PaymentGatewayPreDecryptFlow setGooglePayIntegrationType googlePayIntegrationType />
      <div className={`flex gap-2 justify-end`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()
          }}
          buttonSize={Small}
          customButtonStyle="w-full"
        />
        <Button
          onClick={_ => handleConfirmClick()}
          text="Continue"
          buttonType={Primary}
          customButtonStyle="w-full"
          buttonSize={Small}
        />
      </div>
    </div>
  }
}
