open OffersTypes
open OffersUtils

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
