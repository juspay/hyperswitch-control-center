let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

let useGetData = () => {
  open LogicUtils
  let filters = Dict.make()

  async (
    ~updateDetails: (
      string,
      JSON.t,
      Fetch.requestMethod,
      ~bodyFormData: Fetch.formData=?,
      ~headers: Dict.t<'a>=?,
      ~contentType: AuthHooks.contentType=?,
      unit,
    ) => promise<JSON.t>,
    ~offset,
    ~query,
    ~path,
  ) => {
    filters->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
    filters->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)
    filters->Dict.set("query", query->JSON.Encode.string)

    try {
      let url = APIUtils.getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ~id=Some(path), ())
      let res = await updateDetails(url, filters->JSON.Encode.object, Fetch.Post, ())
      let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("hits", [])
      let total = res->getDictFromJsonObject->getInt("count", 0)

      (data, total)
    } catch {
    | Exn.Error(_) => Exn.raiseError("Something went wrong!")
    }
  }
}
