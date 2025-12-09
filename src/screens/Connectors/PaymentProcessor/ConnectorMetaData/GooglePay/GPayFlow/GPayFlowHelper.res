open Typography
open AdditionalDetailsSidebarHelper

module DirectFlowLandingCard = {
  @react.component
  let make = (~setGooglePayIntegrationType, ~googlePayIntegrationType) => {
    <div className="cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
      <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}>
        <div className={`${body.md.medium}  text-nd_gray-400 mt-2`}>
          {"Google Pay Decryption at Hyperswitch: Unlock from PSP dependency."->React.string}
        </div>
        <div className="flex gap-2 mt-4">
          <CustomTag tagText="For Web & Mobile" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          <CustomTag
            tagText="Additional Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
          />
        </div>
      </Card>
    </div>
  }
}

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
module Landing = {
  @react.component
  let make = (
    ~googlePayIntegrationType,
    ~closeModal,
    ~setGooglePayIntegrationStep,
    ~setGooglePayIntegrationType,
    ~connector,
  ) => {
    open GPayFlowTypes
    let handleConfirmClick = () => {
      setGooglePayIntegrationStep(_ => Configure)
    }
    <div className="flex flex-col gap-6">
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(TESOURO) =>
        <DirectFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
      | Processors(NUVEI) =>
        <PaymentGatewayFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
      | _ =>
        <>
          <PaymentGatewayFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
          <DirectFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
        </>
      }}
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
