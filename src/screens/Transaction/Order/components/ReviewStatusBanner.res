open APIUtils
open LogicUtils
open PaymentInterfaceTypes
open OrderTypes
open OrderUIUtils
open Typography

@react.component
let make = (~order: order, ~refetch) => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let canUpdateStatus = userHasAccess(~groupAccess=OperationsManage) === CommonAuthTypes.Access
  let getURL = useGetURL()
  let getDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (eligibleStatuses, setEligibleStatuses) = React.useState((_): array<manualUpdateStatus> => [])
  let (selectedStatus, setSelectedStatus) = React.useState((_): option<manualUpdateStatus> => Some(
    Succeeded,
  ))
  let isConflicted = order.status->HSwitchOrderUtils.statusVariantMapper === Conflicted

  let getEligibleStatuses = async () => {
    try {
      setEligibleStatuses(_ => [])
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(MANUAL_STATUS_UPDATE),
        ~methodType=Get,
        ~id=Some(order.payment_id),
      )
      let response = await getDetails(url)
      setEligibleStatuses(_ => response->manualUpdateEligibleStatusesFromResponse)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if isConflicted && showModal {
      getEligibleStatuses()->ignore
    }
    None
  }, (showModal, order.payment_id, order.status))

  let updatePaymentStatus = async (intentStatus: manualUpdateStatus) => {
    try {
      let url = getURL(
        ~entityName=V1(MANUAL_STATUS_UPDATE),
        ~methodType=Post,
        ~id=Some(order.payment_id),
      )
      let intentLabel = (intentStatus :> string)->snakeToTitle
      let body =
        [("intent_status", (intentStatus :> string)->JSON.Encode.string)]->getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      showToast(~message=`Payment marked as ${intentLabel}`, ~toastType=ToastState.ToastSuccess)
      refetch()->ignore
    } catch {
    | _ => showToast(~message="Failed to update payment status", ~toastType=ToastState.ToastError)
    }
  }

  let openConfirmationPopUp = (intentStatus: manualUpdateStatus) => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Confirm Status Update?",
      description: `You are about to mark this payment as ${(intentStatus :> string)->snakeToTitle}. This action is final and cannot be undone. Please confirm to proceed.`->React.string,
      handleConfirm: {
        text: "Confirm",
        onClick: _ => updatePaymentStatus(intentStatus)->ignore,
      },
      handleCancel: {text: "Cancel"},
    })
  }

  let statuses: array<manualUpdateStatus> = isConflicted ? eligibleStatuses : [Succeeded, Failed]
  let statusOptions: array<SelectBox.dropdownOption> = statuses->Array.map(status => {
    SelectBox.label: (status :> string)->snakeToTitle,
    value: (status :> string),
  })
  let statusInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "intent_status",
    onBlur: _ => (),
    onFocus: _ => (),
    onChange: event =>
      setSelectedStatus(_ => event->Identity.formReactEventToString->manualUpdateStatusFromString),
    value: selectedStatus->mapOptionOrDefault("", status => (status :> string))->JSON.Encode.string,
    checked: false,
  }

  let onUpdateClick = _ => {
    switch selectedStatus {
    | Some(status) =>
      setShowModal(_ => false)
      openConfirmationPopUp(status)
    | None => ()
    }
  }

  let bannerActions: option<AlertV2Binding.alertV2Actions> = canUpdateStatus
    ? Some({
        position: Bottom,
        primaryAction: {
          text: "Update Payment Status",
          onClick: _ => {
            setSelectedStatus(_ => isConflicted ? None : Some(Succeeded))
            setScreenState(_ =>
              isConflicted ? PageLoaderWrapper.Loading : PageLoaderWrapper.Success
            )
            setShowModal(_ => true)
          },
        },
      })
    : None

  <>
    <AlertV2Binding
      alertType=Warning
      heading="This payment needs manual attention"
      description={isConflicted
        ? "Hyperswitch received a response from the connector that conflicts with this payment's expected details. Review it and update the payment status."
        : "Hyperswitch received an anomalous response from the connector for this payment. Review it and update the status to Succeeded or Failed."}
      actions=?bannerActions
    />
    <Modal
      showModal
      setShowModal
      modalHeading="Update Payment Status"
      modalHeadingDescription="Manually set the status for this payment."
      modalClass="w-full md:w-4/12 mx-auto mt-40"
      childClass="p-0"
      bgClass="bg-nd_gray-0">
      <PageLoaderWrapper
        screenState
        customLoader={<div className="flex justify-center p-6">
          <Icon name="spinner" size=20 className="animate-spin" />
        </div>}
        customUI={<div className="flex flex-col items-center gap-4 p-6">
          <p className={`${body.md.medium} text-nd_gray-600`}>
            {"Unable to load available statuses."->React.string}
          </p>
          <Button text="Retry" buttonType=Secondary onClick={_ => getEligibleStatuses()->ignore} />
        </div>}>
        <div className="flex flex-col gap-6 p-2 m-2">
          <RenderIf condition={statuses->isEmptyArray}>
            <p className={`${body.md.medium} text-nd_gray-600`}>
              {"No status updates are available for this payment."->React.string}
            </p>
          </RenderIf>
          <RenderIf condition={statuses->isNonEmptyArray}>
            <div className="flex flex-col gap-2">
              <p className={`${body.md.medium} text-nd_gray-600`}> {"New Status"->React.string} </p>
              {InputFields.selectInput(
                ~options=statusOptions,
                ~buttonText="Select status",
                ~searchable=false,
              )(~input=statusInput, ~placeholder="Select status")}
            </div>
          </RenderIf>
          <div className="flex justify-end gap-3 mt-2">
            <Button
              text="Cancel"
              buttonType=Secondary
              onClick={_ => {
                setShowModal(_ => false)
                setSelectedStatus(_ => None)
              }}
            />
            <RenderIf condition={statuses->isNonEmptyArray}>
              <Button
                text="Update Status"
                buttonType=Primary
                buttonState={selectedStatus->Option.isSome ? Normal : Disabled}
                onClick=onUpdateClick
              />
            </RenderIf>
          </div>
        </div>
      </PageLoaderWrapper>
    </Modal>
  </>
}
