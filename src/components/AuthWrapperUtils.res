type parent

@val external window: 'a = "window"
@val @scope("window") external parent: parent = "parent"

let getValidToken = oStr => {
  if oStr !== Some("__failed") && oStr !== Some("") {
    oStr
  } else {
    None
  }
}

type tokenType = Default | Original | SwitchOnly

let useLocalStorageToken = tokenType => {
  let lcToken = LocalStorage.useStorageValue("login")->getValidToken
  let switchToken = LocalStorage.useStorageValue("switchToken")->getValidToken

  if switchToken->Js.Option.isSome && switchToken !== Some("__failed") && tokenType !== Original {
    switchToken
  } else if lcToken->Js.Option.isSome && lcToken !== Some("__failed") && tokenType !== SwitchOnly {
    lcToken
  } else {
    None
  }
}

let useTokenParent = (tokenType: tokenType) => {
  useLocalStorageToken(tokenType)
}
