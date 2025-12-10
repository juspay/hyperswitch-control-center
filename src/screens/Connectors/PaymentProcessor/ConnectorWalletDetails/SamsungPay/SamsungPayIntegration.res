@react.component
let make = (~connector, ~setShowWalletConfigurationModal, ~update, ~onCloseClickCustomFun) => {
  open APIUtils
  open LogicUtils
  open SamsungPayIntegrationUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (merchantBusinessCountry, setMerchantBusinessCountry) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)

  let samsungPayFields = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let samsungPayInputFields =
          Window.getConnectorConfig(connector)
          ->getDictFromJsonObject
          ->getDictfromDict("connector_wallets_details")
          ->getArrayFromDict("samsung_pay", [])

        samsungPayInputFields
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

  let setSamsungFormData = () => {
    let initalFormValue =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("connector_wallets_details")
      ->getDictfromDict("samsung_pay")
      ->getDictfromDict("merchant_credentials")

    form.change(
      "connector_wallets_details.samsung_pay.merchant_credentials",
      initalFormValue->samsungPayRequest->Identity.genericTypeToJson,
    )
  }

  let getProcessorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let paymentMethoConfigUrl = getURL(~entityName=V1(PAYMENT_METHOD_CONFIG), ~methodType=Get)
      let res = await fetchDetails(
        `${paymentMethoConfigUrl}?connector=${connector}&paymentMethodType=samsung_pay`,
      )
      let countries =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("countries", [])
        ->Array.map(item => {
          let dict = item->getDictFromJsonObject
          let countryList: SelectBox.dropdownOption = {
            label: dict->getString("name", ""),
            value: dict->getString("code", ""),
          }
          countryList
        })

      setMerchantBusinessCountry(_ => countries)
      setSamsungFormData()
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  React.useEffect(() => {
    if connector->LogicUtils.isNonEmptyString {
      getProcessorDetails()->ignore
    }
    None
  }, [connector])
  
  let onSubmit = () => {
    update()
    setShowWalletConfigurationModal(_ => false)
  }

  let onCancel = () => {
    onCloseClickCustomFun()
    setShowWalletConfigurationModal(_ => false)
  }
  let samsungPayFields =
    samsungPayFields
    ->Array.mapWithIndex((field, index) => {
      let samsungPayField = field->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper
      let {name} = samsungPayField
      <div key={index->Int.toString}>
        {switch name {
        | "merchant_business_country" =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={CommonConnectorHelper.selectInput(
              ~field={samsungPayField},
              ~opt={Some(merchantBusinessCountry)},
              ~formName={
                samsungPayNameMapper(~name="merchant_business_country")
              },
            )}
          />
        | _ =>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={samsungPayValueInput(~samsungPayField, ~fill=textColor.primaryNormal)}
          />
        }}
      </div>
    })
    ->React.array
  <PageLoaderWrapper
    screenState={screenState}
    customLoader={<div className="mt-60 w-scrren flex flex-col justify-center items-center">
      <div className={`animate-spin mb-1`}>
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div className="p-2">
      {samsungPayFields}
      <div className={`flex gap-2  justify-end m-2 p-6`}>
        <Button text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} />
        <Button
          onClick={_ => onSubmit()}
          text="Continue"
          buttonType={Primary}
          buttonState={formState.values->SamsungPayIntegrationUtils.validateSamsungPay}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
