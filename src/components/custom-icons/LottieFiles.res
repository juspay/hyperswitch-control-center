open Promise
type lottieFileJson = Loading(Js.Promise.t<Js.Json.t>) | Loaded(Js.Json.t)

let selectedTick = "selectedTick.json"
let deselectTick = "deselectTick.json"
let enterCheckBox = "checkbox.json"
let exitCheckBox = "uncheckbox.json"
let enterSearchCross = "enterCross.json"
let exitSearchCross = "exitCross.json"

let lottieDict: Js.Dict.t<lottieFileJson> = Dict.make()

let useLottieJson = lottieFileName => {
  let (lottieJson, setlottieJson) = React.useState(_ => Js.Json.null)
  let fetchApi = AuthHooks.useApiFetcher()
  let uriPrefix = LogicUtils.useUrlPrefix()
  let showToast = ToastState.useShowToast()
  let prefix = `${Window.Location.origin}${uriPrefix}`

  React.useEffect1(() => {
    switch lottieDict->Dict.get(lottieFileName) {
    | Some(val) =>
      switch val {
      | Loaded(json) => setlottieJson(_ => json)
      | Loading(promiseJson) => promiseJson->thenResolve(json => setlottieJson(_ => json))->ignore
      }
    | None => {
        let fetchLottie =
          fetchApi(`${prefix}/lottie-files/${lottieFileName}`, ~method_=Get, ())
          ->then(Fetch.Response.json)
          ->then(json => {
            setlottieJson(_ => json)
            lottieDict->Dict.set(lottieFileName, Loaded(json))
            json->resolve
          })
          ->catch(_err => {
            showToast(~message="Error!", ~toastType=ToastError, ())
            Js.Json.null->resolve
          })

        lottieDict->Dict.set(lottieFileName, Loading(fetchLottie))
      }
    }
    None
  }, [lottieFileName])
  lottieJson
}
