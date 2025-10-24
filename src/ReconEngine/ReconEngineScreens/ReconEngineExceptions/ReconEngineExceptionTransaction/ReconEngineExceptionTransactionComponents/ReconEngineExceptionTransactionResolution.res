open Typography
open ReconEngineExceptionTransactionTypes

module IgnoreTransactionModalContent = {
  @react.component
  let make = (~onSubmit, ~setExceptionStage, ~setShowModal) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    <div className="flex flex-col gap-4">
      <Form onSubmit validate={validateReasonField} initialValues={Dict.make()->JSON.Encode.object}>
        {reasonMultiLineTextInputField(~label="Reason to ignore")}
        <div className="flex justify-end gap-3 mt-4 items-center">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Cancel"
            customButtonStyle="mt-4 !w-fit"
            onClick={_ => {
              setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
              setShowModal(_ => None)
            }}
          />
          <FormRenderer.SubmitButton
            text="Ignore Transaction" buttonType={Primary} customSumbitButtonStyle="!w-fit mt-4"
          />
        </div>
      </Form>
    </div>
  }
}

module ForceReconcileModalContent = {
  @react.component
  let make = (~onSubmit, ~setExceptionStage, ~setShowModal) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    <div className="flex flex-col gap-4">
      <Form onSubmit validate={validateReasonField} initialValues={Dict.make()->JSON.Encode.object}>
        {reasonMultiLineTextInputField(~label="Resolution Remark")}
        <div className="flex justify-end gap-3 mt-4 items-center">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Cancel"
            customButtonStyle="mt-4 !w-fit"
            onClick={_ => {
              setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
              setShowModal(_ => None)
            }}
          />
          <FormRenderer.SubmitButton
            text="Force Reconcile" buttonType={Primary} customSumbitButtonStyle="!w-fit mt-4"
          />
        </div>
      </Form>
    </div>
  }
}

module EditEntryModalContent = {
  @react.component
  let make = (
    ~entryDetails: ReconEngineTypes.entryType,
    ~isNewlyCreatedEntry,
    ~updatedEntriesList,
    ~onSubmit,
  ) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    let validate = React.useCallback(values => {
      isNewlyCreatedEntry
        ? validateCreateEntryDetails(values)
        : validateEditEntryDetails(values, ~initialEntryDetails=entryDetails)
    }, (isNewlyCreatedEntry, entryDetails))

    <div className="flex flex-col gap-4 mx-4">
      <Form onSubmit validate initialValues={getInitialValuesForEditEntries(entryDetails)}>
        {accountSelectInputField(~isNewlyCreatedEntry, ~updatedEntriesList, ~disabled=false)}
        {entryTypeSelectInputField(~disabled=false)}
        {currencySelectInputField(
          ~updatedEntriesList,
          ~isNewlyCreatedEntry,
          ~entryDetails,
          ~disabled=false,
        )}
        {amountTextInputField(~disabled=false)}
        {effectiveAtDatePickerInputField()}
        {metadataCustomInputField(~disabled=false)}
        <div className="absolute bottom-4 left-0 right-0 bg-white p-4">
          <FormRenderer.DesktopRow itemWrapperClass="" wrapperClass="items-center">
            <FormRenderer.SubmitButton
              tooltipForWidthClass="w-full"
              text="Save changes"
              buttonType={Primary}
              customSumbitButtonStyle="!w-full"
            />
          </FormRenderer.DesktopRow>
        </div>
      </Form>
    </div>
  }
}

module MarkAsReceivedModalContent = {
  @react.component
  let make = (
    ~entryDetails: ReconEngineTypes.entryType,
    ~isNewlyCreatedEntry,
    ~updatedEntriesList,
    ~onSubmit,
  ) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    <div className="flex flex-col gap-4 mx-4">
      <Form
        onSubmit
        validate={_ => Dict.make()->JSON.Encode.object}
        initialValues={getInitialValuesForEditEntries(entryDetails)}>
        {accountSelectInputField(~isNewlyCreatedEntry, ~updatedEntriesList, ~disabled=true)}
        {entryTypeSelectInputField(~disabled=false)}
        {currencySelectInputField(
          ~updatedEntriesList,
          ~isNewlyCreatedEntry,
          ~entryDetails,
          ~disabled=true,
        )}
        {amountTextInputField(~disabled=false)}
        {effectiveAtDatePickerInputField()}
        {metadataCustomInputField(~disabled=false)}
        <div className="absolute bottom-4 left-0 right-0 bg-white p-4">
          <FormRenderer.DesktopRow itemWrapperClass="" wrapperClass="items-center">
            <FormRenderer.SubmitButton
              tooltipForWidthClass="w-full"
              text="Mark as Received"
              buttonType={Primary}
              customSumbitButtonStyle="!w-full"
            />
          </FormRenderer.DesktopRow>
        </div>
      </Form>
    </div>
  }
}

module CreateEntryModalContent = {
  @react.component
  let make = (~updatedEntriesList, ~onSubmit, ~entryDetails) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    <div className="flex flex-col gap-4 mx-4">
      <Form
        onSubmit
        validate={validateCreateEntryDetails}
        initialValues={getInitialValuesForNewEntries()}>
        {accountSelectInputField(~isNewlyCreatedEntry=true, ~updatedEntriesList)}
        {entryTypeSelectInputField()}
        {currencySelectInputField(~updatedEntriesList, ~isNewlyCreatedEntry=true, ~entryDetails)}
        {amountTextInputField()}
        {effectiveAtDatePickerInputField()}
        {metadataCustomInputField()}
        <div className="absolute bottom-4 left-0 right-0 bg-white p-4">
          <FormRenderer.DesktopRow itemWrapperClass="" wrapperClass="items-center">
            <FormRenderer.SubmitButton
              tooltipForWidthClass="w-full"
              text="Create new entry"
              buttonType={Primary}
              customSumbitButtonStyle="!w-full"
            />
          </FormRenderer.DesktopRow>
        </div>
      </Form>
    </div>
  }
}

@react.component
let make = (
  ~accountInfoMap: Dict.t<accountInfo>,
  ~exceptionStage,
  ~setExceptionStage,
  ~selectedRows,
  ~setSelectedRows,
  ~updatedEntriesList: array<ReconEngineTypes.entryType>,
  ~setUpdatedEntriesList,
  ~currentExceptionDetails: ReconEngineTypes.transactionType,
) => {
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open LogicUtils
  open ReconEngineUtils
  open APIUtils

  let (activeModal, setActiveModal) = React.useState(_ => None)
  let (availableResolutions, setAvailableResolutions) = React.useState(_ => [])
  let showToast = ToastState.useShowToast()
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchTransactionResolutions = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#TRANSACTION_RESOLUTIONS,
        ~methodType=Get,
        ~id=Some(currentExceptionDetails.id),
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

  React.useEffect(() => {
    fetchTransactionResolutions()->ignore
    None
  }, [currentExceptionDetails.id])

  let isResolutionAvailable = (resolution: resolvingException) => {
    availableResolutions->Array.some(r => r == resolution)
  }

  let onIgnoreTransactionSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#VOID_TRANSACTION,
        ~methodType=Put,
        ~id=Some(currentExceptionDetails.id),
      )
      let body = {
        "reason": valuesDict->getString("reason", ""),
      }

      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)
      let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => ExceptionResolved)

      let generatedToastKey = randomString(~length=32)

      showToast(
        ~toastElement=<CustomToastElement transaction toastKey={generatedToastKey} />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey=generatedToastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions"),
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

  let onForceReconcileSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#FORCE_RECONCILE_TRANSACTION,
        ~methodType=Put,
        ~id=Some(currentExceptionDetails.id),
      )
      let body = {
        "reason": valuesDict->getString("reason", ""),
      }

      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)
      let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => ExceptionResolved)

      let generatedToastKey = randomString(~length=32)

      showToast(
        ~toastElement=<CustomToastElement transaction toastKey={generatedToastKey} />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey=generatedToastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions"),
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
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let selectedAccountId = formData->getString("account", "")

    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    let selectedAccountName =
      updatedEntriesList
      ->Array.find(entry => entry.account_id == selectedAccountId)
      ->Option.map(entry => entry.account_name)
      ->Option.getOr("")

    let updatedEntry = getUpdatedEntry(
      ~formData,
      ~accountData={
        account_id: selectedAccountId,
        account_name: selectedAccountName,
      },
      ~entryDetails,
    )
    let newEntriesList =
      updatedEntriesList->Array.map(entry =>
        entry.entry_id == updatedEntry.entry_id ? updatedEntry : entry
      )
    setUpdatedEntriesList(_ => newEntriesList)
    setExceptionStage(_ => ConfirmResolution(EditEntry))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onMarkAsReceivedSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let selectedAccountId = formData->getString("account", "")

    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper

    let selectedAccountName =
      updatedEntriesList
      ->Array.find(entry => entry.account_id == selectedAccountId)
      ->Option.map(entry => entry.account_name)
      ->Option.getOr("")

    let updatedEntry = getUpdatedEntry(
      ~formData,
      ~accountData={
        account_id: selectedAccountId,
        account_name: selectedAccountName,
      },
      ~markAsReceived=true,
      ~entryDetails,
    )
    let newEntriesList =
      updatedEntriesList->Array.map(entry =>
        entry.entry_id == updatedEntry.entry_id ? updatedEntry : entry
      )
    setUpdatedEntriesList(_ => newEntriesList)
    setExceptionStage(_ => ConfirmResolution(EditEntry))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])

    Nullable.null
  }

  let onCreateEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let selectedAccountId = formData->getString("account", "")
    let selectedAccountName =
      updatedEntriesList
      ->Array.find(entry => entry.account_id == selectedAccountId)
      ->Option.map(entry => entry.account_name)
      ->Option.getOr("")

    let newEntry = getNewEntry(
      ~formData,
      ~accountData={
        account_id: selectedAccountId,
        account_name: selectedAccountName,
      },
      ~updatedEntriesList,
    )
    setUpdatedEntriesList(_ => updatedEntriesList->Array.concat([newEntry]))
    setExceptionStage(_ => ConfirmResolution(CreateNewEntry))
    Nullable.null
  }

  let entryDetails = React.useMemo(() => {
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
  }, [selectedRows])

  let showMarkAsReceivedButton =
    currentExceptionDetails.transaction_status == Expected ||
      updatedEntriesList->Array.some(entry => entry.status == Expected)

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData
      height="h-24" message="No exception resolutions available."
    />}
    customLoader={<Shimmer styleClass="h-24 w-full rounded-xl" />}>
    <div
      className="flex flex-row items-center justify-between gap-3 w-full bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 mb-6">
      <ExceptionDataDisplay
        currentExceptionDetails entryDetails=updatedEntriesList accountInfoMap
      />
      <RenderIf
        condition={exceptionStage == ShowResolutionOptions(FixEntries) ||
        exceptionStage == ConfirmResolution(EditEntry) ||
        exceptionStage == ConfirmResolution(CreateNewEntry)}>
        <div className="flex flex-col gap-4">
          <div className="flex flex-row gap-2 flex-wrap justify-end">
            <RenderIf condition={isResolutionAvailable(EditEntry)}>
              <Button
                buttonState=Normal
                buttonSize=Medium
                buttonType=Secondary
                text="Edit entry"
                textWeight={`${body.md.semibold}`}
                leftIcon={CustomIcon(
                  <Icon name="nd-pencil-edit-box" className="text-nd_gray-600" size=16 />,
                )}
                onClick={_ => setExceptionStage(_ => ResolvingException(EditEntry))}
                customButtonStyle="!w-fit"
              />
            </RenderIf>
            <RenderIf condition={showMarkAsReceivedButton}>
              <Button
                buttonState=Normal
                buttonSize=Medium
                buttonType=Secondary
                text="Mark as received"
                textWeight={`${body.md.semibold}`}
                leftIcon={CustomIcon(
                  <Icon name="nd-check-circle-outline" className="text-nd_gray-600" size=16 />,
                )}
                onClick={_ => setExceptionStage(_ => ResolvingException(MarkAsReceived))}
                customButtonStyle="!w-fit"
              />
            </RenderIf>
            <RenderIf condition={isResolutionAvailable(CreateNewEntry)}>
              <Button
                buttonState=Normal
                buttonSize=Medium
                buttonType=Secondary
                text="Create new entry"
                textWeight={`${body.md.semibold}`}
                leftIcon={CustomIcon(<Icon name="nd-plus" className="text-nd_gray-600" size=16 />)}
                onClick={_ => {
                  setExceptionStage(_ => ResolvingException(CreateNewEntry))
                  setActiveModal(_ => Some(CreateEntryModal))
                }}
                customButtonStyle="!w-fit"
              />
            </RenderIf>
          </div>
          <RenderIf condition={exceptionStage == ShowResolutionOptions(FixEntries)}>
            <div
              className="flex flex-row gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl px-3 py-4">
              <Button
                buttonState=Normal
                buttonSize=Medium
                buttonType=Secondary
                text="Discard"
                textWeight={`${body.md.semibold}`}
                customButtonStyle="!w-fit"
                onClick={_ => {
                  setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
                }}
              />
              <Button
                buttonState=Disabled
                buttonSize=Medium
                buttonType=Primary
                text="Resolve Exception"
                textWeight={`${body.md.semibold}`}
                customButtonStyle="!w-fit"
              />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
      <RenderIf condition={exceptionStage == ShowResolutionOptions(NoResolutionOptionNeeded)}>
        <div className="flex flex-row gap-3">
          <RenderIf condition={isResolutionAvailable(ForceReconcile)}>
            <Button
              buttonState=Normal
              buttonSize=Medium
              buttonType=Secondary
              text="Force Reconcile"
              textWeight={`${body.md.semibold}`}
              leftIcon={CustomIcon(
                <Icon name="nd-check-circle-outline" className="text-nd_gray-600" size=16 />,
              )}
              onClick={_ => {
                setExceptionStage(_ => ResolvingException(ForceReconcile))
                setActiveModal(_ => Some(ForceReconcileModal))
              }}
            />
          </RenderIf>
          <RenderIf condition={isResolutionAvailable(VoidTransaction)}>
            <Button
              buttonState=Normal
              buttonSize=Medium
              buttonType=Secondary
              text="Ignore Transaction"
              textWeight={`${body.md.semibold}`}
              leftIcon={CustomIcon(
                <Icon name="nd-delete-dustbin-02" className="text-nd_gray-600" size=16 />,
              )}
              onClick={_ => {
                setExceptionStage(_ => ResolvingException(VoidTransaction))
                setActiveModal(_ => Some(IgnoreTransactionModal))
              }}
            />
          </RenderIf>
          <RenderIf
            condition={isResolutionAvailable(EditEntry) ||
            isResolutionAvailable(CreateNewEntry) ||
            isResolutionAvailable(LinkStagingEntriesToTransaction)}>
            <Button
              buttonState=Normal
              buttonSize=Medium
              buttonType=Primary
              text="Fix Entries"
              textWeight={`${body.md.semibold}`}
              leftIcon={CustomIcon(
                <Icon name="nd-pencil-edit-line" className="text-white" size=16 />,
              )}
              onClick={_ => setExceptionStage(_ => ShowResolutionOptions(FixEntries))}
            />
          </RenderIf>
        </div>
      </RenderIf>
      <RenderIf condition={exceptionStage == ResolvingException(EditEntry)}>
        <div
          className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
          <p className={`${body.md.semibold} text-nd_gray-500`}>
            {"Select entry to edit"->React.string}
          </p>
          <Button
            buttonState={selectedRows->Array.length > 0 ? Normal : Disabled}
            buttonSize=Medium
            buttonType=Primary
            text="Edit entry"
            textWeight={`${body.md.semibold}`}
            customButtonStyle="!w-fit"
            onClick={_ => setActiveModal(_ => Some(EditEntryModal))}
          />
        </div>
      </RenderIf>
      <RenderIf condition={exceptionStage == ResolvingException(MarkAsReceived)}>
        <div
          className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
          <p className={`${body.md.semibold} text-nd_gray-500`}>
            {"Select entry to resolve"->React.string}
          </p>
          <Button
            buttonState={selectedRows->Array.length > 0 ? Normal : Disabled}
            buttonSize=Medium
            buttonType=Primary
            text="Continue"
            textWeight={`${body.md.semibold}`}
            customButtonStyle="!w-fit"
            onClick={_ => setActiveModal(_ => Some(MarkAsReceivedModal))}
          />
        </div>
      </RenderIf>
      <ResolutionModal
        exceptionStage
        setExceptionStage
        setSelectedRows
        activeModal
        setActiveModal
        config={getResolutionModalConfig(exceptionStage)}>
        {switch exceptionStage {
        | ResolvingException(VoidTransaction) =>
          <IgnoreTransactionModalContent
            onSubmit=onIgnoreTransactionSubmit setExceptionStage setShowModal=setActiveModal
          />
        | ResolvingException(ForceReconcile) =>
          <ForceReconcileModalContent
            onSubmit=onForceReconcileSubmit setExceptionStage setShowModal={setActiveModal}
          />
        | ResolvingException(EditEntry) =>
          <EditEntryModalContent
            entryDetails
            isNewlyCreatedEntry={entryDetails.entry_id == "-"}
            updatedEntriesList
            onSubmit=onEditEntrySubmit
          />
        | ResolvingException(MarkAsReceived) =>
          <MarkAsReceivedModalContent
            entryDetails
            isNewlyCreatedEntry={entryDetails.entry_id == "-"}
            updatedEntriesList
            onSubmit=onMarkAsReceivedSubmit
          />
        | ResolvingException(CreateNewEntry) =>
          <CreateEntryModalContent updatedEntriesList onSubmit=onCreateEntrySubmit entryDetails />
        | _ => React.null
        }}
      </ResolutionModal>
    </div>
  </PageLoaderWrapper>
}
