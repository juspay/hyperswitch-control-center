module Verified = {
  @react.component
  let make = (
    ~verifiedDomainList,
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setApplePayIntegrationSteps,
    ~closeAccordionFn,
    ~update,
    ~connector,
  ) => {
    open ApplePayIntegrationHelper
    open ApplePayIntegrationTypes
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let onSubmit = () => {
      open LogicUtils

      let data =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay_combined")

      let applePayData = ApplePayIntegrationUtils.applePay(
        data,
        ~applePayIntegrationType=Some(appleIntegrationType),
        ~connector,
        (),
      )
      switch applePayData {
      | ApplePayCombined(data) =>
        form.change(
          "metadata.apple_pay_combined",
          data.apple_pay_combined->Identity.genericTypeToJson,
        )
      | _ => ()
      }

      let metadata =
        formState.values->getDictFromJsonObject->getDictfromDict("metadata")->JSON.Encode.object

      let _ = update(metadata)
      closeAccordionFn()
    }
    <>
      <div className="p-6 m-2 cursor-pointer">
        <p className="text-xs	font-medium	mt-4"> {" Web Domains"->React.string} </p>
        {verifiedDomainList
        ->Array.mapWithIndex((domainUrl, index) => {
          <div
            key={Int.toString(index)}
            className="mt-4 cursor-pointer"
            onClick={_ => setApplePayIntegrationType(_ => #manual)}>
            <div className={`relative w-full  p-6 rounded flex flex-col justify-between border `}>
              <div className="flex justify-between">
                <div className={`font-medium text-base text-hyperswitch_black `}>
                  {domainUrl->String.length > 0 ? domainUrl->React.string : "Default"->React.string}
                </div>
                <div>
                  {switch appleIntegrationType {
                  | #simplified =>
                    <CustomTag
                      tagText="Verified"
                      tagSize=4
                      tagLeftIcon=Some("ellipse-green")
                      tagCustomStyle="bg-hyperswitch_green_trans"
                    />
                  | #manual =>
                    <Icon
                      onClick={_ => setApplePayIntegrationSteps(_ => Configure)}
                      name={"arrow-right"}
                      size={15}
                    />
                  }}
                </div>
              </div>
            </div>
          </div>
        })
        ->React.array}
        <div className={`flex gap-2 justify-end mt-4`}>
          <Button
            text="Reconfigure"
            buttonType={Secondary}
            onClick={_ => {
              setApplePayIntegrationSteps(_ => Landing)
            }}
            customButtonStyle="w-full"
          />
          <Button
            onClick={_ => {
              onSubmit()
            }}
            text="Proceed"
            buttonType={Primary}
            customButtonStyle="w-full"
          />
        </div>
      </div>
    </>
  }
}

module Landing = {
  @react.component
  let make = (
    ~connector,
    ~appleIntegrationType,
    ~closeModal,
    ~setApplePayIntegrationSteps,
    ~setApplePayIntegrationType,
  ) => {
    open ApplePayIntegrationTypes
    open ApplePayLandingHelper
    open Typography

    let handleConfirmClick = () => {
      setApplePayIntegrationSteps(_ => Configure)
    }
    <div className="flex flex-col gap-6 p-6">
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(STRIPE)
      | Processors(BANKOFAMERICA)
      | Processors(CYBERSOURCE)
      | Processors(NUVEI)
      | Processors(FIUU)
      | Processors(TESOURO) =>
        <>
          <p className={body.md.semibold}> {"Choose Configuration Method"->React.string} </p>
          <ApplePaySimplifiedLandingCard setApplePayIntegrationType appleIntegrationType />
          <ApplePayManualLandingCard setApplePayIntegrationType appleIntegrationType />
        </>
      | Processors(WORLDPAYVANTIV) =>
        <ApplePaySimplifiedLandingCard setApplePayIntegrationType appleIntegrationType />
      | _ => <ApplePayManualLandingCard setApplePayIntegrationType appleIntegrationType />
      }}
      <div className={`flex gap-2 justify-end`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()
          }}
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

@react.component
let make = (~connector, ~closeAccordionFn, ~update, ~onCloseClickCustomFun) => {
  open APIUtils
  open LogicUtils

  open ApplePayIntegrationTypes

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (appleIntegrationType, setApplePayIntegrationType) = React.useState(_ => #manual)
  let (applePayIntegrationStep, setApplePayIntegrationSteps) = React.useState(_ => Landing)
  let (merchantBusinessCountry, setMerchantBusinessCountry) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (verifiedDomainList, setVefifiedDomainList) = React.useState(_ => [])
  let applePayFields = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("apple_pay", [])

        dict
      } else {
        []
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        []
      }
    }
  }, [connector])

  // Chnage this to get for both V1 and V2
  let getProcessorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let paymentMethoConfigUrl = getURL(~entityName=V1(PAYMENT_METHOD_CONFIG), ~methodType=Get)
      let res = await fetchDetails(
        `${paymentMethoConfigUrl}?connector=${connector}&paymentMethodType=apple_pay`,
      )
      let countries =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("countries", [])
        ->Array.map(item => {
          let dict = item->getDictFromJsonObject
          let a: SelectBox.dropdownOption = {
            label: dict->getString("name", ""),
            value: dict->getString("code", ""),
          }
          a
        })

      setMerchantBusinessCountry(_ => countries)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  let closeModal = () => {
    onCloseClickCustomFun()
    closeAccordionFn()
  }

  React.useEffect(() => {
    if connector->String.length > 0 {
      switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(STRIPE)
      | Processors(BANKOFAMERICA)
      | Processors(CYBERSOURCE)
      | Processors(NUVEI)
      | Processors(WORLDPAYVANTIV)
      | Processors(TESOURO) =>
        setApplePayIntegrationType(_ => #simplified)

      | _ => setApplePayIntegrationType(_ => #manual)
      }

      getProcessorDetails()->ignore
    }
    None
  }, [connector])

  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(ZEN) =>
        <ApplePayZen applePayFields update closeModal closeAccordionFn connector />
      | _ =>
        switch applePayIntegrationStep {
        | Landing =>
          <Landing
            connector
            closeModal
            setApplePayIntegrationSteps
            appleIntegrationType
            setApplePayIntegrationType
          />
        | Configure =>
          switch appleIntegrationType {
          | #simplified =>
            <ApplePaySimplifiedFlow
              applePayFields
              merchantBusinessCountry
              setApplePayIntegrationSteps
              setVefifiedDomainList
              connector
              appleIntegrationType
            />
          | #manual =>
            <ApplePayManualFlow
              applePayFields
              merchantBusinessCountry
              setApplePayIntegrationSteps
              setVefifiedDomainList
              connector
              appleIntegrationType
            />
          }
        | Verify =>
          <Verified
            verifiedDomainList
            setApplePayIntegrationType
            closeAccordionFn
            setApplePayIntegrationSteps
            appleIntegrationType
            update
            connector
          />
        }
      }}
    </div>
  </PageLoaderWrapper>
}
