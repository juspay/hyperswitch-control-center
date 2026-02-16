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

@module("papaparse")
external unparse: {"fields": array<string>, "data": array<array<string>>} => string = "unparse"

let downloadOld = (~fileName, ~content) => {
  download(~fileName, ~content, ~fileType="text/plain")
}

let getJsonString = json => {
  switch json->JSON.Classify.classify {
  | String(s) => s
  | Number(f) => f->Float.toString
  | Bool(b) => b ? "true" : "false"
  | _ => json == JSON.Encode.null ? "" : JSON.stringify(json)
  }
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
      dict->Dict.get(key)->Option.mapOr("", getJsonString)
    })
  })

  unparse({"fields": fields, "data": data})
}
