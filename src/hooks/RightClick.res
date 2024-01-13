external ffToWebDom: Js.Nullable.t<Dom.element> => Js.Nullable.t<Webapi.Dom.Element.t> = "%identity"

let useRightClick = (ref: React.ref<Js.Nullable.t<Dom.element>>, callback) => {
  React.useEffect0(() => {
    switch ffToWebDom(ref.current)->Js.Nullable.toOption {
    | Some(ele) =>
      ele->Webapi.Dom.Element.addEventListener("contextmenu", ev => {
        Webapi.Dom.Event.preventDefault(ev)
        callback()
      })
      Some(
        () =>
          ele->Webapi.Dom.Element.removeEventListener("contextmenu", ev =>
            Webapi.Dom.Event.preventDefault(ev)
          ),
      )
    | None => None
    }
  })
}
