open Typography
open LogicUtils

module LedgerTableHeaderHelper = {
  let makeHeaderCell = (~text, ~colSpan=?, ~rowSpan=?, ~isLast=false) => {
    let baseClasses = `${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400 border-b border-nd_br_gray-150`
    let borderClass = isLast ? "" : " border-r"

    <th ?colSpan ?rowSpan className={`${baseClasses}${borderClass}`}> {text->React.string} </th>
  }

  let makeSubHeaderCell = (~text, ~isRightBorder=false) => {
    let baseClasses = `${body.sm.semibold} px-4 py-3 text-center text-nd_gray-400`
    let borderClass = isRightBorder ? " border-r border-nd_br_gray-150" : " border-nd_br_gray-150"

    <th className={`${baseClasses}${borderClass}`}> {text->React.string} </th>
  }

  let makeEmptyCell = (~isRightBorder=false) => {
    let borderClass = isRightBorder ? " border-r border-nd_br_gray-150" : ""
    <th className={`px-4 py-3 text-center${borderClass}`} />
  }
}

module LedgerTableCellHelper = {
  let makeAmountCell = (~value: float, ~currency: string, ~isRightBorder: bool, ~isTotal: bool) => {
    let formattedValue = value->valueFormatter(AmountWithSuffix)

    let baseClasses = "px-4 py-3 text-center border-t border-nd_br_gray-150"
    let borderClass = isRightBorder ? " border-r" : ""
    let textStyle = isTotal ? body.lg.semibold : body.md.medium
    let textColor = isTotal ? "text-nd_gray-600" : "text-nd_gray-700"

    <td className={`${textStyle} ${baseClasses}${borderClass} ${textColor}`}>
      {`${formattedValue} ${currency}`->React.string}
    </td>
  }

  let makeAmountPair = (
    ~creditValue: float,
    ~creditCurrency: string,
    ~debitValue: float,
    ~debitCurrency: string,
    ~isTotal: bool,
  ) => {
    <>
      {makeAmountCell(~value=creditValue, ~currency=creditCurrency, ~isRightBorder=false, ~isTotal)}
      {makeAmountCell(~value=debitValue, ~currency=debitCurrency, ~isRightBorder=true, ~isTotal)}
    </>
  }

  let makeTextCell = (~text: string, ~isRightBorder: bool=false, ~colSpan: option<int>=?) => {
    let baseClasses = `${body.md.medium} px-4 py-3 text-nd_gray-700 border-t border-nd_br_gray-150 text-center`
    let borderClass = isRightBorder ? " border-r" : ""

    <td ?colSpan className={`${baseClasses}${borderClass}`}> {text->React.string} </td>
  }

  let makeTotalCell = (~text: string) => {
    <td
      colSpan=2
      className={`${body.md.semibold} px-8 py-3 text-nd_gray-600 border-t border-r border-nd_br_gray-150 text-center`}>
      {text->React.string}
    </td>
  }
}
