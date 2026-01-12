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

module PaymentGatewayPreDecryptFlow = {
  @react.component
  let make = (~setGooglePayIntegrationType, ~googlePayIntegrationType) => {
    <div className="cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #predecrypt)}>
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
    ~connector,
    ~update,
    ~closeAccordionFn,
  ) => {
    open GPayFlowTypes
    open LogicUtils

    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let handleConfirmClick = () => {
      if googlePayIntegrationType === #predecrypt {
        let connectorWalletDetails =
          formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")

        let metadataDetails =
          connectorWalletDetails
          ->GPayFlowUtils.getMetadataFromConnectorWalletDetailsGooglePay(connector)
          ->Identity.genericTypeToJson
        // Js.log2("metadataDetails", metadataDetails)

        form.change("metadata.google_pay", metadataDetails)
        let _ = update(metadataDetails)
        closeAccordionFn()
      } else {
        setGooglePayIntegrationStep(_ => Configure)
      }
    }

    <div className="flex flex-col gap-6">
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(TESOURO) => {
          Js.log("TESOURO")
          <>
            <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
            <DirectFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
          </>
        }
      | Processors(NUVEI) => {
          Js.log("NUVEI")
          <>
            <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
            <PaymentGatewayFlowLandingCard setGooglePayIntegrationType googlePayIntegrationType />
            <PaymentGatewayPreDecryptFlow setGooglePayIntegrationType googlePayIntegrationType />
          </>
        }

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
