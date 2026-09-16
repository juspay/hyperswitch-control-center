open Typography
open LogicUtils
open OffersUtils

module SectionCard = {
  @react.component
  let make = (~title, ~rightElement=React.null, ~children) =>
    <div className="border border-nd_gray-150 rounded-xl bg-nd_gray-0 flex flex-col">
      <div className="flex items-center justify-between px-5 py-4 border-b border-nd_gray-150">
        <p className={`${body.lg.semibold} text-nd_gray-700`}> {title->React.string} </p>
        rightElement
      </div>
      <div className="px-5 py-4"> children </div>
    </div>
}

module DisplayKeyValueParams = {
  @react.component
  let make = (~heading: Table.header, ~value: Table.cell) => {
    let description = heading.description->Option.getOr("")

    <AddDataAttributes attributes=[("data-label", heading.title)]>
      <div className="flex flex-col gap-1 py-2">
        <div className="flex flex-row">
          <div className={`${body.md.medium} text-nd_gray-500`}>
            {heading.title->React.string}
          </div>
          <RenderIf condition={description->LogicUtils.isNonEmptyString}>
            <div className={`${body.sm.regular} text-nd_gray-500 mx-2 -mt-1`}>
              <ToolTip description toolTipPosition={ToolTip.Top} />
            </div>
          </RenderIf>
        </div>
        <div className={`${body.md.semibold} text-left text-nd_gray-600 break-words`}>
          <Table.TableCell
            cell=value
            textAlign=Table.Left
            fontBold=true
            customMoneyStyle="!font-normal !text-sm"
            labelMargin="!py-0"
          />
        </div>
      </div>
    </AddDataAttributes>
  }
}

module DetailsGrid = {
  @react.component
  let make = (~data, ~getHeading, ~getCell, ~detailsFields, ~widthClass="md:w-1/4 w-full") =>
    <FormRenderer.DesktopRow>
      <div className="flex flex-wrap justify-start lg:flex-row flex-col">
        {detailsFields
        ->Array.mapWithIndex((colType, index) =>
          <div className=widthClass key={index->Int.toString}>
            <DisplayKeyValueParams heading={getHeading(colType)} value={getCell(data, colType)} />
          </div>
        )
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
}

module DetailsTable = {
  @react.component
  let make = (~title, ~columns, ~getHeading, ~getCell, ~items, ~emptyMessage) =>
    items->isEmptyArray
      ? <div className={`${body.md.medium} text-nd_gray-400`}> {emptyMessage->React.string} </div>
      : <Table
          title
          heading={columns->Array.map(getHeading)}
          rows={items->Array.map(item => columns->Array.map(colType => getCell(item, colType)))}
          showScrollBar=true
        />
}

module Chips = {
  @react.component
  let make = (~values: array<string>, ~emptyMessage=emptyValuePlaceholder) =>
    values->isEmptyArray
      ? <div className={`${body.md.medium} text-nd_gray-400`}> {emptyMessage->React.string} </div>
      : <div className="flex flex-wrap gap-2">
          {values
          ->Array.mapWithIndex((value, index) =>
            <TagBinding
              key={index->Int.toString}
              text=value
              color=Neutral
              variant=Subtle
              shape=Squarical
              size=Xs
            />
          )
          ->React.array}
        </div>
}
