@react.component
let make = () => {
  open ThreeDsProcessorTypes
  open ConnectorUtils
  open APIUtils
  let url = RescriptReactRouter.useUrl()

  let connectorName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")

  let connectorID = url.path->List.toArray->Array.get(1)->Option.getOr("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConfigurationFields)
  let updateAPIHook = useUpdateMethod(~showErrorToast=false, ())
  let fetchDetails = useGetMethod()

  let isUpdateFlow = switch url.path {
  | list{"threeds-processors", "new"} => false
  | _ => true
  }

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID), ())
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
        setCurrentStep(_ => Summary)
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

  let connectorDetails = React.useMemo1(() => {
    try {
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = Window.getThreedsConnectorConfig(connectorName)
        setScreenState(_ => Success)
        dict
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

  let (
    bodyType,
    connectorAccountFields,
    connectorMetaDataFields,
    _,
    connectorWebHookDetails,
    connectorLabelDetailField,
  ) = getConnectorFields(connectorDetails)

  React.useEffect1(() => {
    if connectorName->LogicUtils.isNonEmptyString {
      getDetails()->ignore
    } else {
      setScreenState(_ => Error("Connector name not found"))
    }
    None
  }, [connectorName])

  let onSubmit = async (values, _) => {
    try {
      let body = generateInitialValuesDict(
        ~values,
        ~connector=connectorName,
        ~bodyType,
        ~isPayoutFlow=false,
        ~isLiveMode={false},
        (),
      )
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ())
      let response = await updateAPIHook(connectorUrl, body, Post, ())
      setInitialValues(_ => response)

      Js.log2("inside on submit", body)
      setCurrentStep(_ => Summary)
    } catch {
    | Exn.Error(e) => setCurrentStep(_ => ConfigurationFields)
    }
    Nullable.null
  }

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)

    validateConnectorRequiredFields(
      connectorName->getConnectorNameTypeFromString(),
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <BreadCrumbNavigation
        path=[
          connectorID === "new"
            ? {
                title: "Three Ds Processors",
                link: "/threeds-processors",
                warning: `You have not yet completed configuring your ${connectorName->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
              }
            : {
                title: "Three Ds Processors",
                link: "/threeds-processors",
              },
        ]
        currentPageTitle={connectorName->ConnectorUtils.getDisplayNameForConnector}
        cursorStyle="cursor-pointer"
      />
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | ConfigurationFields =>
          <Form initialValues onSubmit validate={validateMandatoryField}>
            <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
              connector=connectorName
              headerButton={<AddDataAttributes
                attributes=[("data-testid", "connector-submit-button")]>
                <FormRenderer.SubmitButton loadingText="Processing..." text="Connect and Proceed" />
              </AddDataAttributes>}>
              <div className={`flex flex-col gap-2 p-2 md:p-10`}>
                <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
                  connector={connectorName->getConnectorNameTypeFromString()}
                  connectorAccountFields
                  selectedConnector={connectorName
                  ->getConnectorNameTypeFromString()
                  ->getConnectorInfo}
                  connectorMetaDataFields
                  connectorWebHookDetails
                  connectorLabelDetailField
                />
              </div>
            </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
            <FormValuesSpy />
          </Form>

        | Summary =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector=connectorName
            headerButton={<Button
              text="Done"
              buttonType=Primary
              onClick={_ => RescriptReactRouter.push("/threeds-processors")}
            />}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo={initialValues
              ->LogicUtils.getDictFromJsonObject
              ->ConnectorTableUtils.getProcessorPayloadType}
              connector=connectorName
              setScreenState={_ => ()}
              isPayoutFlow=false
            />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
