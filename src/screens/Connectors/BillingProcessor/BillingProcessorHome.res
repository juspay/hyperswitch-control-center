@react.component
let make = () => {
  open BillingProcessorTypes
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open Typography

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let url = RescriptReactRouter.useUrl()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let fetchDetails = useGetMethod()
  let connectorName = UrlUtils.useGetFilterDictFromUrl("")->getString("name", "")

  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currentStep, setCurrentStep) = React.useState(_ => ConfigurationFields)
  let (showConfirmModal, setShowConfirmModal) = React.useState(_ => false)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()
  let isUpdateFlow = switch url.path->HSwitchUtils.urlPath {
  | list{"billing-processor", "new"} => false
  | _ => true
  }

  let connectorInfo = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV1,
    initialValues->getDictFromJsonObject,
  )

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
        let dict = BillingProcessorsUtils.getConnectorConfig(connectorName)
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

  let updateBusinessProfileDetails = async mcaId => {
    try {
      let body = Dict.make()
      body->Dict.set("billing_processor_id", mcaId->JSON.Encode.string)
      let _ = await updateBusinessProfile(~body=body->Identity.genericTypeToJson)
    } catch {
    | _ => showToast(~message=`Failed to update`, ~toastType=ToastState.ToastError)
    }
  }
  let billing_processor_id = switch businessProfileRecoilVal.billing_processor_id {
  | Some(id) => id
  | None => ""
  }

  let onSubmit = async (values, _) => {
    try {
      let body =
        generateInitialValuesDict(
          ~values,
          ~connector=connectorName,
          ~bodyType,
          ~isLiveMode={false},
          ~connectorType=ConnectorTypes.BillingProcessor,
        )->ignoreFields(connectorID, connectorIgnoredField)
      let connectorUrl = getURL(
        ~entityName=V1(CONNECTOR),
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorID) : None,
      )
      let response = await updateAPIHook(connectorUrl, body, Post)

      if !isUpdateFlow {
        let mcaId =
          response
          ->getDictFromJsonObject
          ->getString("merchant_connector_id", "")
        let _ = await updateBusinessProfileDetails(mcaId)
      }
      let _ = await fetchConnectorListResponse()
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
      connectorName->getConnectorNameTypeFromString(~connectorType=BillingProcessor),
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
    connectorInfo.merchant_connector_id == billing_processor_id
      ? <div
          className={`border border-nd_gray-200 bg-nd_gray-50 px-2 py-2-px rounded-lg ${body.md.medium}`}>
          {"Default"->React.string}
        </div>
      : React.null
  | _ =>
    <Button
      text="Done"
      buttonType=Primary
      onClick={_ =>
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/billing-processor"))}
    />
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-10 overflow-scroll h-full w-full">
      <BreadCrumbNavigation
        path=[
          connectorID === "new"
            ? {
                title: "Billing Processor",
                link: "/billing-processor",
                warning: `You have not yet completed configuring your ${connectorName->snakeToTitle} connector. Are you sure you want to go back?`,
              }
            : {
                title: "Billing Processor",
                link: "/billing-processor",
              },
        ]
        currentPageTitle={connectorName->getDisplayNameForConnector(
          ~connectorType=BillingProcessor,
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
              connectorType={BillingProcessor}
              headerButton={<BillingProcessorHelper.ConnectButton
                setShowModal={setShowConfirmModal}
              />}>
              <div className="flex flex-col gap-2 p-2 md:px-10">
                <ConnectorAccountDetailsHelper.BusinessProfileRender
                  isUpdateFlow selectedConnector={connectorName}
                />
              </div>
              <div className="flex flex-col gap-2 p-2 md:p-10">
                <div className="grid grid-cols-2 flex-1">
                  <ConnectorAccountDetailsHelper.ConnectorConfigurationFields
                    connector={connectorName->getConnectorNameTypeFromString(
                      ~connectorType=BillingProcessor,
                    )}
                    connectorAccountFields
                    selectedConnector={connectorName
                    ->getConnectorNameTypeFromString(~connectorType=BillingProcessor)
                    ->getConnectorInfo}
                    connectorMetaDataFields
                    connectorWebHookDetails
                    connectorLabelDetailField
                    connectorAdditionalMerchantData
                  />
                </div>
              </div>
            </ConnectorAccountDetailsHelper.ConnectorHeaderWrapper>
            <Modal
              showModal={showConfirmModal}
              setShowModal={setShowConfirmModal}
              modalClass="w-full md:w-4/12 mx-auto my-40 rounded-xl"
              childClass="">
              <div className="relative flex items-start px-4 pb-10 pt-6 gap-4">
                <div className="flex flex-col gap-5">
                  <div className="flex justify-between">
                    <p className={`${heading.sm.semibold}`}>
                      {"Connect Billing Processor ?"->React.string}
                    </p>
                    <Icon
                      name="hswitch-close" size=22 onClick={_ => setShowConfirmModal(_ => false)}
                    />
                  </div>
                  <p className={`text-hyperswitch_black opacity-50 ${body.md.medium}`}>
                    {"Are you sure you want to connect this billing processor ? This will set this as the default processor."->React.string}
                  </p>
                </div>
              </div>
              <div className="flex items-end justify-end gap-4 px-4 pb-4">
                <Button
                  buttonType=Button.Secondary
                  onClick={_ => setShowConfirmModal(_ => false)}
                  text="Cancel"
                />
                <FormRenderer.SubmitButton
                  text="Proceed" buttonType=Button.Primary loadingText="Processing..."
                />
              </div>
            </Modal>
          </Form>

        | Summary | Preview =>
          <ConnectorAccountDetailsHelper.ConnectorHeaderWrapper
            connector=connectorName
            connectorType={BillingProcessor}
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
