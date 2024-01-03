type initialFilters<'t> = {
  field: FormRenderer.fieldInfoType,
  localFilter: option<(Js.Array.t<Js.Nullable.t<'t>>, Js.Json.t) => Js.Array.t<Js.Nullable.t<'t>>>,
}
type optionType<'t> = {
  urlKey: string,
  field: FormRenderer.fieldInfoType,
  parser: Js.Json.t => Js.Json.t,
  localFilter: option<(Js.Array.t<Js.Nullable.t<'t>>, Js.Json.t) => Js.Array.t<Js.Nullable.t<'t>>>,
}
let getDefaultEntityOptionType = (): optionType<'t> => {
  urlKey: "",
  field: FormRenderer.makeFieldInfo(~name="", ()),
  parser: json => json,
  localFilter: None,
}

type summary = {totalCount: int, count: int}

type entityType<'colType, 't> = {
  uri: string,
  getObjects: Js.Json.t => array<'t>,
  defaultColumns: array<'colType>,
  allColumns: option<array<'colType>>,
  getHeading: 'colType => Table.header,
  getCell: ('t, 'colType) => Table.cell,
  dataKey: string,
  summaryKey: string,
  getSummary: Js.Json.t => summary,
  getShowLink: option<'t => string>,
  defaultFilters: Js.Json.t,
  headers: Js.Dict.t<string>,
  initialFilters: array<initialFilters<'t>>,
  options: array<optionType<'t>>,
  getDetailsUri: string => string,
  getNewUrl: Js.Json.t => string,
  getSyncUrl: string => option<string>,
  detailsPageLayout: (Js.Json.t, string) => React.element,
  searchFields: array<FormRenderer.fieldInfoType>,
  searchUrl: string,
  searchKeyList: array<string>,
  optionalSearchFieldsList: array<string>,
  requiredSearchFieldsList: array<string>,
  detailsKey: string,
  popupFilterFields: array<optionType<'t>>,
  dateRangeFilterDict: Js.Dict.t<Js.Json.t>,
  searchValueDict: option<Js.Dict.t<string>>,
  filterCheck: ('t, Js.Array2.t<string>) => bool,
  filterForRow: (option<Js.Array2.t<Js.Nullable.t<'t>>>, int) => TableUtils.filterObject,
}

let emptyObj = {
  let dict = Dict.make()
  Dict.set(dict, "offset", Js.Json.number(0.0))
  Js.Json.object_(dict)
}

let defaultGetSummary = (json, totalCountKey) => {
  switch json->Js.Json.decodeObject {
  | Some(dict) => {
      let summary = {
        totalCount: LogicUtils.getInt(dict, totalCountKey, 0),
        count: LogicUtils.getInt(dict, "count", 0),
      }
      if summary.totalCount < summary.count {
        {totalCount: summary.count, count: summary.count}
      } else {
        summary
      }
    }

  | None => {totalCount: 0, count: 0}
  }
}

let makeEntity = (
  ~uri,
  ~getObjects,
  ~defaultColumns,
  ~allColumns=?,
  ~getHeading,
  ~getCell,
  ~dataKey="list",
  ~summaryKey="summary",
  ~totalCountKey="totalCount",
  ~getSummary=json => defaultGetSummary(json, totalCountKey),
  ~detailsKey="payload",
  ~getShowLink=?,
  ~getNewUrl=_ => "",
  ~defaultFilters=?,
  ~initialFilters=[],
  ~options=[],
  ~getDetailsUri=_ => "",
  ~headers=Dict.make(),
  ~getSyncUrl=_ => None,
  ~detailsPageLayout=(_, _) => React.null,
  ~searchFields=[],
  ~searchUrl="",
  ~searchKeyList=[],
  ~optionalSearchFieldsList=[],
  ~requiredSearchFieldsList=[],
  ~popupFilterFields=[],
  ~dateRangeFilterDict=Dict.make(),
  ~searchValueDict=?,
  ~filterCheck=(_, _) => false,
  ~filterForRow=(_, _): TableUtils.filterObject => {key: "", options: [], selected: []},
  (),
) => {
  {
    uri,
    getObjects,
    defaultColumns,
    allColumns,
    getHeading,
    getCell,
    dataKey,
    summaryKey,
    getSummary,
    detailsKey,
    getShowLink,
    defaultFilters: switch defaultFilters {
    | Some(f) => f
    | None => emptyObj
    },
    searchValueDict,
    initialFilters,
    options,
    getDetailsUri,
    headers,
    getNewUrl,
    getSyncUrl,
    detailsPageLayout,
    searchFields,
    searchUrl,
    searchKeyList,
    optionalSearchFieldsList,
    requiredSearchFieldsList,
    popupFilterFields,
    dateRangeFilterDict,
    filterCheck,
    filterForRow,
  }
}
