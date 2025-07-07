@get external shadowRoot: Dom.element => Nullable.t<Dom.element> = "shadowRoot"

@react.component
let make = (~children, ~styleHref=None) => {
  React.useEffect1(() => {
    let test = DOMUtils.document->DOMUtils.getElementById("shadow-dom-for-application")

    let shadowRoot = switch test->shadowRoot->Nullable.toOption {
    | Some(existingShadowRoot) => existingShadowRoot
    | None => test->DOMUtils.attachShadow({"mode": "open"})
    }

    let newRoot = ReactDOM.Client.createRoot(shadowRoot)

    ReactDOM.Client.Root.render(
      newRoot,
      <>
        {switch styleHref {
        | Some(styleUrl) => <link rel="stylesheet" href={`/ext_libs/${styleUrl}`} />
        | None => React.null
        }}
        {children}
      </>,
    )

    Some(
      () => {
        newRoot->ReactDOM.Client.Root.unmount()
      },
    )
  }, [])

  <div id="shadow-dom-for-application" />
}
