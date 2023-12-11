open Promise
open LogicUtils
@val @scope(("window", "localStorage"))
external clearLocalStorage: unit => unit = "clear"
@val @scope(("window", "location")) external pathName: string = "pathname"
@val @scope(("window", "location")) external hostname: string = "hostname"
type sessionStorage = {
  getItem: (. string) => Js.Nullable.t<string>,
  setItem: (. string, string) => unit,
  removeItem: (. string) => unit,
}

@val external sessionStorage: sessionStorage = "sessionStorage"

external dictToObj: Js.Dict.t<'a> => {..} = "%identity"
@val external atob: string => string = "atob"
let getAgentId = _ => {
  switch LocalStorage.getItem("agentId")->Js.Nullable.toOption {
  | Some(str) => str
  | None => ""
  }
}

let getKey = keyType => {
  switch LocalStorage.getItem(keyType)->Js.Nullable.toOption {
  | Some(str) => str
  | None => "__failed"
  }
}
let getHeadersJson = (
  ~uri,
  ~headers=Js.Dict.empty(),
  ~isLogin,
  key,
  ~requestId,
  ~storageKey: option<string>,
  (),
) => {
  let isLsp = uri->Js.String2.includes("dashboard") ? false : true
  let isFirstVerify = uri->Js.String2.includes("lspotp/verify") ? true : false
  let isTriggerAPI = uri->Js.String2.includes("lspotp/trigger") ? true : false

  let localStorageData = switch storageKey {
  | Some(key) =>
    switch LocalStorage.getItem(key)->Js.Nullable.toOption {
    | Some(str) => str->safeParse->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
    | None => Js.Dict.empty()
    }
  | None => Js.Dict.empty()
  }

  let sessionToken = switch LocalStorage.getItem("sessionToken")->Js.Nullable.toOption {
  | Some(str) => str
  | None => ""
  }
  let merchantId = switch LocalStorage.getItem("merchant-id")->Js.Nullable.toOption {
  | Some(str) => str
  | None => ""
  }

  let headerObj = headers

  switch isLsp {
  | true =>
    if isFirstVerify {
      Js.Dict.set(headerObj, "X-RequestId", requestId->Js.Json.string)
      Js.Dict.set(headerObj, "X-App-Id", merchantId->Js.Json.string)
      Js.Dict.set(headerObj, "X-Merchant-Id", merchantId->Js.Json.string)
      Js.Dict.set(headerObj, "X-Agent-Session-Token", sessionToken->Js.Json.string)
      Js.Dict.set(
        headerObj,
        "X-Device-Token",
        key
        ->Js.String2.replace("-----BEGIN PUBLIC KEY-----\n", "")
        ->Js.String2.replace("\n-----END PUBLIC KEY-----", "")
        ->Identity.genericTypeToJson,
      )
    } else {
      Js.Dict.set(headerObj, "X-RequestId", requestId->Js.Json.string)
      Js.Dict.set(headerObj, "X-App-Id", merchantId->Js.Json.string)
      Js.Dict.set(
        headerObj,
        "X-Session-Token",
        localStorageData->getString("sessionToken", "")->Js.Json.string,
      )
      Js.Dict.set(headerObj, "X-Merchant-Id", merchantId->Js.Json.string)
      Js.Dict.set(headerObj, "X-Agent-Session-Token", sessionToken->Js.Json.string)
      Js.Dict.set(headerObj, "X-User-Id", localStorageData->getString("userId", "")->Js.Json.string)
      if isTriggerAPI {
        Js.Dict.set(
          headerObj,
          "X-Device-Token",
          key
          ->Js.String2.replace("-----BEGIN PUBLIC KEY-----\n", "")
          ->Js.String2.replace("\n-----END PUBLIC KEY-----", "")
          ->Identity.genericTypeToJson,
        )
      }
    }
  | false => {
      Js.Dict.set(headerObj, "Content-Type", "application/json"->Js.Json.string)
      if sessionToken !== "" {
        Js.Dict.set(headerObj, "Session-Token", sessionToken->Js.Json.string)
      }
      if isLogin {
        Js.Dict.set(
          headerObj,
          "X-Device-Token",
          key
          ->Js.String2.replace("-----BEGIN PUBLIC KEY-----\n", "")
          ->Js.String2.replace("\n-----END PUBLIC KEY-----", "")
          ->Identity.genericTypeToJson,
        )
      }
    }
  }

  headerObj->Js.Json.object_
}

let getHeaders = (~uri=?, ~headers=Js.Dict.empty(), ()) => {
  let hyperSwitchToken = LocalStorage.getItem("login")->Js.Nullable.toOption
  let isMixpanel = switch uri {
  | Some(uri) => uri->Js.String2.includes("mixpanel") ? true : false
  | None => false
  }
  switch isMixpanel {
  | true =>
    let headerObj = {
      "Content-Type": "application/x-www-form-urlencoded",
      "accept": "application/json",
    }
    Fetch.HeadersInit.make(headerObj)

  | false =>
    let headerObj =
      headers->Js.Dict.get("api-key")->Belt.Option.getWithDefault("")->Js.String2.length > 0
        ? true
        : false

    switch headerObj {
    | true => {
        let headerObj = {
          "Content-Type": "application/json",
          "api-key": headers->Js.Dict.get("api-key")->Belt.Option.getWithDefault(""),
        }
        Fetch.HeadersInit.make(headerObj)
      }

    | false =>
      switch hyperSwitchToken {
      | Some(token) =>
        if token !== "" {
          let headerObj = {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${hyperSwitchToken->Belt.Option.getWithDefault("")}`,
            "api-key": "hyperswitch",
          }

          Fetch.HeadersInit.make(headerObj)
        } else {
          let headerObj = {
            "Content-Type": "application/json",
          }
          Fetch.HeadersInit.make(headerObj)
        }

      | None =>
        let headerObj = {
          "Content-Type": "application/json",
        }
        Fetch.HeadersInit.make(headerObj)
      }
    }
  }
}

let getPublicKey = ""

let getKid = ""

let handleForbidden = (resp, showToast: ToastState.showToastFn, isJuspay) => {
  resp
  ->Fetch.Response.clone
  ->Fetch.Response.json
  ->then(json => {
    open Belt.Option

    json
    ->Js.Json.decodeObject
    ->flatMap(dict => {
      let messageJson = switch dict->Js.Dict.get("errorMessage") {
      | Some(msg) =>
        isJuspay && msg === "Unauthorized. IP address is not allowed"->Js.Json.string
          ? `Please Connect to VPN`->Js.Json.string->Some
          : `Access Denied`->Js.Json.string->Some
      | None => dict->Js.Dict.get("errorMessage")
      }
      messageJson->flatMap(Js.Json.decodeString)
    })
    ->getWithDefault("Forbidden")
    ->resolve
  })
  ->catch(_ => resp->Fetch.Response.clone->Fetch.Response.text)
  ->then(message => {
    showToast(~toastType=ToastError, ~message, ~autoClose=false, ())

    resolve(resp)
  })
}

let addResellerKey = (bodyStr, optionalMerchantId) => {
  try {
    let bodyJson = bodyStr->safeParse
    switch Js.Json.classify(bodyJson) {
    | Js.Json.JSONObject(bodyDict) =>
      switch optionalMerchantId {
      | Some(merchantId) =>
        bodyDict->Js.Dict.set("merchantId", merchantId->Js.Json.string)

        bodyDict->Js.Json.object_->Js.Json.stringify
      | _ => bodyStr
      }

    | Js.Json.JSONArray(bodyArr) =>
      let newBodyArr = Js.Array.map(ob => {
        let optDict = Js.Json.decodeObject(ob->Js.Json.stringify->safeParse)

        switch optDict {
        | Some(dict) =>
          switch optionalMerchantId {
          | Some(merchantId) =>
            let mDict = Js.Dict.empty()
            Js.Dict.set(mDict, "merchantId", [merchantId->Js.Json.string]->Js.Json.array)
            dict->Js.Dict.set("filters", mDict->Js.Json.object_)
            dict->Js.Json.object_
          | _ => ob
          }
        | None => ob
        }
      }, bodyArr)
      newBodyArr->Js.Json.array->Js.Json.stringify
    | Js.Json.JSONNull =>
      switch optionalMerchantId {
      | Some(merchantId) =>
        let bodyDict = Js.Dict.empty()
        bodyDict->Js.Dict.set("merchantId", merchantId->Js.Json.string)
        bodyDict->Js.Json.object_->Js.Json.stringify
      | _ => bodyStr
      }
    | _ => bodyStr
    }
  } catch {
  | _ => bodyStr
  }
}

@val @scope(("window", "location"))
external hostName: string = "host"

type betaEndpoint = {
  betaApiStr: string,
  originalApiStr: string,
  replaceStr: string,
}

let getUriModifier = uri => {
  uri
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
      ~headers=Js.Dict.empty(),
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
      | Some(val) => Js.String2.replace(uri, val.replaceStr, val.originalApiStr)
      | None => uri
      }

      let body = switch method_ {
      | Get => resolve(None)
      | _ => resolve(Some(Fetch.BodyInit.make(bodyStr)))
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
                clearLocalStorage()
                setAuthStatus(LoggedOut)
                RescriptReactRouter.push("/home")
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
