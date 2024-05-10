let defaultTokenSetter = (_: option<string> => option<string>) => ()
let defaultDictSetter = (_: Dict.t<JSON.t> => Dict.t<JSON.t>) => ()

type tokenContextObjectType = {
  token: option<string>,
  setToken: (option<string> => option<string>) => unit,
  tokenDetailsDict: Dict.t<JSON.t>,
  setTokenDetailsDict: (Dict.t<JSON.t> => Dict.t<JSON.t>) => unit,
  parentAuthInfo: option<BasicAuthTypes.basicAuthInfo>,
}

let defaultTokenObj = {
  token: None,
  setToken: defaultTokenSetter,
  tokenDetailsDict: Dict.make(),
  setTokenDetailsDict: defaultDictSetter,
  parentAuthInfo: BasicAuthTypes.getAuthInfo(JSON.Encode.object(Dict.make()), ""),
}

let tokenContext = React.createContext(defaultTokenObj)

module Parent = {
  let make = React.Context.provider(tokenContext)
}

@react.component
let make = (~children) => {
  let currentToken = AuthWrapperUtils.useTokenParent(Default)
  let (token, setToken) = React.useState(_ => currentToken)
  let (tokenDetailsDict, setTokenDetailsDict) = React.useState(_ => Dict.make())

  let tokenContextObjext = React.useMemo4(() => {
    let parentAuthInfo = BasicAuthTypes.getAuthInfo(
      tokenDetailsDict->LogicUtils.getJsonObjectFromDict("tokenDict"),
      token->Option.getOr(""),
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
