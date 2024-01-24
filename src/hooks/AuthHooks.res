open Promise
type sessionStorage = {
  getItem: (. string) => Js.Nullable.t<string>,
  setItem: (. string, string) => unit,
  removeItem: (. string) => unit,
}

@val external sessionStorage: sessionStorage = "sessionStorage"

external dictToObj: Js.Dict.t<'a> => {..} = "%identity"
@val external atob: string => string = "atob"

let getHeaders = (~uri, ~headers, ()) => {
  let hyperSwitchToken = LocalStorage.getItem("login")->Js.Nullable.toOption
  let isMixpanel = uri->String.includes("mixpanel")

  let headerObj = if isMixpanel {
    [
      ("Content-Type", "application/x-www-form-urlencoded"),
      ("accept", "application/json"),
    ]->Dict.fromArray
  } else {
    let res = switch hyperSwitchToken {
    | Some(token) => {
        headers->Dict.set("authorization", `Bearer ${token}`)
        headers->Dict.set("api-key", `hyperswitch`)
        headers
      }

    | None => headers
    }
    res
  }
  Fetch.HeadersInit.make(headerObj->dictToObj)
}

@val @scope(("window", "location"))
external hostName: string = "host"

type betaEndpoint = {
  betaApiStr: string,
  originalApiStr: string,
  replaceStr: string,
}

let useApiFetcher = () => {
  let (authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)

  let token = React.useMemo1(() => {
    switch authStatus {
    | LoggedIn(info) => Some(info.token)
    | _ => None
    }
  }, [authStatus])
  let setReqProgress = Recoil.useSetRecoilState(ApiProgressHooks.pendingRequestCount)

  React.useCallback1(
    (
      uri,
      ~bodyStr: string="",
      ~bodyFormData=None,
      ~headers=[("Content-Type", "application/json")]->Dict.fromArray,
      ~bodyHeader as _=?,
      ~method_: Fetch.requestMethod,
      ~authToken as _=?,
      ~requestId as _=?,
      ~disableEncryption as _=false,
      ~storageKey as _=?,
      ~betaEndpointConfig=?,
      (),
    ) => {
      let uri = switch betaEndpointConfig {
      | Some(val) => String.replace(uri, val.replaceStr, val.originalApiStr)
      | None => uri
      }

      let body = switch method_ {
      | Get => resolve(None)
      | _ =>
        switch bodyFormData {
        | Some(formDataVal) => resolve(Some(Fetch.BodyInit.makeWithFormData(formDataVal)))
        | None => resolve(Some(Fetch.BodyInit.make(bodyStr)))
        }
      }

      body->then(body => {
        setReqProgress(. p => p + 1)
        Fetch.fetchWithInit(
          uri,
          Fetch.RequestInit.make(
            ~method_,
            ~body?,
            ~credentials=SameOrigin,
            ~headers=getHeaders(~headers, ~uri, ()),
            (),
          ),
        )
        ->catch(
          err => {
            setReqProgress(. p => p - 1)
            reject(err)
          },
        )
        ->then(
          resp => {
            setReqProgress(. p => p - 1)
            if resp->Fetch.Response.status === 401 {
              switch authStatus {
              | LoggedIn(_) =>
                LocalStorage.clear()
                setAuthStatus(LoggedOut)
                RescriptReactRouter.push("/login")
                resolve(resp)

              | _ => resolve(resp)
              }
            } else {
              resolve(resp)
            }
          },
        )
      })
    },
    [token],
  )
}
