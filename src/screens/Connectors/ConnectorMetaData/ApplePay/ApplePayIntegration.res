module Verified = {
  @react.component
  let make = (
    ~verifiedDomainList,
    ~setApplePayIntegrationType,
    ~appleIntegrationType,
    ~setApplePayIntegrationSteps,
    ~setShowWalletConfigurationModal,
    ~update,
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
      setShowWalletConfigurationModal(_ => false)
    }
    <>
      <div className="p-6 m-2 cursor-pointer">
        <p className="text-xs	font-medium	mt-4"> {" Web Domains"->React.string} </p>
        {verifiedDomainList
        ->Array.mapWithIndex((domainUrl, index) => {
          <div
            key={Int.toString(index)}
            className="mt-4 cursor-pointer"
            onClick={_e => setApplePayIntegrationType(_ => #manual)}>
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
                      onClick={_ev => setApplePayIntegrationSteps(_ => Configure)}
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
            onClick={_ev => {
              setApplePayIntegrationSteps(_ => Landing)
            }}
          />
          <Button
            onClick={_ev => {
              onSubmit()
            }}
            text="Proceed"
            buttonType={Primary}
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
    open AdditionalDetailsSidebarHelper
    <>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(STRIPE)
      | Processors(BANKOFAMERICA)
      | Processors(CYBERSOURCE) =>
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
            closeModal()
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
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open APIUtils
  open LogicUtils
  open AdditionalDetailsSidebarHelper
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

  let closeModal = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }

  React.useEffect(() => {
    if connector->String.length > 0 {
      switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(STRIPE)
      | Processors(BANKOFAMERICA)
      | Processors(CYBERSOURCE) =>
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
      <Heading />
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString() {
      | Processors(ZEN) =>
        <ApplePayZen applePayFields update closeModal setShowWalletConfigurationModal />
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
            />
          | #manual =>
            <ApplePayManualFlow
              applePayFields
              merchantBusinessCountry
              setApplePayIntegrationSteps
              setVefifiedDomainList
            />
          }
        | Verify =>
          <Verified
            verifiedDomainList
            setApplePayIntegrationType
            setShowWalletConfigurationModal
            setApplePayIntegrationSteps
            appleIntegrationType
            update
          />
        }
      }}
    </div>
    <FormValuesSpy />
  </PageLoaderWrapper>
}
