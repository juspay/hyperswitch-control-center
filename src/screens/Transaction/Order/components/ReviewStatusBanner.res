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
  let (selectedStatus, setSelectedStatus) = React.useState(_ => Succeeded)

  let updatePaymentStatus = async (intentStatus: status) => {
    try {
      let url = getURL(
        ~entityName=V1(MANUAL_STATUS_UPDATE),
        ~methodType=Post,
        ~id=Some(order.payment_id),
      )
      let intentLabel = (intentStatus :> string)
      let body =
        [
          ("intent_status", intentLabel->String.toLowerCase->JSON.Encode.string),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post)
      showToast(~message=`Payment marked as ${intentLabel}`, ~toastType=ToastState.ToastSuccess)
      refetch()->ignore
    } catch {
    | _ => showToast(~message="Failed to update payment status", ~toastType=ToastState.ToastError)
    }
  }

  let openConfirmationPopUp = (intentStatus: status) => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Confirm Status Update?",
      description: `You are about to mark this payment as ${(intentStatus :> string)}. This action is final and cannot be undone. Please confirm to proceed.`->React.string,
      handleConfirm: {
        text: "Confirm",
        onClick: _ => updatePaymentStatus(intentStatus)->ignore,
      },
      handleCancel: {text: "Cancel"},
    })
  }

  let statusOptions: array<selectMenuGroupType> = [Succeeded, Failed]->Array.map(item => {
    let label = (item :> string)
    {
      items: [{label, value: label->String.toLowerCase}],
    }
  })

  let onUpdateClick = _ => {
    setShowModal(_ => false)
    openConfirmationPopUp(selectedStatus)
  }

  <>
    <AlertV2Binding
      alertType=Warning
      heading="This payment needs manual attention"
      description="Hyperswitch received an anomalous response from the connector for this payment. Review it and update the status to Succeeded or Failed."
      actions={{
        position: Bottom,
        primaryAction: {
          text: "Update Payment Status",
          onClick: _ => {
            setSelectedStatus(_ => Succeeded)
            setShowModal(_ => true)
          },
        },
      }}
    />
    <Modal
      showModal
      setShowModal
      modalHeading="Update Payment Status"
      modalHeadingDescription="Manually set the status for this payment."
      modalClass="w-full md:w-4/12 mx-auto mt-40"
      childClass="p-0"
      bgClass="bg-nd_gray-0">
      <div className="flex flex-col gap-6 p-2 m-2">
        <SingleSelectBinding
          selected={(selectedStatus :> string)->String.toLowerCase}
          onSelect={value => setSelectedStatus(_ => value->statusVariantMapper)}
          items=statusOptions
          label="New Status"
          placeholder="Select status"
        />
        <div className="flex justify-end gap-3 mt-2">
          <Button
            text="Cancel"
            buttonType=Secondary
            onClick={_ => {
              setShowModal(_ => false)
              setSelectedStatus(_ => Succeeded)
            }}
          />
          <Button text="Update Status" buttonType=Primary onClick=onUpdateClick />
        </div>
      </div>
    </Modal>
  </>
}
