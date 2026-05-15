open APIUtils
open PaymentInterfaceTypes
open HSwitchOrderUtils

@react.component
let make = (~order: order, ~refetch) => {
  open MultiSelectBindings

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (selectedStatus, setSelectedStatus) = React.useState(_ => "")

  let updatePaymentStatus = async intentStatus => {
    try {
      let url = getURL(
        ~entityName=V1(MANUAL_STATUS_UPDATE),
        ~methodType=Post,
        ~id=Some(order.payment_id),
      )
      let body =
        [
          ("intent_status", intentStatus->String.toLowerCase->JSON.Encode.string),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      showToast(~message=`Payment marked as ${intentStatus}`, ~toastType=ToastState.ToastSuccess)
      refetch()->ignore
    } catch {
    | _ => showToast(~message="Failed to update payment status", ~toastType=ToastState.ToastError)
    }
  }

  let openConfirmationPopUp = intentStatus => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Confirm Status Update?",
      description: `You are about to mark this payment as ${intentStatus}. This action is final and cannot be undone. Please confirm to proceed.`->React.string,
      handleConfirm: {
        text: "Confirm",
        onClick: _ => updatePaymentStatus(intentStatus)->ignore,
      },
      handleCancel: {text: "Cancel"},
    })
  }

  let statusOptions: array<selectMenuGroupType> = [Succeeded, Failed]->Array.map(item => {
    let status = item->HSwitchOrderUtils.statusToString
    {
      items: [{label: status, value: status->String.toLowerCase}],
    }
  })

  let onUpdateClick = _ => {
    let statusToConfirm = selectedStatus
    setShowModal(_ => false)
    setSelectedStatus(_ => "")
    openConfirmationPopUp(statusToConfirm)
  }

  <>
    <AlertV2Binding
      alertType=AlertV2Binding.Warning
      heading="This payment needs manual attention"
      description="Hyperswitch received an anomalous response from the connector for this payment. Review it and update the status to Succeeded or Failed."
      actions={{
        position: AlertV2Binding.Bottom,
        primaryAction: {
          text: "Update Payment Status",
          onClick: _ => {
            setSelectedStatus(_ => "")
            setShowModal(_ => true)
          },
        },
      }}
    />
    <Modal
      showModal
      setShowModal
      modalHeading="Update Payment Status"
      modalClass="w-full md:w-4/12 mx-auto mt-40"
      childClass="p-0"
      bgClass="bg-white dark:bg-jp-gray-darkgray_background">
      <div className="flex flex-col gap-6 p-2 m-2">
        <p className="text-jp-gray-700 dark:text-jp-gray-300 text-fs-14">
          {"Manually set the status for this payment. You will be asked to confirm before the change is applied."->React.string}
        </p>
        <SingleSelectBinding
          selected=selectedStatus
          onSelect={value => setSelectedStatus(_ => value)}
          items=statusOptions
          label="New Status"
          placeholder="Select status"
        />
        <div className="flex justify-end gap-3 mt-2">
          <Button
            text="Cancel"
            buttonType=Button.Secondary
            onClick={_ => {
              setShowModal(_ => false)
              setSelectedStatus(_ => "")
            }}
          />
          <Button
            text="Update Status"
            buttonType=Button.Primary
            buttonState={selectedStatus->LogicUtils.isEmptyString ? Button.Disabled : Button.Normal}
            onClick=onUpdateClick
          />
        </div>
      </div>
    </Modal>
  </>
}
