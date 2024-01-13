type blobInstanceType
@new
external blob: (array<'a>, {"type": string}) => blobInstanceType = "Blob"
@val @scope(("window", "URL"))
external createObjectURL: (. blobInstanceType) => string = "createObjectURL"
@send
external clickElement: Dom.element => unit = "click"

let download = (~fileName, ~content, ~fileType) => {
  let blobInstance = blob([content], {"type": fileType})
  let url = createObjectURL(. blobInstance)
  let a = Webapi.Dom.document->Webapi.Dom.Document.createElement("a")
  a->Webapi.Dom.Element.setAttribute("href", url)
  a->Webapi.Dom.Element.setAttribute("download", fileName)
  a->clickElement
}
type imageType = [#svg | #png | #jpeg | #jpg]

let downloadOld = (~fileName, ~content) => {
  download(~fileName, ~content, ~fileType="text/plain")
}
