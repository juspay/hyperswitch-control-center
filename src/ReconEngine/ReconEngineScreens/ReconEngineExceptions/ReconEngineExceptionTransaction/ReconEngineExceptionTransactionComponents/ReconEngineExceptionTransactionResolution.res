open Typography
open ReconEngineExceptionTransactionTypes

module IgnoreTransactionModalContent = {
  @react.component
  let make = (~onSubmit, ~setExceptionStage, ~setShowModal) => {
    open ReconEngineExceptionsUtils
    open ReconEngineExceptionTransactionHelper

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
    open ReconEngineExceptionsUtils
    open ReconEngineExceptionTransactionHelper

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
    ~entryDetails: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
    ~isNewlyCreatedEntry,
    ~updatedEntriesList,
    ~onSubmit,
  ) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    let validate = React.useCallback(values => {
      isNewlyCreatedEntry
        ? validateCreateEntryDetails(values)
        : validateEditEntryDetails(
            values,
            ~initialEntryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
          )
    }, (isNewlyCreatedEntry, entryDetails))

    <div className="flex flex-col gap-4 mx-4">
      <Form
        onSubmit
        validate
        initialValues={getInitialValuesForEditEntries(
          entryDetails->getEntryTypeFromExceptionEntryType,
        )}>
        {accountSelectInputField(
          ~isNewlyCreatedEntry,
          ~entriesList=updatedEntriesList,
          ~disabled=false,
        )}
        {entryTypeSelectInputField(~disabled=false)}
        {currencySelectInputField(
          ~entriesList=updatedEntriesList,
          ~isNewlyCreatedEntry,
          ~entryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
          ~disabled=false,
        )}
        {amountTextInputField(~disabled=false)}
        {orderIdTextInputField(~disabled=false)}
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
    ~entryDetails: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
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
        initialValues={getInitialValuesForEditEntries(
          entryDetails->getEntryTypeFromExceptionEntryType,
        )}>
        {accountSelectInputField(
          ~isNewlyCreatedEntry,
          ~entriesList=updatedEntriesList,
          ~disabled=true,
        )}
        {entryTypeSelectInputField(~disabled=false)}
        {currencySelectInputField(
          ~entriesList=updatedEntriesList,
          ~isNewlyCreatedEntry,
          ~entryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
          ~disabled=true,
        )}
        {amountTextInputField(~disabled=false)}
        {orderIdTextInputField(~disabled=false)}
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
  let make = (~entriesList, ~onSubmit, ~entryDetails) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionTransactionHelper

    <div className="flex flex-col gap-4 mx-4">
      <Form
        onSubmit
        validate={validateCreateEntryDetails}
        initialValues={getInitialValuesForNewEntries()}>
        {accountSelectInputField(~isNewlyCreatedEntry=true, ~entriesList)}
        {entryTypeSelectInputField()}
        {currencySelectInputField(
          ~entriesList,
          ~isNewlyCreatedEntry=true,
          ~entryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
        )}
        {amountTextInputField()}
        {orderIdTextInputField()}
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

module LinkStagingEntryModalContent = {
  @react.component
  let make = (
    ~entryDetails: ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType,
    ~accountsData,
    ~currentExceptionDetails: ReconEngineTypes.transactionType,
    ~activeModal,
    ~setActiveModal,
    ~onSubmit,
    ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  ) => {
    open APIUtils
    open LogicUtils
    open ReconEngineExceptionTransactionHelper
    open ReconEngineExceptionTransactionUtils

    let entriesDetailsFields: array<EntriesTableEntity.entryColType> = [
      EntryType,
      Amount,
      Currency,
      Status,
      EntryId,
      EffectiveAt,
      CreatedAt,
    ]

    let stagingEntriesDetailsFields: array<ReconEngineExceptionEntity.processingColType> = [
      EntryType,
      Amount,
      Currency,
      Status,
      StagingEntryId,
      AccountName,
      EffectiveAt,
    ]

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (linkableStagingEntries, setLinkableStagingEntries) = React.useState(_ => [])
    let (filteredStagingEntries, setFilteredStagingEntries) = React.useState(_ => [])
    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let (offset, setOffset) = React.useState(_ => 0)
    let (resultsPerPage, setResultsPerPage) = React.useState(_ => 10)

    let filterLogic = ReactDebounce.useDebounced(ob => {
      let (searchText, arr) = ob
      let filteredList = if searchText->isNonEmptyString {
        arr->Array.filter((obj: ReconEngineTypes.processingEntryType) => {
          isContainingStringLowercase(obj.staging_entry_id, searchText) ||
          isContainingStringLowercase(obj.entry_type, searchText)
        })
      } else {
        arr
      }
      setFilteredStagingEntries(_ => filteredList)
    }, ~wait=200)

    let fetchLinkableStagingEntries = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#LINKABLE_STAGING_ENTRIES,
          ~methodType=Get,
          ~id=Some(currentExceptionDetails.id),
        )
        let response = await fetchDetails(url)
        let stagingEntries =
          response->getArrayDataFromJson(ReconEngineUtils.processingItemToObjMapper)

        let linkedStagingEntryIds =
          updatedEntriesList
          ->Array.filterMap(entry => entry.staging_entry_id)
          ->Set.fromArray

        let availableStagingEntries =
          stagingEntries->Array.filter(stagingEntry =>
            !(linkedStagingEntryIds->Set.has(stagingEntry.id))
          )

        if availableStagingEntries->Array.length > 0 {
          setLinkableStagingEntries(_ => availableStagingEntries)
          setFilteredStagingEntries(_ => availableStagingEntries)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setScreenState(_ => PageLoaderWrapper.Custom)
        }
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(() => {
      if activeModal == Some(LinkStagingEntriesModal) {
        fetchLinkableStagingEntries()->ignore
      }
      None
    }, (currentExceptionDetails.id, updatedEntriesList))

    let (groupedEntries, accountInfoMap) = React.useMemo(() => {
      getGroupedEntriesAndAccountMaps(~accountsData, ~updatedEntriesList=[entryDetails])
    }, accountsData)

    let getEntriesSectionDetails = (sectionIndex: int, rowIndex: int) => {
      getSectionRowDetails(
        ~sectionIndex,
        ~rowIndex,
        ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
      )
    }

    let handleRowSelect = (updateFn: array<JSON.t> => array<JSON.t>) => {
      setSelectedRows(updateFn)
    }

    let entriesTableSections = React.useMemo(() => {
      getEntriesSections(
        ~groupedEntries,
        ~accountInfoMap,
        ~detailsFields=entriesDetailsFields,
        ~showTotalAmount=false,
      )
    }, (groupedEntries, accountInfoMap, entriesDetailsFields, entryDetails))

    let stagingEntriesTableSections = React.useMemo(() => {
      getStagingEntrySections(~stagingEntries=linkableStagingEntries, ~stagingEntriesDetailsFields)
    }, (linkableStagingEntries, stagingEntriesDetailsFields))

    let stagingEntriesSections = (_sectionIndex: int, rowIndex: int) => {
      getStagingEntryDetails(~rowIndex, ~stagingEntries=filteredStagingEntries)
    }

    let formValues = React.useMemo(() => {
      let entriesArray = selectedRows->Array.map(row => {
        let stagingEntry =
          row->getDictFromJsonObject->exceptionTransactionProcessingEntryItemToObjMapper
        getConvertedEntriesFromStagingEntry(stagingEntry)
      })
      entriesArray->JSON.Encode.array
    }, [selectedRows])

    let validate = React.useCallback(values => {
      let errors = Dict.make()
      let valuesDict = values->getDictFromJsonObject
      if valuesDict->isEmptyDict {
        errors->Dict.set(
          "staging_entry",
          "Please select at least one transformed entry."->JSON.Encode.string,
        )
      }
      errors->JSON.Encode.object
    }, [])

    <Form initialValues={formValues} validate onSubmit>
      <div className="p-6 flex flex-col gap-4">
        <ReconEngineCustomExpandableSelectionTable
          title=""
          heading={entriesDetailsFields->Array.map(EntriesTableEntity.getHeading)}
          getSectionRowDetails=getEntriesSectionDetails
          showOptions=false
          selectedRows
          onRowSelect={_ => ()}
          sections=entriesTableSections
          offset=0
          setOffset={_ => ()}
          resultsPerPage=10
          setResultsPerPage={_ => ()}
          totalResults=1
        />
        <PageLoaderWrapper
          screenState
          customLoader={<Shimmer styleClass="h-96 w-full rounded-xl" />}
          customUI={<NewAnalyticsHelper.NoData
            height="h-96" message="No linkable transformed entries found."
          />}>
          <p className={`${body.lg.semibold} text-nd_gray-700`}>
            {"Select entry to match"->React.string}
          </p>
          <ReconEngineCustomExpandableSelectionTable
            title=""
            heading={stagingEntriesDetailsFields->Array.map(
              ReconEngineExceptionEntity.getProcessingHeading,
            )}
            getSectionRowDetails=stagingEntriesSections
            showOptions=true
            selectedRows
            onRowSelect={handleRowSelect}
            sections=stagingEntriesTableSections
            offset
            setOffset
            resultsPerPage
            setResultsPerPage
            totalResults={filteredStagingEntries->Array.length}
            showSearchFilter=true
            searchFilterElement={<TableSearchFilter
              data={linkableStagingEntries}
              filterLogic
              placeholder="Search by Transformed Entry ID or Entry Type"
              customSearchBarWrapperWidth="w-full"
              customInputBoxWidth="w-full rounded-xl"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
          />
        </PageLoaderWrapper>
        <div
          className="absolute bottom-4 left-0 right-0 bg-white p-4 flex flex-row gap-3 items-center">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Cancel"
            customButtonStyle="!w-full"
            onClick={_ => setActiveModal(_ => None)}
          />
          <FormRenderer.SubmitButton
            showToolTip={false} text="Replace" buttonType=Primary customSumbitButtonStyle="!w-full"
          />
        </div>
      </div>
    </Form>
  }
}

@react.component
let make = (
  ~accountInfoMap: Dict.t<accountInfo>,
  ~exceptionStage,
  ~setExceptionStage,
  ~selectedRows,
  ~setSelectedRows,
  ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  ~setUpdatedEntriesList,
  ~currentExceptionDetails: ReconEngineTypes.transactionType,
  ~accountsData: array<ReconEngineTypes.accountType>,
  ~oldEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
) => {
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open ReconEngineExceptionsHelper
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
        entry.entry_key == updatedEntry.entry_key ? updatedEntry : entry
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
        entry.entry_key == updatedEntry.entry_key ? updatedEntry : entry
      )
    setUpdatedEntriesList(_ => newEntriesList)
    setExceptionStage(_ => ConfirmResolution(EditEntry))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])

    Nullable.null
  }

  let onReplaceEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getArrayDataFromJson(exceptionTransactionEntryItemToItemMapper)
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let selectedEntryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    let newEntriesList =
      updatedEntriesList->Array.filter(entry => entry.entry_key != selectedEntryDetails.entry_key)

    setUpdatedEntriesList(_ => newEntriesList->Array.concat(formData))
    setExceptionStage(_ => ConfirmResolution(LinkStagingEntriesToTransaction))
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

  let fixEntriesButtons = getFixEntriesButtons(
    ~isResolutionAvailable,
    ~showMarkAsReceivedButton,
    ~setExceptionStage,
    ~setActiveModal,
  )

  let mainResolutionButtons = getMainResolutionButtons(
    ~isResolutionAvailable,
    ~setExceptionStage,
    ~setActiveModal,
  )

  let bottomBarConfig = getBottomBarConfig(~exceptionStage, ~selectedRows, ~setActiveModal)

  let onDiscardChanges = () => {
    setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
    setSelectedRows(_ => [])
    setUpdatedEntriesList(_ => oldEntriesList)
  }

  let isNewlyCreatedEntry = entryDetails.entry_id == "-"

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData
      height="h-24" message="No exception resolutions available."
    />}
    customLoader={<Shimmer styleClass="h-24 w-full rounded-xl" />}>
    <div
      className="flex flex-row items-center justify-between gap-3 w-full bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 mb-6">
      <ExceptionDataDisplay
        currentExceptionDetails
        entryDetails={updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
        accountInfoMap
      />
      <RenderIf
        condition={exceptionStage == ShowResolutionOptions(FixEntries) ||
        exceptionStage == ConfirmResolution(EditEntry) ||
        exceptionStage == ConfirmResolution(CreateNewEntry) ||
        exceptionStage == ConfirmResolution(LinkStagingEntriesToTransaction)}>
        <div className="flex flex-col gap-4">
          <div className="flex flex-row gap-2 flex-wrap justify-end">
            {fixEntriesButtons
            ->Array.map(config => <ResolutionButton key={config.text} config />)
            ->React.array}
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
                onClick={_ => onDiscardChanges()}
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
          {mainResolutionButtons
          ->Array.map(config => <ResolutionButton key={config.text} config />)
          ->React.array}
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
      {switch bottomBarConfig {
      | Some(config) =>
        <div
          className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Discard"
            onClick={_ => onDiscardChanges()}
            customButtonStyle="!w-fit"
          />
          <div className="border-r border-nd_gray-200 h-6" />
          <BottomActionBar config />
        </div>
      | None => React.null
      }}
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
            isNewlyCreatedEntry
            updatedEntriesList={isNewlyCreatedEntry
              ? oldEntriesList->Array.map(getEntryTypeFromExceptionEntryType)
              : updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
            onSubmit=onEditEntrySubmit
          />
        | ResolvingException(MarkAsReceived) =>
          <MarkAsReceivedModalContent
            entryDetails
            isNewlyCreatedEntry
            updatedEntriesList={isNewlyCreatedEntry
              ? oldEntriesList->Array.map(getEntryTypeFromExceptionEntryType)
              : updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
            onSubmit=onMarkAsReceivedSubmit
          />
        | ResolvingException(CreateNewEntry) =>
          <CreateEntryModalContent
            entriesList={oldEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
            onSubmit=onCreateEntrySubmit
            entryDetails
          />
        | ResolvingException(LinkStagingEntriesToTransaction) =>
          <LinkStagingEntryModalContent
            entryDetails={entryDetails}
            accountsData={accountsData}
            currentExceptionDetails={currentExceptionDetails}
            activeModal
            setActiveModal
            onSubmit={onReplaceEntrySubmit}
            updatedEntriesList
          />
        | _ => React.null
        }}
      </ResolutionModal>
    </div>
  </PageLoaderWrapper>
}
