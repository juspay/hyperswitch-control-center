@react.component
let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate, ~btnCount=4) => {
  let pageNumbers = []
  let total = Js.Math.ceil(Belt.Int.toFloat(totalResults) /. Belt.Int.toFloat(resultsPerPage))

  for x in 1 to total {
    Array.push(pageNumbers, x)->ignore
  }

  let pageToLeft =
    btnCount - (total - currentPage) < btnCount / 2
      ? btnCount / 2
      : btnCount - (total - currentPage)

  let startIndex = Js.Math.max_int(1, currentPage - pageToLeft)
  let endIndex = Js.Math.min_int(startIndex + btnCount, total)

  let nonEmpty = s => s >= startIndex && s <= endIndex

  <ButtonGroup>
    {if currentPage > 1 {
      <Icon
        name="chevron-left"
        className="fill-ardra-secondary-300"
        size=16
        onClick={_evt => paginate(Js.Math.max_int(1, currentPage - 1))}
      />
    } else {
      <Icon
        name="leftDisabledPaginator"
        size=16
        onClick={_evt => paginate(Js.Math.max_int(1, currentPage - 1))}
      />
    }}
    {pageNumbers
    ->Array.filter(nonEmpty)
    ->Array.mapWithIndex((number, idx) => {
      let isSelected = number == currentPage
      if isSelected {
        <div className="p-2">
          <Button
            key={idx->string_of_int}
            text={number->string_of_int}
            buttonType={UpiPaginator}
            onClick={_evt => paginate(number)}
            customButtonStyle="rounded-[4px] w-[39px] h-[36px] border-[1px] border-[#3674E0]"
            textStyle="text-[#0E111E] text-[14px]"
            textWeight="font-light"
          />
        </div>
      } else {
        <div className="p-2">
          <Button
            key={idx->string_of_int}
            text={number->string_of_int}
            onClick={_evt => paginate(number)}
            buttonType={Pill}
            customButtonStyle="rounded-[4px] w-[39px] h-[36px]"
            textStyle="text-[#0E111E] text-[14px]"
            textWeight="font-light"
          />
        </div>
      }
    })
    ->React.array}
    {if currentPage < Belt.Array.length(pageNumbers) {
      <Icon name="chevron-right" size=16 onClick={_evt => paginate(currentPage + 1)} />
    } else {
      <Icon name="rightDisabledPaginator" size=16 onClick={_evt => paginate(currentPage + 1)} />
    }}
  </ButtonGroup>
}
