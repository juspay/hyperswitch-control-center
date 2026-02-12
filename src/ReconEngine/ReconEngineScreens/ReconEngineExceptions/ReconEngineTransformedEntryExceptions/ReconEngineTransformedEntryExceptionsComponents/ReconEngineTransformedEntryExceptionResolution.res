open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsTypes
open ReconEngineTransformedEntryExceptionsHelper
open ReconEngineTransformedEntryExceptionsUtils

module IgnoreTransactionModalContent = {
  @react.component
  let make = (~onSubmit, ~setExceptionStage, ~setShowModal) => {
    open ReconEngineExceptionsUtils

    <div className="flex flex-col gap-4">
      <Form onSubmit validate={validateReasonField} initialValues={Dict.make()->JSON.Encode.object}>
        {reasonMultiLineTextInputField(~label="Add Remark")}
        <div className="flex justify-end gap-3 mt-4 items-center">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Cancel"
            customButtonStyle="mt-4 !w-fit"
            onClick={_ => {
              setExceptionStage(_ => ShowTransformedEntryResolutionOptions(
                NoTransformedEntryResolutionOptionNeeded,
              ))
              setShowModal(_ => None)
            }}
          />
          <FormRenderer.SubmitButton
            text="Ignore Entry" buttonType={Primary} customSumbitButtonStyle="!w-fit mt-4"
          />
        </div>
      </Form>
    </div>
  }
}

module EditEntryModalContent = {
  @react.component
  let make = (~entryDetails: processingEntryType, ~onSubmit) => {
    open APIUtils
    open ReconEngineHooks
    open LogicUtils
    open ReconEngineExceptionsHelper
    open ReconEngineUtils

    let getAccounts = useGetAccounts()
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let fetchMetadataSchema = useFetchMetadataSchema()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (accountsList, setAccountsList) = React.useState(_ => [])
    let (transformationsList, setTransformationsList) = React.useState(_ => [])
    let (metadataSchema, setMetadataSchema) = React.useState(_ =>
      Dict.make()->metadataSchemaItemToObjMapper
    )
    let (metadataRows, setMetadataRows) = React.useState(_ => [])
    let (isMetadataLoading, setIsMetadataLoading) = React.useState(_ => false)

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountData = await getAccounts()
        setAccountsList(_ => accountData)
        if entryDetails.account.account_id->isNonEmptyString {
          let url = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
            ~queryParameters=Some(`account_id=${entryDetails.account.account_id}`),
          )
          let res = await fetchDetails(url)
          setTransformationsList(_ =>
            res->getArrayDataFromJson(transformationConfigItemToObjMapper)
          )
        }
        if entryDetails.transformation_id->isNonEmptyString {
          let schema =
            (await fetchMetadataSchema(~transformationId=entryDetails.transformation_id))
            ->getDictFromJsonObject
            ->metadataSchemaItemToObjMapper
          setMetadataSchema(_ => schema)
        }
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load data"))
      }
    }

    React.useEffect(() => {
      fetchData()->ignore
      None
    }, [])

    let validate = React.useCallback(values => {
      validateEditEntryDetails(values, ~initialEntryDetails=entryDetails, ~metadataSchema)
    }, (entryDetails, metadataSchema.id))

    let initialValues = React.useMemo(() => {
      getInitialValuesForEditEntries(entryDetails)
    }, [entryDetails.id])

    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-full w-full" />}>
      <div className="flex flex-col gap-4 mx-4 h-full">
        <Form onSubmit validate initialValues formClass="h-full flex flex-col justify-between">
          <div className="flex flex-col max-h-890-px overflow-y-auto">
            <FormRenderer.FieldRenderer
              labelClass="font-semibold"
              field={FormRenderer.makeMultiInputFieldInfo(
                ~label="Account",
                ~comboCustomInput=accountComboSelectInputField(
                  ~accountsList,
                  ~disabled=false,
                  ~setTransformationsList,
                  ~initialAccountId=entryDetails.account.account_id,
                ),
                ~inputFields=[
                  FormRenderer.makeInputFieldInfo(~name="account.account_id"),
                  FormRenderer.makeInputFieldInfo(~name="account.account_name"),
                ],
                ~isRequired=true,
              )}
            />
            {transformationConfigSelectInputField(
              ~transformationsList,
              ~disabled=false,
              ~setMetadataSchema,
              ~setIsMetadataLoading,
            )}
            {entryTypeSelectInputField(~disabled=false)}
            {currencySelectInputField(~entryDetails, ~disabled=false)}
            {amountTextInputField(~disabled=false)}
            {orderIdTextInputField(~disabled=false)}
            {effectiveAtDatePickerInputField()}
            {metadataCustomInputField(
              ~disabled=false,
              ~metadataSchema,
              ~metadataRows,
              ~setMetadataRows,
              ~isMetadataLoading,
            )}
          </div>
          <div className="my-4">
            <FormRenderer.SubmitButton
              tooltipForWidthClass="w-full"
              text="Save changes"
              buttonType={Primary}
              showToolTip=false
              customSumbitButtonStyle="!w-full"
            />
          </div>
        </Form>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (
  ~currentTransformedEntryDetails: processingEntryType,
  ~exceptionStage,
  ~setExceptionStage,
  ~setUpdatedTransformedEntryDetails,
) => {
  open APIUtils
  open LogicUtils
  open ReconEngineUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (availableResolutions, setAvailableResolutions) = React.useState(_ => [])
  let (activeModal, setActiveModal) = React.useState(_ => None)

  let fetchTransactionResolutions = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PROCESSING_ENTRY_RESOLUTIONS,
        ~methodType=Get,
        ~id=Some(currentTransformedEntryDetails.id),
      )
      let response = await fetchDetails(url)
      let resolutions = parseResolutionActions(response)
      if resolutions->Array.length > 0 {
        setAvailableResolutions(_ => resolutions)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let isResolutionAvailable = (resolution: resolvingException) => {
    availableResolutions->Array.some(r => r == resolution)
  }

  let mainResolutionButtons = getMainResolutionButtons(
    ~isResolutionAvailable,
    ~setExceptionStage,
    ~setActiveModal,
  )

  let onIgnoreTransactionSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#VOID_PROCESSING_ENTRY,
        ~methodType=Put,
        ~id=Some(currentTransformedEntryDetails.id),
      )
      let body = {
        "reason": valuesDict->getString("reason", ""),
      }
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)

      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters=None,
        ~id=Some(currentTransformedEntryDetails.transformation_history_id),
      )
      let transformationHistoryRes = await fetchDetails(url)
      let transformationHistoryData =
        transformationHistoryRes->getDictFromJsonObject->transformationHistoryItemToObjMapper

      let processingEntry = res->getDictFromJsonObject->processingItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => TransformedEntryExceptionResolved)

      let generatedToastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement
          processingEntry
          toastKey={generatedToastKey}
          ingestionHistoryId={transformationHistoryData.ingestion_history_id}
        />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey=generatedToastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/recon"),
      )
    } catch {
    | _ =>
      showToast(
        ~message="Failed to ignore the transaction. Please try again.",
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  let onEditEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let updatedEntryDetails = getUpdatedEntry(
      ~formData,
      ~entryDetails=currentTransformedEntryDetails,
    )
    setUpdatedTransformedEntryDetails(_ => updatedEntryDetails)
    setExceptionStage(_ => ConfirmTransformedEntryResolution(EditTransformedEntry))
    setActiveModal(_ => None)

    Nullable.null
  }

  React.useEffect(() => {
    fetchTransactionResolutions()->ignore
    None
  }, [currentTransformedEntryDetails.id])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData
      height="h-24" message="No exception resolutions available."
    />}
    customLoader={<Shimmer styleClass="h-24 w-full rounded-xl" />}>
    <div
      className="flex flex-row items-center justify-between gap-3 w-full bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 mb-6">
      <ExceptionDataDisplay currentTransformedEntryDetails />
      <RenderIf
        condition={exceptionStage ==
          ShowTransformedEntryResolutionOptions(NoTransformedEntryResolutionOptionNeeded)}>
        <div className="flex flex-row gap-3">
          {mainResolutionButtons
          ->Array.map(config =>
            <ReconEngineExceptionsHelper.ResolutionButton key={config.text} config />
          )
          ->React.array}
        </div>
      </RenderIf>
      <ResolutionModal
        exceptionStage
        setExceptionStage
        activeModal
        setActiveModal
        config={getResolutionModalConfig(exceptionStage)}>
        {switch exceptionStage {
        | ResolvingTransformedEntry(VoidTransformedEntry) =>
          <IgnoreTransactionModalContent
            onSubmit=onIgnoreTransactionSubmit setExceptionStage setShowModal=setActiveModal
          />

        | ResolvingTransformedEntry(EditTransformedEntry) =>
          <EditEntryModalContent
            entryDetails=currentTransformedEntryDetails onSubmit=onEditEntrySubmit
          />
        | _ => React.null
        }}
      </ResolutionModal>
    </div>
  </PageLoaderWrapper>
}
