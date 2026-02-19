type blobInstanceType
@new
external blob: (array<'a>, {"type": string}) => blobInstanceType = "Blob"
@val @scope(("window", "URL"))
external createObjectURL: blobInstanceType => string = "createObjectURL"
@send
external clickElement: Dom.element => unit = "click"

let download = (~fileName, ~content, ~fileType) => {
  let blobInstance = blob([content], {"type": fileType})
  let url = createObjectURL(blobInstance)
  let a = Webapi.Dom.document->Webapi.Dom.Document.createElement("a")
  a->Webapi.Dom.Element.setAttribute("href", url)
  a->Webapi.Dom.Element.setAttribute("download", fileName)
  a->clickElement
}

let downloadOld = (~fileName, ~content) => {
  download(~fileName, ~content, ~fileType="text/plain")
}

let convertArrayToCSVWithCustomHeaders = (
  arr: array<JSON.t>,
  headers: array<string>,
  customHeaders: array<string>,
) => {
  open LogicUtils

  let fields = customHeaders->Array.length > 0 ? customHeaders : headers

  let data = arr->Array.map(item => {
    let dict = item->getDictFromJsonObject
    headers->Array.map(key => {
      dict->getString(key, "")
    })
  })

  PapaParse.unparse({"fields": fields, "data": data})
}

let downloadTableAsCsv = (
  ~csvHeaders: array<(string, string)>,
  ~rawData: array<JSON.t>,
  ~tableItemToObjMapper: Dict.t<JSON.t> => 'entity,
  ~itemToCSVMapping: 'entity => JSON.t,
  ~fileName: string,
  ~toast: (~message: string, ~toastType: ToastState.toastType) => unit,
) => {
  open LogicUtils
  try {
    let (csvHeadersKeys, csvCustomHeaders) = csvHeaders->Array.reduce(([], []), (
      acc,
      (key, title),
    ) => {
      let (keys, titles) = acc
      (keys->Array.concat([key]), titles->Array.concat([title]))
    })

    let data = rawData->Array.map(item => {
      item->getDictFromJsonObject->tableItemToObjMapper->itemToCSVMapping
    })

    let csvContent = convertArrayToCSVWithCustomHeaders(data, csvHeadersKeys, csvCustomHeaders)
    download(~fileName, ~content=csvContent, ~fileType="text/csv")
  } catch {
  | _ => toast(~message="Failed to download CSV", ~toastType=ToastState.ToastError)
  }
}
