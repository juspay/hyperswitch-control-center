open Typography
open AdditionalDetailsSidebarHelper

module DirectFlowLandingCard = {
  @react.component
  let make = (~setGooglePayIntegrationType, ~googlePayIntegrationType) => {
     let shadowClass = googlePayIntegrationType === #direct ?
      "shadow-cardSelectedShadow"
      :"shadow-md"

    <div className="cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
      <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}  customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}` >
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
      let shadowClass = googlePayIntegrationType === #payment_gateway ?
      "shadow-cardSelectedShadow"
      :"shadow-md"


    <div
      className="cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
      <Card heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway} customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}` >
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
     let shadowClass = googlePayIntegrationType === #predecrypt ?
      "shadow-cardSelectedShadow"
      :"shadow-md"

    <div
      className="cursor-pointer"
      onClick={_ => {
        setGooglePayIntegrationType(_ => #predecrypt)
      }}>
      <Card heading="Pre Decrypted Token" isSelected={googlePayIntegrationType === #predecrypt} customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}` >
        <div className={`${body.md.medium} mt-2 text-nd_gray-400`}>
          {"Enable Google Pay by securely decrypting the Google Pay payment token on your end."->React.string}
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
    ~update,
    ~closeAccordionFn,
  ) => {
    open GPayFlowTypes

    let form = ReactFinalForm.useForm()

    let handleConfirmClick = () => {
      if googlePayIntegrationType === #predecrypt {
        form.change(
          "connector_wallets_details.google_pay.support_predecrypted_token",
          true->JSON.Encode.bool,
        )
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
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(TESOURO) =>
        <>
          <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
          <DirectFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
        </>
      | Processors(NUVEI) =>
        <>
          <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
          <PaymentGatewayFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
          <PaymentGatewayPreDecryptFlow setGooglePayIntegrationType googlePayIntegrationType />
        </>

      | _ =>
        <>
          <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
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
