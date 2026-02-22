@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  open VaultProcessorUtilsV2
  open ConnectorUtils
  open PageLoaderWrapper

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId(~version=V2)

  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (screenState, setScreenState) = React.useState(_ => Success)
  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: (#configureVault: VaultProcessorTypesV2.vaultProcessorSectionsV2 :> string),
    subSectionId: None,
  })

  // Hardcoded connector details following BillingProcessorsUtils pattern
  let connectorDetails = getConnectorConfig()

  let connectorInfoDict = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    initialValues->getDictFromJsonObject,
  )

  let {
    connectorAccountFields,
    connectorMetaDataFields,
    connectorWebHookDetails,
    connectorLabelDetailField,
  } = getConnectorFields(connectorDetails)

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let updatedInitialVal = React.useMemo(() => {
    let dict = initialValues->getDictFromJsonObject
    dict->Dict.set("connector_name", vaultConnectorName->JSON.Encode.string)
    dict->Dict.set("connector_label", `${vaultConnectorName}_${profileId}`->JSON.Encode.string)
    dict->Dict.set("connector_type", "vault_processor"->JSON.Encode.string)
    dict->Dict.set("profile_id", profileId->JSON.Encode.string)
    dict->JSON.Encode.object
  }, [profileId])

  let onNextClick = () => {
    mixpanelEvent(~eventName=currentStep->getVaultProcessorMixPanelEvent)
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(~entityName=V2(V2_CONNECTOR), ~methodType=Post, ~id=None)
      let response = await updateAPIHook(connectorUrl, values, Post, ~version=V2)
      setInitialValues(_ => response)
      fetchConnectorListResponse()->ignore
      let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      setScreenState(_ => Success)
      onNextClick()
      showToast(~message="Vault Processor Connected Successfully!", ~toastType=ToastSuccess)
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v2/orchestration/vault-processors"),
      )
      setShowSideBar(_ => true)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "HE_01" {
          showToast(~message="Connector label already exists!", ~toastType=ToastError)
          setScreenState(_ => Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    validateConnectorRequiredFields(
      vaultConnectorName->getConnectorNameTypeFromString,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let backClick = () => {
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url="/v2/orchestration/vault-processors"),
    )
    setShowSideBar(_ => true)
  }

  React.useEffect(() => {
    setShowSideBar(_ => false)
    None
  }, [])

  let titleElement =
    <>
      <GatewayIcon gateway="HYPERSWITCH_VAULT" className="w-6 h-6" />
      <h1 className="text-medium font-semibold text-gray-600">
        {"Setup Hyperswitch Vault"->React.string}
      </h1>
    </>

  Js.log2("updatedInitialVal", updatedInitialVal)

  <div className="flex flex-col gap-10">
    <div className="flex h-full">
      <div className="flex flex-col">
        <VerticalStepIndicator titleElement sections currentStep backClick />
      </div>
      {switch currentStep.sectionId->stringToSectionVariantMapper {
      | #configureVault =>
        <div className="flex flex-col w-1/2 px-10 mt-8 overflow-y-auto">
          <PageUtils.PageHeading
            showPermLink=false
            title="Configure Vault"
            subTitle="Provide your Hyperswitch Vault credentials. These will be securely encrypted and stored."
            customSubTitleStyle="font-500 font-normal text-nd_gray-700"
          />
          <PageLoaderWrapper screenState>
            <Form onSubmit initialValues={updatedInitialVal} validate=validateMandatoryField>
              <div className="flex flex-col mb-5 gap-3">
                <ConnectorAuthKeys
                  initialValues={updatedInitialVal}
                  showVertically=true
                  processorType={VaultProcessor}
                />
                <ConnectorLabelV2 isInEditState=true connectorInfo={connectorInfoDict} />
                <FormRenderer.SubmitButton
                  text="Connect Vault"
                  buttonSize={Small}
                  customSumbitButtonStyle="!w-full mt-8"
                  tooltipForWidthClass="w-full"
                />
              </div>
            </Form>
          </PageLoaderWrapper>
        </div>
      }}
    </div>
  </div>
}
