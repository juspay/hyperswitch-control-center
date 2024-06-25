type contentType = Headers(string) | Unknown

let getHeaders = (~uri, ~headers, ~contentType=Headers("application/json"), ~token, ()) => {
  let isMixpanel = uri->String.includes("mixpanel")

  let headerObj = if isMixpanel {
    [
      ("Content-Type", "application/x-www-form-urlencoded"),
      ("accept", "application/json"),
    ]->Dict.fromArray
  } else {
    let res = switch token {
    | Some(token) => {
        headers->Dict.set("authorization", `Bearer ${token}`)
        headers->Dict.set("api-key", `hyperswitch`)
        headers
      }
    | None => headers
    }
    switch contentType {
    | Headers(headerString) => headers->Dict.set("Content-Type", headerString)
    | Unknown => ()
    }
    res
  }
  Fetch.HeadersInit.make(headerObj->Identity.dictOfAnyTypeToObj)
}

type betaEndpoint = {
  betaApiStr: string,
  originalApiStr: string,
  replaceStr: string,
}

let useApiFetcher = () => {
  open Promise
  let {authStatus, setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)

  let token = React.useMemo1(() => {
    switch authStatus {
    | PreLogin(info) => Some(info.token)
    | LoggedIn(info) =>
      switch info {
      | BasicAuth(basicInfo) => basicInfo.token
      | Auth(info) => Some(info.token)
      }
    | _ => None
    }
  }, [authStatus])
  let setReqProgress = Recoil.useSetRecoilState(ApiProgressHooks.pendingRequestCount)

  React.useCallback1(
    (
      uri,
      ~bodyStr: string="",
      ~bodyFormData=None,
      ~headers=Dict.make(),
      ~method_: Fetch.requestMethod,
      ~betaEndpointConfig=?,
      ~contentType=Headers("application/json"),
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
            ~headers=getHeaders(~headers, ~uri, ~contentType, ~token, ()),
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
                setAuthStateToLogout()
                RescriptReactRouter.push(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
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
