open Typography

module SelectionModeOption = {
  @react.component
  let make = (~label, ~description="", ~isSelected, ~onSelect) => {
    let containerClass = isSelected ? "border-nd_primary_blue-500" : "border-nd_gray-200"
    let radioClass = isSelected ? "border-nd_primary_blue-500" : "border-nd_gray-300"

    <div
      className={`flex gap-2.5 items-start p-3 rounded-xl border cursor-pointer ${containerClass}`}
      onClick={_ => onSelect()}>
      <div
        className={`h-4 w-4 mt-0.5 rounded-full border flex items-center justify-center flex-shrink-0 ${radioClass}`}>
        <RenderIf condition={isSelected}>
          <div className="h-2 w-2 rounded-full bg-nd_primary_blue-500" />
        </RenderIf>
      </div>
      <div className="flex flex-col gap-0.5">
        <p className={`${body.md.medium} text-nd_gray-700`}> {label->React.string} </p>
        <RenderIf condition={description->LogicUtils.isNonEmptyString}>
          <p className={`${body.sm.regular} text-nd_gray-500`}> {description->React.string} </p>
        </RenderIf>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~selectedRows,
  ~setSelectedRows,
  ~showVoidButton: bool=false,
  ~showPostButton: bool=false,
  ~refreshList,
  ~selectionFilters: option<JSON.t>=?,
  ~filterScopeCopy: option<ReconEngineTransactionsTypes.filterScopeCopy>=?,
  ~currentPageCount=0,
  ~isSinglePage=true,
) => {
  open ReconEngineTransactionsTypes
  open ReconEngineTransactionsUtils
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (actionType, setActionType) = React.useState((): actionType =>
    UnknownBulkTransactionActionType
  )
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (showSuccessModal, setShowSuccessModal) = React.useState(_ => false)
  let (showRecordLimitError, setShowRecordLimitError) = React.useState(_ => false)
  let (selectionMode, setSelectionMode) = React.useState((): bulkSelectionMode => ByIds)
  let showToast = ToastAdapter.useShowToast()
  let (bulkActionResponses, setBulkActionResponses) = React.useState(_ => [])

  let selectedCount = selectedRows->Array.length
  let isWholePageSelected = currentPageCount > 0 && selectedCount === currentPageCount
  let showSelectionModeChoice =
    selectionFilters->Option.isSome && isWholePageSelected && !isSinglePage
  let isFilterSelection = showSelectionModeChoice && selectionMode === ByFilters

  let modalConfig = getBulkActionModalConfig(
    ~action=actionType,
    ~count=selectedCount,
    ~hasSelectionChoice=showSelectionModeChoice,
  )

  let openModal = (action: actionType) => {
    setActionType(_ => action)
    setSelectionMode(_ => ByIds)
    setShowModal(_ => true)
  }

  let closeModal = () => {
    if !isLoading {
      setShowModal(_ => false)
      setActionType(_ => UnknownBulkTransactionActionType)
      setSelectionMode(_ => ByIds)
    }
  }

  let closeSuccessModal = () => {
    setShowSuccessModal(_ => false)
    setActionType(_ => UnknownBulkTransactionActionType)
    setSelectedRows(_ => [])
    refreshList()
  }

  let closeRecordLimitError = () => {
    setShowRecordLimitError(_ => false)
    setActionType(_ => UnknownBulkTransactionActionType)
  }

  let bulkActionFailureMessage = (action: actionType) => {
    switch action {
    | BulkTransactionPost => "Failed to post transactions. Please try again."
    | BulkTransactionVoid => "Failed to ignore transactions. Please try again."
    | UnknownBulkTransactionActionType => "Something went wrong. Please try again."
    }
  }

  let resolveSelection = () => {
    switch (isFilterSelection, selectionFilters) {
    | (true, Some(filters)) => SelectionByFilters(filters)
    | _ => SelectionByIds(selectedRows)
    }
  }

  let handleBulkAction = async (~bulkActionType: actionType, ~values) => {
    setShowModal(_ => false)
    setIsLoading(_ => true)
    let showFailure = () => {
      showToast(~toastType=ToastError, ~message=bulkActionFailureMessage(bulkActionType))
      setActionType(_ => UnknownBulkTransactionActionType)
    }
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#TRANSACTION_BULK_OPERATIONS,
      )
      let body = constructTransactionBulkRequestBody(
        ~bulkActionType,
        ~valuesDict,
        ~selection=resolveSelection(),
      )
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Post)
      let response =
        res->getArrayDataFromJson(ReconEngineExceptionsUtils.bulkActionResponseToObjMapper)
      setBulkActionResponses(_ => response)
      setShowSuccessModal(_ => true)
    } catch {
    | Exn.Error(err) =>
      if err->getErrorCodeFromExn === bulkActionRecordLimitErrorCode {
        setShowRecordLimitError(_ => true)
      } else {
        showFailure()
      }
    | _ => showFailure()
    }
    setIsLoading(_ => false)
  }

  let handleConfirm = async (values, _formApi) => {
    switch actionType {
    | BulkTransactionPost | BulkTransactionVoid =>
      await handleBulkAction(~bulkActionType=actionType, ~values)
    | UnknownBulkTransactionActionType => ()
    }
    Nullable.null
  }

  let validateForm = (values: JSON.t) => {
    let errors = Dict.make()
    let reason = values->getDictFromJsonObject->getString("reason", "")->String.trim
    if isFilterSelection && reason->isEmptyString {
      errors->Dict.set(
        "reason",
        "Add a remark before applying this to all matching transactions"->JSON.Encode.string,
      )
    }
    errors->JSON.Encode.object
  }

  let (successCount, failedCount, skippedCount, totalCount) = getTransactionBulkActionsCount(
    ~bulkActionResponses,
  )

  let bulkActionSuccessModalConfig = getBulkActionSuccessModalConfig(
    actionType,
    successCount,
    failedCount,
    skippedCount,
    totalCount,
  )

  <div>
    <div
      className="flex items-center gap-3 fixed left-1/2 -translate-x-1/2 bottom-4 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
      <p className={`${body.md.semibold} text-nd_gray-500`}>
        {`${selectedCount->Int.toString} Selected`->React.string}
      </p>
      <div className="border-r border-nd_gray-200 h-6" />
      <RenderIf condition={showPostButton}>
        <Button
          buttonState=Normal
          buttonSize=Medium
          buttonType=Primary
          text="Post Transaction"
          textWeight={`${body.md.semibold}`}
          customButtonStyle="!w-fit"
          onClick={_ => openModal(BulkTransactionPost)}
        />
        <div className="border-r border-nd_gray-200 h-6" />
      </RenderIf>
      <RenderIf condition={showVoidButton}>
        <Button
          buttonState=Normal
          buttonSize=Medium
          buttonType=Delete
          text="Ignore Transaction"
          textWeight={`${body.md.semibold}`}
          customButtonStyle="!w-fit"
          onClick={_ => openModal(BulkTransactionVoid)}
        />
        <div className="border-r border-nd_gray-200 h-6" />
      </RenderIf>
      <Button
        buttonType=Secondary
        buttonSize=Medium
        text="Deselect All"
        onClick={_ => setSelectedRows(_ => [])}
        customButtonStyle="!w-fit"
      />
    </div>
    <RenderIf condition={showModal}>
      <Modal
        setShowModal={_ => closeModal()}
        showModal
        borderBottom=false
        closeOnOutsideClick={!isLoading}
        modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
        childClass="mx-4 mb-6 h-full"
        modalHeadingDescription={modalConfig.bulkActionModal.modalDescription}
        modalHeadingClass="text-nd_gray-700"
        modalDescriptionClass="text-nd_gray-600 mt-1"
        modalHeading={modalConfig.bulkActionModal.modalHeading}>
        <Form
          formClass="flex flex-col gap-4"
          onSubmit={handleConfirm}
          validate={validateForm}
          initialValues={Dict.make()->JSON.Encode.object}>
          <RenderIf condition={showSelectionModeChoice}>
            <div className="flex flex-col gap-2">
              <p className={`${body.md.semibold} text-nd_gray-700`}> {"Apply to"->React.string} </p>
              <SelectionModeOption
                label={`${selectedCount->Int.toString} selected transaction${ReconEngineUtils.pluralText(
                    ~count=selectedCount,
                  )}`}
                isSelected={selectionMode === ByIds}
                onSelect={() => setSelectionMode(_ => ByIds)}
              />
              <SelectionModeOption
                label={filterScopeCopy->mapOptionOrDefault(
                  "All transactions, including those on other pages",
                  copy => copy.optionLabel,
                )}
                description={filterScopeCopy->mapOptionOrDefault("", copy =>
                  copy.optionDescription
                )}
                isSelected={selectionMode === ByFilters}
                onSelect={() => setSelectionMode(_ => ByFilters)}
              />
            </div>
          </RenderIf>
          {ReconEngineExceptionsUtils.bulkActionReasonMultiLineTextInputField(
            ~label={isFilterSelection ? "Add Remark" : "Add Remark (Optional)"},
          )}
          <div className="flex gap-3 justify-end">
            <Button
              buttonType=Secondary
              buttonSize=Medium
              text="Cancel"
              onClick={_ => closeModal()}
              customButtonStyle="!w-fit"
            />
            <FormRenderer.SubmitButton
              buttonType={modalConfig.bulkActionModal.modalConfirmButtonType}
              buttonSize=Medium
              text={modalConfig.bulkActionModal.modalConfirmButtonText}
              customSubmitButtonStyle="!w-fit"
            />
          </div>
        </Form>
      </Modal>
    </RenderIf>
    <RenderIf condition={isLoading}>
      <LoaderModal
        showModal=isLoading
        setShowModal={_ => setIsLoading(_ => false)}
        text={modalConfig.bulkActionModal.modalLoadingText}
      />
    </RenderIf>
    <RenderIf condition={showRecordLimitError}>
      <Modal
        setShowModal={_ => closeRecordLimitError()}
        showModal=showRecordLimitError
        closeOnOutsideClick=true
        modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-nd_gray-800"
        childClass="mx-4 mb-6 h-full"
        modalHeading=""
        modalHeadingClass="text-nd_gray-700"
        modalDescriptionClass=""
        borderBottom=false>
        <div className="flex flex-col items-center gap-6">
          <Icon
            name={bulkActionRecordLimitModalConfig.bulkActionIcon->mapOptionOrDefault("", icon =>
              icon.bulkActionIconName
            )}
            size=92
            className={bulkActionRecordLimitModalConfig.bulkActionIcon->mapOptionOrDefault(
              "",
              icon => icon.bulkActionIconClass,
            )}
          />
          <div className="flex flex-col items-center gap-1.5">
            <h3 className={`${heading.sm.semibold} text-nd_gray-700`}>
              {bulkActionRecordLimitModalConfig.bulkActionModal.modalHeading->React.string}
            </h3>
            <p className={`${body.md.regular} text-nd_gray-600 text-center`}>
              {bulkActionRecordLimitModalConfig.bulkActionModal.modalDescription->React.string}
            </p>
          </div>
        </div>
        <div className="flex gap-3 justify-end mt-6">
          <Button
            buttonType=Primary
            buttonSize=Medium
            text={bulkActionRecordLimitModalConfig.bulkActionModal.modalConfirmButtonText}
            onClick={_ => closeRecordLimitError()}
            customButtonStyle="!w-fit"
          />
        </div>
      </Modal>
    </RenderIf>
    <RenderIf condition={showSuccessModal}>
      <Modal
        setShowModal={_ => closeSuccessModal()}
        showModal=showSuccessModal
        closeOnOutsideClick=false
        modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
        childClass="mx-4 mb-4 h-full"
        modalHeading=""
        modalHeadingClass="text-nd_gray-700"
        modalDescriptionClass=""
        borderBottom=false>
        <div className="flex flex-col items-center gap-6">
          <Icon
            name={bulkActionSuccessModalConfig.bulkActionIcon->mapOptionOrDefault("", icon =>
              icon.bulkActionIconName
            )}
            size=92
            className={bulkActionSuccessModalConfig.bulkActionIcon->mapOptionOrDefault("", icon =>
              icon.bulkActionIconClass
            )}
          />
          <div className="flex flex-col items-center gap-1.5">
            <h3 className={`${heading.sm.semibold} text-nd_gray-700`}>
              {bulkActionSuccessModalConfig.bulkActionModal.modalHeading->React.string}
            </h3>
            <p className={`${body.md.regular} text-nd_gray-600 text-center`}>
              {bulkActionSuccessModalConfig.bulkActionModal.modalDescription->React.string}
            </p>
          </div>
        </div>
        <div className="max-h-96 overflow-y-auto my-6">
          <LoadedTable
            showAutoScroll=true
            title="Bulk Action Summary"
            hideTitle=true
            actualData={bulkActionResponses->Array.map(Nullable.make)}
            entity={ReconEngineBulkActionTableEntity.bulkActionTransactionSummaryLoadedTableEntity()}
            resultsPerPage={bulkActionResponses->Array.length}
            showSerialNumber=false
            totalResults={bulkActionResponses->Array.length}
            offset={0}
            showPagination=false
            setOffset={_ => ()}
            currentFetchCount={bulkActionResponses->Array.length}
            onEntityClick={_ => ()}
          />
        </div>
        <div className="flex gap-3 justify-end p-4">
          <Button
            buttonType=Secondary
            buttonSize=Medium
            text="Close"
            onClick={_ => closeSuccessModal()}
            customButtonStyle="!w-fit"
          />
          <Button
            buttonType={bulkActionSuccessModalConfig.bulkActionModal.modalConfirmButtonType}
            buttonSize=Medium
            leftIcon={CustomIcon(<Icon name="nd-download-down" size=16 className="text-white" />)}
            text={bulkActionSuccessModalConfig.bulkActionModal.modalConfirmButtonText}
            onClick={_ => downloadBulkActionReport(bulkActionResponses, ~action=actionType)}
            customButtonStyle="!w-fit"
          />
        </div>
      </Modal>
    </RenderIf>
  </div>
}
