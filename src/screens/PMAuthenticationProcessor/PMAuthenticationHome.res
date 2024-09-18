module MenuOption = {
  open HeadlessUI
  @react.component
  let make = (~disableConnector, ~isConnectorDisabled) => {
    let showPopUp = PopUpState.useShowPopUp()
    let openConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action?",
        description: `You are about to ${isConnectorDisabled
            ? "Enable"
            : "Disable"->String.toLowerCase} this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => disableConnector(isConnectorDisabled)->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }

    let connectorStatusAvailableToSwitch = isConnectorDisabled ? "Enable" : "Disable"

    <Popover \"as"="div" className="relative inline-block text-left">
      {_popoverProps => <>
        <Popover.Button> {_ => <Icon name="menu-option" size=28 />} </Popover.Button>
        <Popover.Panel className="absolute z-20 right-5 top-4">
          {panelProps => {
            <div
              id="neglectTopbarTheme"
              className="relative flex flex-col bg-white py-1 overflow-hidden rounded ring-1 ring-black ring-opacity-5 w-40">
              {<>
                <Navbar.MenuOption
                  text={connectorStatusAvailableToSwitch}
                  onClick={_ => {
                    panelProps["close"]()
                    openConfirmationPopUp()
                  }}
                />
              </>}
            </div>
          }}
        </Popover.Panel>
      </>}
    </Popover>
  }
}

@react.component
let make = () => {
  open PMAuthenticationTypes
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let connectorName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")

  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConfigurationFields)

  let activeBusinessProfile =
    Recoil.useRecoilValueFromAtom(
      HyperswitchAtom.businessProfilesAtom,
    )->MerchantAccountUtils.getValueFromBusinessProfile

  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"pm-authentication-processor", "new"} => false
  | _ => true
  }

  let connectorInfo =
    initialValues->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  let isConnectorDisabled = connectorInfo.disabled

  let disableConnector = async isConnectorDisabled => {
    try {
      let connectorID = connectorInfo.merchant_connector_id
      let disableConnectorPayload = ConnectorUtils.getDisableConnectorPayload(
        connectorInfo.connector_type,
        isConnectorDisabled,
      )
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(connectorID))
      let _ = await updateDetails(url, disableConnectorPayload->JSON.Encode.object, Post)
      showToast(~message="Successfully Saved the Changes", ~toastType=ToastSuccess)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/pm-authentication-processor"))
    } catch {
    | Exn.Error(_) => showToast(~message="Failed to Disable connector!", ~toastType=ToastError)
    }
  }

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
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
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = Window.getPMAuthenticationProcessorConfig(connectorName)
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
    connectorAdditionalMerchantData,
  ) = getConnectorFields(connectorDetails)

  React.useEffect(() => {
    let initialValuesToDict = initialValues->LogicUtils.getDictFromJsonObject

    if !isUpdateFlow {
      initialValuesToDict->Dict.set(
        "profile_id",
        activeBusinessProfile.profile_id->JSON.Encode.string,
      )
      initialValuesToDict->Dict.set(
        "connector_label",
        `${connectorName}_${activeBusinessProfile.profile_name}`->JSON.Encode.string,
      )
    }
    None
  }, [connectorName, activeBusinessProfile.profile_id])

  React.useEffect(() => {
    if connectorName->LogicUtils.isNonEmptyString {
      getDetails()->ignore
    } else {
      setScreenState(_ => Error("Connector name not found"))
    }
    None
  }, [connectorName])

  let onSubmit = async (values, _) => {
    try {
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector=connectorName,
          ~bodyType,
          ~isPayoutFlow=false,
          ~isLiveMode={false},
          ~connectorType=ConnectorTypes.PMAuthenticationProcessor,
        )->ignoreFields(connectorID, connectorIgnoredField)
      let connectorUrl = getURL(
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorID) : None,
      )
      let response = await updateAPIHook(connectorUrl, body, Post)
      setInitialValues(_ => response)
      setCurrentStep(_ => Summary)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")

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
      connectorName->getConnectorNameTypeFromString(~connectorType=PMAuthenticationProcessor),
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let connectorStatusStyle = connectorStatus =>
    switch connectorStatus {
    | true => "border bg-red-600 bg-opacity-40 border-red-400 text-red-500"
    | false => "border bg-green-600 bg-opacity-40 border-green-700 text-green-700"
    }

  let summaryPageButton = switch currentStep {
  | Preview =>
    <div className="flex gap-6 items-center">
      <div
        className={`px-4 py-2 rounded-full w-fit font-medium text-sm !text-black ${isConnectorDisabled->connectorStatusStyle}`}>
        {(isConnectorDisabled ? "DISABLED" : "ENABLED")->React.string}
      </div>
      <MenuOption disableConnector isConnectorDisabled />
    </div>
  | _ =>
    <Button
      text="Done"
      buttonType=Primary
      onClick={_ =>
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(~url="/pm-authentication-processor"),
        )}
    />
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <BreadCrumbNavigation
        path=[
          connectorID === "new"
            ? {
                title: "PM Authentication Processor",
                link: "/pm-authentication-processor",
                warning: `You have not yet completed configuring your ${connectorName->LogicUtils.snakeToTitle} connector. Are you sure you want to go back?`,
              }
            : {
                title: "PM Authentication Porcessor",
                link: "/pm-authentication-processor",
              },
        ]
        currentPageTitle={connectorName->ConnectorUtils.getDisplayNameForConnector(
          ~connectorType=PMAuthenticationProcessor,
        )}
        cursorStyle="cursor-pointer"
      />
      <div
        className="bg-white rounded-lg border h-3/4 overflow-scroll shadow-boxShadowMultiple show-scrollbar">
        {switch currentStep {
        | ConfigurationFields =>
          <Form initialValues={initialValues} onSubmit validate={validateMandatoryField}>
            <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
              connector=connectorName
              connectorType={PMAuthenticationProcessor}
              headerButton={<AddDataAttributes
                attributes=[("data-testid", "connector-submit-button")]>
                <FormRenderer.SubmitButton loadingText="Processing..." text="Connect and Proceed" />
              </AddDataAttributes>}>
              <div className="flex flex-col gap-2 p-2 md:px-10">
                <ConnectorAccountDetailsHelper.BusinessProfileRender
                  isUpdateFlow selectedConnector={connectorName}
                />
              </div>
              <div className={`flex flex-col gap-2 p-2 md:p-10`}>
                <div className="grid grid-cols-2 flex-1">
                  <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
                    connector={connectorName->getConnectorNameTypeFromString(
                      ~connectorType=PMAuthenticationProcessor,
                    )}
                    connectorAccountFields
                    selectedConnector={connectorName
                    ->getConnectorNameTypeFromString(~connectorType=PMAuthenticationProcessor)
                    ->getConnectorInfo}
                    connectorMetaDataFields
                    connectorWebHookDetails
                    connectorLabelDetailField
                    connectorAdditionalMerchantData
                  />
                </div>
              </div>
            </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
            <FormValuesSpy />
          </Form>

        | Summary | Preview =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector=connectorName
            connectorType={PMAuthenticationProcessor}
            headerButton={summaryPageButton}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo
              connector=connectorName
              setScreenState={_ => ()}
              isPayoutFlow=false
              getConnectorDetails={Some(getConnectorDetails)}
              setCurrentStep={_ => ()}
            />
            <div />
          </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
