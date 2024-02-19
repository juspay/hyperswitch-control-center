@react.component
let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate, ~btnCount=4) => {
  let pageNumbers = []
  let total = Math.ceil(Int.toFloat(totalResults) /. Int.toFloat(resultsPerPage))->Float.toInt

  for x in 1 to total {
    Array.push(pageNumbers, x)->ignore
  }

  let pageToLeft =
    btnCount - (total - currentPage) < btnCount / 2
      ? btnCount / 2
      : btnCount - (total - currentPage)

  let startIndex = Math.Int.max(1, currentPage - pageToLeft)
  let endIndex = Math.Int.min(startIndex + btnCount, total)

  let nonEmpty = s => s >= startIndex && s <= endIndex

  <ButtonGroup>
    {if currentPage > 1 {
      <Icon
        name="chevron-left"
        className="fill-ardra-secondary-300"
        size=16
        onClick={_evt => paginate(Math.Int.max(1, currentPage - 1))}
      />
    } else {
      <Icon
        name="leftDisabledPaginator"
        size=16
        onClick={_evt => paginate(Math.Int.max(1, currentPage - 1))}
      />
    }}
    {pageNumbers
    ->Array.filter(nonEmpty)
    ->Array.mapWithIndex((number, idx) => {
      let isSelected = number == currentPage
      if isSelected {
        <div className="p-2">
          <Button
            key={idx->Int.toString}
            text={number->Int.toString}
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
            key={idx->Int.toString}
            text={number->Int.toString}
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
    {if currentPage < Array.length(pageNumbers) {
      <Icon name="chevron-right" size=16 onClick={_evt => paginate(currentPage + 1)} />
    } else {
      <Icon name="rightDisabledPaginator" size=16 onClick={_evt => paginate(currentPage + 1)} />
    }}
  </ButtonGroup>
}
