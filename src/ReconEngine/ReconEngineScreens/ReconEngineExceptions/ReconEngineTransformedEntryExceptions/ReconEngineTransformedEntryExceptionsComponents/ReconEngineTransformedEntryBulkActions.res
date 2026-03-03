open Typography

@react.component
let make = (~selectedRows, ~setSelectedRows) => {
  open ReconEngineTransformedEntryExceptionsTypes
  open ReconEngineTransformedEntryExceptionsUtils
  open APIUtils
  open ReconEngineTypes
  open LogicUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (actionType, setActionType) = React.useState((): actionType =>
    UnknownBulkTransformedEntryActionType
  )
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (showSuccessModal, setShowSuccessModal) = React.useState(_ => false)
  let modalConfig = getBulkActionModalConfig(~action=actionType, ~count=selectedRows->Array.length)
  let showToast = ToastState.useShowToast()
  let (bulkActionResponses, setBulkActionResponses) = React.useState(_ => [])

  let openModal = (action: actionType) => {
    setActionType(_ => action)
    setShowModal(_ => true)
  }

  let closeModal = () => {
    if !isLoading {
      setShowModal(_ => false)
      setActionType(_ => UnknownBulkTransformedEntryActionType)
    }
  }

  let closeSuccessModal = () => {
    setShowSuccessModal(_ => false)
    setActionType(_ => UnknownBulkTransformedEntryActionType)
    setSelectedRows(_ => [])
  }

  let handleVoid = async values => {
    setShowModal(_ => false)
    setIsLoading(_ => true)
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#STAGING_ENTRY_BULK_OPERATIONS,
      )
      let body = {
        "action": {
          "void": {
            "reason": valuesDict->getString("reason", ""),
          },
        },
        "selection": {
          "selection_type": "ids",
          "ids": selectedRows->Array.map((entry: processingEntryType) => entry.id),
        },
      }
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Post)
      let response = res->getArrayDataFromJson(bulkActionResponseToObjMapper)
      setBulkActionResponses(_ => response)
      setIsLoading(_ => false)
      setShowSuccessModal(_ => true)
    } catch {
    | _ => {
        showToast(
          ~toastType=ToastError,
          ~message="Failed to ignore staging entries. Please try again.",
        )
        setIsLoading(_ => false)
        setActionType(_ => UnknownBulkTransformedEntryActionType)
      }
    }
  }

  let handleConfirm = async (values, _formApi) => {
    switch actionType {
    | BulkTransformedEntryVoid => await handleVoid(values)
    | UnknownBulkTransformedEntryActionType => ()
    }
    Nullable.null
  }

  let (successCount, failedCount, skippedCount, totalCount) = bulkActionResponses->Array.reduce(
    (0, 0, 0, 0),
    (acc, response) => {
      let (successCount, failedCount, skippedCount, totalCount) = acc
      switch response.bulk_action_status {
      | BulkActionSuccess => (successCount + 1, failedCount, skippedCount, totalCount + 1)
      | BulkActionFailed => (successCount, failedCount + 1, skippedCount, totalCount + 1)
      | BulkActionSkipped => (successCount, failedCount, skippedCount + 1, totalCount + 1)
      | UnknownBulkActionStatus => (successCount, failedCount, skippedCount, totalCount + 1)
      }
    },
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
      className="flex flex-row items-center gap-3 absolute right-1/2 bottom-8 border border-nd_gray-200 bg-nd_gray-0 shadow-lg rounded-2xl p-3">
      <p className={`${body.md.semibold} text-nd_gray-500`}>
        {`${selectedRows->Array.length->Int.toString} Selected`->React.string}
      </p>
      <div className="border-r border-nd_gray-200 h-6" />
      <Button
        buttonState=Normal
        buttonSize=Medium
        buttonType=Delete
        text="Ignore Entry"
        textWeight={`${body.md.semibold}`}
        customButtonStyle="!w-fit"
        onClick={_ => openModal(BulkTransformedEntryVoid)}
      />
      <div className="border-r border-nd_gray-200 h-6" />
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
          initialValues={Dict.make()->JSON.Encode.object}>
          {bulkActionReasonMultiLineTextInputField(~label="Add Remark (Optional)")}
          <div className="flex flex-row gap-3 justify-end">
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
              customSumbitButtonStyle="!w-fit"
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
            name={bulkActionSuccessModalConfig.bulkActionIcon->Option.mapOr("", icon =>
              icon.bulkActionIconName
            )}
            size=92
            className={bulkActionSuccessModalConfig.bulkActionIcon->Option.mapOr("", icon =>
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
            entity={ReconEngineBulkActionTableEntity.bulkActionTransformedEntrySummaryLoadedTableEntity()}
            resultsPerPage={bulkActionResponses->Array.length}
            showSerialNumber=false
            totalResults={bulkActionResponses->Array.length}
            offset={0}
            showPagination=false
            setOffset={_ => ()}
            currrentFetchCount={bulkActionResponses->Array.length}
            onEntityClick={_ => ()}
          />
        </div>
        <div className="flex flex-row gap-3 justify-end p-4">
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
            onClick={_ => downloadBulkActionReport(bulkActionResponses)}
            customButtonStyle="!w-fit"
          />
        </div>
      </Modal>
    </RenderIf>
  </div>
}
