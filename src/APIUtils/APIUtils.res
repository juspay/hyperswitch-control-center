open LogicUtils
open APIUtilsTypes
exception JsonException(JSON.t)

let getV2Url = (
  ~entityName: v2entityNameType,
  ~userType: userType=#NONE,
  ~methodType: Fetch.requestMethod,
  ~id=None,
  ~profileId,
  ~merchantId,
  ~queryParamerters: option<string>=None,
) => {
  let connectorBaseURL = "v2/connector-accounts"
  let peymantsBaseURL = "v2/payments"

  switch entityName {
  | CUSTOMERS =>
    switch (methodType, id) {
    | (Get, None) => "v2/customers/list"
    | (Get, Some(customerId)) => `v2/customers/${customerId}`
    | _ => ""
    }
  | V2_CONNECTOR =>
    switch methodType {
    | Get =>
      switch id {
      | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
      | None => `v2/profiles/${profileId}/connector-accounts`
      }
    | Put =>
      switch id {
      | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
      | None => connectorBaseURL
      }
    | Post =>
      switch id {
      | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
      | None => connectorBaseURL
      }
    | _ => ""
    }
  | V2_ORDERS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParamerters {
        | Some(queryParams) => `${peymantsBaseURL}/${key_id}?${queryParams}`
        | None => `${peymantsBaseURL}/${key_id}/get-intent`
        }
      | None =>
        switch queryParamerters {
        | Some(queryParams) => `${peymantsBaseURL}/list?${queryParams}`
        | None => `${peymantsBaseURL}/list?limit=100`
        }
      }
    | _ => ""
    }
  | V2_ATTEMPTS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => `${peymantsBaseURL}/${key_id}/list_attempts`
      | None => ""
      }
    | _ => ""
    }
  | PROCESS_TRACKER =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => `v2/process_tracker/revenue_recovery_workflow/${key_id}`
      | None => "v2/process_tracker/revenue_recovery_workflow"
      }
    | _ => ""
    }
  | V2_ORDER_FILTERS => "v2/payments/profile/filter"
  | PAYMENT_METHOD_LIST =>
    switch id {
    | Some(customerId) => `v2/customers/${customerId}/saved-payment-methods`
    | None => ""
    }
  | TOTAL_TOKEN_COUNT => `v2/customers/total-payment-methods`
  | RETRIEVE_PAYMENT_METHOD =>
    switch id {
    | Some(paymentMethodId) => `v2/payment-methods/${paymentMethodId}`
    | None => ""
    }
  /* MERCHANT ACCOUNT DETAILS (Get,Post and Put) */
  | MERCHANT_ACCOUNT => `v2/merchant-accounts/${merchantId}`
  | USERS =>
    let userUrl = `user`
    switch userType {
    | #CREATE_MERCHANT =>
      switch queryParamerters {
      | Some(params) => `v2/${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
      | None => `v2/${userUrl}/${(userType :> string)->String.toLowerCase}`
      }
    | #LIST_MERCHANT => `v2/${userUrl}/list/merchant`
    | #SWITCH_MERCHANT_NEW => `v2/${userUrl}/switch/merchant`

    | #LIST_PROFILE => `v2/${userUrl}/list/profile`
    | _ => ""
    }
  }
}

let useGetURL = () => {
  let {getUserInfoData} = React.useContext(UserInfoProvider.defaultContext)

  let getUrl = (
    ~entityName: entityTypeWithVersion,
    ~methodType: Fetch.requestMethod,
    ~id=None,
    ~connector=None,
    ~userType: userType=#NONE,
    ~userRoleTypes: userRoleTypes=NONE,
    ~reconType: reconType=#NONE,
    ~hyperswitchReconType: hyperswitchReconType=#NONE,
    ~hypersenseType: hypersenseType=#NONE,
    ~queryParamerters: option<string>=None,
  ) => {
    let {transactionEntity, analyticsEntity, userEntity, merchantId, profileId} = getUserInfoData()
    let connectorBaseURL = `account/${merchantId}/connectors`
    let recoveryAnalyticsDemo = "revenue-recovery-demo"
    let reconBaseURL = `hyperswitch-recon-engine`

    let endpoint = switch entityName {
    | V1(entityNameType) =>
      switch entityNameType {
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

      /* ORGANIZATION UPDATE */
      | UPDATE_ORGANIZATION =>
        switch methodType {
        | Put =>
          switch id {
          | Some(id) => `organization/${id}`
          | None => `organization`
          }
        | _ => ""
        }

      /* CUSTOMERS DETAILS */
      | CUSTOMERS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(customerId) => `customers/${customerId}`
          | None =>
            switch queryParamerters {
            | Some(queryParams) => `customers/list?${queryParams}`
            | None => `customers/list?limit=500`
            }
          }
        | _ => ""
        }
      | PAYMENT_METHODS =>
        switch methodType {
        | Get => "payemnt_methods"
        | _ => ""
        }
      | PAYMENT_METHODS_DETAILS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => `payemnt_methods/${id}`
          | None => `payemnt_methods`
          }
        | _ => ""
        }

      /* CONNECTORS & FRAUD AND RISK MANAGEMENT */
      | FRAUD_RISK_MANAGEMENT | CONNECTOR =>
        switch methodType {
        | Get =>
          switch id {
          | Some(connectorID) => `${connectorBaseURL}/${connectorID}`
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              `account/${merchantId}/profile/connectors`
            }
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
      | REFUND_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => `refunds/v2/filter`
          | #Profile => `refunds/v2/profile/filter`
          | _ => `refunds/v2/filter`
          }

        | _ => ""
        }
      | ORDER_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => `payments/v2/filter`
          | #Profile => `payments/v2/profile/filter`
          | _ => `payments/v2/filter`
          }

        | _ => ""
        }
      | DISPUTE_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Profile => `disputes/profile/filter`
          | #Merchant
          | _ => `disputes/filter`
          }

        | _ => ""
        }
      | PAYOUTS_FILTERS =>
        switch methodType {
        | Post =>
          switch transactionEntity {
          | #Merchant => `payouts/filter`
          | #Profile => `payouts/profile/filter`
          | _ => `payouts/filter`
          }

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
            switch transactionEntity {
            | #Merchant => `payments/list?limit=100`
            | #Profile => `payments/profile/list?limit=100`
            | _ => `payments/list?limit=100`
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => `payments/list`
          | #Profile => `payments/profile/list`
          | _ => `payments/list`
          }

        | _ => ""
        }
      | ORDERS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Merchant => `payments/aggregate?${queryParams}`
            | #Profile => `payments/profile/aggregate?${queryParams}`
            | _ => `payments/aggregate?${queryParams}`
            }
          | None => `payments/aggregate`
          }
        | _ => `payments/aggregate`
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
            | Some(queryParams) =>
              switch transactionEntity {
              | #Merchant => `refunds/list?${queryParams}`
              | #Profile => `refunds/profile/list?limit=100`
              | _ => `refunds/list?limit=100`
              }
            | None => `refunds/list?limit=100`
            }
          }
        | Post =>
          switch id {
          | Some(_keyid) =>
            switch transactionEntity {
            | #Merchant => `refunds/list`
            | #Profile => `refunds/profile/list`
            | _ => `refunds/list`
            }
          | None => `refunds`
          }
        | _ => ""
        }
      | REFUNDS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => `refunds/profile/aggregate?${queryParams}`
            | #Merchant
            | _ =>
              `refunds/aggregate?${queryParams}`
            }
          | None => `refunds/aggregate`
          }
        | _ => `refunds/aggregate`
        }
      | DISPUTES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(dispute_id) => `disputes/${dispute_id}`
          | None =>
            switch queryParamerters {
            | Some(queryParams) =>
              switch transactionEntity {
              | #Profile => `disputes/profile/list?${queryParams}&limit=10000`
              | #Merchant
              | _ =>
                `disputes/list?${queryParams}&limit=10000`
              }
            | None =>
              switch transactionEntity {
              | #Profile => `disputes/profile/list?limit=10000`
              | #Merchant
              | _ => `disputes/list?limit=10000`
              }
            }
          }
        | _ => ""
        }
      | DISPUTES_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => `disputes/profile/aggregate?${queryParams}`
            | #Merchant
            | _ =>
              `disputes/aggregate?${queryParams}`
            }
          | None => `disputes/aggregate`
          }
        | _ => `disputes/aggregate`
        }
      | PAYOUTS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(payout_id) => `payouts/${payout_id}`
          | None =>
            switch transactionEntity {
            | #Merchant => `payouts/list?limit=100`
            | #Profile => `payouts/profile/list?limit=10000`
            | _ => `payouts/list?limit=100`
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => `payouts/list`
          | #Profile => `payouts/profile/list`
          | _ => `payouts/list`
          }

        | _ => ""
        }

      /* ROUTING */
      | DEFAULT_FALLBACK => `routing/default`
      | ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => `routing/${routingId}`
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile => `routing/list/profile`
            }
          }
        | Post =>
          switch id {
          | Some(routing_id) => `routing/${routing_id}/activate`
          | _ => `routing`
          }
        | _ => ""
        }
      | ACTIVE_ROUTING => `routing/active`
      | ENABLE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch queryParamerters {
          | Some(param) =>
            `account/${merchantId}/business_profile/${profileId}/dynamic_routing/success_based/toggle?${param}`
          | None => ""
          }
        | _ => ""
        }
      | SET_CONFIG_AUTH_RATE_ROUTING =>
        switch methodType {
        | Patch =>
          switch id {
          | Some(id) =>
            `account/${merchantId}/business_profile/${profileId}/dynamic_routing/success_based/config/${id}`
          | None => ""
          }
        | _ => ""
        }
      | ACTIVATE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch id {
          | Some(id) => `routing/${id}/activate`
          | None => ""
          }
        | _ => ""
        }
      | SET_VOLUME_SPLIT =>
        switch methodType {
        | Post =>
          switch queryParamerters {
          | Some(param) =>
            `account/${merchantId}/business_profile/${profileId}/dynamic_routing/set_volume_split?${param}`
          | None => ""
          }
        | _ => ""
        }
      | GET_VOLUME_SPLIT =>
        switch methodType {
        | Get =>
          `account/${merchantId}/business_profile/${profileId}/dynamic_routing/get_volume_split`
        | _ => ""
        }
      /* ANALYTICS V2 */

      | ANALYTICS_PAYMENTS_V2 =>
        switch methodType {
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              `analytics/v2/org/metrics/${domain}`
            | #Merchant => `analytics/v2/merchant/metrics/${domain}`
            | #Profile => `analytics/v2/profile/metrics/${domain}`
            }

          | _ => ""
          }
        | _ => ""
        }

      /* ANALYTICS */
      | ANALYTICS_REFUNDS
      | ANALYTICS_PAYMENTS
      | ANALYTICS_DISPUTES
      | ANALYTICS_AUTHENTICATION =>
        switch methodType {
        | Get =>
          switch id {
          // Need to write seperate enum for info api
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              `analytics/v1/org/${domain}/info`
            | #Merchant => `analytics/v1/merchant/${domain}/info`
            | #Profile => `analytics/v1/profile/${domain}/info`
            }

          | _ => ""
          }
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              `analytics/v1/org/metrics/${domain}`
            | #Merchant => `analytics/v1/merchant/metrics/${domain}`
            | #Profile => `analytics/v1/profile/metrics/${domain}`
            }

          | _ => ""
          }
        | _ => ""
        }
      | ANALYTICS_AUTHENTICATION_V2 =>
        switch methodType {
        | Get =>
          switch analyticsEntity {
          | #Tenant
          | #Organization => `analytics/v1/org/auth_events/info`
          | #Merchant => `analytics/v1/merchant/auth_events/info`
          | #Profile => `analytics/v1/profile/auth_events/info`
          }
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization => `analytics/v1/org/metrics/auth_events`
          | #Merchant => `analytics/v1/merchant/metrics/auth_events`
          | #Profile => `analytics/v1/profile/metrics/auth_events`
          }

        | _ => ""
        }
      | ANALYTICS_AUTHENTICATION_V2_FILTERS =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization => `analytics/v1/org/filters/auth_events`
          | #Merchant => `analytics/v1/merchant/filters/auth_events`
          | #Profile => `analytics/v1/profile/filters/auth_events`
          }
        | _ => ""
        }
      | ANALYTICS_FILTERS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              `analytics/v1/org/filters/${domain}`
            | #Merchant => `analytics/v1/merchant/filters/${domain}`
            | #Profile => `analytics/v1/profile/filters/${domain}`
            }

          | _ => ""
          }
        | _ => ""
        }

      | API_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(params) => `analytics/v1/profile/api_event_logs?${params}`
          | None => ``
          }
        | _ => ""
        }
      | ANALYTICS_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization => `analytics/v1/org/metrics/sankey`
          | #Merchant => `analytics/v1/merchant/metrics/sankey`
          | #Profile => `analytics/v1/profile/metrics/sankey`
          }

        | _ => ""
        }
      | ANALYTICS_SCA_EXEMPTION_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization => `analytics/v1/org/metrics/auth_events/sankey`
          | #Merchant => `analytics/v1/merchant/metrics/auth_events/sankey`
          | #Profile => `analytics/v1/profile/metrics/auth_events/sankey`
          }

        | _ => ""
        }
      /* PAYOUTS ROUTING */
      | PAYOUT_DEFAULT_FALLBACK => `routing/payouts/default`
      | PAYOUT_ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => `routing/${routingId}`
          | _ =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile => `routing/payouts/list/profile`
            }
          }

        | Put =>
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

      /* THREE DS ROUTING */

      | THREE_DS_EXEMPTION_RULES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => `routing/${routingId}`
          | None => `routing/active?transaction_type=three_ds_authentication&limit=100`
          }
        | Post =>
          switch id {
          | Some(routing_id) => `routing/${routing_id}/activate`
          | _ => "routing"
          }
        | _ => ""
        }

      /* SURCHARGE ROUTING */
      | SURCHARGE => `routing/decision/surcharge`

      /* RECONCILIATION */
      | RECON => `recon/${(reconType :> string)->String.toLowerCase}`
      | HYPERSENSE => `hypersense/${(hypersenseType :> string)->String.toLowerCase}`

      /* REPORTS */
      | PAYMENT_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization => `analytics/v1/org/report/payments`
        | #Merchant => `analytics/v1/merchant/report/payments`
        | #Profile => `analytics/v1/profile/report/payments`
        }

      | REFUND_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization => `analytics/v1/org/report/refunds`
        | #Merchant => `analytics/v1/merchant/report/refunds`
        | #Profile => `analytics/v1/profile/report/refunds`
        }

      | DISPUTE_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization => `analytics/v1/org/report/dispute`
        | #Merchant => `analytics/v1/merchant/report/dispute`
        | #Profile => `analytics/v1/profile/report/dispute`
        }

      | AUTHENTICATION_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization => `analytics/v1/org/report/authentications`
        | #Merchant => `analytics/v1/merchant/report/authentications`
        | #Profile => `analytics/v1/profile/report/authentications`
        }

      /* EVENT LOGS */
      | SDK_EVENT_LOGS => `analytics/v1/profile/sdk_event_logs`

      | WEBHOOK_EVENTS => `events/profile/list`
      | WEBHOOK_EVENTS_ATTEMPTS =>
        switch id {
        | Some(id) => `events/${merchantId}/${id}/attempts`
        | None => `events/${merchantId}/attempts`
        }
      | WEBHOOKS_EVENTS_RETRY =>
        switch id {
        | Some(id) => `events/${merchantId}/${id}/retry`
        | None => `events/${merchantId}/retry`
        }
      | WEBHOOKS_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(params) => `analytics/v1/profile/outgoing_webhook_event_logs?${params}`
          | None => `analytics/v1/outgoing_webhook_event_logs`
          }
        | _ => ""
        }
      | CONNECTOR_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(params) => `analytics/v1/profile/connector_event_logs?${params}`
          | None => `analytics/v1/connector_event_logs`
          }
        | _ => ""
        }
      | ROUTING_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParamerters {
          | Some(params) => `analytics/v1/profile/routing_event_logs?${params}`
          | None => `analytics/v1/routing_event_logs`
          }
        | _ => ""
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
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => `account/${merchantId}/business_profile/${id}`
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              `account/${merchantId}/profile`
            }
          }

        | Post =>
          switch id {
          | Some(id) => `account/${merchantId}/business_profile/${id}`
          | None => `account/${merchantId}/business_profile`
          }
        | _ => `account/${merchantId}/business_profile`
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

      /* MERCHANT ACQUIRER */
      | ACQUIRER_CONFIG_SETTINGS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(acquirerId) => `profile_acquirer/${profileId}/${acquirerId}`
          | None => `profile_acquirer`
          }
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

      /* USER MANGEMENT REVAMP */
      | USER_MANAGEMENT => {
          let userUrl = `user`
          switch userRoleTypes {
          | USER_LIST =>
            switch queryParamerters {
            | Some(queryParams) => `${userUrl}/user/list?${queryParams}`
            | None => `${userUrl}/user/list`
            }
          | ROLE_LIST =>
            switch queryParamerters {
            | Some(queryParams) => `${userUrl}/role/list?${queryParams}`
            | None => `${userUrl}/role/list`
            }
          | ROLE_ID =>
            switch id {
            | Some(key_id) => `${userUrl}/role/${key_id}/v2`
            | None => ""
            }
          | _ => ""
          }
        }

      | HYPERSWITCH_RECON =>
        switch hyperswitchReconType {
        | #FILE_UPLOAD =>
          switch methodType {
          | Post =>
            switch id {
            | Some(accountid) => `${reconBaseURL}/accounts/${accountid}/upload`
            | None => ``
            }
          | _ => ""
          }
        | #ACCOUNTS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) => `${reconBaseURL}/accounts/${accountId}`
            | None => `${reconBaseURL}/accounts`
            }
          | _ => ""
          }
        | #TRANSACTIONS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionID) => `${reconBaseURL}/transactions/${transactionID}`
            | None => `${reconBaseURL}/transactions`
            }
          | _ => ""
          }
        | #PROCESSED_ENTRIES_LIST_WITH_ACCOUNT =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) => `${reconBaseURL}/accounts/${accountId}/entries`
            | None => ""
            }
          | _ => ""
          }
        | #PROCESSED_ENTRIES_LIST_WITH_TRANSACTION =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionId) => `${reconBaseURL}/transactions/${transactionId}/entries`
            | None => `${reconBaseURL}/entries`
            }
          | _ => ""
          }
        | #PROCESSING_ENTRIES_LIST =>
          switch methodType {
          | Get =>
            switch queryParamerters {
            | Some(queryParams) => `${reconBaseURL}/staging_entries?${queryParams}`
            | None => `${reconBaseURL}/staging_entries`
            }
          | _ => ""
          }
        | #NONE => ""
        }

      /* INTELLIGENT ROUTING */
      | GET_REVIEW_FIELDS => `dynamic-routing/simulate/baseline-review-fields`
      | SIMULATE_INTELLIGENT_ROUTING =>
        switch queryParamerters {
        | Some(queryParams) => `dynamic-routing/simulate/${merchantId}?${queryParams}`
        | None => `dynamic-routing/simulate/${merchantId}`
        }
      | INTELLIGENT_ROUTING_RECORDS =>
        switch queryParamerters {
        | Some(queryParams) => `dynamic-routing/simulate/${merchantId}/get-records?${queryParams}`
        | None => `dynamic-routing/simulate/${merchantId}/get-records`
        }
      | INTELLIGENT_ROUTING_GET_STATISTICS =>
        `dynamic-routing/simulate/${merchantId}/get-statistics`

      /* Revenue Recovery */
      | TRANSACTION_OVERVIEW => `${recoveryAnalyticsDemo}/analytics/transaction_overview`
      | RETRY_PERFORMANCE => `${recoveryAnalyticsDemo}/analytics/retry_performance`
      | MONTHLY_RETRY_SUCCESS => `${recoveryAnalyticsDemo}/analytics/monthly_retry_success`
      | RETRY_ATTEMPTS_TREND => `${recoveryAnalyticsDemo}/analytics/retry_attempts_trend`
      | ERROR_CATEGORY_ANALYSIS => `${recoveryAnalyticsDemo}/analytics/error_category_analysis`
      | RECOVERY_INVOICES => `${recoveryAnalyticsDemo}/list-invoices`
      | RECOVERY_ATTEMPTS =>
        switch queryParamerters {
        | Some(queryParams) => `${recoveryAnalyticsDemo}/list-attempts/${queryParams}`
        | None => `${recoveryAnalyticsDemo}/list-attempts`
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

        // USER GROUP ACCESS
        | #GET_GROUP_ACL => `${userUrl}/role/v2`
        | #ROLE_INFO => `${userUrl}/parent/list`

        | #GROUP_ACCESS_INFO =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/permission_info?${params}`
          | None => `${userUrl}/permission_info`
          }

        // USER ACTIONS
        | #USER_DELETE => `${userUrl}/user/delete`
        | #USER_UPDATE => `${userUrl}/update`
        | #UPDATE_ROLE => `${userUrl}/user/${(userType :> string)->String.toLowerCase}`

        // INVITATION INSIDE DASHBOARD
        | #RESEND_INVITE => `${userUrl}/user/resend_invite`
        | #ACCEPT_INVITATION_HOME => `${userUrl}/user/invite/accept`
        | #INVITE_MULTIPLE =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/user/${(userType :> string)->String.toLowerCase}?${params}`
          | None => `${userUrl}/user/${(userType :> string)->String.toLowerCase}`
          }

        // ACCEPT INVITE PRE_LOGIN
        | #ACCEPT_INVITATION_PRE_LOGIN => `${userUrl}/user/invite/accept/pre_auth`

        // CREATE_ORG
        | #CREATE_ORG => `user/create_org`
        // CREATE MERCHANT
        | #CREATE_MERCHANT =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
          | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
          }
        | #SWITCH_ORG => `${userUrl}/switch/org`
        | #SWITCH_MERCHANT_NEW => `${userUrl}/switch/merchant`
        | #SWITCH_PROFILE => `${userUrl}/switch/profile`

        // Org-Merchant-Profile List
        | #LIST_ORG => `${userUrl}/list/org`
        | #LIST_MERCHANT => `${userUrl}/list/merchant`
        | #LIST_PROFILE => `${userUrl}/list/profile`

        // CREATE ROLES
        | #CREATE_CUSTOM_ROLE => `${userUrl}/role`

        // EMAIL FLOWS
        | #FROM_EMAIL => `${userUrl}/from_email`
        | #VERIFY_EMAILV2 => `${userUrl}/v2/verify_email`
        | #ACCEPT_INVITE_FROM_EMAIL =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`
          | None => `${userUrl}/${(userType :> string)->String.toLowerCase}`
          }

        // SPT FLOWS (Totp)
        | #BEGIN_TOTP => `${userUrl}/2fa/totp/begin`
        | #CHECK_TWO_FACTOR_AUTH_STATUS_V2 => `${userUrl}/2fa/v2`
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

        // user-management revamp
        | #LIST_ROLES_FOR_INVITE =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/role/list/invite?${params}`
          | None => ""
          }
        | #LIST_INVITATION => `${userUrl}/list/invitation`
        | #USER_DETAILS => `${userUrl}/user`
        | #LIST_ROLES_FOR_ROLE_UPDATE =>
          switch queryParamerters {
          | Some(params) => `${userUrl}/role/list/update?${params}`
          | None => ""
          }

        | #NONE => ""
        }

      /* TO BE CHECKED */
      | INTEGRATION_DETAILS => `user/get_sandbox_integration_details`
      | SDK_PAYMENT => "payments"
      }

    | V2(entityNameForv2) =>
      getV2Url(
        ~entityName=entityNameForv2,
        ~userType,
        ~id,
        ~methodType,
        ~queryParamerters,
        ~profileId,
        ~merchantId,
      )
    }

    `${Window.env.apiBaseUrl}/${endpoint}`
  }
  getUrl
}

let useHandleLogout = (~eventName="user_sign_out") => {
  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  let clearRecoilValue = ClearRecoilValueHook.useClearRecoilValue()
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  () => {
    try {
      let logoutUrl = getURL(~entityName=V1(USERS), ~methodType=Post, ~userType=#SIGNOUT)
      open Promise
      mixpanelEvent(~eventName)
      let _ =
        fetchApi(logoutUrl, ~method_=Post, ~xFeatureRoute, ~forceCookies)
        ->then(Fetch.Response.json)
        ->then(json => {
          json->resolve
        })
        ->catch(_err => {
          JSON.Encode.null->resolve
        })
      setAuthStateToLogout()
      clearRecoilValue()
      CommonAuthUtils.clearLocalStorage()
    } catch {
    | _ => CommonAuthUtils.clearLocalStorage()
    }
  }
}

let sessionExpired = ref(false)

let responseHandler = async (
  ~url,
  ~res,
  ~showToast: ToastState.showToastFn,
  ~showErrorToast: bool,
  ~showPopUp: PopUpState.popUpProps => unit,
  ~isPlayground,
  ~popUpCallBack,
  ~handleLogout,
  ~sendEvent: (
    ~eventName: string,
    ~email: string=?,
    ~description: option<'a>=?,
    ~section: string=?,
    ~metadata: JSON.t=?,
  ) => unit,
) => {
  let json = try {
    await res->(res => res->Fetch.Response.json)
  } catch {
  | _ => JSON.Encode.null
  }

  let responseStatus = res->Fetch.Response.status
  let responseHeaders = res->Fetch.Response.headers

  if responseStatus >= 500 && responseStatus < 600 {
    let xRequestId = responseHeaders->Fetch.Headers.get("x-request-id")->Option.getOr("")
    let metaData =
      [
        ("url", url->JSON.Encode.string),
        ("response", json),
        ("status", responseStatus->JSON.Encode.int),
        ("x-request-id", xRequestId->JSON.Encode.string),
      ]->getJsonFromArrayOfJson
    sendEvent(~eventName="API Error", ~description=Some(responseStatus), ~metadata=metaData)
  }

  let noAccessControlText = "You do not have the required permissions to access this module. Please contact your admin."

  switch responseStatus {
  | 200 => json
  | _ => {
      let errorDict = json->getDictFromJsonObject->getObj("error", Dict.make())
      let errorStringifiedJson = errorDict->JSON.Encode.object->JSON.stringify

      if isPlayground && responseStatus === 403 {
        popUpCallBack()
      } else if showErrorToast {
        switch responseStatus {
        | 400 => {
            let errorCode = errorDict->getString("code", "")
            switch errorCode->CommonAuthUtils.errorSubCodeMapper {
            | HE_02 | UR_33 =>
              RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
            | _ => ()
            }
          }
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
              noAccessControlText->React.string
            },
            handleConfirm: {
              text: "Close",
              onClick: {
                _ => ()
              },
            },
          })

        | 404 => {
            let errorCode = errorDict->getString("code", "")
            switch errorCode->CommonAuthUtils.errorSubCodeMapper {
            | HE_02 => RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
            | _ => ()
            }
          }
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
  let {userInfo: {merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let handleLogout = useHandleLogout()
  let sendEvent = MixpanelHook.useSendEvent()
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
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  async (url, ~version=UserInfoTypes.V1) => {
    try {
      let res = await fetchApi(
        url,
        ~method_=Get,
        ~xFeatureRoute,
        ~forceCookies,
        ~merchantId,
        ~profileId,
        ~version,
      )
      await responseHandler(
        ~url,
        ~res,
        ~showErrorToast,
        ~showToast,
        ~showPopUp,
        ~isPlayground,
        ~popUpCallBack,
        ~handleLogout,
        ~sendEvent,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useUpdateMethod = (~showErrorToast=true) => {
  let {userInfo: {merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let handleLogout = useHandleLogout()
  let sendEvent = MixpanelHook.useSendEvent()
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
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  async (
    url,
    body,
    method,
    ~bodyFormData=?,
    ~headers=Dict.make(),
    ~contentType=AuthHooks.Headers("application/json"),
    ~version=UserInfoTypes.V1,
  ) => {
    try {
      let res = await fetchApi(
        url,
        ~method_=method,
        ~bodyStr=body->JSON.stringify,
        ~bodyFormData,
        ~headers,
        ~contentType,
        ~xFeatureRoute,
        ~forceCookies,
        ~merchantId,
        ~profileId,
        ~version,
      )
      await responseHandler(
        ~url,
        ~res,
        ~showErrorToast,
        ~showToast,
        ~isPlayground,
        ~showPopUp,
        ~popUpCallBack,
        ~handleLogout,
        ~sendEvent,
      )
    } catch {
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
