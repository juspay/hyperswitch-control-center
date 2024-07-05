@react.component
let make = (~url) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (redirectToken, setRedirecToken) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (iframeLoaded, setIframeLoaded) = React.useState(_ => false)
  let mainElement = DOMUtils.document->DOMUtils.getElementById("recon-module")

  let getReconToken = async () => {
    try {
      let url = getURL(~entityName=RECON, ~reconType=#TOKEN, ~methodType=Get, ())
      let res = await fetchDetails(url)
      let token = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("token", "")
      setRedirecToken(_ => token)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect1(() => {
    if redirectToken->isNonEmptyString && iframeLoaded {
      let tokenDict = [("token", redirectToken->JSON.Encode.string)]->Dict.fromArray
      let dict =
        [
          ("eventType", "AuthenticationDetails"->JSON.Encode.string),
          ("payload", tokenDict->JSON.Encode.object),
        ]->Dict.fromArray
      mainElement->IframeUtils.iframePostMessage(dict)
    } else {
      getReconToken()->ignore
    }
    None
  }, [iframeLoaded])

  <PageLoaderWrapper screenState>
    {if redirectToken->isNonEmptyString {
      <div className="h-85-vh overflow-scroll">
        <iframe
          onLoad={_ev => {
            setIframeLoaded(_ => true)
          }}
          id="recon-module"
          className="h-full w-full"
          src={`http://localhost:9011/${url}`}
          height="100%"
          width="100%"
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
