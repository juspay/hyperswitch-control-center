let regex = searchString => {
  RegExp.fromStringWithFlags(`` ++ searchString ++ ``, ~flags="gi")
}
let highlightedText = (str, searchedText) => {
  let shouldHighlight =
    searchedText->LogicUtils.isNonEmptyString &&
      String.includes(str->String.toLowerCase, searchedText->String.toLowerCase)
  if shouldHighlight {
    let re = regex(searchedText)
    let matchFn = (matchPart, _offset, _wholeString) => `@@${matchPart}@@`
    let listText = Js.String.unsafeReplaceBy0(re, matchFn, str)->String.split("@@")

    {
      listText
      ->Array.mapWithIndex((item, i) => {
        if (
          String.toLowerCase(item) == String.toLowerCase(searchedText) &&
            String.length(searchedText) > 0
        ) {
          <mark key={i->Int.toString} className="bg-yellow"> {item->React.string} </mark>
        } else {
          let className = ""
          <span key={i->Int.toString} className value=str> {item->React.string} </span>
        }
      })
      ->React.array
    }
  } else {
    React.string(str)
  }
}

type labelColor =
  | LabelGreen
  | LabelRed
  | LabelBlue
  | LabelGray
  | LabelOrange
  | LabelYellow
  | LabelLightGray

type filterDataType =
  | Float(float, float)
  | String
  | DateTime

type disableField = {
  key: string,
  values: array<string>,
}

type customiseColumnConfig = {
  showDropDown: bool,
  customizeColumnUi: React.element,
}

type selectAllSubmitActions = {
  btnText: string,
  showMultiSelectCheckBox: bool,
  onClick: array<JSON.t> => unit,
  disableParam: disableField,
}

type hideItem = {
  key: string,
  value: string,
}

external jsonToStr: JSON.t => string = "%identity"

type textAlign = Left | Right

type fontBold = bool
type labelMargin = string

type sortOrder = INC | DEC | NONE
type sortedObject = {
  key: string,
  order: sortOrder,
}
type multipleSelectRows = ALL | PARTIAL
type filterObject = {
  key: string,
  options: array<string>,
  selected: array<string>,
}

let getSortOrderString = (order: sortOrder) => {
  switch order {
  | INC => "desc"
  | DEC => "asc"
  | NONE => ""
  }
}

type label = {
  title: string,
  color: labelColor,
  showIcon?: bool,
}

type currency = string
type filterRow =
  | DropDownFilter(string, array<JSON.t>)
  | TextFilter(string)
  | Range(string, float, float)

type cell =
  | Label(label)
  | Text(string)
  | EllipsisText(string, string)
  | Currency(float, currency)
  | Date(string)
  | DateWithoutTime(string)
  | DateWithCustomDateStyle(string, string)
  | StartEndDate(string, string)
  | InputField(React.element)
  | Link(string)
  | Progress(int)
  | CustomCell(React.element, string)
  | DisplayCopyCell(string)
  | TrimmedText(string, string)
  | DeltaPercentage(float, float)
  | DropDown(string)
  | Numeric(float, float => string) // value and mapper
  | ColoredText(label)

type cellType = LabelType | TextType | MoneyType | NumericType | ProgressType | DropDown

type header = {
  key: string,
  title: string,
  dataType: cellType,
  showSort: bool,
  showFilter: bool,
  highlightCellOnHover: bool,
  headerElement: option<React.element>,
  description: option<string>,
  data: option<string>,
  isMandatory: option<bool>,
  showMultiSelectCheckBox: option<bool>,
  hideOnShrink: option<bool>,
  customWidth: option<string>,
}

let makeHeaderInfo = (
  ~key,
  ~title,
  ~dataType=TextType,
  ~showSort=false,
  ~showFilter=false,
  ~highlightCellOnHover=false,
  ~headerElement=?,
  ~description=?,
  ~data=?,
  ~isMandatory=?,
  ~showMultiSelectCheckBox=?,
  ~hideOnShrink=?,
  ~customWidth=?,
) => {
  {
    key,
    title,
    dataType,
    showSort,
    showFilter,
    highlightCellOnHover,
    headerElement,
    description,
    data,
    isMandatory,
    showMultiSelectCheckBox,
    hideOnShrink,
    customWidth,
  }
}

let getCell = (item): cell => {
  Text(item)
}

module ProgressCell = {
  @react.component
  let make = (~progressPercentage) => {
    <div className="w-full bg-gray-200 rounded-full">
      <div
        className="bg-green-700 text font-medium text-blue-100 text-left pl-5 p-0.5 leading-none rounded-full"
        style={width: `${Int.toString(progressPercentage)}%`}>
        {React.string(Int.toString(progressPercentage) ++ "%")}
      </div>
    </div>
  }
}
let getTextAlignmentClass = textAlign => {
  switch textAlign {
  | Left => "text-left"
  | Right => "text-right px-2"
  }
}
module BaseComponentMethod = {
  @react.component
  let make = (~showDropDown, ~filterKey) => {
    let (_, setLclFilterOpen) = React.useContext(DataTableFilterOpenContext.filterOpenContext)
    React.useEffect(() => {
      setLclFilterOpen(filterKey, showDropDown)
      None
    }, [showDropDown])

    <div
      className={`flex px-1 pt-1 pb-0.5 items-center rounded-sm ${showDropDown
          ? "bg-jp-2-light-primary-100 !text-jp-2-light-primary-600"
          : ""}`}>
      <Icon name="bars-filter" size=12 parentClass="cursor-pointer" />
    </div>
  }
}
module LabelCell = {
  @react.component
  let make = (
    ~labelColor: labelColor,
    ~text,
    ~labelMargin="",
    ~highlightText="",
    ~fontStyle="font-ibm-plex",
    ~showIcon=true,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let bgOpacity = isMobileView ? "bg-opacity-12 dark:!bg-opacity-12" : ""
    let borderColor = switch labelColor {
    | LabelGreen => `bg-nd_green-50 ${bgOpacity} dark:bg-opacity-50`
    | LabelRed => `bg-nd_red-50 ${bgOpacity} dark:bg-opacity-50`
    | LabelBlue => `bg-nd_primary_blue-50 bg-opacity-50`
    | LabelGray => "bg-nd_gray-150"
    | LabelOrange => `bg-nd_orange-50 ${bgOpacity} dark:bg-opacity-50`
    | LabelYellow => "bg-nd_yellow-100"
    | LabelLightGray => "bg-nd_gray-50"
    }

    let textColor = switch labelColor {
    | LabelGreen => "text-nd_green-600"
    | LabelRed => "text-nd_red-600"
    | LabelOrange => "text-nd_orange-600"
    | LabelYellow => "text-nd_yellow-800"
    | LabelGray => "text-nd_gray-600"
    | LabelLightGray => "text-nd_gray_600"
    | LabelBlue => "text-nd_primary_blue-600"
    }

    let mobileTextColor = switch labelColor {
    | LabelGreen => "text-green-950"
    | LabelOrange => "text-orange-950"
    | LabelRed => "text-red-960"
    | _ => "text-white"
    }

    let textColor = isMobileView ? mobileTextColor : textColor

    let fontStyle = "font-inter-style"

    <div className="flex">
      <div className="flex-initial ">
        <div className={`rounded ${borderColor}`}>
          <div
            className={`${labelMargin} ${fontStyle} ${textColor} text-fs-10 font-bold px-2 py-0.5`}>
            <AddDataAttributes attributes=[("data-label", text)]>
              <div> {highlightedText(text, highlightText)} </div>
            </AddDataAttributes>
          </div>
        </div>
      </div>
    </div>
  }
}

module NewLabelCell = {
  @react.component
  let make = (
    ~labelColor: labelColor,
    ~text,
    ~labelMargin="",
    ~highlightText="",
    ~fontStyle="font-ibm-plex",
  ) => {
    let _borderColor = switch labelColor {
    | LabelGreen => "bg-green-950 dark:bg-opacity-50"
    | LabelRed => "bg-red-960 dark:bg-opacity-50"
    | LabelBlue => "bg-primary dark:bg-opacity-50"
    | LabelGray => "bg-blue-table_gray"
    | LabelOrange => "bg-orange-950 dark:bg-opacity-50"
    | LabelYellow => "bg-blue-table_yellow"
    | LabelLightGray => "bg-nd_gray-50"
    }
    let bgColor = switch labelColor {
    | LabelGreen => "bg-[#ECFDF3]"
    | LabelYellow => "bg-[#FFF9E2]"
    | LabelRed => "bg-[#FEECEB]"
    | _ => "bg-[#FFF9E2]"
    }

    let textColor = switch labelColor {
    | LabelGreen => "text-[#027A48]"
    | LabelYellow => "text-[#333333]"
    | LabelRed => "text-[#A83027]"
    | _ => "text-[#333333]"
    }

    let dotColor = switch labelColor {
    | LabelGreen => "fill-[#12B76A]"
    | LabelYellow => "fill-[#FDD744]"
    | LabelRed => "fill-[#F04438]"
    | _ => "fill-[#FDD744]"
    }

    <div className="flex">
      <div className="flex-initial ">
        <div
          className={`flex flex-row px-2 py-0.5 ${bgColor} rounded-[16px] text-fs-10 font-bold ${textColor}`}>
          <Icon className={`${dotColor} mr-2`} name="circle_unfilled" size=6 />
          <div className={`${textColor} font-medium text-xs`}> {React.string(text)} </div>
        </div>
      </div>
    </div>
  }
}
module ColoredTextCell = {
  @react.component
  let make = (~labelColor: labelColor, ~text, ~customPadding="px-2") => {
    let textColor = switch labelColor {
    | LabelGreen => "text-status-green"
    | LabelRed => "text-red-980"
    | LabelBlue => "text-sky-500"
    | LabelOrange => "text-status-text-orange"
    | LabelGray => "text-grey-500"
    | LabelYellow => "text-yellow-400"
    | LabelLightGray => "text-nd_gray-600"
    }

    <div className="flex">
      <div className="flex-initial ">
        <p className={`py-0.5 fira-code text-fs-13 font-semibold ${textColor} ${customPadding}`}>
          {React.string(text)}
        </p>
      </div>
    </div>
  }
}

module Numeric = {
  @react.component
  let make = (~num: float, ~mapper, ~clearFormatting) => {
    if clearFormatting {
      <AddDataAttributes attributes=[("data-numeric", num->Float.toString)]>
        <div> {React.string(num->Float.toString)} </div>
      </AddDataAttributes>
    } else {
      <AddDataAttributes attributes=[("data-numeric", num->mapper)]>
        <div> {React.string(num->mapper)} </div>
      </AddDataAttributes>
    }
  }
}

module MoneyCell = {
  let getAmountValue = (amount, currency) => {
    let amountSplitArr = Float.toFixedWithPrecision(amount, ~digits=2)->String.split(".")
    let decimal = amountSplitArr[1]->Option.getOr("00")
    let receivedValue = amountSplitArr->Array.get(0)->Option.getOr("")

    let formattedAmount = if receivedValue->String.includes("e") {
      receivedValue
    } else if currency === "INR" {
      receivedValue->String.replaceRegExp(%re("/(\d)(?=(?:(\d\d)+(\d)(?!\d))+(?!\d))/g"), "$1,")
    } else {
      receivedValue->String.replaceRegExp(%re("/(\d)(?=(\d{3})+(?!\d))/g"), "$1,")
    }
    let formatted_amount = `${formattedAmount}.${decimal}`

    `${formatted_amount} ${currency}`
  }
  @react.component
  let make = (
    ~amount: float,
    ~currency,
    ~isCard=false,
    ~textAlign=Right,
    ~fontBold=false,
    ~customMoneyStyle="",
  ) => {
    let textAlignClass = textAlign->getTextAlignmentClass
    let boldClass = fontBold
      ? `text-fs-20 font-bold text-jp-gray-900`
      : `text-fs-13 text-jp-gray-dark_disable_border_color`

    let wrapperClass = isCard
      ? `font-semibold font-fira-code`
      : `${boldClass} text-start dark:text-white ${textAlignClass} ${customMoneyStyle}`
    let amountValue = getAmountValue(amount, currency)
    <AddDataAttributes attributes=[("data-money-cell", amountValue)]>
      <div className=wrapperClass> {React.string(amountValue)} </div>
    </AddDataAttributes>
  }
}

module LinkCell = {
  @react.component
  let make = (~data, ~trimLength=?) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let (showCopy, setShowCopy) = React.useState(() => false)
    let isMobileView = MatchMedia.useMobileChecker()

    let trimData = switch trimLength {
    | Some(length) => {
        let length = isMobileView ? 36 : length
        String.concat("..", Js.String.substrAtMost(~from=0, ~length, data))
      }

    | None => data
    }
    let mouseOver = _ => {
      setShowCopy(_ => true)
    }

    let mouseOut = _ => {
      setShowCopy(_ => false)
    }
    let visibility = showCopy && !isMobileView ? "visible" : "invisible"

    let preventEvent = ev => {
      ev->ReactEvent.Mouse.stopPropagation
    }

    <div className="flex flex-row items-center" onMouseOver={mouseOver} onMouseOut={mouseOut}>
      <div
        className={`whitespace-pre text-sm font-fira-code dark:text-opacity-75 text-right p-1 ${textColor.primaryNormal} text-ellipsis overflow-hidden`}>
        <a href=data target="_blank" onClick=preventEvent> {React.string(trimData)} </a>
      </div>
      <div className=visibility>
        <Clipboard.Copy data toolTipPosition={Top} />
      </div>
    </div>
  }
}

module DateCell = {
  @react.component
  let make = (
    ~timestamp,
    ~isCard=false,
    ~textStyle=?,
    ~textAlign=Right,
    ~customDateStyle="",
    ~hideTime=false,
    ~hideTimeZone=false,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let dateFormat = React.useContext(DateFormatProvider.dateFormatContext)
    let dateFormat = isMobileView
      ? "DD MMM HH:mm"
      : customDateStyle->LogicUtils.isNonEmptyString
      ? customDateStyle
      : dateFormat

    let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()
    let getFormattedDate = dateStr => {
      try {
        let customTimeZone = isoStringToCustomTimeZone(dateStr)
        TimeZoneHook.formattedDateTimeFloat(customTimeZone, dateFormat)
      } catch {
      | _ => `${dateStr} - unable to parse`
      }
    }

    let fontType = switch textStyle {
    | Some(font) => font
    | None => "font-semibold"
    }

    let fontStyle = "font-inter-style"
    let (zone, _setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let selectedTimeZoneData = TimeZoneData.getTimeZoneData(zone)
    let selectedTimeZoneAlias = selectedTimeZoneData.title
    let textAlignClass = textAlign->getTextAlignmentClass

    let wrapperClass = isCard
      ? fontType
      : `dark:text-jp-gray-text_darktheme dark:text-opacity-75 ${textAlignClass} ${fontStyle}`

    <AddDataAttributes attributes=[("data-date", timestamp->getFormattedDate)]>
      <div className={`${wrapperClass} whitespace-nowrap`}>
        {hideTime
          ? React.string(timestamp->getFormattedDate->String.slice(~start=0, ~end=12))
          : hideTimeZone
          ? React.string(`${timestamp->getFormattedDate}`)
          : React.string(`${timestamp->getFormattedDate} ${selectedTimeZoneAlias}`)}
      </div>
    </AddDataAttributes>
  }
}

module StartEndDateCell = {
  @react.component
  let make = (~startDate, ~endDate, ~isCard=false) => {
    let _ = isCard
    <div>
      <div className="flex justify-between">
        {React.string("Start: ")}
        <DateCell timestamp=startDate />
      </div>
      <div className="flex justify-between">
        {React.string("End: ")}
        <DateCell timestamp=endDate />
      </div>
    </div>
  }
}

module EllipsisText = {
  @react.component
  let make = (
    ~text,
    ~width,
    ~highlightText="",
    ~isEllipsisTextRelative=true,
    ~ellipseClass="",
    ~ellipsisIdentifier="",
    ~ellipsisThreshold=20,
    ~toolTipPosition: ToolTip.toolTipPosition=ToolTip.Right,
  ) => {
    open LogicUtils
    let modifiedText =
      ellipsisIdentifier->isNonEmptyString
        ? {
            text->String.split(ellipsisIdentifier)->Array.get(0)->Option.getOr("") ++ "..."
          }
        : text
    let ellipsesCondition =
      ellipsisIdentifier->isNonEmptyString
        ? String.includes(ellipsisIdentifier, text)
        : text->String.length > ellipsisThreshold

    // If text character count is greater than ellipsisThreshold, it will render tooltip else we will have whole text in cell
    if ellipsesCondition {
      <ToolTip
        contentAlign=Left
        description=text
        toolTipPosition
        tooltipForWidthClass=ellipseClass
        isRelative=isEllipsisTextRelative
        toolTipFor={<div className={`whitespace-pre text-ellipsis overflow-x-hidden ${width}`}>
          {highlightedText(modifiedText, highlightText)}
        </div>}
      />
    } else {
      <div className={`whitespace-pre text-ellipsis ${ellipseClass} ${width}`}>
        {highlightedText(text, highlightText)}
      </div>
    }
  }
}

module TrimmedText = {
  @react.component
  let make = (~text, ~width, ~highlightText="", ~hideShowMore=false) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let (show, setshow) = React.useState(_ => true)
    let breakWords = hideShowMore ? "" : "whitespace-nowrap text-ellipsis overflow-x-hidden"
    if text->String.length > 40 {
      <div className={show ? `${breakWords}  justify-content ${width}` : "justify-content"}>
        <AddDataAttributes attributes=[("data-trimmed-text", text)]>
          <div className={hideShowMore ? "truncate" : ""}>
            {highlightedText(text, highlightText)}
          </div>
        </AddDataAttributes>
        {if !hideShowMore {
          <div
            className={`${textColor.primaryNormal} cursor-pointer`}
            onClick={_ => setshow(show => !show)}>
            {show ? React.string("More") : React.string("Less")}
          </div>
        } else {
          React.null
        }}
      </div>
    } else {
      <div>
        <AddDataAttributes attributes=[("data-trimmed-text", text)]>
          <div className={hideShowMore ? `justify-content ${width} truncate` : ""}>
            {highlightedText(text, highlightText)}
          </div>
        </AddDataAttributes>
      </div>
    }
  }
}
module TableFilterCell = {
  @react.component
  let make = (~cell: filterRow) => {
    open TableLocalFilters
    switch cell {
    | DropDownFilter(val, arr) => <FilterDropDown val arr />
    | TextFilter(val) => <TextFilterCell val />
    | Range(val, minVal, maxVal) => <RangeFilterCell minVal maxVal val />
    }
  }
}
module DeltaColumn = {
  @react.component
  let make = (~value, ~delta) => {
    let detlaStr = Float.toFixedWithPrecision(delta, ~digits=2) ++ "%"
    let (deltaText, textColor, _, _, _) = if delta == 0. {
      let textColor = ""
      ("", textColor, "", "", "bg-jp-2-gray-30")
    } else if delta < 0. {
      let textColor = "text-red-980"
      ("", textColor, "text-jp-2-red-100", "arrow-down", "bg-jp-2-red-100")
    } else {
      let textColor = "text-green-950"
      ("+", textColor, "text-jp-2-green-300", "arrow-up", "bg-jp-2-green-50")
    }
    let detlaStr = deltaText ++ detlaStr
    let paraparentCss = "flex items-center rounded"
    // font-style can be changed acc to the module  fira-code
    <div className="flex">
      <div className="flex justify-between">
        <div className=paraparentCss>
          <p className="px-2 py-0.5 fira-code text-fs-13">
            {React.string(Float.toFixedWithPrecision(value, ~digits=2) ++ "%")}
          </p>
        </div>
        <RenderIf condition={delta !== value}>
          <div className=paraparentCss>
            <p className={`px-2 py-0.5 fira-code text-fs-10  ${textColor}`}>
              {React.string(detlaStr)}
            </p>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

module TableCell = {
  @react.component
  let make = (
    ~cell,
    ~textAlign: option<textAlign>=?,
    ~fontBold=false,
    ~labelMargin: option<labelMargin>=?,
    ~customMoneyStyle="",
    ~customDateStyle="",
    ~highlightText="",
    ~hideShowMore=false,
    ~clearFormatting=false,
    ~fontStyle="",
    ~isEllipsisTextRelative=true,
    ~ellipseClass="",
  ) => {
    open LogicUtils
    switch cell {
    | Label(x) =>
      <AddDataAttributes attributes=[("data-testid", x.title->String.toLowerCase)]>
        <LabelCell
          labelColor=x.color
          text=x.title
          showIcon=?{x.showIcon}
          ?labelMargin
          highlightText
          fontStyle
        />
      </AddDataAttributes>
    | Text(x) | DropDown(x) => {
        let x = x->isEmptyString ? "NA" : x
        <AddDataAttributes attributes=[("data-desc", x), ("data-testid", x->String.toLowerCase)]>
          <div> {highlightedText(x, highlightText)} </div>
        </AddDataAttributes>
      }

    | EllipsisText(text, width) =>
      <AddDataAttributes attributes=[("data-testid", text->String.toLowerCase)]>
        <EllipsisText text width highlightText isEllipsisTextRelative ellipseClass />
      </AddDataAttributes>
    | TrimmedText(text, width) => <TrimmedText text width highlightText hideShowMore />
    | Currency(amount, currency) =>
      <MoneyCell amount currency ?textAlign fontBold customMoneyStyle />

    | Date(timestamp) =>
      timestamp->isNonEmptyString
        ? <DateCell timestamp textAlign=Left customDateStyle />
        : <div> {React.string("-")} </div>
    | DateWithoutTime(timestamp) =>
      timestamp->isNonEmptyString
        ? <DateCell timestamp textAlign=Left customDateStyle hideTime=true />
        : <div> {React.string("-")} </div>
    | DateWithCustomDateStyle(timestamp, dateFormat) =>
      timestamp->isNonEmptyString
        ? <DateCell
            timestamp textAlign=Left hideTime=false hideTimeZone=true customDateStyle=dateFormat
          />
        : <div> {React.string("-")} </div>
    | StartEndDate(startDate, endDate) => <StartEndDateCell startDate endDate />
    | InputField(fieldElement) => fieldElement
    | Link(ele) => <LinkCell data=ele trimLength=55 />
    | Progress(percent) => <ProgressCell progressPercentage=percent />
    | CustomCell(ele, _) => ele
    | DisplayCopyCell(string) => <HelperComponents.CopyTextCustomComp displayValue=Some(string) />
    | DeltaPercentage(value, delta) => <DeltaColumn value delta />
    | Numeric(num, mapper) => <Numeric num mapper clearFormatting />
    | ColoredText(x) => <ColoredTextCell labelColor=x.color text=x.title />
    }
  }
}

module NewTableCell = {
  @react.component
  let make = (
    ~cell,
    ~textAlign: option<textAlign>=?,
    ~fontBold=false,
    ~labelMargin: option<labelMargin>=?,
    ~customMoneyStyle="",
    ~customDateStyle="",
    ~highlightText="",
    ~hideShowMore=false,
    ~clearFormatting=false,
    ~fontStyle="",
  ) => {
    open LogicUtils
    switch cell {
    | Label(x) =>
      <NewLabelCell labelColor=x.color text=x.title ?labelMargin highlightText fontStyle />
    | Text(x) | DropDown(x) => {
        let x = x->isEmptyString ? "NA" : x
        <AddDataAttributes attributes=[("data-desc", x)]>
          <div> {highlightedText(x, highlightText)} </div>
        </AddDataAttributes>
      }

    | EllipsisText(text, width) => <EllipsisText text width highlightText />
    | TrimmedText(text, width) => <TrimmedText text width highlightText hideShowMore />
    | Currency(amount, currency) =>
      <MoneyCell amount currency ?textAlign fontBold customMoneyStyle />

    | Date(timestamp) =>
      timestamp->isNonEmptyString
        ? <DateCell timestamp textAlign=Left customDateStyle />
        : <div> {React.string("-")} </div>
    | DateWithoutTime(timestamp) =>
      timestamp->isNonEmptyString
        ? <DateCell timestamp textAlign=Left customDateStyle hideTime=true />
        : <div> {React.string("-")} </div>
    | DateWithCustomDateStyle(timestamp, dateFormat) =>
      timestamp->isNonEmptyString
        ? <DateCell
            timestamp textAlign=Left hideTime=false hideTimeZone=true customDateStyle=dateFormat
          />
        : <div> {React.string("-")} </div>
    | StartEndDate(startDate, endDate) => <StartEndDateCell startDate endDate />
    | InputField(fieldElement) => fieldElement
    | Link(ele) => <LinkCell data=ele trimLength=55 />
    | Progress(percent) => <ProgressCell progressPercentage=percent />
    | CustomCell(ele, _) => ele
    | DisplayCopyCell(string) => <HelperComponents.CopyTextCustomComp displayValue=Some(string) />
    | DeltaPercentage(value, delta) => <DeltaColumn value delta />
    | Numeric(num, mapper) => <Numeric num mapper clearFormatting />
    | ColoredText(x) => <ColoredTextCell labelColor=x.color text=x.title />
    }
  }
}

type rowType = Filter | Row

let getTableCellValue = cell => {
  switch cell {
  | Label(x) => x.title
  | Text(x) => x
  | Date(x) => x
  | DateWithoutTime(x) => x
  | Currency(val, _) => val->Float.toString
  | Link(str) => str
  | CustomCell(_, value) => value
  | DisplayCopyCell(str) => str
  | EllipsisText(x, _) => x
  | DeltaPercentage(x, _) | Numeric(x, _) => x->Float.toString
  | ColoredText(x) => x.title
  | _ => ""
  }
}

module SortIcons = {
  @react.component
  let make = (~order: sortOrder, ~size: int) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let (iconColor1, iconColor2) = switch order {
    | INC => ("text-gray-300", textColor.primaryNormal)
    | DEC => (textColor.primaryNormal, "text-gray-300")
    | NONE => ("text-gray-300", "text-gray-300")
    }
    <div className="flex flex-col justify-center">
      <Icon className={`-mb-0.5 ${iconColor1}`} name="caret-up" size />
      <Icon className={`-mt-0.5 ${iconColor2}`} name="caret-down" size />
    </div>
  }
}

module HeaderActions = {
  @react.component
  let make = (
    ~order: sortOrder,
    ~actionOptions: array<SelectBox.dropdownOption>=[
      {
        label: "Sort Ascending",
        value: "DEC",
        icon: Euler("sortAscending"),
      },
      {
        label: "Sort Descending",
        value: "INC",
        icon: Euler("sortDescending"),
      },
    ],
    ~onChange,
    ~filterRow: option<filterRow>,
    ~isLastCol=false,
    ~filterKey: string,
  ) => {
    let (toggleDropdownState, _) = React.useState(_ => false)
    let getSortOrderToString = order =>
      switch order {
      | INC => "INC"
      | DEC => "DEC"
      | NONE => ""
      }

    let actionInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "heading",
      onBlur: _ => (),
      onChange,
      onFocus: _ => (),
      value: order->getSortOrderToString->JSON.Encode.string,
      checked: true,
    }
    let customButton = switch filterRow {
    | Some(obj) =>
      <div className="flex relative flex-col w-full bg-white rounded-b-lg">
        <div className="w-full h-[1px] bg-jp-2-light-gray-400 px-1" />
        <TableFilterCell cell=obj />
      </div>
    | None => React.null
    }

    <SelectBox.BaseDropdown
      allowMultiSelect=false
      hideMultiSelectButtons=true
      fixedDropDownDirection={isLastCol ? BottomLeft : BottomRight}
      buttonText=""
      input={actionInput}
      options=actionOptions
      baseComponentMethod={showDropDown => {
        <BaseComponentMethod showDropDown filterKey />
      }}
      dropDownCustomBtnClick=toggleDropdownState
      autoApply=true
      showClearAll=false
      showSelectAll=false
      marginTop="mt-5.5"
      customButton
      showCustomBtnAtEnd=true
    />
  }
}
