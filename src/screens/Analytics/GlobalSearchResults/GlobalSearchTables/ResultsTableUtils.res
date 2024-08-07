let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

let useGetData = () => {
  open LogicUtils
  let body = Dict.make()
  let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
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
    body->Dict.set("offset", offset->Int.toFloat->JSON.Encode.float)
    body->Dict.set("count", 10->Int.toFloat->JSON.Encode.float)
    body->Dict.set("query", query->JSON.Encode.string)

    if !(query->CommonAuthUtils.isValidEmail) {
      let filters = [("customer_email", [query->JSON.Encode.string]->JSON.Encode.array)]
      body->Dict.set("filters", filters->getJsonFromArrayOfJson)
      body->Dict.set("query", merchantDetailsValue.merchant_id->JSON.Encode.string)
    } else {
      body->Dict.set("query", query->JSON.Encode.string)
    }

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
