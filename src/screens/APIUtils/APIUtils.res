open LogicUtils
open APIUtilsTypes
open CommonAuthHooks
exception JsonException(JSON.t)

let useGetURL = () => {
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let getUrl = (
    ~entityName: entityName,
    ~methodType: Fetch.requestMethod,
    ~id=None,
    ~connector=None,
    ~userType: userType=#NONE,
    ~userRoleTypes: userRoleTypes=NONE,
    ~reconType: reconType=#NONE,
    ~queryParamerters: option<string>=None,
  ) => {
    let connectorBaseURL = `account/${merchantId}/connectors`

    let endpoint = switch entityName {
    /* GLOBAL SEARCH */
    | GLOBAL_SEARCH =>
      switch methodType {
      | Post =>
        switch id {
        | Some(topic) => `analytics/v1/search/${topic}`
        | None => `analytics/v1/search`
        }
      | _ => ""
      }

    /* MERCHANT ACCOUNT DETAILS (Get and Post) */
    | MERCHANT_ACCOUNT => `accounts/${merchantId}`

    /* CUSTOMERS DETAILS */
    | CUSTOMERS =>
      switch methodType {
      | Get =>
        switch id {
        | Some(customerId) => `customers/${customerId}`
        | None => `customers/list?limit=10000`
        }
      | _ => ""
      }

    /* CONNECTORS & FRAUD AND RISK MANAGEMENT */
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

    /* OPERATIONS */
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
    | PAYOUTS =>
      switch methodType {
      | Get =>
        switch id {
        | Some(payout_id) => `payouts/${payout_id}`
        | None => `payouts/list?limit=100`
        }
      | Post => `payouts/list`
      | _ => ""
      }

    /* ROUTING */
    | DEFAULT_FALLBACK => `routing/default`
    | ROUTING =>
      switch methodType {
      | Get =>
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
    | ACTIVE_ROUTING => `routing/active`

    /* ANALYTICS */
    | ANALYTICS_REFUNDS
    | ANALYTICS_PAYMENTS
    | ANALYTICS_USER_JOURNEY
    | ANALYTICS_AUTHENTICATION
    | ANALYTICS_SYSTEM_METRICS
    | ANALYTICS_DISPUTES
    | ANALYTICS_ACTIVE_PAYMENTS =>
      switch methodType {
      | Get =>
        switch id {
        | Some(domain) => `analytics/v1/${domain}/info`
        | _ => ""
        }
      | Post =>
        switch id {
        | Some(domain) => `analytics/v1/metrics/${domain}`
        | _ => ""
        }
      | _ => ""
      }
    | ANALYTICS_FILTERS =>
      switch methodType {
      | Post =>
        switch id {
        | Some(domain) => `analytics/v1/filters/${domain}`
        | _ => ""
        }
      | _ => ""
      }

    /* PAYMENT LOGS (AUDIT TRAIL) */
    | PAYMENT_LOGS =>
      switch methodType {
      | Get =>
        switch id {
        | Some(payment_id) => `analytics/v1/api_event_logs?type=Payment&payment_id=${payment_id}`
        | None => `analytics/v1/event-logs`
        }
      | _ => ""
      }

    /* PAYOUTS ROUTING */
    | PAYOUT_DEFAULT_FALLBACK => `routing/payouts/default`
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
    | ACTIVE_PAYOUT_ROUTING => `routing/payouts/active`

    /* THREE DS ROUTING */
    | THREE_DS => `routing/decision`

    /* SURCHARGE ROUTING */
    | SURCHARGE => `routing/decision/surcharge`

    /* RECONCILIATION */
    | RECON => `recon/${(reconType :> string)->String.toLowerCase}`

    /* REPORTS */
    | PAYMENT_REPORT => `analytics/v1/report/payments`
    | REFUND_REPORT => `analytics/v1/report/refunds`
    | DISPUTE_REPORT => `analytics/v1/report/dispute`

    /* EVENT LOGS */
    | SDK_EVENT_LOGS => `analytics/v1/sdk_event_logs`
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

    /* SAMPLE DATA */
    | GENERATE_SAMPLE_DATA => `user/sample_data`

    /* VERIFY APPLE PAY */
    | VERIFY_APPLE_PAY =>
      switch id {
      | Some(merchant_id) => `verify/apple_pay/${merchant_id}`
      | None => `verify/apple_pay`
      }

    /* PAYPAL ONBOARDING */
    | PAYPAL_ONBOARDING => `connector_onboarding`
    | PAYPAL_ONBOARDING_SYNC => `connector_onboarding/sync`
    | ACTION_URL => `connector_onboarding/action_url`
    | RESET_TRACKING_ID => `connector_onboarding/reset_tracking_id`

    /* BUSINESS PROFILE */
    | BUSINESS_PROFILE =>
      switch id {
      | Some(id) => `account/${merchantId}/business_profile/${id}`
      | None => `account/${merchantId}/business_profile`
      }

    /* API KEYS */
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

    /* DISPUTES EVIDENCE */
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

    /* PMTS COUNTRY-CURRENCY DETAILS */
    | PAYMENT_METHOD_CONFIG => `payment_methods/filter`

    /* USER MANAGEMENT */
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

    /* USERS */
    | USERS =>
      let userUrl = `user`

      switch userType {
      // DASHBOARD LOGIN / SIGNUP
      | #CONNECT_ACCOUNT =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/connect_account?${params}`
        | None => `${userUrl}/connect_account`
        }
      | #SIGNINV2 => `${userUrl}/v2/signin`
      | #SIGNINV2_TOKEN_ONLY => `${userUrl}/v2/signin?token_only=true`
      | #CHANGE_PASSWORD => `${userUrl}/change_password`
      | #SIGNUP
      | #SIGNOUT
      | #RESET_PASSWORD
      | #VERIFY_EMAIL_REQUEST
      | #FORGOT_PASSWORD
      | #ROTATE_PASSWORD =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }
      | #SIGNUP_TOKEN_ONLY => `${userUrl}/signup?token_only=true`
      | #RESET_PASSWORD_TOKEN_ONLY => `${userUrl}/reset_password?token_only=true`

      // POST LOGIN QUESTIONARE
      | #SET_METADATA =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }

      // USER DATA
      | #USER_DATA =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/data?${params}`
        | None => `${userUrl}/data`
        }
      | #MERCHANT_DATA => `${userUrl}/data`
      | #USER_INFO => userUrl

      // USER PERMISSIONS
      | #GET_PERMISSIONS =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/role?${params}`
        | None => `${userUrl}/role`
        }
      | #PERMISSION_INFO =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }

      // USER ACTIONS
      | #USER_DELETE => `${userUrl}/user/delete`
      | #USER_UPDATE => `${userUrl}/update`
      | #UPDATE_ROLE => `${userUrl}/user/${(userType :> string)->String.toLowerCase}`

      // INVITATION INSIDE DASHBOARD
      | #RESEND_INVITE
      | #INVITE_MULTIPLE =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/user/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/user/${(userType :> string)->String.toLowerCase}`
        }
      | #INVITE_MULTIPLE_TOKEN_ONLY =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/user/invite_multiple?${params}&token_only=true`
        | None => `${userUrl}/user/invite_multiple?token_only=true`
        }

      // SWITCH & CREATE MERCHANT
      | #SWITCH_MERCHANT =>
        switch methodType {
        | Get => `${userUrl}/switch/list`
        | _ => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }
      | #CREATE_MERCHANT =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }

      // CREATE ROLES
      | #CREATE_CUSTOM_ROLE => `${userUrl}/role`
      | #ACCEPT_INVITE => `${userUrl}/user/invite/accept`

      // EMAIL FLOWS
      | #FROM_EMAIL => `${userUrl}/from_email`
      | #VERIFY_EMAILV2 => `${userUrl}/v2/verify_email`
      | #ACCEPT_INVITE_FROM_EMAIL =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
        | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
        }

      // SPT FLOWS (Merchant select)
      | #ACCEPT_INVITE_TOKEN_ONLY => `${userUrl}/user/invite/accept?token_only=true`
      | #MERCHANTS_SELECT => `${userUrl}/merchants_select/list`

      // SPT FLOWS (Totp)
      | #BEGIN_TOTP => `${userUrl}/2fa/totp/begin`
      | #VERIFY_TOTP => `${userUrl}/2fa/totp/verify`
      | #VERIFY_RECOVERY_CODE => `${userUrl}/2fa/recovery_code/verify`
      | #GENERATE_RECOVERY_CODES => `${userUrl}/2fa/recovery_code/generate`
      | #TERMINATE_TWO_FACTOR_AUTH =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/2fa/terminate?${params}`
        | None => `${userUrl}/2fa/terminate`
        }

      | #CHECK_TWO_FACTOR_AUTH_STATUS => `${userUrl}/2fa`
      | #RESET_TOTP => `${userUrl}/2fa/totp/reset`

      // SPT FLOWS (SSO)
      | #GET_AUTH_LIST =>
        switch queryParamerters {
        | Some(params) => `${userUrl}/auth/list?${params}`
        | None => `${userUrl}/auth/list`
        }
      | #SIGN_IN_WITH_SSO => `${userUrl}/oidc`
      | #AUTH_SELECT => `${userUrl}/auth/select`

      // SPT EMAIL FLOWS
      | #VERIFY_EMAILV2_TOKEN_ONLY => `${userUrl}/v2/verify_email?token_only=true`
      | #ACCEPT_INVITE_FROM_EMAIL_TOKEN_ONLY =>
        `${userUrl}/accept_invite_from_email?token_only=true`

      | #NONE => ""
      }

    /* TO BE CHECKED */
    | INTEGRATION_DETAILS => `user/get_sandbox_integration_details`
    }
    `${Window.env.apiBaseUrl}/${endpoint}`
  }
  getUrl
}
let useHandleLogout = () => {
  let getURL = useGetURL()
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let clearRecoilValue = ClearRecoilValueHook.useClearRecoilValue()
  let fetchApi = AuthHooks.useApiFetcher()

  () => {
    try {
      let logoutUrl = getURL(~entityName=USERS, ~methodType=Post, ~userType=#SIGNOUT)
      open Promise
      let _ =
        fetchApi(logoutUrl, ~method_=Post)
        ->then(Fetch.Response.json)
        ->then(json => {
          json->resolve
        })
        ->catch(_err => {
          JSON.Encode.null->resolve
        })
      setAuthStateToLogout()
      setIsSidebarExpanded(_ => false)
      clearRecoilValue()
      AuthUtils.redirectToLogin()
      LocalStorage.clear()
    } catch {
    | _ => LocalStorage.clear()
    }
  }
}

let sessionExpired = ref(false)

let responseHandler = async (
  ~res,
  ~showToast: ToastState.showToastFn,
  ~showErrorToast: bool,
  ~showPopUp: PopUpState.popUpProps => unit,
  ~isPlayground,
  ~popUpCallBack,
  ~handleLogout,
) => {
  let json = try {
    await res->(res => res->Fetch.Response.json)
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
            showToast(~toastType=ToastWarning, ~message="Session Expired", ~autoClose=false)
            handleLogout()->ignore
            AuthUtils.redirectToLogin()
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
        showToast(~toastType=ToastError, ~message="Something Went Wrong", ~autoClose=false)
      }
      Exn.raiseError("Failed to Fetch")
    }
  }
}

let useGetMethod = (~showErrorToast=true) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let handleLogout = useHandleLogout()
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
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
          _ => handleLogout()->ignore
        },
      },
    })

  async url => {
    try {
      let res = await fetchApi(url, ~method_=Get)
      await responseHandler(
        ~res,
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
        ~handleLogout,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useUpdateMethod = (~showErrorToast=true) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let handleLogout = useHandleLogout()
  let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

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
          _ => handleLogout()->ignore
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
  ) => {
    try {
      let res = await fetchApi(
        url,
        ~method_=method,
        ~bodyStr=body->JSON.stringify,
        ~bodyFormData,
        ~headers,
        ~contentType,
      )
      await responseHandler(
        ~res,
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~showPopUp,
        ~popUpCallBack,
        ~handleLogout,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
