type contentType = Headers(string) | Unknown

let headersForXFeature = (~uri, ~headers) => {
  if (
    uri->String.includes("lottie-files") ||
    uri->String.includes("config/merchant") ||
    uri->String.includes("config/feature") ||
    uri->String.includes("config/theme")
  ) {
    headers->Dict.set("Content-Type", `application/json`)
  } else {
    headers->Dict.set("x-feature", "integ-custom")
  }
}

let getHeaders = (
  ~uri,
  ~headers,
  ~contentType=Headers("application/json"),
  ~xFeatureRoute,
  ~token,
  ~merchantId,
  ~profileId,
  ~version: UserInfoTypes.version,
) => {
  let isMixpanel = uri->String.includes("mixpanel")

  let headerObj = if isMixpanel {
    [
      ("Content-Type", "application/x-www-form-urlencoded"),
      ("accept", "application/json"),
    ]->Dict.fromArray
  } else {
    switch (token, version) {
    | (Some(str), V1) => {
        headers->Dict.set("authorization", `Bearer ${str}`)
        headers->Dict.set("api-key", `hyperswitch`)
      }
    | (Some(str), V2) => headers->Dict.set("authorization", `Bearer ${str}`)
    | _ => ()
    }
    switch contentType {
    | Headers(headerString) => headers->Dict.set("Content-Type", headerString)
    | Unknown => ()
    }
    if xFeatureRoute {
      headersForXFeature(~headers, ~uri)
    }

    // this header is specific to Intelligent Routing (Dynamic Routing)
    if uri->String.includes("dynamic-routing") {
      headers->Dict.set("x-feature", "dynamo-simulator")
    }

    // this header is specific to Chat Bot for session tracking
    if uri->String.includes("/chat/ai/data") {
      let sessionKey = "chatbot_session_id"
      switch SessionStorage.sessionStorage.getItem(sessionKey)->Nullable.toOption {
      | Some(sessionId) => headers->Dict.set("x-chat-session-id", sessionId)
      | None => ()
      }
    }
    // headers for V2
    headers->Dict.set("X-Profile-Id", profileId)
    headers->Dict.set("X-Merchant-Id", merchantId)
    headers
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
  let url = RescriptReactRouter.useUrl()
  let setReqProgress = Recoil.useSetRecoilState(ApiProgressHooks.pendingRequestCount)
  React.useCallback(
    (
      uri,
      ~bodyStr: string="",
      ~bodyFormData=None,
      ~headers=Dict.make(),
      ~method_: Fetch.requestMethod,
      ~betaEndpointConfig=?,
      ~contentType=Headers("application/json"),
      ~xFeatureRoute,
      ~forceCookies,
      ~merchantId="",
      ~profileId="",
      ~version=UserInfoTypes.V1,
      ~isEmbeddableSession=false,
    ) => {
      let token = {
        if isEmbeddableSession {
          Some(AuthUtils.getEmbeddableInfoDetailsFromLocalStorage())
        } else {
          switch authStatus {
          | PreLogin(info) => info.token
          | LoggedIn(info) =>
            switch info {
            | Auth(_) => AuthUtils.getUserInfoDetailsFromLocalStorage().token
            }
          | _ => None
          }
        }
      }

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
        setReqProgress(p => p + 1)
        Fetch.fetchWithInit(
          uri,
          Fetch.RequestInit.make(
            ~method_,
            ~body?,
            ~credentials={forceCookies ? SameOrigin : Omit},
            ~headers=getHeaders(
              ~headers,
              ~uri,
              ~contentType,
              ~token,
              ~xFeatureRoute,
              ~merchantId,
              ~profileId,
              ~version,
            ),
          ),
        )
        ->catch(
          err => {
            setReqProgress(p => p - 1)
            reject(err)
          },
        )
        ->then(
          resp => {
            setReqProgress(p => p - 1)
            if resp->Fetch.Response.status === 401 {
              let jsonPromise =
                resp
                ->Fetch.Response.clone
                ->Fetch.Response.json
                ->catch(_ => resolve(JSON.Encode.null))

              jsonPromise->then(
                json => {
                  let errorDict = json->LogicUtils.getDictFromJsonObject
                  let errorObj = errorDict->LogicUtils.getObj("error", Dict.make())
                  let errorCode = errorObj->LogicUtils.getString("code", "")
                  if errorCode->CommonAuthUtils.errorSubCodeMapper == IR_48 {
                    EmbeddableUtils.sendEventToParentForRefetchToken()
                  } else {
                    switch authStatus {
                    | LoggedIn(_) =>
                      let _ = CommonAuthUtils.clearLocalStorage()
                      let _ = CommonAuthUtils.handleSwitchUserQueryParam(~url)
                      setAuthStateToLogout()
                      AuthUtils.redirectToLogin()

                    | _ => ()
                    }
                  }
                  resolve(resp)
                },
              )
            } else {
              resolve(resp)
            }
          },
        )
      })
    },
    [],
  )
}
