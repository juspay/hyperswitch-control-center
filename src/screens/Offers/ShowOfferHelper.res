open Typography

module DetailField = {
  @react.component
  let make = (~heading: Table.header, ~value: Table.cell) => {
    <AddDataAttributes attributes=[("data-label", heading.title)]>
      <div className="flex flex-col gap-2 py-4">
        <div className={`text-nd_gray-500 ${body.md.medium}`}> {heading.title->React.string} </div>
        <div className={`text-left text-nd_gray-600 ${body.md.semibold}`}>
          <Table.TableCell cell=value textAlign=Table.Left fontBold=true labelMargin="!py-0" />
        </div>
      </div>
    </AddDataAttributes>
  }
}

module OfferInfoSection = {
  @react.component
  let make = (~title, ~data, ~getHeading, ~getCell, ~detailsFields) => {
    <div className="flex flex-col gap-4">
      <div className={`${heading.sm.semibold} text-nd_gray-700`}> {title->React.string} </div>
      <div className="flex flex-wrap border border-nd_gray-150 bg-white rounded-xl p-5">
        {detailsFields
        ->Array.mapWithIndex((colType, index) =>
          <div className="w-full md:w-1/2 lg:w-1/3" key={index->Int.toString}>
            <DetailField heading={getHeading(colType)} value={getCell(data, colType)} />
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}
