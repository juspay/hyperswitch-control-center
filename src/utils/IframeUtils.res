@val external document: 'a = "document"
type window
type parent
@val external window: window = "window"
@val @scope("window") external iframeParent: parent = "parent"
type event = {data: string}
@get
external contentWindow: Dom.element => Dom.element = "contentWindow"

@send external postMessageToParent: (parent, JSON.t, string) => unit = "postMessage"
let handlePostMessage = (~targetOrigin="*", messageArr) => {
  iframeParent->postMessageToParent(messageArr->Dict.fromArray->JSON.Encode.object, targetOrigin)
}

@send external postMessageToChildren: (Dom.element, string, string) => unit = "postMessage"
let sendPostMessage = (element, message, ~targetOrigin="*") => {
  element->postMessageToChildren(message->JSON.Encode.object->JSON.stringify, targetOrigin)
}

let iframePostMessage = (iframeRef: Dom.element, message) => {
  iframeRef
  ->contentWindow
  ->sendPostMessage(message)
}
