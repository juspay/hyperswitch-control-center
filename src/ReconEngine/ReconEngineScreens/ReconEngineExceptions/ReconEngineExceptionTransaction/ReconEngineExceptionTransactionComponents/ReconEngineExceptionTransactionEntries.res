open Typography

@react.component
let make = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~currentExceptionDetails: ReconEngineTypes.transactionType,
  ~accountsData: array<ReconEngineTypes.accountType>,
) => {
  open EntriesTableEntity
  open ReconEngineUtils
  open ReconEngineExceptionTransactionTypes
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open APIUtils
  open LogicUtils

  let (exceptionStage, setExceptionStage) = React.useState(_ => ShowResolutionOptions(
    NoResolutionOptionNeeded,
  ))
  let showToast = ToastState.useShowToast()
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (updatedEntriesList, setUpdatedEntriesList) = React.useState(_ =>
    entriesList->addUniqueIdsToEntries
  )
  let detailsFields = [
    EntryType,
    Amount,
    Currency,
    Status,
    EntryId,
    OrderID,
    EffectiveAt,
    CreatedAt,
  ]
  let (showConfirmationModal, setShowConfirmationModal) = React.useState(_ => false)
  let (offset, setOffset) = React.useState(_ => 0)
  let (resultsPerPage, setResultsPerPage) = React.useState(_ => 10)
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  let handleRowSelect = (updateFn: array<JSON.t> => array<JSON.t>) => {
    setSelectedRows(prev => {
      let updated = updateFn(prev)
      switch updated->Array.length {
      | 0 => []
      | _ => [updated->getValueFromArray(updated->Array.length - 1, JSON.Encode.null)]
      }
    })
  }

  let (groupedEntries, accountInfoMap) = React.useMemo(() => {
    getGroupedEntriesAndAccountMaps(~accountsData, ~updatedEntriesList)
  }, (updatedEntriesList, accountsData))

  let sectionDetails = (sectionIndex: int, rowIndex: int) => {
    getSectionRowDetails(
      ~sectionIndex,
      ~rowIndex,
      ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
    )
  }

  let tableSections = React.useMemo(() => {
    let sections = getEntriesSections(~groupedEntries, ~accountInfoMap, ~detailsFields)
    let accountIds = groupedEntries->Dict.keysToArray
    sections->Array.mapWithIndex((section, index) => {
      let accountId = accountIds->getValueFromArray(index, "")
      let entriesWithUniqueId = groupedEntries->Dict.get(accountId)->Option.getOr([])
      {
        ...section,
        rowData: entriesWithUniqueId->Array.map(entry => entry->Identity.genericTypeToJson),
      }
    })
  }, (groupedEntries, accountInfoMap, detailsFields, currentExceptionDetails.transaction_status))

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let url = getURL(
      ~entityName=V1(HYPERSWITCH_RECON),
      ~hyperswitchReconType=#MANUAL_RECONCILIATION,
      ~methodType=Post,
      ~id=Some(currentExceptionDetails.id),
    )
    let body = constructManualReconciliationBody(~updatedEntriesList, ~values)
    let res = await updateDetails(url, body, Post)
    let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
    setShowConfirmationModal(_ => false)
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
      GlobalVars.appendDashboardPath(~url="/v1/recon-engine/transaction-exceptions"),
    )
    Nullable.null
  }

  let summaryItems = React.useMemo(() => {
    generateAllResolutionSummaries(
      entriesList,
      updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType),
    )
  }, (entriesList, updatedEntriesList))

  let onCloseClickCustomFun = () => {
    setExceptionStage(_ => ConfirmResolution(exceptionStage->getInnerVariant))
    setShowConfirmationModal(_ => false)
  }

  let isRowSelectable = switch exceptionStage {
  | ResolvingException(MarkAsReceived) =>
    Some(
      (rowData: JSON.t) => {
        let entry =
          rowData
          ->getDictFromJsonObject
          ->exceptionTransactionEntryItemToItemMapper
        entry.status == Expected
      },
    )
  | _ => None
  }

  <div className="flex flex-col gap-4 mt-6 mb-16">
    <ReconEngineExceptionTransactionResolution
      accountInfoMap
      exceptionStage
      setExceptionStage
      selectedRows
      setSelectedRows
      updatedEntriesList
      setUpdatedEntriesList
      currentExceptionDetails
      accountsData
      oldEntriesList={entriesList->addUniqueIdsToEntries}
    />
    <ReconEngineCustomExpandableSelectionTable
      title=""
      heading={detailsFields->Array.map(getHeading)}
      getSectionRowDetails=sectionDetails
      showScrollBar=true
      showOptions={exceptionStage == ResolvingException(EditEntry) ||
      exceptionStage == ResolvingException(MarkAsReceived) ||
      exceptionStage == ResolvingException(LinkStagingEntriesToTransaction)}
      selectedRows
      onRowSelect=handleRowSelect
      sections=tableSections
      offset
      setOffset
      resultsPerPage
      setResultsPerPage
      totalResults={updatedEntriesList->Array.length}
      ?isRowSelectable
    />
    <RenderIf
      condition={exceptionStage == ConfirmResolution(EditEntry) ||
      exceptionStage == ConfirmResolution(CreateNewEntry) ||
      exceptionStage == ConfirmResolution(MarkAsReceived) ||
      exceptionStage == ConfirmResolution(LinkStagingEntriesToTransaction)}>
      <div
        className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
        <div className="flex gap-3">
          <Button
            text="Discard"
            buttonType={Secondary}
            customButtonStyle="!w-full"
            onClick={_ => {
              setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
              setUpdatedEntriesList(_ => entriesList->addUniqueIdsToEntries)
              setSelectedRows(_ => [])
            }}
          />
          <Button
            text="Resolve Exception"
            buttonType={Primary}
            customButtonStyle="!w-full"
            onClick={_ => setShowConfirmationModal(_ => true)}
          />
        </div>
      </div>
    </RenderIf>
    <Modal
      setShowModal=setShowConfirmationModal
      showModal=showConfirmationModal
      closeOnOutsideClick=true
      onCloseClickCustomFun
      modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
      childClass="mx-4 mb-4 h-full"
      modalHeadingClass={`${heading.sm.semibold} text-nd_gray-700`}
      modalHeading="Resolve Exception">
      <div className="flex flex-col gap-4">
        <Form
          onSubmit validate={validateReasonField} initialValues={Dict.make()->JSON.Encode.object}>
          {reasonMultiLineTextInputField(~label="Add Remark")}
          <div className="flex flex-col">
            {<RenderIf condition={summaryItems->Array.length > 0}>
              {<React.Fragment>
                <p className={`${body.md.semibold} text-nd_gray-700 mx-2 mt-4`}>
                  {"Resolution Summary"->React.string}
                </p>
                <div className="flex flex-col gap-2 mx-2 mt-2">
                  {summaryItems
                  ->Array.mapWithIndex((item, index) =>
                    <div
                      key={index->Int.toString} className={`${body.md.regular} text-nd_gray-600`}>
                      {`${(index + 1)->Int.toString}. ${item}`->React.string}
                    </div>
                  )
                  ->React.array}
                </div>
              </React.Fragment>}
            </RenderIf>}
            <div className="flex justify-end gap-3 mt-4 items-center">
              <Button
                buttonType=Secondary
                buttonSize=Medium
                text="Cancel"
                customButtonStyle="mt-4 !w-fit"
                onClick={_ => {
                  setExceptionStage(_ => ConfirmResolution(exceptionStage->getInnerVariant))
                  setShowConfirmationModal(_ => false)
                }}
              />
              <FormRenderer.SubmitButton
                text="Save Changes" buttonType={Primary} customSumbitButtonStyle="!w-fit mt-4"
              />
            </div>
          </div>
        </Form>
      </div>
    </Modal>
  </div>
}
