let defaultTokenSetter = (_: option<string> => option<string>) => ()
let defaultDictSetter = (_: Js.Dict.t<Js.Json.t> => Js.Dict.t<Js.Json.t>) => ()

type tokenContextObjectType = {
  token: option<Js.String2.t>,
  setToken: (option<string> => option<string>) => unit,
  tokenDetailsDict: Js.Dict.t<Js.Json.t>,
  setTokenDetailsDict: (Js.Dict.t<Js.Json.t> => Js.Dict.t<Js.Json.t>) => unit,
  parentAuthInfo: option<HyperSwitchAuthTypes.authInfo>,
}

let defaultTokenObj = {
  token: None,
  setToken: defaultTokenSetter,
  tokenDetailsDict: Js.Dict.empty(),
  setTokenDetailsDict: defaultDictSetter,
  parentAuthInfo: HyperSwitchAuthTypes.getAuthInfo(Js.Json.object_(Js.Dict.empty()), ""),
}

let tokenContext = React.createContext(defaultTokenObj)

module Parent = {
  let make = React.Context.provider(tokenContext)
}

@react.component
let make = (~children) => {
  let currentToken = AuthWrapperUtils.useTokenParent(Default)
  let (token, setToken) = React.useState(_ => currentToken)
  let (tokenDetailsDict, setTokenDetailsDict) = React.useState(_ => Js.Dict.empty())

  let tokenContextObjext = React.useMemo4(() => {
    let parentAuthInfo = HyperSwitchAuthTypes.getAuthInfo(
      tokenDetailsDict->LogicUtils.getJsonObjectFromDict("tokenDict"),
      token->Belt.Option.getWithDefault(""),
    )

    {
      token,
      setToken,
      tokenDetailsDict,
      setTokenDetailsDict,
      parentAuthInfo,
    }
  }, (token, tokenDetailsDict, setToken, setTokenDetailsDict))

  <Parent value=tokenContextObjext> children </Parent>
}
