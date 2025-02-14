let tableBorderClass = "border-collapse border border-gray-200/30 border-solid border-2 dark:border-gray-800/30"

let useGetData = () => {
  open LogicUtils
  let getURL = APIUtils.useGetURL()
  async (
    ~updateDetails: (
      string,
      JSON.t,
      Fetch.requestMethod,
      ~bodyFormData: Fetch.formData=?,
      ~headers: Dict.t<'a>=?,
      ~contentType: AuthHooks.contentType=?,
    ) => promise<JSON.t>,
    ~offset,
    ~query,
    ~path,
  ) => {
    let body = query->GlobalSearchBarUtils.generateQuery
    body->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
    body->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)

    try {
      let url = getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ~id=Some(path))
      let res = await updateDetails(url, body->JSON.Encode.object, Post)
      let data = res->LogicUtils.getDictFromJsonObject->LogicUtils.getArrayFromDict("hits", [])
      let total = res->getDictFromJsonObject->getInt("count", 0)

      (data, total)
    } catch {
    | Exn.Error(_) => Exn.raiseError("Something went wrong!")
    }
  }
}
