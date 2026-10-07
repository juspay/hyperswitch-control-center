open OffersTypes
open OffersUtils
open OffersHooks

@react.component
let make = (~offer: offer, ~onStatusToggled, ~onDeleted) => {
  let updateOfferStatus = useUpdateOfferStatus()
  let deleteOffer = useDeleteOffer()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (isUpdating, setIsUpdating) = React.useState(_ => false)

  let nextStatus = offer->nextStatusOnToggle

  let toggleStatus = async () => {
    setIsUpdating(_ => true)
    try {
      let _ = await updateOfferStatus(~offerId=offer.offerId, ~status=nextStatus)
      showToast(
        ~message=`Offer ${nextStatus === Active ? "activated" : "paused"}`,
        ~toastType=ToastSuccess,
      )
      onStatusToggled()
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Unable to update the offer status")
      showToast(~message=err, ~toastType=ToastError)
    }
    setIsUpdating(_ => false)
  }

  let deleteOfferAsync = async () => {
    setIsUpdating(_ => true)
    try {
      let _ = await deleteOffer(offer.offerId)
      showToast(~message="Offer deleted", ~toastType=ToastSuccess)
      onDeleted()
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Unable to delete the offer")
      showToast(~message=err, ~toastType=ToastError)
    }
    setIsUpdating(_ => false)
  }

  let confirmDelete = _ =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Delete offer",
      description: `Are you sure you want to delete ${offer.offerCode}? This cannot be undone.`->React.string,
      handleConfirm: {
        text: "Yes, delete it",
        onClick: {_ => deleteOfferAsync()->ignore},
      },
      handleCancel: {text: "No, keep it"},
    })

  let disabledClass = isUpdating ? "opacity-50 pointer-events-none" : ""

  <div
    className="flex items-center gap-3" onClick={event => event->ReactEvent.Mouse.stopPropagation}>
    <RenderIf condition={offer->canPauseOrActivate}>
      <div
        className={`text-nd_gray-500 hover:text-nd_gray-700 cursor-pointer ${disabledClass}`}
        onClick={_ => toggleStatus()->ignore}>
        <Icon name={nextStatus === Active ? "play" : "pause"} size=16 />
      </div>
    </RenderIf>
    <RenderIf condition={offer->canDelete}>
      <div
        className={`text-nd_gray-300 hover:text-nd_red-500 cursor-pointer ${disabledClass}`}
        onClick=confirmDelete>
        <Icon name="trash-outline" size=18 />
      </div>
    </RenderIf>
  </div>
}
