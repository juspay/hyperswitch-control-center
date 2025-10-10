let regex: string => RescriptCore.RegExp.t
let highlightedText: (Js.String.t, string) => React.element
type labelColor = TableUtils.labelColor =
  | LabelGreen
  | LabelRed
  | LabelBlue
  | LabelGray
  | LabelOrange
  | LabelYellow
  | LabelLightGray
  | LabelPurple
type filterDataType = TableUtils.filterDataType = Float(float, float) | String | DateTime
type disableField = TableUtils.disableField = {key: string, values: array<string>}
type customiseColumnConfig = TableUtils.customiseColumnConfig = {
  showDropDown: bool,
  customizeColumnUi: React.element,
}
type selectAllSubmitActions = TableUtils.selectAllSubmitActions = {
  btnText: string,
  showMultiSelectCheckBox: bool,
  onClick: array<RescriptCore.JSON.t> => unit,
  disableParam: disableField,
}
type hideItem = TableUtils.hideItem = {key: string, value: string}
external jsonToStr: RescriptCore.JSON.t => string = "%identity"
type textAlign = TableUtils.textAlign = Left | Right
type fontBold = bool
type labelMargin = string
type sortOrder = TableUtils.sortOrder = INC | DEC | NONE
type sortedObject = TableUtils.sortedObject = {key: string, order: sortOrder}
type multipleSelectRows = TableUtils.multipleSelectRows = ALL | PARTIAL
type filterObject = TableUtils.filterObject = {
  key: string,
  options: array<string>,
  selected: array<string>,
}
let getSortOrderString: sortOrder => string
type label = TableUtils.label = {title: string, color: labelColor, showIcon?: bool}
type currency = string
type filterRow = TableUtils.filterRow =
  | DropDownFilter(string, array<RescriptCore.JSON.t>)
  | TextFilter(string)
  | Range(string, float, float)
type cell = TableUtils.cell =
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
) => header
let getCell: string => cell
module ProgressCell = TableUtils.ProgressCell
let getTextAlignmentClass: textAlign => string
module BaseComponentMethod = TableUtils.BaseComponentMethod
module LabelCell = TableUtils.LabelCell
module NewLabelCell = TableUtils.NewLabelCell
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
module NewTableCell = TableUtils.NewTableCell
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
    ~customSeparationArray: array<(int, int)>=?,
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
    ~highlightEnabledFieldsArray: array<int>,
    ~tableDataBorderClass: string=?,
    ~collapseTableRow: bool=?,
    ~expandedRow: unit => React.element,
    ~onMouseEnter: option<int => unit>,
    ~onMouseLeave: option<int => unit>,
    ~highlightText: string,
    ~clearFormatting: bool=?,
    ~rowHeightClass: string=?,
    ~rowCustomClass: string=?,
    ~fixedWidthClass: string,
    ~isHighchartLegend: bool=?,
    ~labelMargin: TableUtils.labelMargin=?,
    ~isEllipsisTextRelative: bool=?,
    ~customMoneyStyle: string=?,
    ~ellipseClass: string=?,
    ~selectedRowColor: string=?,
    ~lastColClass: string=?,
    ~fixLastCol: bool=?,
    ~alignCellContent: string=?,
    ~customCellColor: string=?,
    ~highlightSelectedRow: bool=?,
    ~selectedIndex: int,
    ~setSelectedIndex: ('a => int) => unit,
    ~areLastCellsRounded: bool=?,
    ~customSeparationArray: array<(int, int)>=?,
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
    ~setFilterObj: option<(array<filterObject> => array<filterObject>) => unit>,
    ~headingCenter: bool,
    ~filterIcon: React.element=?,
    ~filterDropdownClass: string=?,
    ~filterDropdownMaxHeight: string=?,
    ~selectAllCheckBox: option<multipleSelectRows>,
    ~setSelectAllCheckBox: option<('c => option<multipleSelectRows>) => unit>,
    ~isFrozen: bool=?,
    ~lastHeadingClass: string=?,
    ~fixLastCol: bool=?,
    ~headerCustomBgColor: string=?,
    ~filterRow: option<filterRow>,
    ~customizeColumnNewTheme: customiseColumnConfig=?,
    ~tableHeadingTextClass: string=?,
  ) => React.element
}
module TableHeadingRow: {
  @react.component
  let make: (
    ~headingArray: array<header>,
    ~isHighchartLegend: bool,
    ~frozenUpto: int,
    ~heightHeadingClass: string,
    ~tableheadingClass: string,
    ~sortedObj: option<TableUtils.sortedObject>,
    ~setSortedObj: option<('a => option<sortedObject>) => unit>,
    ~filterObj: option<array<filterObject>>,
    ~fixedWidthClass: string,
    ~setFilterObj: option<(array<filterObject> => array<filterObject>) => unit>,
    ~headingCenter: bool,
    ~filterIcon: React.element=?,
    ~filterDropdownClass: string=?,
    ~selectAllCheckBox: option<multipleSelectRows>,
    ~setSelectAllCheckBox: option<('b => option<multipleSelectRows>) => unit>,
    ~isFrozen: bool=?,
    ~lastHeadingClass: string=?,
    ~fixLastCol: bool=?,
    ~headerCustomBgColor: string=?,
    ~filterDropdownMaxHeight: string=?,
    ~columnFilterRow: option<array<filterRow>>,
    ~customizeColumnNewTheme: customiseColumnConfig=?,
    ~tableHeadingTextClass: string=?,
  ) => React.element
}
@react.component
let make: (
  ~title: string=?,
  ~heading: array<header>=?,
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
  ~setFilterObj: (array<filterObject> => array<filterObject>) => unit=?,
  ~filterObj: array<filterObject>=?,
  ~columnFilterRow: array<filterRow>=?,
  ~tableheadingClass: string=?,
  ~tableBorderClass: string=?,
  ~tableDataBorderClass: string=?,
  ~collapseTableRow: bool=?,
  ~getRowDetails: RescriptCore.Nullable.t<'b> => React.element=?,
  ~actualData: array<RescriptCore.Nullable.t<'b>>=?,
  ~onExpandClickData: 'c=?,
  ~onMouseEnter: int => unit=?,
  ~onMouseLeave: int => unit=?,
  ~highlightText: string=?,
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
  ~labelMargin: TableUtils.labelMargin=?,
  ~customFilterRowStyle: string=?,
  ~selectAllCheckBox: multipleSelectRows=?,
  ~setSelectAllCheckBox: ('d => option<multipleSelectRows>) => unit=?,
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
  ~customizeColumnNewTheme: customiseColumnConfig=?,
  ~customCellColor: string=?,
  ~customBorderClass: string=?,
  ~showborderColor: bool=?,
  ~tableHeadingTextClass: string=?,
  ~nonFrozenTableParentClass: string=?,
  ~showAutoScroll: bool=?,
  ~showVerticalScroll: bool=?,
  ~showPagination: bool=?,
  ~highlightSelectedRow: bool=?,
  ~freezeFirstColumn: bool=?,
  ~customSeparation: array<(int, int)>=?,
) => React.element
