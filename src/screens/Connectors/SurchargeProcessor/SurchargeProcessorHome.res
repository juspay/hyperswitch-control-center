@react.component
let make = () => {
  open SurchargeProcessorTypes
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open Typography
  open SurchargeProcessorHelper

  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let connectorName = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")
  let showToast = ToastAdapter.useShowToast()

  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConfigurationFields)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"surcharge-processor", "new"} => false
  | _ => true
  }

  let connectorInfo = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV1,
    initialValues->getDictFromJsonObject,
  )

  let isConnectorDisabled = connectorInfo.disabled

  let disableConnector = async currentIsDisabled => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let mcaId = connectorInfo.merchant_connector_id
      let disableConnectorPayload = ConnectorUtils.getDisableConnectorPayload(
        connectorInfo.connector_type->ConnectorUtils.connectorTypeTypedValueToStringMapper,
        currentIsDisabled,
      )
      let url = getURL(~entityName=V1(CONNECTOR), ~methodType=Post, ~id=Some(mcaId))
      let res = await updateDetails(url, disableConnectorPayload, Post)
      setInitialValues(_ => res)
      let _ = await fetchConnectorListResponse()
      setScreenState(_ => PageLoaderWrapper.Success)
      showToast(~message="Successfully Saved the Changes", ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(_) => {
        let action = currentIsDisabled ? "enable" : "disable"

        showToast(~message=`Failed to ${action} connector!`, ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }

  let getDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let _ = await Window.connectorWasmInit()
      if isUpdateFlow {
        await getConnectorDetails()
        setCurrentStep(_ => Preview)
      } else {
        setCurrentStep(_ => ConfigurationFields)
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => Error(err))
      }
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  let connectorDetails = React.useMemo(() => {
    try {
      if connectorName->isNonEmptyString {
        Window.getSurchargeProcessorConfig(connectorName)
      } else {
        Dict.make()->JSON.Encode.object
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Dict.make()->JSON.Encode.object
      }
    }
  }, [connectorName])

  let {
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  } = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject

    if !isUpdateFlow {
      initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
      initialValuesToDict->Dict.set(
        "connector_label",
        `${connectorName}_${businessProfileRecoilVal.profile_name}`->JSON.Encode.string,
      )
    }
    None
  }, [connectorName, profileId])

  React.useEffect(() => {
    if connectorName->isNonEmptyString {
      getDetails()->ignore
    } else {
      setScreenState(_ => Error("Connector name not found"))
    }
    None
  }, [connectorName])

  let surchargeProcessorId =
    businessProfileRecoilVal.surcharge_connector_details->Option.mapOr("", details =>
      details.surcharge_connector_id
    )
  let onSubmit = async (values, _) => {
    try {
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector=connectorName,
          ~bodyType,
          ~isLiveMode,
          ~connectorType=ConnectorTypes.SurchargeProcessor,
        )->ignoreFields(connectorID, connectorIgnoredField)
      let connectorUrl = getURL(
        ~entityName=V1(CONNECTOR),
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorID) : None,
      )
      let response = await updateDetails(connectorUrl, body, Post)

      let _ = await fetchConnectorListResponse()
      setInitialValues(_ => response)
      setCurrentStep(_ => Summary)
      showToast(
        ~message=!isUpdateFlow ? "Connector Created Successfully!" : "Details Updated!",
        ~toastType=ToastSuccess,
      )
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errJson = err->safeParse->getDictFromJsonObject
        let errorCode = errJson->getString("code", "")
        let errorMessage = errJson->getString("message", "")

        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setCurrentStep(_ => ConfigurationFields)
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
      connectorName->getConnectorNameTypeFromString(~connectorType=SurchargeProcessor),
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let summaryPageButton = switch currentStep {
  | Preview =>
    <div className="flex gap-6 items-center">
      <RenderIf condition={connectorInfo.merchant_connector_id == surchargeProcessorId}>
        <div
          className={`border border-nd_gray-200 bg-nd_gray-50 px-2 py-2-px rounded-lg ${body.md.medium}`}>
          {"Default"->React.string}
        </div>
      </RenderIf>
      <ConnectorPreviewHelper.EnableDisableConnectorToggle disableConnector isConnectorDisabled />
    </div>
  | _ =>
    <Button
      text="Done"
      buttonType=Primary
      onClick={_ =>
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/surcharge-processor"))}
    />
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <BreadCrumbNavigation
        path=[
          connectorID === "new"
            ? {
                title: "Surcharge Processor",
                link: "/surcharge-processor",
                warning: `You have not yet completed configuring your ${connectorName->snakeToTitle} connector. Are you sure you want to go back?`,
              }
            : {
                title: "Surcharge Processor",
                link: "/surcharge-processor",
              },
        ]
        currentPageTitle={connectorName->getDisplayNameForConnector(
          ~connectorType=SurchargeProcessor,
        )}
      />
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | ConfigurationFields =>
          <Form initialValues={initialValues} onSubmit validate={validateMandatoryField}>
            <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
              connector=connectorName
              connectorType={SurchargeProcessor}
              headerButton={<ConnectButton />}>
              <div className="flex flex-col gap-2 p-2 md:px-10">
                <ConnectorAccountDetailsHelper.BusinessProfileRender
                  isUpdateFlow selectedConnector={connectorName}
                />
              </div>
              <div className="flex flex-col gap-2 p-2 md:p-10">
                <div className="grid grid-cols-2 flex-1">
                  <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
                    connector={connectorName->getConnectorNameTypeFromString(
                      ~connectorType=SurchargeProcessor,
                    )}
                    connectorAccountFields
                    selectedConnector={connectorName
                    ->getConnectorNameTypeFromString(~connectorType=SurchargeProcessor)
                    ->getConnectorInfo}
                    connectorMetaDataFields
                    connectorWebHookDetails
                    connectorLabelDetailField
                    connectorAdditionalMerchantData
                  />
                </div>
              </div>
            </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
          </Form>

        | Summary | Preview =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector=connectorName
            connectorType={SurchargeProcessor}
            headerButton={summaryPageButton}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo={ConnectorInterface.mapDictToTypedConnectorPayload(
                ConnectorInterface.connectorInterfaceV1,
                initialValues->getDictFromJsonObject,
              )}
              connector=connectorName
              setCurrentStep
              getConnectorDetails={Some(getConnectorDetails)}
            />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
