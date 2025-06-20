@react.component
let make = (
  ~currentStep,
  ~setConnectorID,
  ~connector,
  ~setConnectorName,
  ~setNextStep,
  ~profileId,
  ~merchantId,
  ~activeBusinessProfile,
) => {
  open APIUtils
  open LogicUtils
  open ConnectorUtils
  open PageLoaderWrapper
  open RevenueRecoveryOnboardingUtils
  open ConnectProcessorsHelper

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=UserInfoTypes.V2,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let (arrow, setArrow) = React.useState(_ => false)

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let connectorInfoDict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->LogicUtils.getDictFromJsonObject,
  )
  let connectorTypeFromName = connector->getConnectorNameTypeFromString

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connector])

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->isNonEmptyString {
        let dict = Window.getConnectorConfig(connector)
        dict
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        Dict.make()->JSON.Encode.object
      }
    }
  }, [selectedConnector])

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set(
      "connector_label",
      `${connector}_${activeBusinessProfile}`->JSON.Encode.string,
    )
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->Dict.set(
      "connector_webhook_details",
      RevenueRecoveryData.payment_connector_webhook_details,
    )
    initialValuesToDict->Dict.set(
      "connector_account_details",
      RevenueRecoveryData.connector_account_details,
    )
    let keys =
      connectorDetails
      ->getDictFromJsonObject
      ->Dict.keysToArray
      ->Array.filter(val => Array.includes(["credit", "debit"], val))

    let pmtype = keys->Array.flatMap(key => {
      let paymentMethodType = connectorDetails->getDictFromJsonObject->getArrayFromDict(key, [])
      let updatedData = paymentMethodType->Array.map(
        val => {
          let wasmDict = val->getDictFromJsonObject
          let exisitngData =
            wasmDict->ConnectorPaymentMethodV2Utils.getPaymentMethodDictV2(key, connector)
          exisitngData
        },
      )
      updatedData
    })
    let pmSubTypeDict =
      [
        ("payment_method_type", "card"->JSON.Encode.string),
        ("payment_method_subtypes", pmtype->Identity.genericTypeToJson),
      ]->Dict.fromArray
    let pmArr = Array.make(~length=1, pmSubTypeDict)
    initialValuesToDict->Dict.set("payment_methods_enabled", pmArr->Identity.genericTypeToJson)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    mixpanelEvent(~eventName=currentStep->getMixpanelEventName)
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Put, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post, ~version=V2)
      setInitialValues(_ => response)

      let connectorInfoDict = ConnectorInterface.mapDictToConnectorPayload(
        ConnectorInterface.connectorInterfaceV2,
        response->getDictFromJsonObject,
      )
      setConnectorID(_ => connectorInfoDict.id)
      fetchConnectorListResponse()->ignore
      setScreenState(_ => Success)
      onNextClick(currentStep, setNextStep)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setNextStep(_ => RevenueRecoveryOnboardingUtils.defaultStep)
          setScreenState(_ => Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let {
    connectorAccountFields,
    connectorMetaDataFields,
    connectorWebHookDetails,
    connectorLabelDetailField,
  } = getConnectorFields(connectorDetails)

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    let profileId = valuesFlattenJson->getString("profile_id", "")
    if profileId->String.length === 0 {
      Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
    }

    validateConnectorRequiredFields(
      connectorTypeFromName,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }
  let handleClick = () => {
    mixpanelEvent(~eventName=currentStep->getMixpanelEventName)
    onNextClick(currentStep, setNextStep)->ignore
  }
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      setConnectorName(_ => value)
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/v2/recovery/onboarding?name=${value}`),
      )
    },
    onFocus: _ => (),
    value: connector->JSON.Encode.string,
    checked: true,
  }
  let options = RecoveryConnectorUtils.recoveryConnectorList->getOptions

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 !w-full"

  let recoveryConnectorListProd: array<
    BillingProcessorsUtils.optionType,
  > = RecoveryConnectorUtils.recoveryConnectorListProd->Array.map(connector => {
    let connectorName = connector->getConnectorNameString

    let option: BillingProcessorsUtils.optionType = {
      name: connectorName->getDisplayNameForConnector(~connectorType=ConnectorTypes.Processor),
      icon: `/Gateway/${connectorName->String.toUpperCase}.svg`,
    }

    option
  })

  let gatewaysBottomComponent = {
    open BillingProcessorsUtils
    <>
      <p
        className="text-nd_gray-500 font-semibold leading-3 text-fs-12 tracking-wider bg-white border-t px-5 pt-4">
        {"Available for Production"->React.string}
      </p>
      <div className="p-2">
        <ReadOnlyOptionsList list=recoveryConnectorListProd headerText="Payment Gateways" />
        <ReadOnlyOptionsList
          list=RecoveryConnectorUtils.recoveryConnectorInHouseList headerText="Payment Orchestrator"
        />
      </div>
    </>
  }

  open IntelligentRoutingUtils
  <div>
    {switch currentStep->RevenueRecoveryOnboardingUtils.getSectionVariant {
    | (#chooseDataSource, _) =>
      <PageWrapper
        title="Choose Your Data Source" subTitle="Select a data source to begin your simulation">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          {dataSource
          ->Array.map(dataSource => {
            switch dataSource {
            | Historical =>
              <>
                <div className="text-nd_gray-400 text-xs font-semibold tracking-wider">
                  {dataSource
                  ->dataTypeVariantToString
                  ->String.toUpperCase
                  ->React.string}
                </div>
                {fileTypes
                ->Array.map(item => {
                  let fileTypeHeading = item->getFileTypeHeading
                  let fileTypeDescription = item->getFileTypeDescription
                  let fileTypeIcon = item->getFileTypeIconName
                  let isSelected = item == Sample

                  <StepCard
                    stepName={fileTypeHeading}
                    description={fileTypeDescription}
                    isSelected
                    onClick={_ => ()}
                    iconName=fileTypeIcon
                    isDisabled={item === Upload}
                    showDemoLabel={item === Sample ? true : false}
                  />
                })
                ->React.array}
              </>
            | Realtime =>
              <>
                <div className="text-nd_gray-400 text-xs font-semibold tracking-wider">
                  {dataSource
                  ->dataTypeVariantToString
                  ->String.toUpperCase
                  ->React.string}
                </div>
                {realtime
                ->Array.map(item => {
                  let realtimeHeading = item->getRealtimeHeading
                  let realtimeDescription = item->getRealtimeDescription
                  let realtimeIcon = item->getRealtimeIconName

                  <StepCard
                    stepName={realtimeHeading}
                    description={realtimeDescription}
                    isSelected=false
                    onClick={_ => ()}
                    iconName=realtimeIcon
                    isDisabled={item === StreamLive}
                  />
                })
                ->React.array}
              </>
            }
          })
          ->React.array}
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => handleClick()}
            customButtonStyle="w-full mt-8"
          />
        </div>
      </PageWrapper>
    | (#connectProcessor, #selectProcessor) =>
      <PageWrapper
        title="Where do you process your payments"
        subTitle="Link the payment processor you use for handling subscription transactions.">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues validate=validateMandatoryField>
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText="Choose a processor"
                input
                deselectDisable=true
                customButtonStyle="!rounded-xl h-[45px] pr-2"
                options
                baseComponent={<ListBaseComp
                  placeHolder="Choose a processor" heading="Profile" subHeading=connector arrow
                />}
                bottomComponent=gatewaysBottomComponent
                hideMultiSelectButtons=true
                addButton=false
                searchable=true
                customStyle="!w-full"
                customScrollStyle
                dropdownContainerStyle
                toggleChevronState
                customDropdownOuterClass="!border-none"
                fullLength=true
                shouldDisplaySelectedOnTop=true
                searchInputPlaceHolder="Search Processor"
              />
              <RenderIf condition={connector->isNonEmptyString}>
                <div className="flex flex-col mb-5 mt-7 gap-3 w-full ">
                  <ConnectorAuthKeys
                    initialValues={updatedInitialVal} showVertically=true updateAccountDetails=false
                  />
                  <ConnectorLabelV2 isInEditState=true connectorInfo={connectorInfoDict} />
                  <ConnectorMetadataV2 isInEditState=true connectorInfo={connectorInfoDict} />
                  <ConnectorWebhookDetails isInEditState=true connectorInfo={connectorInfoDict} />
                  <FormRenderer.SubmitButton
                    text="Next"
                    buttonSize={Small}
                    customSumbitButtonStyle="!w-full mt-8"
                    tooltipForWidthClass="w-full"
                  />
                </div>
              </RenderIf>
            </Form>
          </PageLoaderWrapper>
        </div>
      </PageWrapper>
    | (#connectProcessor, #activePaymentMethods) =>
      <PageWrapper title="Payment Methods" subTitle="Configure your PaymentMethods.">
        <div className="mb-10 flex flex-col gap-7 w-540-px">
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues validate=validateMandatoryField>
              <div className="flex flex-col mb-5 gap-3 ">
                <ConnectorPaymentMethodV2 initialValues isInEditState=true />
                <FormRenderer.SubmitButton
                  text="Next"
                  buttonSize={Small}
                  customSumbitButtonStyle="!w-full mt-8"
                  tooltipForWidthClass="w-full"
                />
              </div>
            </Form>
          </PageLoaderWrapper>
        </div>
      </PageWrapper>
    | (#connectProcessor, #setupWebhookProcessor) =>
      <PageWrapper
        title="Setup Payments Webhook"
        subTitle="Configure this endpoint in the payment processors dashboard under webhook settings for us to receive events from the processor.">
        <div className="-m-1 mb-10 flex flex-col gap-7 w-540-px">
          <ConnectorWebhookPreview
            merchantId
            connectorName=connectorInfoDict.id
            textCss="border border-nd_gray-400 font-medium rounded-xl px-4 py-2 mb-6 mt-6  text-nd_gray-400 w-full !font-jetbrain-mono"
            containerClass="flex flex-row items-center justify-between"
            displayTextLength=38
            hideLabel=true
            showFullCopy=true
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => handleClick()}
            customButtonStyle="w-full mt-8"
          />
        </div>
      </PageWrapper>

    | (_, _) => React.null
    }}
  </div>
}
