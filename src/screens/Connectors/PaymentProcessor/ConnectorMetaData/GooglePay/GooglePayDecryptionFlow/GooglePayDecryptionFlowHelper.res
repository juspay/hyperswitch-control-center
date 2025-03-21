module GooglePayDecryptionFlowPaymentGateway = {
  @react.component
  let make = (
    ~googlePayFields,
    ~googlePayIntegrationType,
    ~closeModal,
    ~connector,
    ~setShowWalletConfigurationModal,
    ~update,
  ) => {
    open LogicUtils
    open GooglePayDecryptionFlowUtils

    let form = ReactFinalForm.useForm()

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let initialGooglePayDict = React.useMemo(() => {
      formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")
    }, [])

    let googlePayFieldsForPaymentGateway = googlePayFields->Array.filter(field => {
      let typedData = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      !(ignoreDirectFields->Array.includes(typedData.name))
    })

    let setFormData = () => {
      if connector->isNonEmptyString {
        let value = googlePay(
          initialGooglePayDict->getDictfromDict("google_pay"),
          connector,
          ~googlePayIntegrationType,
        )
        form.change("connector_wallets_details.google_pay", value->Identity.genericTypeToJson)
      }
    }

    React.useEffect(() => {
      setFormData()
      None
    }, [connector])

    let onSubmit = () => {
      let connectorWalletDetails =
        formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")

      let metadataDetails =
        connectorWalletDetails
        ->getMetadataGooglePayFromConnectorWalletDetailsGooglePay(
          connector,
          ~googlePayIntegrationType,
        )
        ->JSON.Encode.object
      form.change("metadata.google_pay", metadataDetails)
      setShowWalletConfigurationModal(_ => false)
      let _ = update(metadataDetails)
      Nullable.null->Promise.resolve
    }

    <>
      {googlePayFieldsForPaymentGateway
      ->Array.mapWithIndex((field, index) => {
        let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
        <div key={index->Int.toString}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={googlePayValueInput(~googlePayField, ~googlePayIntegrationType)}
          />
        </div>
      })
      ->React.array}
      <div className={`flex gap-2 justify-end mt-4`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()->ignore
          }}
        />
        <Button
          onClick={_ => {
            onSubmit()->ignore
          }}
          text="Proceed"
          buttonType={Primary}
          buttonState={formState.values->validateGooglePay(connector, ~googlePayIntegrationType)}
        />
      </div>
      <FormValuesSpy />
    </>
  }
}

module GooglePayDecryptionFlowDirect = {
  @react.component
  let make = (
    ~googlePayFields,
    ~googlePayIntegrationType,
    ~closeModal,
    ~connector,
    ~setShowWalletConfigurationModal,
    ~update,
  ) => {
    open LogicUtils
    open GooglePayDecryptionFlowUtils

    let form = ReactFinalForm.useForm()

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let initialGooglePayDict = React.useMemo(() => {
      formState.values->getDictFromJsonObject->getDictfromDict("connector_wallets_details")
    }, [])

    let setFormData = () => {
      if connector->isNonEmptyString {
        let value = googlePay(
          initialGooglePayDict->getDictfromDict("google_pay"),
          connector,
          ~googlePayIntegrationType,
        )
        form.change("connector_wallets_details.google_pay", value->Identity.genericTypeToJson)
      }
    }

    React.useEffect(() => {
      setFormData()
      None
    }, [connector])

    let onSubmit = () => {
      let metadata =
        formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object
      setShowWalletConfigurationModal(_ => false)
      let _ = update(metadata)
      Nullable.null->Promise.resolve
    }

    let googlePayFieldsForDirect = googlePayFields->Array.filter(field => {
      let typedData = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      directFields->Array.includes(typedData.name)
    })

    <>
      {googlePayFieldsForDirect
      ->Array.mapWithIndex((field, index) => {
        let googlePayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
        <div key={index->Int.toString}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={googlePayValueInput(~googlePayField, ~googlePayIntegrationType)}
          />
        </div>
      })
      ->React.array}
      <div className={`flex gap-2 justify-end mt-4`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()->ignore
          }}
        />
        <Button
          onClick={_ => {
            onSubmit()->ignore
          }}
          text="Proceed"
          buttonType={Primary}
          buttonState={formState.values->validateGooglePay(connector, ~googlePayIntegrationType)}
        />
      </div>
      <FormValuesSpy />
    </>
  }
}

module Landing = {
  @react.component
  let make = (
    ~googlePayIntegrationType,
    ~closeModal,
    ~setGooglePayIntegrationStep,
    ~setGooglePayIntegrationType,
  ) => {
    open GooglePayDecryptionFlowTypes
    open AdditionalDetailsSidebarHelper
    <>
      <div
        className="p-6 m-2 cursor-pointer"
        onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
        <Card heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            {"Integrate Google Pay with your payment gateway."->React.string}
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          </div>
        </Card>
      </div>
      <div
        className="p-6 m-2 cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
        <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
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
      <div className={`flex gap-2 justify-end m-2 p-6`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()
          }}
        />
        <Button
          onClick={_ => setGooglePayIntegrationStep(_ => Configure)}
          text="Continue"
          buttonType={Primary}
        />
      </div>
    </>
  }
}
