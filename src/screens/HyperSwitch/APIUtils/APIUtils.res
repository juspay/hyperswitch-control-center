open HSLocalStorage
open LogicUtils
open APIUtilsTypes
exception JsonException(Js.Json.t)

let getURL = (
  ~entityName: entityName,
  ~methodType: Fetch.requestMethod,
  ~id=None,
  ~connector=None,
  ~userType: userType=#NONE,
  ~userRoleTypes: userRoleTypes=NONE,
  ~reconType: reconType=#NONE,
  ~queryParamerters: option<string>=None,
  (),
) => {
  let merchantId = getFromMerchantDetails("merchant_id")
  let connectorBaseURL = `account/${merchantId}/connectors`

  let endpoint = switch entityName {
  | INTEGRATION_DETAILS => `user/get_sandbox_integration_details`
  | DEFAULT_FALLBACK => `routing/default`
  | CHANGE_PASSWORD => `user/change_password`
  | MERCHANT_ACCOUNT => `accounts/${merchantId}`
  | ONBOARDING => `onboarding`
  | PAYMENT_REPORT => `analytics/v1/report/payments`
  | REFUND_REPORT => `analytics/v1/report/refunds`
  | DISPUTE_REPORT => `analytics/v1/report/dispute`
  | SDK_EVENT_LOGS => `analytics/v1/sdk_event_logs`
  | GENERATE_SAMPLE_DATA =>
    switch methodType {
    | Post => `user/sample_data`
    | Delete => `user/sample_data`
    | _ => ""
    }
  | TEST_LIVE_PAYMENT => `test_payment`
  | THREE_DS => `routing/decision`
  | VERIFY_APPLE_PAY => `verify/apple_pay`
  | SURCHARGE => `routing/decision/surcharge`
  | FRAUD_RISK_MANAGEMENT | CONNECTOR =>
    switch methodType {
    | Get =>
      switch id {
      | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
      | None => connectorBaseURL
      }
    | Post =>
      switch connector {
      | Some(_con) => `account/connectors/verify`
      | None =>
        switch id {
        | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
        | None => connectorBaseURL
        }
      }
    | _ => ""
    }
  | ROUTING =>
    switch methodType {
    | Get =>
      switch id {
      | Some(routingId) => `routing/${routingId}`
      | _ => `routing`
      }
    | Post =>
      switch id {
      | Some(routing_id) => `routing/${routing_id}/activate `
      | _ => `routing`
      }
    | Put =>
      switch id {
      | Some(routing_id) => `routing/${routing_id}`
      | _ => `routing `
      }
    | _ => ""
    }
  | API_KEYS =>
    switch methodType {
    | Get => `api_keys/${merchantId}/list`
    | Post =>
      switch id {
      | Some(key_id) => `api_keys/${merchantId}/${key_id}`
      | None => `api_keys/${merchantId}`
      }
    | Delete => `api_keys/${merchantId}/${id->Belt.Option.getWithDefault("")}`
    | _ => ""
    }
  | ORDERS =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParamerters {
        | Some(queryParams) => `payments/${key_id}?${queryParams}`
        | None => `payments/${key_id}`
        }
      | None =>
        switch queryParamerters {
        | Some(queryParams) => `payments/list?${queryParams}`
        | None => `payments/list?limit=100`
        }
      }
    | Post => `payments/list`
    | _ => ""
    }
  | REFUNDS =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => `refunds/${key_id}`
      | None => ""
      }
    | Post =>
      switch id {
      | Some(_keyid) => `refunds/list`
      | None => `refunds`
      }
    | _ => ""
    }
  | DISPUTES =>
    switch methodType {
    | Get =>
      switch id {
      | Some(dispute_id) => `disputes/${dispute_id}`
      | None => `disputes/list?limit=100`
      }
    | _ => ""
    }
  | ANALYTICS_REFUNDS | ANALYTICS_PAYMENTS | ANALYTICS_USER_JOURNEY | ANALYTICS_SYSTEM_METRICS =>
    switch methodType {
    | Get =>
      switch id {
      | Some(domain) => `analytics/v1/${domain}/info`
      | _ => ""
      }
    | _ => ""
    }
  | PAYMENT_LOGS =>
    switch methodType {
    | Get =>
      switch id {
      | Some(payment_id) => `analytics/v1/api_event_logs?type=Payment&payment_id=${payment_id}`
      | None => `analytics/v1/event-logs`
      }
    | _ => ""
    }
  | USERS =>
    let userUrl = `user`
    switch userType {
    | #NONE => ""
    | #VERIFY_MAGIC_LINK => `${userUrl}/v2/signin/verify`
    | #SIGNIN
    | #SIGNUP
    | #VERIFY_EMAIL =>
      `${userUrl}/${(userType :> string)->Js.String2.toLowerCase}`
    | #USER_DATA => `${userUrl}/data`
    | #MERCHANT_DATA => `${userUrl}/data/merchant`
    | #INVITE
    | #RESEND_INVITE =>
      `${userUrl}/user/${(userType :> string)->Js.String2.toLowerCase}`
    | #CONNECT_ACCOUNT => `${userUrl}/connect_account`
    | #SWITCH_MERCHANT =>
      switch methodType {
      | Get => `${userUrl}/switch/list`
      | _ => `${userUrl}/${(userType :> string)->Js.String2.toLowerCase}`
      }
    | #CREATE_MERCHANT => `${userUrl}/create_merchant`
    | _ => `${userUrl}/${(userType :> string)->Js.String2.toLowerCase}`
    }
  | RECON => `recon/${(reconType :> string)->Js.String2.toLowerCase}`
  | USER_MANAGEMENT => {
      let userUrl = `user`
      switch userRoleTypes {
      | USER_LIST => `${userUrl}/user/list`
      | ROLE_LIST => `${userUrl}/role/list`
      | ROLE_ID =>
        switch id {
        | Some(key_id) => `${userUrl}/role/${key_id}`
        | None => ""
        }
      | NONE => ""
      }
    }
  | BUSINESS_PROFILE =>
    switch id {
    | Some(id) => `account/${merchantId}/business_profile/${id}`
    | None => `account/${merchantId}/business_profile`
    }
  | PAYMENT | SETTINGS => ""
  }

  `${HSwitchGlobalVars.hyperSwitchApiPrefix}/${endpoint}`
}

let sessionExpired = ref(false)

let handleLogout = async (
  ~fetchApi as _: (
    Js.String2.t,
    ~bodyStr: string=?,
    ~headers: Js.Dict.t<Js.String2.t>=?,
    ~bodyHeader: Js.Dict.t<Js.Json.t>=?,
    ~method_: Fetch.requestMethod,
    ~authToken: option<Js.String2.t>=?,
    ~requestId: Js.String.t=?,
    ~disableEncryption: bool=?,
    ~storageKey: string=?,
    ~betaEndpointConfig: AuthHooks.betaEndpoint=?,
    unit,
  ) => Promise.t<Fetch.Response.t>,
  ~setAuthStatus,
  ~setIsSidebarExpanded,
) => {
  // let logoutUrl = getURL(~entityName=USERS, ~methodType=Post, ~userType=#SIGNOUT, ())
  // let _ = await fetchApi(logoutUrl, ~method_=Fetch.Post, ())
  setAuthStatus(HyperSwitchAuthTypes.LoggedOut)
  setIsSidebarExpanded(_ => false)
  LocalStorage.clear()
  RescriptReactRouter.push("/login")
}

let responseHandler = async (
  ~res,
  ~url,
  ~showToast: ToastState.showToastFn,
  ~requestMethod,
  ~showErrorToast: bool,
  ~showPopUp: React.callback<PopUpState.popUpProps, unit>,
  ~isPlayground,
  ~popUpCallBack,
  ~hyperswitchMixPanel: HSMixPanel.functionType,
) => {
  let json = try {
    await res->Fetch.Response.json
  } catch {
  | _ => Js.Json.null
  }

  let responseStatus = res->Fetch.Response.status

  switch responseStatus {
  | 200 => json
  | _ => {
      let errorDict = json->getDictFromJsonObject->getObj("error", Js.Dict.empty())
      let errorStringifiedJson = errorDict->Js.Json.object_->Js.Json.stringify
      hyperswitchMixPanel(
        ~isApiFailure=true,
        ~apiUrl=url,
        ~apiMethodName=requestMethod->LogicUtils.methodStr,
        ~description=Some(errorStringifiedJson),
        ~responseStatusCode=Some(responseStatus),
        ~xRequestId=Some(res->HyperSwitchUtils.fetchRequestIdFromAPI),
        (),
      )

      //TODO:-
      // errorCodes to be handled
      // let errorCode = errorDict->getString("code", "")

      if isPlayground && responseStatus === 403 {
        popUpCallBack()
      } else if showErrorToast {
        switch responseStatus {
        | 401 =>
          if !sessionExpired.contents {
            showToast(~toastType=ToastWarning, ~message="Session Expired", ~autoClose=false, ())
            hyperswitchMixPanel(
              ~eventName=Some(`Hyperswitch - Unauthorized Token - Session Expired`),
              (),
            )
            RescriptReactRouter.push("/login")
            sessionExpired := true
          }

        | 403 => {
            showPopUp({
              popUpType: (Warning, WithIcon),
              heading: "Access Forbidden",
              description: {
                "You do not have the required permissions to access this module. Please contact your administrator for necessary permissions."->React.string
              },
              handleConfirm: {
                text: "Close",
                onClick: {
                  _ => ()
                },
              },
            })
            hyperswitchMixPanel(~eventName=Some(`Hyperswitch - Access Forbidden`), ())
          }

        | _ =>
          showToast(
            ~toastType=ToastError,
            ~message=errorDict->getString("message", "Error Occured"),
            ~autoClose=false,
            (),
          )
        }
      }
      Js.Exn.raiseError(errorStringifiedJson)
    }
  }
}

let catchHandler = (
  ~err,
  ~requestMethod,
  ~url,
  ~showErrorToast,
  ~showToast: ToastState.showToastFn,
  ~isPlayground,
  ~popUpCallBack,
  ~hyperswitchMixPanel: HSMixPanel.functionType,
) => {
  switch Js.Exn.message(err) {
  | Some(msg) => Js.Exn.raiseError(msg)
  | None => {
      hyperswitchMixPanel(
        ~isApiFailure=true,
        ~apiMethodName=requestMethod->LogicUtils.methodStr,
        ~apiUrl=url,
        ~description=Some("Failed to Fetch"),
        (),
      )
      if isPlayground {
        popUpCallBack()
      } else if showErrorToast {
        showToast(~toastType=ToastError, ~message="Something Went Wrong", ~autoClose=false, ())
      }
      Js.Exn.raiseError("Failed to Fetch")
    }
  }
}

let useGetMethod = (~showErrorToast=true, ()) => {
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (_authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
  let url = RescriptReactRouter.useUrl()
  let urlPath = url.path->Belt.List.toArray->Js.Array2.joinWith("_")

  let popUpCallBack = () =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Sign Up to Access All Features!",
      description: {
        "To unlock the potential and experience the full range of capabilities, simply sign up today. Join our community of explorers and gain access to an enhanced world of possibilities"->React.string
      },
      handleConfirm: {
        text: "Sign up Now",
        onClick: {
          _ => {
            hyperswitchMixPanel(~eventName=Some(`${urlPath}_tryplayground_register`), ())
            hyperswitchMixPanel(~eventName=Some(`global_tryplayground_register`), ())
            let _ = handleLogout(~fetchApi, ~setAuthStatus, ~setIsSidebarExpanded)
          }
        },
      },
    })

  async url => {
    try {
      let res = await fetchApi(url, ~method_=Get, ())
      await responseHandler(
        ~res,
        ~url,
        ~requestMethod={Get},
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
        ~hyperswitchMixPanel,
      )
    } catch {
    | Js.Exn.Error(e) =>
      catchHandler(
        ~err={e},
        ~url,
        ~requestMethod={Get},
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
        ~hyperswitchMixPanel,
      )
    | _ => Js.Exn.raiseError("Something went wrong")
    }
  }
}

let useUpdateMethod = (~showErrorToast=true, ()) => {
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let (_authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
  let url = RescriptReactRouter.useUrl()
  let urlPath = url.path->Belt.List.toArray->Js.Array2.joinWith("_")
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)

  let popUpCallBack = () =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Sign Up to Access All Features!",
      description: {
        "To unlock the potential and experience the full range of capabilities, simply sign up today. Join our community of explorers and gain access to an enhanced world of possibilities"->React.string
      },
      handleConfirm: {
        text: "Sign up Now",
        onClick: {
          _ => {
            hyperswitchMixPanel(~eventName=Some(`${urlPath}_tryplayground_register`), ())
            hyperswitchMixPanel(~eventName=Some(`global_tryplayground_register`), ())
            let _ = handleLogout(~fetchApi, ~setAuthStatus, ~setIsSidebarExpanded)
          }
        },
      },
    })

  async (url, body, method) => {
    try {
      let res = await fetchApi(url, ~method_=method, ~bodyStr=body->Js.Json.stringify, ())
      await responseHandler(
        ~res,
        ~url,
        ~requestMethod={method},
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~showPopUp,
        ~popUpCallBack,
        ~hyperswitchMixPanel,
      )
    } catch {
    | Js.Exn.Error(e) =>
      catchHandler(
        ~err={e},
        ~url,
        ~requestMethod={method},
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~popUpCallBack,
        ~hyperswitchMixPanel,
      )
    | _ => Js.Exn.raiseError("Something went wrong")
    }
  }
}
