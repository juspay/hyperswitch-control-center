let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

let setData = (
  offset,
  setOffset,
  total,
  data,
  setTotalCount,
  setTableData,
  setScreenState,
  mapper,
) => {
  let arr = Array.make(~length=offset, Dict.make())
  if total <= offset {
    setOffset(_ => 0)
  }

  if total > 0 {
    let dataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
    let orderData = arr->Array.concat(dataDictArr)->Array.map(mapper)
    let list = orderData->Array.map(Nullable.make)

    setTotalCount(_ => total)
    setTableData(_ => list)
    setScreenState(_ => PageLoaderWrapper.Success)
  } else {
    setScreenState(_ => PageLoaderWrapper.Custom)
  }
}

let getData = async (
  ~updateDetails: (
    string,
    JSON.t,
    Fetch.requestMethod,
    ~bodyFormData: Fetch.formData=?,
    ~headers: Dict.t<'a>=?,
    ~contentType: AuthHooks.contentType=?,
    unit,
  ) => promise<JSON.t>,
  ~setTableData,
  ~setScreenState,
  ~setOffset,
  ~setTotalCount,
  ~offset,
  ~query,
  ~path,
  ~mapper,
) => {
  open LogicUtils
  setScreenState(_ => PageLoaderWrapper.Loading)
  let filters = Dict.make()
  filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
  filters->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)
  filters->Dict.set("query", query->JSON.Encode.string)

  try {
    let url = APIUtils.getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ~id=Some(path), ())
    let res = await updateDetails(url, filters->JSON.Encode.object, Fetch.Post, ())
    let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("hits", [])
    let total = res->getDictFromJsonObject->getInt("count", 0)

    setData(offset, setOffset, total, data, setTotalCount, setTableData, setScreenState, mapper)
  } catch {
  | Exn.Error(_) => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
  }
}
