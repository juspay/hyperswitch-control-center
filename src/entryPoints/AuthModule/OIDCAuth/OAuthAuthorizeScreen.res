@react.component
let make = () => {
  open APIUtils
  open Typography

  let url = RescriptReactRouter.useUrl()
  let getURL = useGetURL()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (errorMessage, setErrorMessage) = React.useState(_ => "")

  let redirectToOIDCAuthorize = () => {
    let queryString = url.search
    if queryString->String.length === 0 {
      let errorMsg = "Missing authorization parameters"
      setErrorMessage(_ => errorMsg)
      setScreenState(_ => Error(errorMsg))
    } else {
      let apiUrl = getURL(~entityName=V1(OIDC_AUTHORIZE), ~methodType=Get)
      Window.Location.replace(`${apiUrl}?${queryString}`)
    }
  }

  React.useEffect(() => {
    redirectToOIDCAuthorize()
    None
  }, [])

  <div className="h-screen w-screen flex flex-col items-center justify-center bg-white">
    {switch screenState {
    | Loading =>
      <>
        <Loader />
        <div className={`mt-4 text-nd_gray-500 ${body.md.medium}`}>
          {"Processing authorization request..."->React.string}
        </div>
      </>
    | Error(_) =>
      <div className="flex flex-col items-center gap-4 p-8">
        <Icon name="close-circle" size=48 className="text-red-600" />
        <div className={`${heading.lg.semibold} text-nd_gray-900`}>
          {"Authorization failed"->React.string}
        </div>
        <div className={`text-center max-w-md text-nd_gray-500 ${body.md.medium}`}>
          {errorMessage->React.string}
        </div>
      </div>
    | _ => React.null
    }}
  </div>
}
