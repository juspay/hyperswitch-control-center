let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

let useGetData = () => {
  open LogicUtils
  let getURL = APIUtils.useGetURL()
  async (
    ~updateDetails: (
      string,
      JSON.t,
      Fetch.requestMethod,
      ~fieldsToIgnore: array<string>=?,
      ~bodyFormData: Fetch.formData=?,
      ~headers: Dict.t<'a>=?,
      ~contentType: AuthHooks.contentType=?,
      ~version: UserInfoTypes.version=?,
    ) => promise<JSON.t>,
    ~offset,
    ~query,
    ~path,
  ) => {
    let body = query->GlobalSearchBarUtils.generateQuery
    body->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
    body->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)

    try {
      let url = getURL(~entityName=V1(GLOBAL_SEARCH), ~methodType=Post, ~id=Some(path))
      let res = await updateDetails(url, body->JSON.Encode.object, Post)
      let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("hits", [])
      let total = res->getDictFromJsonObject->getInt("count", 0)

      (data, total)
    } catch {
    | Exn.Error(_) => Exn.raiseError("Something went wrong!")
    }
  }
}
