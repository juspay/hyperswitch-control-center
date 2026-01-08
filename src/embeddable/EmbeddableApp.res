open DOMUtils
open Window

@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  let contentRef = React.useRef(Js.Nullable.null)
  let (componentKey, setComponentKey) = React.useState(_ => "")

  let measureAndSendDimensions = rootElement => {
    // Get height dimensions - PRIORITIZING SCROLL HEIGHT
    let scrollH = rootElement->scrollHeight
    let clientH = rootElement->clientHeight
    let offsetH = rootElement->offsetHeight

    // Get width dimensions - PRIORITIZING SCROLL WIDTH
    let scrollW = rootElement->scrollWidth
    let clientW = rootElement->clientWidth
    let offsetW = rootElement->offsetWidth

    // Use scroll dimensions as primary, but fall back to max of others if needed
    let finalHeight = if scrollH > 0 {
      scrollH // Prioritize scroll height
    } else {
      Js.Math.max_int(clientH, offsetH) // Fallback
    }

    let finalWidth = if scrollW > 0 {
      scrollW // Prioritize scroll width
    } else {
      Js.Math.max_int(clientW, offsetW) // Fallback
    }

    // Send dimensions message to parent iframe
    IframeUtils.handlePostMessage([
      ("type", JSON.Encode.string("EMBEDDED_COMPONENT_RESIZE")),
      ("height", finalHeight->JSON.Encode.int),
      ("width", finalWidth->JSON.Encode.int),
      ("component", JSON.Encode.string(url.path->urlPath->LogicUtils.getListHead)),
    ])
  }

  React.useEffect(() => {
    let rec checkDomAndMeasure = () => {
      let element = Webapi.Dom.document->Webapi.Dom.Document.querySelector("#embeddable-app")

      switch element {
      | Some(rootElement) => measureAndSendDimensions(rootElement)
      | None => requestAnimationFrame(() => checkDomAndMeasure())->ignore
      }
    }

    checkDomAndMeasure()

    None
  }, [url.path])

  // Monitor for content changes using ResizeObserver
  React.useEffect(() => {
    switch contentRef.current->Js.Nullable.toOption {
    | Some(rootElement) => {
        let observer = createResizeObserver(_ => {
          measureAndSendDimensions(rootElement)
        })

        observer->observeElement(rootElement)

        Some(() => observer->disconnectObserver)
      }
    | None => None
    }
  }, [url.path])

  React.useEffect(() => {
    let handleLoad = () => {
      switch contentRef.current->Js.Nullable.toOption {
      | Some(rootElement) => measureAndSendDimensions(rootElement)
      | None => ()
      }
    }

    addEventListener("load", handleLoad)

    addEventListener("DOMContentLoaded", handleLoad)

    Some(
      () => {
        removeEventListener("load", handleLoad)
        removeEventListener("DOMContentLoaded", handleLoad)
      },
    )
  }, [])

  React.useEffect(() => {
    let handleAuthMessage = (ev: Dom.event) => {
      let objectdata = ev->HandlingEvents.convertToCustomEvent
      switch objectdata.data->JSON.Decode.object {
      | Some(dict) => {
          let messageType = dict->LogicUtils.getString("type", "")
          if messageType->LogicUtils.isNonEmptyString && messageType == "AUTH_TOKEN" {
            let tokenFromParent = dict->LogicUtils.getString("token", "")
            if tokenFromParent->LogicUtils.isNonEmptyString {
              LocalStorage.setItem("EMBEDDABLE_INFO", tokenFromParent)
              setComponentKey(_ => LogicUtils.randomString(~length=10))
            }
          }
        }
      | None => ()
      }
    }

    addEventListener("message", handleAuthMessage)
    Some(() => removeEventListener("message", handleAuthMessage))
  }, [])

  //

  <div id="embeddable-app" ref={ReactDOM.Ref.domRef(contentRef)}>
    <ErrorBoundary key={componentKey}>
      {switch url.path->urlPath {
      | list{"connectors", ..._} => <ConnectorEmbeddedContainer />
      | _ => <> </>
      }}
    </ErrorBoundary>
  </div>
}
