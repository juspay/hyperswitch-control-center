@react.component
let make = () => {
  open APIUtils
  let url = RescriptReactRouter.useUrl()
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let (hasError, setHasError) = React.useState(_ => false)
  let (errorMessage, setErrorMessage) = React.useState(_ => "")

  let redirectToOIDCAuthorize = () => {
    let queryString = url.search
    if queryString->String.length === 0 {
      let errorMsg = "Missing authorization parameters."
      setErrorMessage(_ => errorMsg)
      setHasError(_ => true)
      showToast(~message="Authorization failed", ~toastType=ToastError)
    } else {
      let apiUrl = getURL(~entityName=V1(OIDC_AUTHORIZE), ~methodType=Get)
      Window.Location.replace(`${apiUrl}?${queryString}`)
    }
  }

  React.useEffect(() => {
    redirectToOIDCAuthorize()
    None
  }, [])

  if hasError {
    <OIDCError errorMessage />
  } else {
    <PageLoaderWrapper screenState={PageLoaderWrapper.Loading} sectionHeight="h-screen">
      React.null
    </PageLoaderWrapper>
  }
}
