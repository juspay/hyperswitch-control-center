let regex: string => Js.Re.t
let highlightedText: (Js.String.t, Js.String.t) => React.element
type labelColor = TableUtils.labelColor =
  | LabelGreen
  | LabelRed
  | LabelBlue
  | LabelGray
  | LabelOrange
  | LabelYellow
  | LabelDarkGreen
  | LabelDarkRed
  | LabelBrown
  | LabelLightBlue
  | LabelWhite
  | LabelLightOrange
  | LabelLightGray
  | LabelViolet
  | LabelLightGreen
  | LabelLightRed

type filterDataType = TableUtils.filterDataType =
  | Float(float, float)
  | String
  | DateTime
external jsonToStr: Js.Json.t => string = "%identity"
type textAlign = TableUtils.textAlign = Left | Right
type fontBold = bool
type labelMargin = string
type sortOrder = TableUtils.sortOrder = INC | DEC | NONE
type multipleSelectRows = TableUtils.multipleSelectRows = ALL | PARTIAL
type sortedObject = TableUtils.sortedObject = {key: string, order: sortOrder}
type filterObject = TableUtils.filterObject = {
  key: string,
  options: array<string>,
  selected: array<string>,
}
let getSortOrderString: sortOrder => string
type label = TableUtils.label = {title: string, color: labelColor, showIcon?: bool}
type currency = string
type filterRow = TableUtils.filterRow =
  | DropDownFilter(string, array<Js.Json.t>)
  | TextFilter(string)
  | Range(string, float, float)
type cell = TableUtils.cell =
  | Label(label)
  | Text(string)
  | EllipsisText(string, string)
  | Currency(float, currency)
  | Date(string)
  | DateWithoutTime(string)
  | StartEndDate(string, string)
  | InputField(React.element)
  | Link(string)
  | Progress(int)
  | CustomCell(React.element, string)
  | TrimmedText(string, string)
  | DeltaPercentage(float, float)
  | DropDown(string)
  | Numeric(float, float => string)
  | ColoredText(label)
type cellType = TableUtils.cellType =
  | LabelType
  | TextType
  | MoneyType
  | NumericType
  | ProgressType
  | DropDown
type header = TableUtils.header = {
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
  unit,
) => header
let dateFormat: (string, string) => string
let getCell: string => cell
module ProgressCell = TableUtils.ProgressCell
let getTextAlignmentClass: textAlign => string
module LabelCell = TableUtils.LabelCell
module ColoredTextCell = TableUtils.ColoredTextCell
module Numeric = TableUtils.Numeric
module MoneyCell = TableUtils.MoneyCell
module LinkCell = TableUtils.LinkCell
module DateCell = TableUtils.DateCell
module StartEndDateCell = TableUtils.StartEndDateCell
module EllipsisText = TableUtils.EllipsisText
module TrimmedText = TableUtils.TrimmedText
module TableFilterCell = TableUtils.TableFilterCell
module DeltaColumn = TableUtils.DeltaColumn
module TableCell = TableUtils.TableCell
type rowType = TableUtils.rowType = Filter | Row
let getTableCellValue: cell => string
module SortIcons = TableUtils.SortIcons
module HeaderActions = TableUtils.HeaderActions
module TableFilterRow: {
  @react.component
  let make: (
    ~item: array<filterRow>,
    ~removeVerticalLines: bool,
    ~removeHorizontalLines: bool,
    ~evenVertivalLines: bool,
    ~tableDataBorderClass: string,
    ~customFilterRowStyle: string,
    ~showCheckbox: bool,
  ) => React.element
}
module TableRow: {
  @react.component
  let make: (
    ~title: string,
    ~item: array<cell>,
    ~rowIndex: int,
    ~onRowClick: option<int => unit>,
    ~onRowDoubleClick: option<int => unit>,
    ~onRowClickPresent: bool,
    ~offset: int,
    ~removeVerticalLines: bool,
    ~removeHorizontalLines: bool,
    ~evenVertivalLines: bool,
    ~highlightEnabledFieldsArray: Js.Array2.t<int>,
    ~tableDataBorderClass: string=?,
    ~collapseTableRow: bool=?,
    ~expandedRow: unit => React.element,
    ~onMouseEnter: option<int => unit>,
    ~onMouseLeave: option<int => unit>,
    ~highlightText: Js.String.t,
    ~clearFormatting: bool=?,
    ~rowHeightClass: string=?,
    ~rowCustomClass: string=?,
    ~fixedWidthClass: string,
    ~isHighchartLegend: bool=?,
    ~labelMargin: string=?,
    ~isEllipsisTextRelative: bool=?,
    ~customMoneyStyle: string=?,
    ~ellipseClass: string=?,
    ~selectedRowColor: string=?,
    ~lastColClass: string=?,
    ~fixLastCol: bool=?,
    ~alignCellContent: string=?,
    ~customCellColor: string=?,
  ) => React.element
}
module SortAction: {
  @react.component
  let make: (
    ~item: TableUtils.header,
    ~sortedObj: option<TableUtils.sortedObject>,
    ~setSortedObj: option<('a => option<sortedObject>) => unit>,
    ~sortIconSize: int,
    ~isLastCol: bool=?,
    ~filterRow: option<filterRow>,
  ) => React.element
}
module TableHeadingCell: {
  @react.component
  let make: (
    ~item: header,
    ~index: int,
    ~headingArray: array<'a>,
    ~isHighchartLegend: bool,
    ~frozenUpto: int,
    ~heightHeadingClass: string,
    ~tableheadingClass: string,
    ~sortedObj: option<TableUtils.sortedObject>,
    ~setSortedObj: option<('b => option<sortedObject>) => unit>,
    ~filterObj: option<array<filterObject>>,
    ~fixedWidthClass: string,
    ~setFilterObj: option<(array<filterObject> => Js.Array2.t<filterObject>) => unit>,
    ~headingCenter: bool,
    ~filterIcon: React.element=?,
    ~filterDropdownClass: string=?,
    ~filterDropdownMaxHeight: string=?,
    ~selectAllCheckBox: option<TableUtils.multipleSelectRows>,
    ~setSelectAllCheckBox: option<
      (option<TableUtils.multipleSelectRows> => option<TableUtils.multipleSelectRows>) => unit,
    >,
    ~isFrozen: bool=?,
    ~lastHeadingClass: string=?,
    ~fixLastCol: bool=?,
    ~headerCustomBgColor: string=?,
    ~filterRow: option<filterRow>,
    ~customizeColumnNewTheme: TableUtils.customiseColumnConfig=?,
    ~tableHeadingTextClass: string=?,
  ) => React.element
}
module TableHeadingRow: {
  @react.component
  let make: (
    ~headingArray: Js.Array2.t<header>,
    ~isHighchartLegend: bool,
    ~frozenUpto: int,
    ~heightHeadingClass: string,
    ~tableheadingClass: string,
    ~sortedObj: option<TableUtils.sortedObject>,
    ~setSortedObj: option<('a => option<sortedObject>) => unit>,
    ~filterObj: option<array<filterObject>>,
    ~fixedWidthClass: string,
    ~setFilterObj: option<(array<filterObject> => Js.Array2.t<filterObject>) => unit>,
    ~headingCenter: bool,
    ~filterIcon: React.element=?,
    ~filterDropdownClass: string=?,
    ~selectAllCheckBox: option<TableUtils.multipleSelectRows>,
    ~setSelectAllCheckBox: option<
      (option<TableUtils.multipleSelectRows> => option<TableUtils.multipleSelectRows>) => unit,
    >,
    ~isFrozen: bool=?,
    ~lastHeadingClass: string=?,
    ~fixLastCol: bool=?,
    ~headerCustomBgColor: string=?,
    ~filterDropdownMaxHeight: string=?,
    ~columnFilterRow: option<Js.Array2.t<filterRow>>,
    ~customizeColumnNewTheme: TableUtils.customiseColumnConfig=?,
    ~tableHeadingTextClass: string=?,
  ) => React.element
}
@react.component
let make: (
  ~title: string=?,
  ~heading: Js.Array2.t<header>=?,
  ~rows: array<array<cell>>,
  ~offset: int=?,
  ~onRowClick: int => unit=?,
  ~onRowDoubleClick: int => unit=?,
  ~onRowClickPresent: bool=?,
  ~fullWidth: bool=?,
  ~removeVerticalLines: bool=?,
  ~removeHorizontalLines: bool=?,
  ~evenVertivalLines: bool=?,
  ~showScrollBar: bool=?,
  ~setSortedObj: ('a => option<sortedObject>) => unit=?,
  ~sortedObj: TableUtils.sortedObject=?,
  ~setFilterObj: (array<filterObject> => Js.Array2.t<filterObject>) => unit=?,
  ~filterObj: array<filterObject>=?,
  ~columnFilterRow: Js.Array2.t<filterRow>=?,
  ~tableheadingClass: string=?,
  ~tableBorderClass: string=?,
  ~tableDataBorderClass: string=?,
  ~collapseTableRow: bool=?,
  ~getRowDetails: Js.Nullable.t<'b> => React.element=?,
  ~actualData: Js.Array2.t<Js.Nullable.t<'b>>=?,
  ~onExpandClickData: 'onExpandClickData=?,
  ~onMouseEnter: int => unit=?,
  ~onMouseLeave: int => unit=?,
  ~highlightText: Js.String.t=?,
  ~heightHeadingClass: string=?,
  ~frozenUpto: int=?,
  ~clearFormatting: bool=?,
  ~rowHeightClass: string=?,
  ~isMinHeightRequired: bool=?,
  ~rowCustomClass: string=?,
  ~enableEqualWidthCol: bool=?,
  ~isHighchartLegend: bool=?,
  ~headingCenter: bool=?,
  ~filterIcon: React.element=?,
  ~filterDropdownClass: string=?,
  ~showHeading: bool=?,
  ~maxTableHeight: string=?,
  ~labelMargin: string=?,
  ~customFilterRowStyle: string=?,
  ~selectAllCheckBox: multipleSelectRows=?,
  ~setSelectAllCheckBox: (option<multipleSelectRows> => option<multipleSelectRows>) => unit=?,
  ~isEllipsisTextRelative: bool=?,
  ~customMoneyStyle: string=?,
  ~ellipseClass: string=?,
  ~selectedRowColor: string=?,
  ~lastHeadingClass: string=?,
  ~showCheckbox: bool=?,
  ~lastColClass: string=?,
  ~fixLastCol: bool=?,
  ~headerCustomBgColor: string=?,
  ~alignCellContent: string=?,
  ~minTableHeightClass: string=?,
  ~filterDropdownMaxHeight: string=?,
  ~customizeColumnNewTheme: TableUtils.customiseColumnConfig=?,
  ~customCellColor: string=?,
  ~customBorderClass: string=?,
  ~showborderColor: bool=?,
  ~tableHeadingTextClass: string=?,
) => React.element
