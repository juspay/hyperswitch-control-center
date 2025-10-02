let regex: string => RescriptCore.RegExp.t
let highlightedText: (Js.String.t, string) => React.element
type labelColor =
  | LabelGreen
  | LabelRed
  | LabelBlue
  | LabelGray
  | LabelOrange
  | LabelYellow
  | LabelLightGray
  | LabelPurple
type filterDataType = Float(float, float) | String | DateTime
type disableField = {key: string, values: array<string>}
type customiseColumnConfig = {showDropDown: bool, customizeColumnUi: React.element}
type selectAllSubmitActions = {
  btnText: string,
  showMultiSelectCheckBox: bool,
  onClick: array<RescriptCore.JSON.t> => unit,
  disableParam: disableField,
}
type hideItem = {key: string, value: string}
external jsonToStr: RescriptCore.JSON.t => string = "%identity"
type textAlign = Left | Right
type fontBold = bool
type labelMargin = string
type sortOrder = INC | DEC | NONE
type sortedObject = {key: string, order: sortOrder}
type multipleSelectRows = ALL | PARTIAL
type filterObject = {key: string, options: array<string>, selected: array<string>}
let getSortOrderString: sortOrder => string
type label = {title: string, color: labelColor, showIcon?: bool}
type currency = string
type filterRow =
  | DropDownFilter(string, array<RescriptCore.JSON.t>)
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
  | Numeric(float, float => string)
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
let makeHeaderInfo: (
  ~key: string,
  ~title: string,
  ~dataType: cellType=?,
  ~showSort: bool=?,
  ~showFilter: bool=?,
  ~highlightCellOnHover: bool=?,
  ~headerElement: React.element=?,
  ~description: string=?,
  ~data: string=?,
  ~isMandatory: bool=?,
  ~showMultiSelectCheckBox: bool=?,
  ~hideOnShrink: bool=?,
  ~customWidth: string=?,
) => header
let getCell: string => cell
module ProgressCell: {
  @react.component
  let make: (~progressPercentage: int) => React.element
}
let getTextAlignmentClass: textAlign => string
module BaseComponentMethod: {
  @react.component
  let make: (~showDropDown: bool, ~filterKey: string) => React.element
}
module LabelCell: {
  @react.component
  let make: (
    ~labelColor: labelColor,
    ~text: Js.String.t,
    ~labelMargin: string=?,
    ~highlightText: string=?,
    ~fontStyle: string=?,
    ~showIcon: bool=?,
  ) => React.element
}
module NewLabelCell: {
  @react.component
  let make: (
    ~labelColor: labelColor,
    ~text: string,
    ~labelMargin: string=?,
    ~highlightText: string=?,
    ~fontStyle: string=?,
  ) => React.element
}
module ColoredTextCell: {
  @react.component
  let make: (~labelColor: labelColor, ~text: string, ~customPadding: string=?) => React.element
}
module Numeric: {
  @react.component
  let make: (~num: float, ~mapper: float => string, ~clearFormatting: bool) => React.element
}
module MoneyCell: {
  let getAmountValue: (float, string) => string
  @react.component
  let make: (
    ~amount: float,
    ~currency: string,
    ~isCard: bool=?,
    ~textAlign: textAlign=?,
    ~fontBold: bool=?,
    ~customMoneyStyle: string=?,
  ) => React.element
}
module LinkCell: {
  @react.component
  let make: (~data: Js.String.t, ~trimLength: int=?) => React.element
}
module DateCell: {
  @react.component
  let make: (
    ~timestamp: string,
    ~isCard: bool=?,
    ~textStyle: string=?,
    ~textAlign: textAlign=?,
    ~customDateStyle: string=?,
    ~hideTime: bool=?,
    ~hideTimeZone: bool=?,
  ) => React.element
}
module StartEndDateCell: {
  @react.component
  let make: (~startDate: string, ~endDate: string, ~isCard: bool=?) => React.element
}
module EllipsisText: {
  @react.component
  let make: (
    ~text: Js.String.t,
    ~width: string,
    ~highlightText: string=?,
    ~isEllipsisTextRelative: bool=?,
    ~ellipseClass: string=?,
    ~ellipsisIdentifier: string=?,
    ~ellipsisThreshold: int=?,
    ~toolTipPosition: ToolTip.toolTipPosition=?,
  ) => React.element
}
module TrimmedText: {
  @react.component
  let make: (
    ~text: Js.String.t,
    ~width: string,
    ~highlightText: string=?,
    ~hideShowMore: bool=?,
  ) => React.element
}
module TableFilterCell: {
  @react.component
  let make: (~cell: filterRow) => React.element
}
module DeltaColumn: {
  @react.component
  let make: (~value: float, ~delta: float) => React.element
}
module TableCell: {
  @react.component
  let make: (
    ~cell: cell,
    ~textAlign: textAlign=?,
    ~fontBold: bool=?,
    ~labelMargin: labelMargin=?,
    ~customMoneyStyle: string=?,
    ~customDateStyle: string=?,
    ~highlightText: string=?,
    ~hideShowMore: bool=?,
    ~clearFormatting: bool=?,
    ~fontStyle: string=?,
    ~isEllipsisTextRelative: bool=?,
    ~ellipseClass: string=?,
  ) => React.element
}
module NewTableCell: {
  @react.component
  let make: (
    ~cell: cell,
    ~textAlign: textAlign=?,
    ~fontBold: bool=?,
    ~labelMargin: labelMargin=?,
    ~customMoneyStyle: string=?,
    ~customDateStyle: string=?,
    ~highlightText: string=?,
    ~hideShowMore: bool=?,
    ~clearFormatting: bool=?,
    ~fontStyle: string=?,
  ) => React.element
}
type rowType = Filter | Row
let getTableCellValue: cell => string
module SortIcons: {
  @react.component
  let make: (~order: sortOrder, ~size: int) => React.element
}
module HeaderActions: {
  @react.component
  let make: (
    ~order: sortOrder,
    ~actionOptions: array<SelectBox.dropdownOption>=?,
    ~onChange: ReactEvent.Form.t => unit,
    ~filterRow: option<filterRow>,
    ~isLastCol: bool=?,
    ~filterKey: string,
  ) => React.element
}
