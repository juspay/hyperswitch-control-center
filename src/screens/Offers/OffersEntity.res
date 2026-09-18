open OffersTypes
open OffersUtils
open OffersHooks

module OfferRowActions = {
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
      className="flex items-center gap-3"
      onClick={event => event->ReactEvent.Mouse.stopPropagation}>
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
}

let defaultColumns: array<colType> = [
  OfferCode,
  Title,
  Status,
  Benefit,
  StartEndTime,
  CreatedAt,
  Actions,
]

let allColumns: array<colType> = [OfferId, ...defaultColumns]

let getHeading = (colType: colType) =>
  switch colType {
  | OfferId => Table.makeHeaderInfo(~key="offer_id", ~title="Offer ID")
  | OfferCode => Table.makeHeaderInfo(~key="offer_code", ~title="Offer Code")
  | Title => Table.makeHeaderInfo(~key="offer_description.title", ~title="Offer Title")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Benefit => Table.makeHeaderInfo(~key="benefit", ~title="Benefit")
  | StartEndTime => Table.makeHeaderInfo(~key="start_time", ~title="Start and End Time")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions")
  }

let getCell = (~onStatusToggled, ~onDeleted, ~hasManageAccess) => (
  offer: offer,
  colType: colType,
): Table.cell =>
  switch colType {
  | OfferId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(offer.offerId)}
        copyValue={Some(offer.offerId)}
        showTooltip=true
      />,
      "",
    )
  | OfferCode =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(offer.offerCode)}
        copyValue={Some(offer.offerCode)}
        showTooltip=true
      />,
      "",
    )
  | Title => EllipsisText(offer->offerTitle->displayOrPlaceholder, "w-48")
  | Status =>
    Label({
      title: offer.status->statusToDisplayName->String.toUpperCase,
      color: offer.status->statusToLabelColor,
    })
  | Benefit => Text(offer->benefitLabel)
  | StartEndTime =>
    CustomCell(
      {
        open TableUtils
        <div className="flex items-center gap-2">
          <DateCell timestamp=offer.startTime textAlign={Left} />
          <Icon name="nd-arrow-right" size=12 className="text-nd_gray-400 shrink-0" />
          <DateCell timestamp=offer.endTime textAlign={Left} />
        </div>
      },
      "",
    )
  | CreatedAt => Date(offer.createdAt)
  | Actions =>
    CustomCell(
      <RenderIf condition=hasManageAccess>
        <OfferRowActions offer onStatusToggled onDeleted />
      </RenderIf>,
      "",
    )
  }

let offersEntity = (~onStatusToggled, ~onDeleted, ~hasManageAccess) => {
  let getPermittedColumns = columns =>
    hasManageAccess ? columns : columns->Array.filter(colType => colType !== Actions)

  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns=defaultColumns->getPermittedColumns,
    ~allColumns=allColumns->getPermittedColumns,
    ~getHeading,
    ~getCell=getCell(~onStatusToggled, ~onDeleted, ~hasManageAccess),
    ~dataKey="",
  )
}
