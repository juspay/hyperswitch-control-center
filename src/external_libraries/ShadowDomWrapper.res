@react.component
let make = (~children, ~styleHref=None) => {
  open DOMUtils
  let (cssLoaded, setCssLoaded) = React.useState(_ => false)
  React.useEffect(() => {
    let test = DOMUtils.document->getElementById("shadow-dom-for-application")

    let shadowRoot = switch test->shadowRoot->Nullable.toOption {
    | Some(existingShadowRoot) => existingShadowRoot
    | None => test->attachShadow({"mode": "open"})
    }

    switch styleHref {
    | Some(hrefUrl) => {
        let link = DOMUtils.document->createElement("link")
        link->setAttribute("rel", "stylesheet")
        link->setAttribute("href", `/ext_libs/${hrefUrl}`)
        link->setOnload(_ => setCssLoaded(_ => true))
        shadowRoot->appendChildToElement(link)
      }
    | None => setCssLoaded(_ => true)
    }

    let newRoot = ReactDOM.Client.createRoot(shadowRoot)

    ReactDOM.Client.Root.render(newRoot, children)

    Some(() => newRoot->ReactDOM.Client.Root.unmount())
  }, [])

  <div id="shadow-dom-for-application" className={cssLoaded ? "visible" : "hidden"} />
}
