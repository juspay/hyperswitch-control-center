open Typography

@react.component
let make = (
  ~currentTransformedEntryDetails: ReconEngineTypes.processingEntryType,
  ~setUpdatedTransformedEntryDetails,
  ~updatedTransformedEntryDetails: ReconEngineTypes.processingEntryType,
) => {
  open ReconEngineTransformedEntryExceptionsTypes
  open ReconEngineExceptionEntity
  open ReconEngineTransformedEntryExceptionsHelper
  open ReconEngineTransformedEntryExceptionsUtils
  open APIUtils
  open LogicUtils
  open ReconEngineUtils
  open ReconEngineExceptionsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  let (
    exceptionStage,
    setExceptionStage,
  ) = React.useState(_ => ShowTransformedEntryResolutionOptions(
    NoTransformedEntryResolutionOptionNeeded,
  ))
  let (offset, setOffset) = React.useState(_ => 0)
  let (resultsPerPage, setResultsPerPage) = React.useState(_ => 10)
  let (showConfirmationModal, setShowConfirmationModal) = React.useState(_ => false)

  let detailsFields = [
    StagingEntryId,
    EntryType,
    AccountName,
    Amount,
    Currency,
    Status,
    OrderId,
    EffectiveAt,
  ]

  let sectionDetails = (sectionIndex: int, rowIndex: int) => {
    getSectionRowDetails(
      ~sectionIndex,
      ~rowIndex,
      ~groupedEntries=getGroupedEntriesAndAccountMaps(
        ~updatedEntriesList=[updatedTransformedEntryDetails],
      ),
    )
  }

  let tableSections = React.useMemo(() => {
    let sections = getEntriesSections(
      ~groupedEntries=[updatedTransformedEntryDetails],
      ~detailsFields,
    )
    sections->Array.map(section => {
      {
        ...section,
        rowData: section.rowData->Array.map(entry => entry->Identity.genericTypeToJson),
      }
    })
  }, (detailsFields, updatedTransformedEntryDetails))

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~methodType=Put,
        ~id=Some(currentTransformedEntryDetails.id),
      )
      let body = constructManualReconciliationBody(
        ~updatedEntry=updatedTransformedEntryDetails,
        ~values,
      )
      let res = await updateDetails(url, body, Put)
      let transformedEntry = res->getDictFromJsonObject->processingItemToObjMapper

      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=None,
        ~id=Some(currentTransformedEntryDetails.transformation_history_id),
      )
      let transformationHistoryRes = await fetchDetails(url)
      let transformationHistoryData =
        transformationHistoryRes->getDictFromJsonObject->transformationHistoryItemToObjMapper
      setShowConfirmationModal(_ => false)
      setExceptionStage(_ => TransformedEntryExceptionResolved)

      let generatedToastKey = randomString(~length=32)

      showToast(
        ~toastElement=<CustomToastElement
          processingEntry=transformedEntry
          toastKey={generatedToastKey}
          ingestionHistoryId=transformationHistoryData.ingestion_history_id
        />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey=generatedToastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/transformed-entries"),
      )
      Nullable.null
    } catch {
    | _ => {
        showToast(~message="Failed to update entry. Please try again.", ~toastType=ToastError)
        Nullable.null
      }
    }
  }

  let onCloseClickCustomFun = () => {
    setExceptionStage(_ => ConfirmTransformedEntryResolution(exceptionStage->getInnerVariant))
    setShowConfirmationModal(_ => false)
  }

  let summaryItems = React.useMemo(() => {
    generateResolutionSummary(
      ~currentEntry=currentTransformedEntryDetails,
      ~updatedEntry=updatedTransformedEntryDetails,
    )
  }, (currentTransformedEntryDetails, updatedTransformedEntryDetails))

  <div className="flex flex-col gap-4 mt-6 mb-16">
    <ReconEngineTransformedEntryExceptionResolution
      currentTransformedEntryDetails
      exceptionStage
      setExceptionStage
      setUpdatedTransformedEntryDetails
    />
    <ReconEngineCustomExpandableSelectionTable
      title=""
      heading={detailsFields->Array.map(getProcessingHeading)}
      getSectionRowDetails=sectionDetails
      showScrollBar=true
      showOptions={exceptionStage == ResolvingTransformedEntry(EditTransformedEntry)}
      sections=tableSections
      offset
      setOffset
      resultsPerPage
      setResultsPerPage
      totalResults=1
    />
    <RenderIf condition={exceptionStage == ConfirmTransformedEntryResolution(EditTransformedEntry)}>
      <div
        className="flex flex-row items-center gap-3 absolute right-1/2 bottom-10 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
        <div className="flex gap-3">
          <Button
            text="Discard"
            buttonType={Secondary}
            customButtonStyle="!w-full"
            onClick={_ => {
              setUpdatedTransformedEntryDetails(_ => currentTransformedEntryDetails)
              setExceptionStage(_ => ShowTransformedEntryResolutionOptions(
                NoTransformedEntryResolutionOptionNeeded,
              ))
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
                  setExceptionStage(_ => ConfirmTransformedEntryResolution(
                    exceptionStage->getInnerVariant,
                  ))
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
