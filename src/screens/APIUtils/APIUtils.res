open LogicUtils
open APIUtilsTypes
open CommonAuthHooks
exception JsonException(JSON.t)

let useGetURL = () => {
  let {merchant_id: merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let getUrl = (
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
    | GENERATE_SAMPLE_DATA => `user/sample_data`
    | TEST_LIVE_PAYMENT => `test_payment`
    | THREE_DS => `routing/decision`
    | VERIFY_APPLE_PAY => `verify/apple_pay`
    | PAYPAL_ONBOARDING => `connector_onboarding`
    | SURCHARGE => `routing/decision/surcharge`
    | PAYOUT_DEFAULT_FALLBACK => `routing/payouts/default`
    | CUSTOMERS =>
      switch methodType {
      | Get =>
        switch id {
        | Some(customerId) => `customers/${customerId}`
        | None => `customers/list?limit=10000`
        }
      | _ => ""
      }
    | FRAUD_RISK_MANAGEMENT | CONNECTOR =>
      switch methodType {
      | Get =>
        switch id {
        | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
        | None => connectorBaseURL
        }
      | Post | Delete =>
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
      | Get | Put =>
        switch id {
        | Some(routingId) => `routing/${routingId}`
        | _ => `routing`
        }
      | Post =>
        switch id {
        | Some(routing_id) => `routing/${routing_id}/activate`
        | _ => `routing`
        }
      | _ => ""
      }
    | PAYOUT_ROUTING =>
      switch methodType {
      | Get | Put =>
        switch id {
        | Some(routingId) => `routing/${routingId}`
        | _ => `routing/payouts`
        }
      | Post =>
        switch id {
        | Some(routing_id) => `routing/payouts/${routing_id}/activate`
        | _ => `routing/payouts`
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
      | Delete => `api_keys/${merchantId}/${id->Option.getOr("")}`
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
        | Some(key_id) =>
          switch queryParamerters {
          | Some(queryParams) => `refunds/${key_id}?${queryParams}`
          | None => `refunds/${key_id}`
          }

        | None =>
          switch queryParamerters {
          | Some(queryParams) => `refunds/list?${queryParams}`
          | None => `refunds/list?limit=100`
          }
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
        | None => `disputes/list?limit=10000`
        }
      | _ => ""
      }
    | GLOBAL_SEARCH =>
      switch methodType {
      | Post =>
        switch id {
        | Some(topic) => `analytics/v1/search/${topic}`
        | None => `analytics/v1/search`
        }
      | _ => ""
      }
    | ANALYTICS_REFUNDS
    | ANALYTICS_PAYMENTS
    | ANALYTICS_USER_JOURNEY
    | ANALYTICS_AUTHENTICATION
    | ANALYTICS_SYSTEM_METRICS
    | ANALYTICS_DISPUTES =>
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
    | WEBHOOKS_EVENT_LOGS =>
      switch id {
      | Some(payment_id) => `analytics/v1/outgoing_webhook_event_logs?payment_id=${payment_id}`
      | None => ""
      }
    | CONNECTOR_EVENT_LOGS =>
      switch id {
      | Some(payment_id) =>
        `analytics/v1/connector_event_logs?type=Payment&payment_id=${payment_id}`
      | None => ""
      }
    | USERS =>
      let userUrl = `user`
      switch userType {
      | #NONE => ""
      | #USER_DATA => `${userUrl}/data`
      | #MERCHANT_DATA => `${userUrl}/data`
      | #INVITE_MULTIPLE
      | #RESEND_INVITE =>
        `${userUrl}/user/${(userType :> string)->String.toLowerCase}`
      | #CONNECT_ACCOUNT => `${userUrl}/connect_account`
      | #SWITCH_MERCHANT =>
        switch methodType {
        | Get => `${userUrl}/switch/list`
        | _ => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }
      | #GET_PERMISSIONS | #CREATE_CUSTOM_ROLE => `${userUrl}/role`
      | #SIGNINV2 => `${userUrl}/v2/signin`
      | #VERIFY_EMAILV2 => `${userUrl}/v2/verify_email`
      | #ACCEPT_INVITE => `${userUrl}/user/invite/accept`
      | #ACCEPT_INVITE_TOKEN_ONLY => `${userUrl}/user/invite/accept?token_only=true`
      | #USER_DELETE => `${userUrl}/user/delete`
      | #USER_UPDATE => `${userUrl}/update`
      | #UPDATE_ROLE => `${userUrl}/user/${(userType :> string)->String.toLowerCase}`
      | #MERCHANTS_SELECT => `${userUrl}/merchants_select/list`
      | #SIGNUP
      | #SIGNOUT
      | #RESET_PASSWORD
      | #SET_METADATA
      | #VERIFY_EMAIL_REQUEST
      | #FORGOT_PASSWORD
      | #CREATE_MERCHANT
      | #PERMISSION_INFO
      | #ACCEPT_INVITE_FROM_EMAIL
      | #ROTATE_PASSWORD =>
        `${userUrl}/${(userType :> string)->String.toLowerCase}`
      | #SIGNINV2_TOKEN_ONLY => `${userUrl}/v2/signin?token_only=true`
      | #VERIFY_EMAILV2_TOKEN_ONLY => `${userUrl}/v2/verify_email?token_only=true`
      | #SIGNUPV2 => `${userUrl}/signup`
      | #SIGNUP_TOKEN_ONLY => `${userUrl}/signup?token_only=true`
      | #RESET_PASSWORD_TOKEN_ONLY => `${userUrl}/reset_password?token_only=true`
      | #FROM_EMAIL => `${userUrl}/from_email`
      | #BEGIN_TOTP => `${userUrl}/totp/begin`
      | #VERIFY_TOTP => `${userUrl}/totp/verify`
      | #INVITE_MULTIPLE_TOKEN_ONLY => `${userUrl}/user/invite_multiple?token_only=true`
      | #GENERATE_RECOVERY_CODES => `${userUrl}/recovery_codes/generate`
      | #ACCEPT_INVITE_FROM_EMAIL_TOKEN_ONLY =>
        `${userUrl}/accept_invite_from_email?token_only=true`
      | #USER_INFO => userUrl
      }
    | RECON => `recon/${(reconType :> string)->String.toLowerCase}`
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
    | ACCEPT_DISPUTE =>
      switch id {
      | Some(id) => `disputes/accept/${id}`
      | None => `disputes`
      }
    | DISPUTES_ATTACH_EVIDENCE =>
      switch id {
      | Some(id) => `disputes/evidence/${id}`
      | _ => `disputes/evidence`
      }
    | PAYMENT | SETTINGS => ""
    | PAYMENT_METHOD_CONFIG => `payment_methods/filter`
    }
    `${Window.env.apiBaseUrl}/${endpoint}`
  }
  getUrl
}

let sessionExpired = ref(false)

let handleLogout = async (
  ~fetchApi: (
    string,
    ~bodyStr: string=?,
    ~bodyFormData: option<Fetch.formData>=?,
    ~headers: Dict.t<string>=?,
    ~method_: Fetch.requestMethod,
    ~betaEndpointConfig: AuthHooks.betaEndpoint=?,
    ~contentType: AuthHooks.contentType=?,
    unit,
  ) => Promise.t<Fetch.Response.t>,
  ~setAuthStateToLogout,
  ~setIsSidebarExpanded,
  ~clearRecoilValue,
  ~getURL: (
    ~entityName: APIUtilsTypes.entityName,
    ~methodType: Fetch.requestMethod,
    ~id: option<string>=?,
    ~connector: option<'a>=?,
    ~userType: APIUtilsTypes.userType=?,
    ~userRoleTypes: APIUtilsTypes.userRoleTypes=?,
    ~reconType: APIUtilsTypes.reconType=?,
    ~queryParamerters: option<string>=?,
    unit,
  ) => string,
) => {
  try {
    setAuthStateToLogout()
    setIsSidebarExpanded(_ => false)
    clearRecoilValue()
    RescriptReactRouter.push(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
    let logoutUrl = getURL(~entityName=USERS, ~methodType=Post, ~userType=#SIGNOUT, ())
    let _ = await fetchApi(logoutUrl, ~method_=Fetch.Post, ())
    LocalStorage.clear()
  } catch {
  | _ => LocalStorage.clear()
  }
}

let responseHandler = async (
  ~res,
  ~showToast: ToastState.showToastFn,
  ~showErrorToast: bool,
  ~showPopUp: React.callback<PopUpState.popUpProps, unit>,
  ~isPlayground,
  ~popUpCallBack,
  ~setAuthStatus,
) => {
  let json = try {
    await res->Fetch.Response.json
  } catch {
  | _ => JSON.Encode.null
  }

  let responseStatus = res->Fetch.Response.status

  switch responseStatus {
  | 200 => json
  | _ => {
      let errorDict = json->getDictFromJsonObject->getObj("error", Dict.make())
      let errorStringifiedJson = errorDict->JSON.Encode.object->JSON.stringify

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
            setAuthStatus(AuthProviderTypes.LoggedOut)
            RescriptReactRouter.push(HSwitchGlobalVars.appendDashboardPath(~url="/login"))
            sessionExpired := true
          }

        | 403 =>
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: "Access Forbidden",
            description: {
              HSwitchUtils.noAccessControlText->React.string
            },
            handleConfirm: {
              text: "Close",
              onClick: {
                _ => ()
              },
            },
          })

        | _ =>
          showToast(
            ~toastType=ToastError,
            ~message=errorDict->getString("message", "Error Occured"),
            ~autoClose=false,
            (),
          )
        }
      }
      Exn.raiseError(errorStringifiedJson)
    }
  }
}

let catchHandler = (
  ~err,
  ~showErrorToast,
  ~showToast: ToastState.showToastFn,
  ~isPlayground,
  ~popUpCallBack,
) => {
  switch Exn.message(err) {
  | Some(msg) => Exn.raiseError(msg)
  | None => {
      if isPlayground {
        popUpCallBack()
      } else if showErrorToast {
        showToast(~toastType=ToastError, ~message="Something Went Wrong", ~autoClose=false, ())
      }
      Exn.raiseError("Failed to Fetch")
    }
  }
}

let useGetMethod = (~showErrorToast=true, ()) => {
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
  let clearRecoilValue = ClearRecoilValueHook.useClearRecoilValue()
  let getURL = useGetURL()
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
            let _ = handleLogout(
              ~fetchApi,
              ~setAuthStateToLogout,
              ~setIsSidebarExpanded,
              ~clearRecoilValue,
              ~getURL,
            )
          }
        },
      },
    })

  async url => {
    try {
      let res = await fetchApi(url, ~method_=Get, ())
      await responseHandler(
        ~res,
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
        ~setAuthStatus,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(
        ~err={e},
        ~requestMethod={Fetch.Get},
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
      )
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useUpdateMethod = (~showErrorToast=true, ()) => {
  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let clearRecoilValue = ClearRecoilValueHook.useClearRecoilValue()

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
            let _ = handleLogout(
              ~fetchApi,
              ~setAuthStateToLogout,
              ~setIsSidebarExpanded,
              ~clearRecoilValue,
            )
          }
        },
      },
    })

  async (
    url,
    body,
    method,
    ~bodyFormData=?,
    ~headers=Dict.make(),
    ~contentType=AuthHooks.Headers("application/json"),
    (),
  ) => {
    try {
      let res = await fetchApi(
        url,
        ~method_=method,
        ~bodyStr=body->JSON.stringify,
        ~bodyFormData,
        ~headers,
        ~contentType,
        (),
      )
      await responseHandler(
        ~res,
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~showPopUp,
        ~popUpCallBack,
        ~setAuthStatus,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(
        ~err={e},
        ~requestMethod={method},
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~popUpCallBack,
      )
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
