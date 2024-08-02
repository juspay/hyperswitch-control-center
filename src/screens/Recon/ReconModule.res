@react.component
let make = (~urlList) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (redirectToken, setRedirectToken) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (iframeLoaded, setIframeLoaded) = React.useState(_ => false)
  let iframeRef = React.useRef(Js.Nullable.null)

  let getReconToken = async () => {
    try {
      let url = getURL(~entityName=RECON, ~reconType=#TOKEN, ~methodType=Get)
      let res = await fetchDetails(url)
      let token = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("token", "")
      setRedirectToken(_ => token)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  let redirectUrl = switch urlList {
  | list{"upload-files"}
  | list{"run-recon"}
  | list{"reports"}
  | list{"config-settings"}
  | list{"file-processor"} =>
    urlList->List.toArray->Array.joinWithUnsafe("/")
  | list{"recon-analytics"} => "analytics"
  | _ => ""
  }

  React.useEffect(() => {
    getReconToken()->ignore
    None
  }, (iframeLoaded, redirectUrl))

  <>
    {
      switch iframeRef.current->Js.Nullable.toOption {
      | Some(iframeEl) => {
          let tokenDict = [("token", redirectToken->JSON.Encode.string)]->Dict.fromArray
          let dict =
            [
              ("eventType", "AuthenticationDetails"->JSON.Encode.string),
              ("payload", tokenDict->JSON.Encode.object),
            ]->Dict.fromArray
          iframeEl->IframeUtils.iframePostMessage(dict)
        }

      | None => ()
      }
      <PageLoaderWrapper screenState>
        {if redirectToken->isNonEmptyString {
          <div className="h-85-vh overflow-scroll">
            <iframe
              onLoad={_ev => {
                setIframeLoaded(_ => true)
              }}
              id="recon-module"
              className="h-full w-full"
              src={`${Window.env.reconIframeUrl->Option.getOr("")}/${redirectUrl}`}
              height="100%"
              width="100%"
              ref={iframeRef->ReactDOM.Ref.domRef}
            />
          </div>
        } else {
          <div
            className={`bg-white dark:bg-jp-gray-lightgray_background border-2 rounded dark:border-jp-gray-850 grid grid-cols-1 md:gap-5 p-2 md:p-8 h-2/3 items-center`}>
            <div className={`flex flex-col items-center w-4/6 md:w-2/6 justify-self-center gap-1`}>
              <div
                className={`text-center text-semibold text-s text-grey-700 opacity-60 dark:text-white`}>
                {"If you encounter any errors, please refresh the page to resolve the issue."->React.string}
              </div>
              <Button
                text="Refresh recon tab"
                buttonType={Primary}
                customButtonStyle="w-2/3 rounded-sm !bg-jp-blue-button_blue border border-jp-blue-border_blue mt-4"
                buttonSize={Small}
                buttonState={Normal}
                onClick={_v => {
                  getReconToken()->ignore
                }}
              />
            </div>
          </div>
        }}
      </PageLoaderWrapper>
    }
  </>
}
