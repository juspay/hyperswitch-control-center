@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~url,
  ~body="",
  ~method: Fetch.requestMethod=Post,
  ~dataKey="",
  ~buttonText,
  ~disableSelect=false,
  ~allowMultiSelect=false,
) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let (dataLoading, setDataLoading) = React.useState(() => true)
  let (loadErr, setLoadErr) = React.useState(() => false)
  let (options, setOptions) = React.useState(() => [])

  React.useEffect1(() => {
    open Promise
    fetchApi(url, ~bodyStr=body, ~method_=method, ())
    ->then(Fetch.Response.json)
    ->then(json => {
      switch Js.Json.classify(json) {
      | Js.Json.JSONObject(jsonDict) => {
          let payloadArr =
            jsonDict
            ->Dict.get(dataKey)
            ->Belt.Option.flatMap(Js.Json.decodeArray)
            ->Belt.Option.map(x => x->Belt.Array.keepMap(Js.Json.decodeString))
            ->Belt.Option.getWithDefault([])

          setOptions(_ => payloadArr)
          setDataLoading(_ => false)
        }

      | Js.Json.JSONArray(jsonArr) => {
          let payloadArr = jsonArr->Belt.Array.keepMap(Js.Json.decodeString)
          setOptions(_ => payloadArr)
          setDataLoading(_ => false)
        }

      | _ =>
        Js.log("Incorrect type")
        setDataLoading(_ => false)
      }
      resolve()
    })
    ->catch(_err => {
      setLoadErr(_ => true)
      setDataLoading(_ => false)
      showToast(~message="Could not load options", ~toastType=ToastError, ())
      resolve()
    })
    ->ignore

    None
  }, [url])

  let loadingOption = ["Loading..."]->SelectBox.makeOptions
  let shouldDisable = loadErr || options->Array.length <= 0 ? true : disableSelect
  let buttonText = options->Array.length <= 0 ? "No Options Found" : buttonText

  if dataLoading {
    <SelectBox
      input options=loadingOption buttonText="Loading" disableSelect=true allowMultiSelect
    />
  } else {
    <SelectBox
      input
      options={SelectBox.makeOptions(options)}
      buttonText
      disableSelect=shouldDisable
      allowMultiSelect
    />
  }
}
