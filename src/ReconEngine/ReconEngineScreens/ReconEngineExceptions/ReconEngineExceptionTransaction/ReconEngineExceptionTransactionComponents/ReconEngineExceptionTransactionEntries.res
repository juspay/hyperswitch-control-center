open Typography

@react.component
let make = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~currentExceptionDetails: ReconEngineTypes.transactionType,
) => {
  open EntriesTableEntity
  open ReconEngineUtils
  open ReconEngineTransactionsUtils
  open ReconEngineExceptionTransactionTypes
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionTransactionHelper
  open APIUtils
  open LogicUtils

  let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [])
  let (exceptionStage, setExceptionStage) = React.useState(_ => ShowResolutionOptions(
    NoResolutionOptionNeeded,
  ))
  let showToast = ToastState.useShowToast()
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (updatedEntriesList, setUpdatedEntriesList) = React.useState(_ => entriesList)
  let detailsFields = [EntryType, Amount, Currency, Status, EntryId, EffectiveAt, CreatedAt]
  let (showConfirmationModal, setShowConfirmationModal) = React.useState(_ => false)
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  let handleRowSelect = (updateFn: array<JSON.t> => array<JSON.t>) => {
    setSelectedRows(prev => {
      let updated = updateFn(prev)
      switch updated->Array.length {
      | 0 => []
      | _ => [updated->Array.get(updated->Array.length - 1)->Option.getOr(JSON.Encode.null)]
      }
    })
  }

  let onExpandIconClick = (isExpanded, rowIndex) => {
    if isExpanded {
      setExpandedRowIndexArray(prev => prev->Array.filter(index => index !== rowIndex))
    } else {
      setExpandedRowIndexArray(prev => prev->Array.concat([rowIndex]))
    }
  }

  let getRowDetails = (rowIndex: int) => {
    let entry =
      updatedEntriesList->Array.get(rowIndex)->Option.getOr(Dict.make()->entryItemToObjMapper)
    let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
    let hasEntryMetadata = filteredEntryMetadata->Dict.keysToArray->Array.length > 0

    <RenderIf condition={hasEntryMetadata}>
      <div className="p-4">
        <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
          <PrettyPrintJson
            jsonToDisplay={filteredEntryMetadata->JSON.Encode.object->JSON.stringify}
          />
        </div>
      </div>
    </RenderIf>
  }

  let (groupedEntries, accountIdNameMap) = React.useMemo(() => {
    let groupDict = Dict.make()
    let idNameDict = Dict.make()

    updatedEntriesList->Array.forEach(entry => {
      let accountId = entry.account_id
      let existingEntries = groupDict->Dict.get(accountId)->Option.getOr([])
      groupDict->Dict.set(accountId, existingEntries->Array.concat([entry]))
      idNameDict->Dict.set(accountId, entry.account_name)
    })

    (groupDict, idNameDict)
  }, [updatedEntriesList])

  let getSectionRowDetails = (sectionIndex: int, rowIndex: int) => {
    let accountId = groupedEntries->Dict.keysToArray->getValueFromArray(sectionIndex, "")
    let sectionEntries = groupedEntries->Dict.get(accountId)->Option.getOr([])
    let entry = sectionEntries->getValueFromArray(rowIndex, Dict.make()->entryItemToObjMapper)
    let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
    let hasEntryMetadata = filteredEntryMetadata->Dict.keysToArray->Array.length > 0

    <RenderIf condition={hasEntryMetadata}>
      <div className="p-4">
        <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
          <PrettyPrintJson
            jsonToDisplay={filteredEntryMetadata->JSON.Encode.object->JSON.stringify}
          />
        </div>
      </div>
    </RenderIf>
  }

  let tableSections = React.useMemo(() => {
    groupedEntries
    ->Dict.keysToArray
    ->Array.map(accountId => {
      let accountName = accountIdNameMap->getvalFromDict(accountId)->Option.getOr("")
      let accountEntries = groupedEntries->getvalFromDict(accountId)->Option.getOr([])

      let (totalAmount, currency) = getSumOfAmountWithCurrency(accountEntries)

      let accountRows =
        accountEntries->Array.map(
          entry => detailsFields->Array.map(colType => getCell(entry, colType)),
        )
      let rowData = accountEntries->Array.map(entry => entry->Identity.genericTypeToJson)

      let titleElement =
        <div className="flex justify-between items-center mb-4">
          <p className={`text-nd_gray-700 ${body.lg.semibold}`}> {accountName->React.string} </p>
          <div className={`text-nd_gray-700 ${body.lg.medium}`}>
            {(currency ++ " " ++ totalAmount->Float.toString)->React.string}
          </div>
        </div>

      (
        {
          titleElement,
          rows: accountRows,
          rowData,
        }: Table.tableSection
      )
    })
  }, (groupedEntries, accountIdNameMap, detailsFields))

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let url = getURL(
      ~entityName=V1(HYPERSWITCH_RECON),
      ~hyperswitchReconType=#MANUAL_RECONCILIATION,
      ~methodType=Post,
      ~id=Some(currentExceptionDetails.id),
    )
    let body = constructManualReconciliationBody(~updatedEntriesList, ~values)
    let res = await updateDetails(url, body, Post)
    let transactionData = res->getDictFromJsonObject->transactionItemToObjMapper
    setShowConfirmationModal(_ => false)
    setExceptionStage(_ => ExceptionResolved)

    let generatedToastKey = randomString(~length=32)
    showToast(
      ~toastElement=<CustomToastElement
        message="Transaction matched successfully"
        transactionId={transactionData.id}
        toastKey={generatedToastKey}
      />,
      ~message="",
      ~toastType=ToastSuccess,
      ~toastKey=generatedToastKey,
      ~toastDuration=5000,
    )
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions"))
    Nullable.null
  }

  <div className="overflow-visible mt-7">
    <ReconEngineExceptionTransactionResolution
      accountIdNameMap
      exceptionStage
      setExceptionStage
      selectedRows
      setSelectedRows
      updatedEntriesList
      setUpdatedEntriesList
      currentExceptionDetails
    />
    <CustomExpandableTable
      title=""
      heading={detailsFields->Array.map(getHeading)}
      tableClass="overflow-y-auto"
      borderClass="border rounded-xl"
      firstColRoundedHeadingClass="rounded-tl-xl"
      lastColRoundedHeadingClass="rounded-tr-xl"
      headingBgColor="bg-nd_gray-25"
      headingFontWeight="font-semibold"
      headingFontColor="text-nd_gray-400"
      rowFontColor="text-nd_gray-600"
      customRowStyle="text-sm"
      rowFontStyle="font-medium"
      onExpandIconClick
      expandedRowIndexArray
      getRowDetails
      getSectionRowDetails
      showSerial=false
      showScrollBar=true
      showOptions={exceptionStage == ResolvingException(EditEntry) ||
        exceptionStage == ResolvingException(MarkAsReceived)}
      selectedRows
      onRowSelect=handleRowSelect
      sections=tableSections
    />
    <RenderIf
      condition={exceptionStage == ConfirmResolution(EditEntry) ||
        exceptionStage == ConfirmResolution(CreateNewEntry)}>
      <div
        className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
        <div className="flex gap-3">
          <Button
            text="Discard"
            buttonType={Secondary}
            customButtonStyle="!w-full"
            onClick={_ => {
              setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
              setUpdatedEntriesList(_ => entriesList)
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
      onCloseClickCustomFun={_ => {
        setExceptionStage(_ => ConfirmResolution(exceptionStage->getInnerVariant))
        setShowConfirmationModal(_ => false)
      }}
      modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
      childClass="mx-4 mb-4 h-full"
      modalHeadingClass={`${heading.sm.semibold} text-nd_gray-700`}
      modalHeading="Resolve Exception">
      <div className="flex flex-col gap-4">
        <Form
          onSubmit validate={validateReasonField} initialValues={Dict.make()->JSON.Encode.object}>
          {reasonMultiLineTextInputField(~label="Resolution Remark")}
          <div className="flex flex-col">
            {
              let summaryItems = generateAllResolutionSummaries(entriesList, updatedEntriesList)
              <RenderIf condition={summaryItems->Array.length > 0}>
                {<>
                  <p className={`${body.md.semibold} text-nd_gray-700 mx-2 mt-4`}>
                    {"Resolution Summary"->React.string}
                  </p>
                  <div className="flex flex-col gap-2 mx-2 mt-2">
                    {
                      let summaryItems = generateAllResolutionSummaries(
                        entriesList,
                        updatedEntriesList,
                      )
                      if summaryItems->Array.length > 0 {
                        summaryItems
                        ->Array.mapWithIndex((item, index) =>
                          <div
                            key={index->Int.toString}
                            className={`${body.md.regular} text-nd_gray-600`}>
                            {`${(index + 1)->Int.toString}. ${item}`->React.string}
                          </div>
                        )
                        ->React.array
                      } else {
                        <div className={`${body.md.regular} text-nd_gray-600`}>
                          {"No changes made"->React.string}
                        </div>
                      }
                    }
                  </div>
                </>}
              </RenderIf>
            }
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
