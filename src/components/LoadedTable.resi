type sortTyp = ASC | DSC
type sortOb = {sortKey: string, sortType: sortTyp}
type checkBoxProps = {
  showCheckBox: bool,
  selectedData: Js.Array2.t<Js.Json.t>,
  setSelectedData: (Js.Array2.t<Js.Json.t> => Js.Array2.t<Js.Json.t>) => unit,
}
let checkBoxPropDefaultVal: checkBoxProps
let sortAtom: Recoil.recoilAtom<Js.Dict.t<sortOb>>
let backgroundClass: string
let useSortedObj: (
  string,
  option<Table.sortedObject>,
) => (
  option<Table.sortedObject>,
  (option<Table.sortedObject> => option<Table.sortedObject>) => unit,
)
// let sortArray: (Js.Array2.t<'a>, RescriptCoreFuture.Dict.key, Table.sortOrder) => Js.Array2.t<'a>
type pageDetails = {offset: int, resultsPerPage: int}
let table_pageDetails: Recoil.recoilAtom<Js.Dict.t<pageDetails>>
@react.component
let make: (
  ~visibleColumns: Js.Array2.t<'colType>=?,
  ~defaultSort: Table.sortedObject=?,
  ~title: Js.Dict.key,
  ~titleSize: NewThemeUtils.headingSize=?,
  ~description: Js.String2.t=?,
  ~tableActions: React.element=?,
  ~isTableActionBesideFilters: bool=?,
  ~hideFilterTopPortals: bool=?,
  ~rightTitleElement: React.element=?,
  ~clearFormattedDataButton: React.element=?,
  ~bottomActions: React.element=?,
  ~showSerialNumber: bool=?,
  ~actualData: Js.Array2.t<Js.Nullable.t<'t>>,
  ~totalResults: int,
  ~resultsPerPage: int,
  ~offset: int,
  ~setOffset: ('b => int) => unit,
  ~handleRefetch: unit => unit=?,
  ~entity: EntityType.entityType<'colType, 't>,
  ~onEntityClick: 't => unit=?,
  ~onEntityDoubleClick: 't => unit=?,
  ~onExpandClickData: 'onExpandClickData=?,
  ~currrentFetchCount: int,
  ~filters: React.element=?,
  ~showFilterBorder: bool=?,
  ~headBottomMargin: string=?,
  ~removeVerticalLines: bool=?,
  ~removeHorizontalLines: bool=?,
  ~evenVertivalLines: bool=?,
  ~showPagination: bool=?,
  ~downloadCsv: React.element=?,
  ~ignoreUrlUpdate: bool=?,
  ~hideTitle: bool=?,
  ~ignoreHeaderBg: bool=?,
  ~tableDataLoading: bool=?,
  ~dataLoading: bool=?,
  ~advancedSearchComponent: React.element=?,
  ~setData: ('c => option<Js.Array2.t<Js.Nullable.t<'t>>>) => unit=?,
  ~setSummary: ('d => EntityType.summary) => unit=?,
  ~customGetObjects: Js.Json.t => array<'a>=?,
  ~dataNotFoundComponent: React.element=?,
  ~renderCard: (~index: int, ~item: 't, ~onRowClick: React.callback<int, unit>) => React.element=?,
  ~tableLocalFilter: bool=?,
  ~tableheadingClass: string=?,
  ~tableBorderClass: string=?,
  ~tableDataBorderClass: string=?,
  ~collapseTableRow: bool=?,
  ~getRowDetails: Js.Nullable.t<'t> => React.element=?,
  ~onMouseEnter: 't => unit=?,
  ~onMouseLeave: 't => unit=?,
  ~frozenUpto: int=?,
  ~heightHeadingClass: string=?,
  ~highlightText: Js.String.t=?,
  ~enableEqualWidthCol: bool=?,
  ~clearFormatting: bool=?,
  ~rowHeightClass: string=?,
  ~allowNullableRows: bool=?,
  ~titleTooltip: bool=?,
  ~isAnalyticsModule: bool=?,
  ~rowCustomClass: string=?,
  ~isHighchartLegend: bool=?,
  ~filterObj: array<Table.filterObject>=?,
  ~setFilterObj: (array<Table.filterObject> => Js.Array2.t<Table.filterObject>) => unit=?,
  ~headingCenter: bool=?,
  ~filterIcon: React.element=?,
  ~filterDropdownClass: string=?,
  ~maxTableHeight: string=?,
  ~showTableOnMobileView: bool=?,
  ~labelMargin: string=?,
  ~customFilterRowStyle: string=?,
  ~noDataMsg: string=?,
  ~tableActionBorder: string=?,
  ~isEllipsisTextRelative: bool=?,
  ~customMoneyStyle: string=?,
  ~ellipseClass: string=?,
  ~checkBoxProps: checkBoxProps=?,
  ~selectedRowColor: string=?,
  ~paginationClass: string=?,
  ~lastHeadingClass: string=?,
  ~lastColClass: string=?,
  ~fixLastCol: bool=?,
  ~headerCustomBgColor: string=?,
  ~alignCellContent: string=?,
  ~minTableHeightClass: string=?,
  ~setExtFilteredDataLength: ('f => int) => unit=?,
  ~filterDropdownMaxHeight: string=?,
  ~showResultsPerPageSelector: bool=?,
  ~customCellColor: string=?,
  ~defaultResultsPerPage: bool=?,
  ~noScrollbar: bool=?,
  ~tableDataBackgroundClass: string=?,
  ~customBorderClass: string=?,
  ~showborderColor: bool=?,
  ~tableHeadingTextClass: string=?,
) => React.element
