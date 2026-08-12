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
            text="Ignore Transaction" buttonType={Primary} customSubmitButtonStyle="!w-fit mt-4"
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
            text="Force Match" buttonType={Primary} customSubmitButtonStyle="!w-fit mt-4"
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
    open ReconEngineExceptionsHelper
    open ReconEngineExceptionTransactionHelper
    open APIUtils
    open ReconEngineHooks
    open LogicUtils
    open ReconEngineUtils

    let getAccounts = useGetAccounts()
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let fetchMetadataSchema = useFetchMetadataSchema()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (accountsList, setAccountsList) = React.useState(_ => [])
    let (transformationsList, setTransformationsList) = React.useState(_ => [])
    let (metadataSchema, setMetadataSchema) = React.useState(_ =>
      Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper
    )
    let (metadataRows, setMetadataRows) = React.useState(_ => [])
    let (isMetadataLoading, setIsMetadataLoading) = React.useState(_ => false)

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountData = await getAccounts()
        setAccountsList(_ => accountData)
        if entryDetails.account_id->isNonEmptyString {
          let url = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
            ~queryParameters=Some(`account_id=${entryDetails.account_id}`),
          )
          let res = await fetchDetails(url)
          setTransformationsList(_ =>
            res->getArrayDataFromJson(transformationConfigItemToObjMapper)
          )
          switch entryDetails.transformation_id {
          | Some(transformationId) => {
              let schema =
                (await fetchMetadataSchema(~transformationId))
                ->getDictFromJsonObject
                ->metadataSchemaItemToObjMapper
              setMetadataSchema(_ => schema)
            }
          | None => ()
          }
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
      isNewlyCreatedEntry
        ? validateCreateEntryDetails(values, ~metadataSchema)
        : validateEditEntryDetails(
            values,
            ~initialEntryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
            ~metadataSchema,
          )
    }, (isNewlyCreatedEntry, entryDetails, metadataSchema.id))

    let initialFormValues = React.useMemo(() => {
      getInitialValuesForEditEntries(entryDetails->getEntryTypeFromExceptionEntryType)
    }, [])

    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-full w-full" />}>
      <div className="flex flex-col gap-4 mx-4 h-full">
        <Form
          onSubmit
          validate
          initialValues={initialFormValues}
          formClass="h-full flex flex-col justify-between">
          <div className="flex flex-col max-h-890-px overflow-y-auto">
            {accountTransformationSelectInputField(~accountsList, ~setTransformationsList)}
            {transformationConfigSelectInputField(
              ~transformationsList,
              ~disabled=false,
              ~setMetadataSchema,
              ~setIsMetadataLoading,
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
              text="Save changes"
              buttonType={Primary}
              toolTipFullWidth=true
              customSubmitButtonStyle="!w-full"
            />
          </div>
        </Form>
      </div>
    </PageLoaderWrapper>
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
    open ReconEngineExceptionsHelper
    open APIUtils
    open ReconEngineHooks
    open LogicUtils
    open ReconEngineUtils

    let getAccounts = useGetAccounts()
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let fetchMetadataSchema = useFetchMetadataSchema()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (accountsList, setAccountsList) = React.useState(_ => [])
    let (transformationsList, setTransformationsList) = React.useState(_ => [])
    let (metadataSchema, setMetadataSchema) = React.useState(_ =>
      Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper
    )
    let (metadataRows, setMetadataRows) = React.useState(_ => [])
    let (isMetadataLoading, setIsMetadataLoading) = React.useState(_ => false)

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountData = await getAccounts()
        setAccountsList(_ => accountData)
        if entryDetails.account_id->isNonEmptyString {
          let url = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Get,
            ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
            ~queryParameters=Some(`account_id=${entryDetails.account_id}`),
          )
          let res = await fetchDetails(url)
          setTransformationsList(_ =>
            res->getArrayDataFromJson(transformationConfigItemToObjMapper)
          )

          switch entryDetails.transformation_id {
          | Some(transformationId) => {
              let schema =
                (await fetchMetadataSchema(~transformationId))
                ->getDictFromJsonObject
                ->metadataSchemaItemToObjMapper
              setMetadataSchema(_ => schema)
            }
          | None => ()
          }
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
      validateCreateEntryDetails(values, ~metadataSchema)
    }, [metadataSchema.id])

    let initialFormValues = React.useMemo(() => {
      getInitialValuesForEditEntries(entryDetails->getEntryTypeFromExceptionEntryType)
    }, [])

    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-full w-full" />}>
      <div className="flex flex-col gap-4 mx-4 h-full">
        <Form
          onSubmit
          validate
          initialValues={initialFormValues}
          formClass="h-full flex flex-col justify-between">
          <div className="flex flex-col max-h-890-px overflow-y-auto">
            {accountTransformationSelectInputField(~accountsList, ~setTransformationsList)}
            {transformationConfigSelectInputField(
              ~transformationsList,
              ~disabled=false,
              ~setMetadataSchema,
              ~setIsMetadataLoading,
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
              text="Mark as Received"
              buttonType={Primary}
              toolTipFullWidth=true
              customSubmitButtonStyle="!w-full"
            />
          </div>
        </Form>
      </div>
    </PageLoaderWrapper>
  }
}

module CreateEntryModalContent = {
  @react.component
  let make = (~entriesList, ~onSubmit, ~entryDetails) => {
    open ReconEngineExceptionTransactionUtils
    open ReconEngineExceptionsHelper
    open ReconEngineExceptionTransactionHelper
    open ReconEngineHooks

    let getAccounts = useGetAccounts()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (accountsList, setAccountsList) = React.useState(_ => [])
    let (transformationsList, setTransformationsList) = React.useState(_ => [])
    let (metadataSchema, setMetadataSchema) = React.useState(_ =>
      Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper
    )
    let (metadataRows, setMetadataRows) = React.useState(_ => [])
    let (isMetadataLoading, setIsMetadataLoading) = React.useState(_ => false)

    let fetchData = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountData = await getAccounts()
        setAccountsList(_ => accountData)
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
      validateCreateEntryDetails(values, ~metadataSchema)
    }, [metadataSchema.id])

    let initialValues = React.useMemo(() => {
      getInitialValuesForNewEntries()
    }, [])

    <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="h-full w-full" />}>
      <div className="flex flex-col gap-4 mx-4 h-full">
        <Form
          onSubmit
          validate
          initialValues={initialValues}
          formClass="h-full flex flex-col justify-between">
          <div className="flex flex-col max-h-890-px overflow-y-auto">
            {accountTransformationSelectInputField(~accountsList, ~setTransformationsList)}
            {transformationConfigSelectInputField(
              ~transformationsList,
              ~disabled=false,
              ~setMetadataSchema,
              ~setIsMetadataLoading,
            )}
            {entryTypeSelectInputField()}
            {currencySelectInputField(
              ~entriesList,
              ~isNewlyCreatedEntry=true,
              ~entryDetails=entryDetails->getEntryTypeFromExceptionEntryType,
            )}
            {amountTextInputField()}
            {orderIdTextInputField()}
            {effectiveAtDatePickerInputField()}
            {metadataCustomInputField(
              ~metadataSchema,
              ~metadataRows,
              ~setMetadataRows,
              ~isMetadataLoading,
            )}
          </div>
          <div className="my-4">
            <FormRenderer.SubmitButton
              text="Create new entry"
              buttonType={Primary}
              toolTipFullWidth=true
              customSubmitButtonStyle="!w-full"
            />
          </div>
        </Form>
      </div>
    </PageLoaderWrapper>
  }
}

module ReplaceStagingEntryModalContent = {
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
      OrderId,
      EntryType,
      Amount,
      Currency,
      AccountName,
      Status,
      StagingEntryId,
      EffectiveAt,
    ]

    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let searchTypeRef = React.useRef(ReconEnginePipelinesTypes.SearchStagingEntryId)

    let getLinkableStagingEntriesV2 = ReconEngineHooks.useGetCursorPage(
      ~hyperswitchReconType=#LINKABLE_STAGING_ENTRIES,
      ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
    )

    let {
      items: linkableStagingEntries,
      cursors,
      screenState,
      goToFirstPage,
      goToNextPage,
      goToPrevPage,
    } = ReconEngineCursorPaginationHook.useCursorPagination(~fetchPage=async (
      ~sortBy,
      ~direction,
    ) => {
      let linkedStagingEntryIds =
        updatedEntriesList->Array.filterMap(entry => entry.staging_entry_id)->Set.fromArray

      let page = await getLinkableStagingEntriesV2(
        ~body=buildLinkableStagingEntriesV2Body(
          ~sortBy,
          ~direction,
          ~searchType=searchTypeRef.current,
          ~searchText,
        ),
        ~id=Some(currentExceptionDetails.id),
      )
      {
        ...page,
        items: page.items->Array.filter(entry => !(linkedStagingEntryIds->Set.has(entry.id))),
      }
    })

    let handleSearchSubmit = (selectedType: option<string>) => {
      let newSearchType =
        selectedType->mapOptionOrDefault(
          ReconEnginePipelinesTypes.SearchStagingEntryId,
          ReconEnginePipelinesUtils.stagingEntrySearchTypeFromString,
        )
      searchTypeRef.current = newSearchType
      setSelectedRows(_ => [])
      goToFirstPage()
    }

    React.useEffect(() => {
      if activeModal == Some(LinkStagingEntriesModal) {
        goToFirstPage()
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
      getStagingEntryDetails(~rowIndex, ~stagingEntries=linkableStagingEntries)
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

    <Form
      initialValues={formValues} validate onSubmit formClass="h-full flex flex-col justify-between">
      <div className="p-6 flex flex-col gap-4 overflow-y-auto">
        <ReconEngineCustomExpandableSelectionTable
          title=""
          heading={entriesDetailsFields->Array.map(EntriesTableEntity.getHeading)}
          getSectionRowDetails=getEntriesSectionDetails
          showOptions=false
          selectedRows
          onRowSelect={_ => ()}
          sections=entriesTableSections
        />
        <p className={`${body.lg.semibold} text-nd_gray-700`}>
          {"Select entry to match"->React.string}
        </p>
        <SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search by ID"
          showTypeSelector=true
          typeSelectorOptions=ReconEnginePipelinesUtils.stagingEntrySearchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-full"
        />
        <PageLoaderWrapper
          screenState customLoader={<Shimmer styleClass="h-96 w-full rounded-xl" />}>
          <RenderIf condition={linkableStagingEntries->isEmptyArray}>
            <NewAnalyticsHelper.NoData
              height="h-96" message="No linkable transformed entries found."
            />
          </RenderIf>
          <RenderIf condition={linkableStagingEntries->isNonEmptyArray}>
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
            />
            <ReconEngineCursorPaginationButtons
              cursors
              isLoading={screenState === PageLoaderWrapper.Loading}
              hasData={linkableStagingEntries->isNonEmptyArray}
              onPrev={() => {
                setSelectedRows(_ => [])
                goToPrevPage()
              }}
              onNext={() => {
                setSelectedRows(_ => [])
                goToNextPage()
              }}
            />
          </RenderIf>
        </PageLoaderWrapper>
      </div>
      <div className="flex justify-end gap-3 p-6 items-center border-t border-nd_gray-150">
        <Button
          buttonType=Secondary
          buttonSize=Medium
          text="Cancel"
          customButtonStyle="!w-full"
          onClick={_ => setActiveModal(_ => None)}
        />
        <FormRenderer.SubmitButton
          text="Replace" buttonType=Primary toolTipFullWidth=true customSubmitButtonStyle="!w-full"
        />
      </div>
    </Form>
  }
}

module LinkStagingEntryModalContent = {
  @react.component
  let make = (
    ~currentExceptionDetails: ReconEngineTypes.transactionType,
    ~activeModal,
    ~setActiveModal,
    ~setExceptionStage,
    ~onSubmit,
    ~updatedEntriesList: array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>,
  ) => {
    open LogicUtils
    open ReconEngineExceptionTransactionHelper
    open ReconEngineExceptionTransactionUtils

    let stagingEntriesDetailsFields: array<ReconEngineExceptionEntity.processingColType> = [
      OrderId,
      EntryType,
      Amount,
      Currency,
      AccountName,
      Status,
      StagingEntryId,
      EffectiveAt,
    ]

    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let searchTypeRef = React.useRef(ReconEnginePipelinesTypes.SearchStagingEntryId)

    let getLinkableStagingEntriesV2 = ReconEngineHooks.useGetCursorPage(
      ~hyperswitchReconType=#LINKABLE_STAGING_ENTRIES,
      ~itemMapper=ReconEngineUtils.processingItemToObjMapper,
    )

    let {
      items: linkableStagingEntries,
      cursors,
      screenState,
      goToFirstPage,
      goToNextPage,
      goToPrevPage,
    } = ReconEngineCursorPaginationHook.useCursorPagination(
      ~fetchPage=async (~sortBy, ~direction) => {
        let linkedStagingEntryIds =
          updatedEntriesList->Array.filterMap(entry => entry.staging_entry_id)->Set.fromArray

        let page = await getLinkableStagingEntriesV2(
          ~body=buildLinkableStagingEntriesV2Body(
            ~sortBy,
            ~direction,
            ~searchType=searchTypeRef.current,
            ~searchText,
          ),
          ~id=Some(currentExceptionDetails.id),
        )
        {
          ...page,
          items: page.items->Array.filter(entry => !(linkedStagingEntryIds->Set.has(entry.id))),
        }
      },
      ~persistKey=None,
    )

    let handleSearchSubmit = (selectedType: option<string>) => {
      let newSearchType =
        selectedType->mapOptionOrDefault(
          ReconEnginePipelinesTypes.SearchStagingEntryId,
          ReconEnginePipelinesUtils.stagingEntrySearchTypeFromString,
        )
      searchTypeRef.current = newSearchType
      setSelectedRows(_ => [])
      goToFirstPage()
    }

    React.useEffect(() => {
      if activeModal == Some(LinkStagingEntriesModal) {
        goToFirstPage()
      }
      None
    }, (currentExceptionDetails.id, updatedEntriesList))

    let handleRowSelect = (updateFn: array<JSON.t> => array<JSON.t>) => {
      setSelectedRows(updateFn)
    }

    let stagingEntriesTableSections = React.useMemo(() => {
      getStagingEntrySections(~stagingEntries=linkableStagingEntries, ~stagingEntriesDetailsFields)
    }, (linkableStagingEntries, stagingEntriesDetailsFields))

    let stagingEntriesSections = (_sectionIndex: int, rowIndex: int) => {
      getStagingEntryDetails(~rowIndex, ~stagingEntries=linkableStagingEntries)
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

    <Form
      initialValues={formValues} validate onSubmit formClass="h-full flex flex-col justify-between">
      <div className="p-6 flex flex-col gap-4 overflow-y-auto">
        <p className={`${body.lg.semibold} text-nd_gray-700`}>
          {"Select entry to link"->React.string}
        </p>
        <SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search by ID"
          showTypeSelector=true
          typeSelectorOptions=ReconEnginePipelinesUtils.stagingEntrySearchTypeOptions
          onSubmitSearchDropdown=handleSearchSubmit
          showSearchIcon=true
          widthClass="w-full"
        />
        <PageLoaderWrapper
          screenState customLoader={<Shimmer styleClass="h-96 w-full rounded-xl" />}>
          <RenderIf condition={linkableStagingEntries->isEmptyArray}>
            <NewAnalyticsHelper.NoData
              height="h-96" message="No linkable transformed entries found."
            />
          </RenderIf>
          <RenderIf condition={linkableStagingEntries->isNonEmptyArray}>
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
            />
            <ReconEngineCursorPaginationButtons
              cursors
              isLoading={screenState === PageLoaderWrapper.Loading}
              hasData={linkableStagingEntries->isNonEmptyArray}
              onPrev={() => {
                setSelectedRows(_ => [])
                goToPrevPage()
              }}
              onNext={() => {
                setSelectedRows(_ => [])
                goToNextPage()
              }}
            />
          </RenderIf>
        </PageLoaderWrapper>
      </div>
      <div className="flex justify-end gap-3 p-6 items-center border-t border-nd_gray-150">
        <Button
          buttonType=Secondary
          buttonSize=Medium
          text="Cancel"
          customButtonStyle="!w-full"
          onClick={_ => {
            setExceptionStage(_ => ShowResolutionOptions(FixEntries))
            setActiveModal(_ => None)
          }}
        />
        <FormRenderer.SubmitButton
          text="Link Entry"
          buttonType=Primary
          toolTipFullWidth=true
          customSubmitButtonStyle="!w-full"
        />
      </div>
    </Form>
  }
}

@react.component
let make = (
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

  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (activeModal, setActiveModal) = React.useState(_ => None)
  let (availableResolutions, setAvailableResolutions) = React.useState(_ => [])
  let showToast = ToastAdapter.useShowToast()
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
        ~message="Failed to force reconcile the transaction. Please try again.",
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  let onEditEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper

    let updatedEntry = getUpdatedEntry(~formData, ~entryDetails)
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
    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper

    let updatedEntry = getUpdatedEntry(~formData, ~markAsReceived=true, ~entryDetails)
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
    setExceptionStage(_ => ConfirmResolution(ReplaceStagingEntryToTransaction))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onLinkEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getArrayDataFromJson(exceptionTransactionEntryItemToItemMapper)
    setUpdatedEntriesList(_ => updatedEntriesList->Array.concat(formData))
    setExceptionStage(_ => ConfirmResolution(LinkStagingEntryToTransaction))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onCreateEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let newEntry = getNewEntry(~formData, ~updatedEntriesList)
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
      className="flex flex-row items-start justify-between gap-6 w-full bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 mb-6">
      <ExceptionDataDisplay
        currentExceptionDetails
        entryDetails={updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
      />
      <RenderIf
        condition={exceptionStage == ShowResolutionOptions(FixEntries) ||
        exceptionStage == ConfirmResolution(EditEntry) ||
        exceptionStage == ConfirmResolution(CreateNewEntry) ||
        exceptionStage == ConfirmResolution(ReplaceStagingEntryToTransaction) ||
        exceptionStage == ConfirmResolution(LinkStagingEntryToTransaction)}>
        <div className="flex flex-col gap-4">
          <div className="flex flex-row gap-2 flex-wrap justify-end">
            {fixEntriesButtons
            ->Array.map(config => <ResolutionButton key={config.text} config />)
            ->React.array}
          </div>
          <RenderIf condition={exceptionStage == ShowResolutionOptions(FixEntries)}>
            <div
              className="flex flex-row gap-3 fixed left-1/2 -translate-x-1/2 bottom-4 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl px-3 py-4">
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
            isResolutionAvailable(ReplaceStagingEntryToTransaction) ||
            isResolutionAvailable(LinkStagingEntryToTransaction)}>
            <ACLButton
              authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
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
          className="flex flex-row items-center gap-3 fixed left-1/2 -translate-x-1/2 bottom-4 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
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
        | ResolvingException(ReplaceStagingEntryToTransaction) =>
          <ReplaceStagingEntryModalContent
            entryDetails={entryDetails}
            accountsData={accountsData}
            currentExceptionDetails={currentExceptionDetails}
            activeModal
            setActiveModal
            onSubmit={onReplaceEntrySubmit}
            updatedEntriesList
          />
        | ResolvingException(LinkStagingEntryToTransaction) =>
          <LinkStagingEntryModalContent
            currentExceptionDetails={currentExceptionDetails}
            activeModal
            setActiveModal
            setExceptionStage
            onSubmit={onLinkEntrySubmit}
            updatedEntriesList
          />
        | _ => React.null
        }}
      </ResolutionModal>
    </div>
  </PageLoaderWrapper>
}
