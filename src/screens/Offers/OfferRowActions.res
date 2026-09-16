open OffersTypes
open OffersUtils

@react.component
let make = (~offer: offer, ~onStatusToggled, ~onDiscarded) => {
  let updateOfferStatus = OffersHooks.useUpdateOfferStatus()
  let deleteOffer = OffersHooks.useDeleteOffer()
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

  let discardOffer = async () => {
    setIsUpdating(_ => true)
    try {
      let _ = await deleteOffer(offer.offerId)
      showToast(~message="Offer discarded", ~toastType=ToastSuccess)
      onDiscarded()
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Unable to discard the offer")
      showToast(~message=err, ~toastType=ToastError)
    }
    setIsUpdating(_ => false)
  }

  let confirmDiscard = _ =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Discard offer",
      description: `Are you sure you want to discard ${offer.offerCode}? This cannot be undone.`->React.string,
      handleConfirm: {
        text: "Yes, discard it",
        onClick: {_ => discardOffer()->ignore},
      },
      handleCancel: {text: "No, keep it", onClick: _ => ()},
    })

  <div
    className="flex items-center gap-2" onClick={event => event->ReactEvent.Mouse.stopPropagation}>
    <RenderIf condition={offer->canPauseOrActivate}>
      <Button
        text={nextStatus === Active ? "Activate" : "Pause"}
        buttonType={SecondaryFilled}
        buttonSize={Small}
        buttonState={isUpdating ? Loading : Normal}
        onClick={_ => toggleStatus()->ignore}
      />
    </RenderIf>
    <RenderIf condition={offer->canDiscard}>
      <Button
        text="Discard"
        buttonType={SecondaryFilled}
        buttonSize={Small}
        buttonState={isUpdating ? Loading : Normal}
        onClick=confirmDiscard
      />
    </RenderIf>
  </div>
}
