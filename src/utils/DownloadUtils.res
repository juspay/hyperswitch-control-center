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
type imageType = [#svg | #png | #jpeg | #jpg]

let downloadOld = (~fileName, ~content) => {
  download(~fileName, ~content, ~fileType="text/plain")
}

let convertArrayToCSVWithCustomHeaders = (arr: array<JSON.t>, headers: array<string>) => {
  open LogicUtils
  
  if arr->Array.length === 0 {
    headers->Array.joinWith(",") ++ "\n"
  } else {
    let rows =
      arr
      ->Array.map(item => {
        let dict = item->getDictFromJsonObject
        headers
        ->Array.map(key => {
          let value = switch dict->Dict.get(key) {
          | Some(json) =>
            let str = switch json->JSON.Decode.string {
            | Some(s) => s
            | None =>
              switch json->JSON.Decode.float {
              | Some(f) => f->Float.toString
              | None =>
                switch json->JSON.Decode.bool {
                | Some(b) => b ? "true" : "false"
                | None =>
                  if json == JSON.Encode.null {
                    ""
                  } else {
                    JSON.stringify(json)
                  }
                }
              }
            }
            str
          | None => ""
          }
          
          if value->String.includes(",") || value->String.includes("\"") || value->String.includes("\n") {
            let escapedValue = stringReplaceAll(value, "\"", "\"\"")
            `"${escapedValue}"`
          } else {
            value
          }
        })
        ->Array.joinWith(",")
      })
      ->Array.joinWith("\n")

    headers->Array.joinWith(",") ++ "\n" ++ rows
  }
}
