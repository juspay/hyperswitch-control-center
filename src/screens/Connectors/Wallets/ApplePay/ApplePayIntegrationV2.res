module Landing = {
  open WalletHelper
  @react.component
  let make = (
    ~connector,
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setShowWalletConfigurationModal,
    ~setApplePayIntegrationSteps,
  ) => {
    open ApplePayIntegrationTypesV2
    <>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(STRIPE) | Processors(BANKOFAMERICA) | Processors(CYBERSOURCE) =>
        <div
          className="p-6 m-2 cursor-pointer"
          onClick={_e => setApplePayIntegrationType(_ => #simplified)}>
          <Card heading="Web Domain" isSelected={appleIntegrationType === #simplified}>
            <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
              {"Get Apple Pay enabled on your web domains by hosting a verification file, that’s it."->React.string}
            </div>
            <div className="flex gap-2 mt-4">
              <CustomTag
                tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green")
              />
              <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            </div>
          </Card>
        </div>
      | _ => React.null
      }}
      <div
        className="p-6 m-2 cursor-pointer" onClick={_e => setApplePayIntegrationType(_ => #manual)}>
        <Card heading="iOS Certificate" isSelected={appleIntegrationType === #manual}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            <CustomSubText />
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
          onClick={_ev => {
            setShowWalletConfigurationModal(_ => false)
          }}
        />
        <Button
          onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
          text="Continue"
          buttonType={Primary}
        />
      </div>
    </>
  }
}

@react.component
let make = (~connector, ~setShowWalletConfigurationModal) => {
  open LogicUtils
  open ApplePayIntegrationTypesV2
  open ApplePayIntegrationUtilsV2
  open WalletHelper
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (appleIntegrationType, setApplePayIntegrationType) = React.useState(_ => #manual)
  let (applePayIntegrationStep, setApplePayIntegrationSteps) = React.useState(_ => Landing)
  let (merchantBusinessCountry, setMerchantBusinessCountry) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let applePayFileds = React.useMemo1(() => {
    try {
      if connector->isNonEmptyString {
        let dict =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("metadata")
          ->getArrayFromDict("apple_pay_v2", [])

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

  let getProcessorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let paymentMethoConfigUrl = getURL(~entityName=PAYMENT_METHOD_CONFIG, ~methodType=Get, ())
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

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()

  React.useEffect1(() => {
    // Need to refactor
    if connector->String.length > 0 {
      {
        switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
        | Processors(STRIPE)
        | Processors(BANKOFAMERICA)
        | Processors(CYBERSOURCE) =>
          setApplePayIntegrationType(_ => #simplified)
        | _ => setApplePayIntegrationType(_ => #manual)
        }
      }

      getProcessorDetails()->ignore
    }
    None
  }, [connector])

  React.useEffect1(() => {
    if connector->isNonEmptyString {
      let initialGooglePayDict =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
        ->getDictfromDict("apple_pay")
      let value = applePay(initialGooglePayDict, appleIntegrationType)
      Js.log2(value, "value")
      form.change("metadata.apple_pay", value->Identity.genericTypeToJson)
    }
    None
  }, [appleIntegrationType])
  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div>
      <Heading />
      <Landing
        connector
        setApplePayIntegrationType
        setShowWalletConfigurationModal
        setApplePayIntegrationSteps
        appleIntegrationType
      />
    </div>
  </PageLoaderWrapper>
}
