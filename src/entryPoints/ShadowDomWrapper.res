@get external shadowRoot: Dom.element => Nullable.t<Dom.element> = "shadowRoot"

@react.component
let make = (~styles="") => {
  // Js.log2(screenState, "screenState")
  // let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Success)
  let containerRef = React.useRef(Js.Nullable.null)
  let shadowDomRootRef = React.useRef(Js.Nullable.null)

  React.useEffect1(() => {
    Js.log2("Shadow DOM root created: ", containerRef.current->Js.Nullable.isNullable)
    Js.log2(shadowDomRootRef, "shadowDomRootRef")
    // setScreenState(_ => PageLoaderWrapper.Loading)
    switch containerRef.current->Js.Nullable.toOption {
    | Some(container) =>
      // let shadowRoot = switch container->shadowRoot->Nullable.toOption {
      // | Some(shadorRoot) => shadorRoot
      // | None => container->DOMUtils.attachShadow({"mode": mode})
      // }

      switch shadowDomRootRef.current->Js.Nullable.toOption {
      | Some(existingRoot) => {
          Js.log("some")
          ()
        }
      | None =>
        Js.log("none")
        let shadowRoot = container->DOMUtils.attachShadow({"mode": "open"})
        let newRoot = ReactDOM.Client.createRoot(shadowRoot)
        shadowDomRootRef.current = Js.Nullable.return(newRoot)
        ReactDOM.Client.Root.render(
          newRoot,
          <>
            <link rel="stylesheet" href="/ext_libs/de-routing/style.css" />
            <ReactLibrary.ABC basename={`/${GlobalVars.dashboardPrefix}`} />
          </>,
        )
        // setScreenState(_ => PageLoaderWrapper.Success)

        ()
      }

    // setScreenState(_ => PageLoaderWrapper.Success)
    | None => ()
    }
    None
    // Cleanup function
    // Some(
    //   () => {
    //     switch containerRef.current->Js.Nullable.toOption {
    //     | Some(_) =>
    //       // Container exists, now check for the shadow root
    //       switch shadowDomRootRef.current->Js.Nullable.toOption {
    //       | Some(existingShadowDom) => {
    //           existingShadowDom->ReactDOM.Client.Root.unmount()

    //           // root->Webapi.Dom.Element.setInnerHTML(str)
    //           shadowDomRootRef.current = Js.Nullable.null
    //         }
    //       | None => ()
    //       }
    //     | None => ()
    //     }

    //     switch containerRef.current->Js.Nullable.toOption {
    //     | Some(container) =>
    //       switch container->shadowRoot->Nullable.toOption {
    //       | Some(shadowRootElement) => shadowRootElement->Webapi.Dom.Element.setInnerHTML("")

    //       | None => ()
    //       }
    //     | None => ()
    //     }
    //   },
    // )
  }, [])

  // <PageLoaderWrapper screenState>
  Js.log2(containerRef.current, "containerRef")
  switch containerRef.current {
  | Value(_) =>
    // DOMUtils.appendChild(test)
    "SIMPLE"->React.string
  | Null | Undefined => <div id={"test-shadowdom"} ref={ReactDOM.Ref.domRef(containerRef)} />

  // {Js.log(containerRef)}
  // "SIMPLE"->React.string
  }

  // <div id={"test-shadowdom"} ref={ReactDOM.Ref.domRef(containerRef)} />

  // </PageLoaderWrapper>
}
