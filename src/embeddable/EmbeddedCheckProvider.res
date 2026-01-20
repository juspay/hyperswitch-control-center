type embeddedState = Success | NotInsideIframe | TokenFetchError | Loading

type embeddedContextTye = {setEmbeddedStateToError: unit => unit}

let embeddedProviderContext: embeddedContextTye = {
  setEmbeddedStateToError: () => (),
}

let embeddedContext = React.createContext(embeddedProviderContext)

module Provider = {
  let make = React.Context.provider(embeddedContext)
}

@react.component
let make = (~children) => {
  open Typography
  open LogicUtils
  open EmbeddableGlobalUtils
  open EmbeddedStorageUtils

  let isEmbedded = (): bool => {
    Window.self !== Window.top
  }

  let (componentKey, setComponentKey) = React.useState(_ => "")
  let (embeddedState, setEmbeddedState) = React.useState(_ => Loading)

  let handleAuthMessage = (ev: Dom.event) => {
    setComponentKey(_ => "")
    setEmbeddedState(_ => Loading)
    let objectdata = ev->HandlingEvents.convertToCustomEvent
    switch objectdata.data->JSON.Decode.object {
    | Some(dict) => {
        let tokenFromParent = dict->getOptionString("token")
        let messageType = dict->getString("type", "")

        switch tokenFromParent {
        | Some(tokenStringFromParent) =>
          if messageType->isNonEmptyString {
            if (
              messageType->messageToTypeConversion == AUTH_TOKEN &&
                tokenStringFromParent->isNonEmptyString
            ) {
              LocalStorage.setEmbeddedTokenToStorage(tokenStringFromParent)
              setComponentKey(_ => randomString(~length=10))
              setEmbeddedState(_ => Success)
            }
          }
        | None => ()
        }

        if messageType->messageToTypeConversion == AUTH_ERROR {
          LocalStorage.setEmbeddedTokenToStorage("")
          setEmbeddedState(_ => TokenFetchError)
        }
      }
    | None => ()
    }
  }

  let setEmbeddedStateToError = () => {
    setEmbeddedState(_ => TokenFetchError)
  }

  React.useEffect(() => {
    if !isEmbedded() {
      setEmbeddedState(_ => NotInsideIframe)
      None
    } else {
      Window.addEventListener("message", handleAuthMessage)
      Some(() => Window.removeEventListener("message", handleAuthMessage))
    }
  }, [])

  <Provider value={setEmbeddedStateToError: setEmbeddedStateToError}>
    {switch embeddedState {
    | NotInsideIframe =>
      <div className="h-screen w-screen flex justify-center items-center p-4">
        <div className="max-w-lg w-full rounded-lg shadow-md border border-nd_gray-200 p-8">
          <div className="flex flex-col items-center text-center">
            <div className="mb-6">
              <Icon name="exclamation-circle" size=25 className="text-nd_primary_blue-500" />
            </div>
            <div className={`${heading.md.semibold} text-nd_gray-800 mb-3`}>
              {"Direct Link Not Supported"->React.string}
            </div>
            <div className={`${body.md.regular} text-nd_gray-600 leading-relaxed`}>
              {"Direct access isn't supported for this application. Please open it through the embedded interface in your platform."->React.string}
            </div>
          </div>
        </div>
      </div>
    | Success => <React.Fragment key={componentKey}> children </React.Fragment>
    | Loading =>
      <Icon
        name="spinner"
        size=20
        className="animate-spin"
        parentClass="w-full h-full flex justify-center items-center"
      />
    | TokenFetchError =>
      <div className="h-screen w-screen flex justify-center items-center p-4">
        <div className="max-w-lg w-full rounded-lg shadow-md border border-nd_gray-200 p-8">
          <div className="flex flex-col items-center text-center">
            <div className="mb-6">
              <Icon name="exclamation-circle" size=25 className="text-nd_primary_blue-500" />
            </div>
            <div className={`${heading.md.semibold} text-nd_gray-800 mb-3`}>
              {"Something went wrong"->React.string}
            </div>
          </div>
        </div>
      </div>
    }}
  </Provider>
}
