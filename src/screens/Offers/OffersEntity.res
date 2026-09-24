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
    ~getShowLink={offer => GlobalVars.appendDashboardPath(~url=`/offers/${offer.offerId}`)},
  )
}

let getOfferDetailsHeading = (colType: offerDetailsColType) =>
  switch colType {
  | Code => Table.makeHeaderInfo(~key="offer_code", ~title="Offer Code")
  | Id => Table.makeHeaderInfo(~key="offer_id", ~title="Offer ID")
  | OfferTitle => Table.makeHeaderInfo(~key="title", ~title="Offer Title")
  | DisplayTitle => Table.makeHeaderInfo(~key="display_title", ~title="Offer Display Title")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Offer Description")
  | Language => Table.makeHeaderInfo(~key="language", ~title="Language")
  | Logo => Table.makeHeaderInfo(~key="sponsored_by", ~title="Logo for Offer")
  | ValidFrom => Table.makeHeaderInfo(~key="start_time", ~title="Offer Start Date")
  | ValidTill => Table.makeHeaderInfo(~key="end_time", ~title="Offer End Date")
  | OfferType => Table.makeHeaderInfo(~key="offer_type", ~title="Offer Type")
  | OfferAmount => Table.makeHeaderInfo(~key="offer_amount", ~title="Offer Amount")
  | MaxDiscountAmount => Table.makeHeaderInfo(~key="max_amount", ~title="Maximum Amount")
  | MinTxnAmount =>
    Table.makeHeaderInfo(~key="min_order_amount", ~title="Minimum Transaction Amount")
  | MaxTxnAmount =>
    Table.makeHeaderInfo(~key="max_order_amount", ~title="Maximum Transaction Amount")
  | CampaignAmount => Table.makeHeaderInfo(~key="campaign_amount", ~title="Offer Campaign Amount")
  | CampaignCount => Table.makeHeaderInfo(~key="campaign_count", ~title="Offer Campaign Count")
  }

let getOfferDetailsCell = (detail: offerDetail, colType: offerDetailsColType): Table.cell =>
  switch colType {
  | Code => DisplayCopyCell(detail.offer.offerCode)
  | Id => DisplayCopyCell(detail.offer.offerId)
  | OfferTitle => Text(detail.offer.offerDescription.title->displayOrPlaceholder)
  | DisplayTitle => Text(detail.offer.offerDescription.displayTitle->displayOrPlaceholder)
  | Description => Text(detail.offer.offerDescription.description->displayOrPlaceholder)
  | Language => Text(detail.language->languageToDisplayName->displayOrPlaceholder)
  | Logo =>
    Text(
      detail.offer.offerDescription.sponsoredBy
      ->OffersSponsors.sponsorToDisplayName
      ->displayOrPlaceholder,
    )
  | ValidFrom => Date(detail.offer.startTime)
  | ValidTill => Date(detail.offer.endTime)
  | OfferType => Text("Discount")
  | OfferAmount => Text(detail->offerAmountLabel)
  | MaxDiscountAmount => Text(detail->maxDiscountAmountLabel)
  | MinTxnAmount => Text(detail->currencyRangeLabel(~getAmount=currency => currency.minOrderAmount))
  | MaxTxnAmount => Text(detail->currencyRangeLabel(~getAmount=currency => currency.maxOrderAmount))
  | CampaignAmount => Text(detail->optionalAmountLabel(detail.campaignAmount))
  | CampaignCount => Text(detail.campaignCount->optionalCountLabel)
  }

let getPaymentDetailsHeading = (colType: paymentDetailsColType) =>
  switch colType {
  | AmountPerCard => Table.makeHeaderInfo(~key="amount_per_card", ~title="Amount Per Unique Card")
  | CountPerCard =>
    Table.makeHeaderInfo(~key="count_per_card", ~title="Offer Count Per Unique Card")
  | BinList => Table.makeHeaderInfo(~key="bin_list", ~title="Uploaded BIN List")
  | BinListType => Table.makeHeaderInfo(~key="bin_list_type", ~title="BIN List Type")
  }

let getPaymentDetailsCell = (detail: offerDetail, colType: paymentDetailsColType): Table.cell =>
  switch colType {
  | AmountPerCard => Text(detail->optionalAmountLabel(detail.amountPerCard))
  | CountPerCard => Text(detail.countPerCard->optionalCountLabel)
  | BinList => Text(detail.binListMode->Option.isSome ? "Uploaded" : emptyValuePlaceholder)
  | BinListType =>
    Text(
      detail.binListMode->LogicUtils.mapOptionOrDefault(
        emptyValuePlaceholder,
        binListModeToDisplayName,
      ),
    )
  }

let offerDetailsFields = [
  Code,
  Id,
  OfferTitle,
  DisplayTitle,
  Description,
  Language,
  Logo,
  ValidFrom,
  ValidTill,
  OfferType,
  OfferAmount,
  MaxDiscountAmount,
  MinTxnAmount,
  MaxTxnAmount,
  CampaignAmount,
  CampaignCount,
]

let paymentDetailsFields = [AmountPerCard, CountPerCard, BinList, BinListType]
