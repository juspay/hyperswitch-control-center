open Promise
type lottieFileJson = Loading(Promise.t<JSON.t>) | Loaded(JSON.t)

let selectedTick = "selectedTick.json"
let deselectTick = "deselectTick.json"
let enterCheckBox = "checkbox.json"
let exitCheckBox = "uncheckbox.json"
let enterSearchCross = "enterCross.json"
let exitSearchCross = "exitCross.json"

let lottieDict: Dict.t<lottieFileJson> = Dict.make()

let useLottieJson = lottieFileName => {
  let (lottieJson, setlottieJson) = React.useState(_ => JSON.Encode.null)
  let fetchApi = AuthHooks.useApiFetcher()
  let uriPrefix = LogicUtils.useUrlPrefix()
  let showToast = ToastState.useShowToast()
  let prefix = `${Window.Location.origin}${uriPrefix}`
  React.useEffect(() => {
    switch lottieDict->Dict.get(lottieFileName) {
    | Some(val) =>
      switch val {
      | Loaded(json) => setlottieJson(_ => json)
      | Loading(promiseJson) => promiseJson->thenResolve(json => setlottieJson(_ => json))->ignore
      }
    | None => {
        let fetchLottie =
          fetchApi(
            `${prefix}/lottie-files/${lottieFileName}`,
            ~method_=Get,
            ~xFeatureRoute=false,
            ~forceCookies=false,
          )
          ->then(res => res->Fetch.Response.json)
          ->then(json => {
            setlottieJson(_ => json)
            lottieDict->Dict.set(lottieFileName, Loaded(json))
            json->resolve
          })
          ->catch(_err => {
            showToast(~message="Error!", ~toastType=ToastError)
            JSON.Encode.null->resolve
          })

        lottieDict->Dict.set(lottieFileName, Loading(fetchLottie))
      }
    }
    None
  }, [lottieFileName])
  lottieJson
}
