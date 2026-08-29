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
  ~transactionEntity,
  ~queryParameters: option<string>=None,
): endpoint => {
  let connectorBaseURL = "v2/connector-accounts"
  let paymentsBaseURL = "v2/payments"

  switch entityName {
  | CUSTOMERS =>
    switch (methodType, id) {
    | (Get, None) => Default("v1/customers/list")
    | (Get, Some(customerId)) => Default(`v1/customers/${customerId}`)
    | _ => Default("")
    }
  | CUSTOMERS_COUNT =>
    switch (methodType, id) {
    | (Get, None) => Default("v1/customers/list_with_count")
    | (Get, Some(customerId)) => Default(`v1/customers/${customerId}`)
    | _ => Default("")
    }
  | V2_CONNECTOR =>
    switch methodType {
    | Get =>
      switch id {
      | Some(connectorID) => Default(`${connectorBaseURL}/${connectorID}`)
      | None => Default(`v2/profiles/${profileId}/connector-accounts`)
      }
    | Put =>
      switch id {
      | Some(connectorID) => Default(`${connectorBaseURL}/${connectorID}`)
      | None => Default(connectorBaseURL)
      }
    | Post =>
      switch id {
      | Some(connectorID) => Default(`${connectorBaseURL}/${connectorID}`)
      | None => Default(connectorBaseURL)
      }
    | _ => Default("")
    }
  | V2_ORDERS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParameters {
        | Some(queryParams) => Default(`${paymentsBaseURL}/${key_id}?${queryParams}`)
        | None => Default(`${paymentsBaseURL}/${key_id}`)
        }
      | None =>
        switch queryParameters {
        | Some(queryParams) => Default(`${paymentsBaseURL}/list?${queryParams}`)
        | None => Default(`${paymentsBaseURL}/list?limit=100`)
        }
      }
    | _ => Default("")
    }
  | V2_RECOVERY_INVOICES_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParameters {
        | Some(queryParams) => Default(`${paymentsBaseURL}/${key_id}?${queryParams}`)
        | None => Default(`${paymentsBaseURL}/${key_id}/get-revenue-recovery-intent`)
        }
      | None =>
        switch queryParameters {
        | Some(queryParams) => Default(`${paymentsBaseURL}/recovery-list?${queryParams}`)
        | None => Default(`${paymentsBaseURL}/recovery-list?limit=100`)
        }
      }
    | _ => Default("")
    }
  /* REPORTS */
  | REVENUE_RECOVERY_REPORT =>
    switch transactionEntity {
    | #Tenant
    | #Organization =>
      Default(`v2/analytics/org/report/payments`)
    | #Merchant => Default(`v2/analytics/merchant/report/payments`)
    | #Profile => Default(`v2/analytics/profile/report/payments`)
    }
  | V2_ATTEMPTS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => Default(`${paymentsBaseURL}/${key_id}/list_attempts`)
      | None => Default("")
      }
    | _ => Default("")
    }
  | PROCESS_TRACKER =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => Default(`v2/process_tracker/revenue_recovery_workflow/${key_id}`)
      | None => Default("v2/process_tracker/revenue_recovery_workflow")
      }
    | _ => Default("")
    }
  | V2_ORDER_FILTERS => Default("v2/payments/profile/filter")
  | V2_ORDERS_AGGREGATE =>
    switch methodType {
    | Get =>
      switch queryParameters {
      | Some(queryParams) =>
        switch transactionEntity {
        | #Merchant => Default(`v2/payments/aggregate?${queryParams}`)
        | #Profile => Default(`v2/payments/profile/aggregate?${queryParams}`)
        | _ => Default(`v2/payments/aggregate?${queryParams}`)
        }
      | None => Default(``)
      }
    | _ => Default(``)
    }
  | PAYMENT_METHOD_LIST =>
    switch id {
    | Some(customerId) => Default(`v1/customers/${customerId}/saved-payment-methods`)
    | None => Default("")
    }
  | TOTAL_TOKEN_COUNT => Default(`v1/customers/total-payment-methods`)
  | RETRIEVE_PAYMENT_METHOD =>
    switch id {
    | Some(paymentMethodId) => Default(`v1/payment-methods/${paymentMethodId}/details`)
    | None => Default("")
    }
  /* MERCHANT ACCOUNT DETAILS (Get,Post and Put) */
  | MERCHANT_ACCOUNT => Default(`v2/merchant-accounts/${merchantId}`)
  | USERS =>
    let userUrl = `user`
    switch userType {
    | #CREATE_MERCHANT =>
      switch queryParameters {
      | Some(params) =>
        Default(`v2/${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
      | None => Default(`v2/${userUrl}/${(userType :> string)->String.toLowerCase}`)
      }
    | #LIST_MERCHANT => Default(`v2/${userUrl}/list/merchant`)
    | #SWITCH_MERCHANT_NEW => Default(`v2/${userUrl}/switch/merchant`)
    | #SWITCH_PROFILE_NEW => Default(`v2/${userUrl}/switch/profile`)

    | #LIST_PROFILE => Default(`v2/${userUrl}/list/profile`)
    | _ => Default("")
    }
  /* API KEYS */
  | API_KEYS =>
    switch methodType {
    | Get => Default(`v2/api-keys/list`)
    | Post
    | Put
    | Delete =>
      switch id {
      | Some(key_id) => Default(`v2/api-keys/${key_id}`)
      | None => Default(`v2/api-keys`)
      }
    | _ => Default("")
    }
  | BUSINESS_PROFILE =>
    switch methodType {
    | Get =>
      switch id {
      | Some(id) => Default(`v2/profiles/${id}`)
      | None => Default(`v2/profiles`)
      }

    | Post =>
      switch id {
      | Some(id) => Default(`v2/profiles/${id}`)
      | None => Default(`v2/profiles`)
      }
    | Put =>
      switch id {
      | Some(id) => Default(`v2/profiles/${id}`)
      | None => Default(`v2/profiles`)
      }

    | _ => Default(`v2/profiles`)
    }
  | REFUNDS =>
    switch methodType {
    | Post => Default(`v2/refunds`)
    | _ => Default("")
    }
  }
}

let resolveEndpoint = endpoint =>
  switch endpoint {
  | Olap(path) =>
    Window.env.olapPrefix->String.length > 0 ? `${Window.env.olapPrefix}/${path}` : path
  | Default(path) => path
  }

let useGetURL = () => {
  let {getCommonSessionDetails, state} = React.useContext(UserInfoProvider.defaultContext)
  let {merchantId, profileId} = getCommonSessionDetails()

  let getUrl = (
    ~entityName: entityTypeWithVersion,
    ~methodType: Fetch.requestMethod,
    ~id=None,
    ~connector=None,
    ~userType: userType=#NONE,
    ~userRoleTypes: userRoleTypes=NONE,
    ~hyperswitchReconType: hyperswitchReconType=#NONE,
    ~hypersenseType: hypersenseType=#NONE,
    ~queryParameters: option<string>=None,
  ) => {
    let (transactionEntity, analyticsEntity, userEntity) = switch state {
    | DashboardSession(userInfo) => (
        userInfo.transactionEntity,
        userInfo.analyticsEntity,
        userInfo.userEntity,
      )
    | EmbeddableSession(_) => (#Merchant, #Merchant, #Merchant)
    }

    let connectorBaseURL = `account/${merchantId}/connectors`
    let recoveryAnalyticsDemo = "revenue-recovery-demo"
    let reconBaseURL = `hyperswitch-recon-engine`

    let endpoint: endpoint = switch entityName {
    | V1(entityNameType) =>
      switch entityNameType {
      /* GLOBAL SEARCH */
      | GLOBAL_SEARCH =>
        switch methodType {
        | Post =>
          switch id {
          | Some(topic) => Default(`analytics/v1/search/${topic}`)
          | None => Default(`analytics/v1/search`)
          }
        | _ => Default("")
        }

      /* BLOCKLIST */
      | BLOCKLIST_BATCH =>
        switch methodType {
        | Get =>
          switch id {
          | Some(jobId) => Default(`blocklist/batch/${jobId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => Default(`blocklist/batch?${queryParams}`)
            | None => Default(`blocklist/batch`)
            }
          }
        | Post => Default(`blocklist/batch`)
        | _ => Default("")
        }
      | BLOCKLIST =>
        switch methodType {
        | Post | Delete => Default(`blocklist`)
        | _ => Default("")
        }

      /* MERCHANT ACCOUNT DETAILS (Get and Post) */
      | MERCHANT_ACCOUNT => Default(`accounts/${merchantId}`)

      /* ORGANIZATION UPDATE */
      | ORGANIZATION_RETRIEVE =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => Default(`organization/${id}`)
          | None => Default(``)
          }
        | Put =>
          switch id {
          | Some(id) => Default(`organization/${id}`)
          | None => Default(`organization`)
          }
        | _ => Default("")
        }

      /* CUSTOMERS DETAILS */
      | CUSTOMERS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(customerId) => Default(`customers/${customerId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => Olap(`customers/list?${queryParams}`)
            | None => Olap(`customers/list?limit=100`)
            }
          }
        | _ => Default("")
        }
      | CUSTOMERS_COUNT =>
        switch methodType {
        | Get =>
          switch id {
          | Some(customerId) => Default(`customers/${customerId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => Olap(`customers/list_with_count?${queryParams}`)
            | None => Olap(`customers/list_with_count`)
            }
          }
        | _ => Default("")
        }
      | PAYMENT_METHODS =>
        switch methodType {
        | Get => Default("payment_methods")
        | _ => Default("")
        }
      | PAYMENT_METHODS_DETAILS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => Default(`payment_methods/${id}`)
          | None => Default(`payment_methods`)
          }
        | _ => Default("")
        }

      /* CONNECTORS & FRAUD AND RISK MANAGEMENT */
      | FRAUD_RISK_MANAGEMENT | CONNECTOR =>
        switch methodType {
        | Get =>
          switch id {
          | Some(connectorID) => Default(`${connectorBaseURL}/${connectorID}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              Olap(`account/${merchantId}/profile/connectors`)
            }
          }
        | Post | Delete =>
          switch connector {
          | Some(_con) => Default(`account/connectors/verify`)
          | None =>
            switch id {
            | Some(connectorID) => Default(`${connectorBaseURL}/${connectorID}`)
            | None => Default(connectorBaseURL)
            }
          }
        | _ => Default("")
        }
      | CONNECTOR_WEBHOOK =>
        switch id {
        | Some(mcaId) => `${connectorBaseURL}/webhooks/${mcaId}`
        | None => connectorBaseURL
        }

      /* OPERATIONS */
      | REFUND_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => Default(`refunds/v2/filter`)
          | #Profile => Default(`refunds/v2/profile/filter`)
          | _ => Default(`refunds/v2/filter`)
          }

        | _ => Default("")
        }
      | ORDER_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => Default(`payments/v2/filter`)
          | #Profile => Default(`payments/v2/profile/filter`)
          | _ => Default(`payments/v2/filter`)
          }

        | _ => Default("")
        }
      | DISPUTE_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Profile => Default(`disputes/profile/filter`)
          | #Merchant
          | _ =>
            Default(`disputes/filter`)
          }

        | _ => Default("")
        }
      | PAYOUTS_FILTERS =>
        switch methodType {
        | Post =>
          switch transactionEntity {
          | #Merchant => Olap(`payouts/filter`)
          | #Profile => Olap(`payouts/profile/filter`)
          | _ => Olap(`payouts/filter`)
          }

        | _ => Default("")
        }
      | ORDERS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(key_id) =>
            switch queryParameters {
            | Some(queryParams) => Default(`payments/${key_id}?${queryParams}`)
            | None => Default(`payments/${key_id}`)
            }

          | None =>
            switch transactionEntity {
            | #Merchant => Olap(`payments/list?limit=100`)
            | #Profile => Olap(`payments/profile/list?limit=100`)
            | _ => Olap(`payments/list?limit=100`)
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => Olap(`payments/list`)
          | #Profile => Olap(`payments/profile/list`)
          | _ => Olap(`payments/list`)
          }

        | _ => Default("")
        }
      | PAYMENT_CANCEL =>
        switch (methodType, id) {
        | (Post, Some(payment_id)) => Default(`payments/${payment_id}/cancel`)
        | _ => Default("")
        }
      | PAYMENT_CAPTURE =>
        switch (methodType, id) {
        | (Post, Some(payment_id)) => Default(`payments/${payment_id}/capture`)
        | _ => Default("")
        }
      | ORDERS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Merchant => Default(`payments/aggregate?${queryParams}`)
            | #Profile => Default(`payments/profile/aggregate?${queryParams}`)
            | _ => Default(`payments/aggregate?${queryParams}`)
            }
          | None => Default(`payments/aggregate`)
          }
        | _ => Default(`payments/aggregate`)
        }
      | MANUAL_STATUS_UPDATE =>
        switch methodType {
        | Post =>
          switch id {
          | Some(payment_id) => Default(`payments/${payment_id}/manual-status-update`)
          | None => Default("")
          }
        | _ => Default("")
        }
      | REFUNDS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(key_id) =>
            switch queryParameters {
            | Some(queryParams) => Default(`refunds/${key_id}?${queryParams}`)
            | None => Default(`refunds/${key_id}`)
            }

          | None =>
            switch queryParameters {
            | Some(queryParams) =>
              switch transactionEntity {
              | #Merchant => Default(`refunds/list?${queryParams}`)
              | #Profile => Default(`refunds/profile/list?limit=100`)
              | _ => Default(`refunds/list?limit=100`)
              }
            | None => Default(`refunds/list?limit=100`)
            }
          }
        | Post =>
          switch id {
          | Some(_keyid) =>
            switch transactionEntity {
            | #Merchant => Olap(`refunds/list`)
            | #Profile => Olap(`refunds/profile/list`)
            | _ => Olap(`refunds/list`)
            }
          | None => Default(`refunds`)
          }
        | _ => Default("")
        }
      | REFUNDS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => Default(`refunds/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              Default(`refunds/aggregate?${queryParams}`)
            }
          | None => Default(`refunds/aggregate`)
          }
        | _ => Default(`refunds/aggregate`)
        }
      | DISPUTES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(dispute_id) => Default(`disputes/${dispute_id}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) =>
              switch transactionEntity {
              | #Profile => Olap(`disputes/profile/list?${queryParams}`)
              | #Merchant
              | _ =>
                Olap(`disputes/list?${queryParams}`)
              }
            | None =>
              switch transactionEntity {
              | #Profile => Olap(`disputes/profile/list?limit=100`)
              | #Merchant
              | _ =>
                Olap(`disputes/list?limit=100`)
              }
            }
          }
        | _ => Default("")
        }
      | DISPUTES_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => Default(`disputes/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              Default(`disputes/aggregate?${queryParams}`)
            }
          | None => Default(`disputes/aggregate`)
          }
        | _ => Default(`disputes/aggregate`)
        }
      | PAYOUTS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => Default(`payouts/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              Default(`payouts/aggregate?${queryParams}`)
            }
          | None => Default(`payouts/aggregate`)
          }
        | _ => Default(`payouts/aggregate`)
        }
      | PAYOUTS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(payout_id) =>
            switch queryParameters {
            | Some(queryParams) => Default(`payouts/${payout_id}?${queryParams}`)
            | None => Default(`payouts/${payout_id}`)
            }
          | None =>
            switch transactionEntity {
            | #Merchant => Olap(`payouts/list?limit=100`)
            | #Profile => Olap(`payouts/profile/list?limit=100`)
            | _ => Olap(`payouts/list?limit=100`)
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => Olap(`payouts/list`)
          | #Profile => Olap(`payouts/profile/list`)
          | _ => Olap(`payouts/list`)
          }

        | _ => Default("")
        }

      /* ROUTING */
      | DEFAULT_FALLBACK => Default(`routing/default`)
      | ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => Default(`routing/${routingId}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              Olap(`routing/list/profile`)
            }
          }
        | Post =>
          switch id {
          | Some(routing_id) => Default(`routing/${routing_id}/activate`)
          | _ => Default(`routing`)
          }
        | _ => Default("")
        }
      | ACTIVE_ROUTING => Default(`routing/active`)
      | CREATE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch queryParameters {
          | Some(param) =>
            Default(
              `account/${merchantId}/business_profile/${profileId}/dynamic_routing/success_based/create?${param}`,
            )
          | None => Default("")
          }
        | _ => Default("")
        }
      | ACTIVATE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch id {
          | Some(id) => Default(`routing/${id}/activate`)
          | None => Default("")
          }
        | _ => Default("")
        }
      | SET_VOLUME_SPLIT =>
        switch methodType {
        | Post =>
          switch queryParameters {
          | Some(param) =>
            Default(
              `account/${merchantId}/business_profile/${profileId}/dynamic_routing/set_volume_split?${param}`,
            )
          | None => Default("")
          }
        | _ => Default("")
        }
      | GET_VOLUME_SPLIT =>
        switch methodType {
        | Get =>
          Default(
            `account/${merchantId}/business_profile/${profileId}/dynamic_routing/get_volume_split`,
          )
        | _ => Default("")
        }

      /* OIDC */
      | OIDC_AUTHORIZE =>
        switch methodType {
        | Get => Default(`oidc/authorize`)
        | _ => Default("")
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
              Default(`analytics/v2/org/metrics/${domain}`)
            | #Merchant => Default(`analytics/v2/merchant/metrics/${domain}`)
            | #Profile => Default(`analytics/v2/profile/metrics/${domain}`)
            }

          | _ => Default("")
          }
        | _ => Default("")
        }

      /* ANALYTICS */
      | ANALYTICS_REFUNDS
      | ANALYTICS_PAYMENTS
      | ANALYTICS_DISPUTES
      | ANALYTICS_AUTHENTICATION
      | ANALYTICS_ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          // Need to write separate enum for info api
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              Default(`analytics/v1/org/${domain}/info`)
            | #Merchant => Default(`analytics/v1/merchant/${domain}/info`)
            | #Profile => Default(`analytics/v1/profile/${domain}/info`)
            }

          | _ => Default("")
          }
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              Default(`analytics/v1/org/metrics/${domain}`)
            | #Merchant => Default(`analytics/v1/merchant/metrics/${domain}`)
            | #Profile => Default(`analytics/v1/profile/metrics/${domain}`)
            }

          | _ => Default("")
          }
        | _ => Default("")
        }
      | ANALYTICS_AUTHENTICATION_V2 =>
        switch methodType {
        | Get =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            Default(`analytics/v1/org/auth_events/info`)
          | #Merchant => Default(`analytics/v1/merchant/auth_events/info`)
          | #Profile => Default(`analytics/v1/profile/auth_events/info`)
          }
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            Default(`analytics/v1/org/metrics/auth_events`)
          | #Merchant => Default(`analytics/v1/merchant/metrics/auth_events`)
          | #Profile => Default(`analytics/v1/profile/metrics/auth_events`)
          }

        | _ => Default("")
        }
      | ANALYTICS_AUTHENTICATION_V2_FILTERS =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            Default(`analytics/v1/org/filters/auth_events`)
          | #Merchant => Default(`analytics/v1/merchant/filters/auth_events`)
          | #Profile => Default(`analytics/v1/profile/filters/auth_events`)
          }
        | _ => Default("")
        }
      | ANALYTICS_FILTERS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              Default(`analytics/v1/org/filters/${domain}`)
            | #Merchant => Default(`analytics/v1/merchant/filters/${domain}`)
            | #Profile => Default(`analytics/v1/profile/filters/${domain}`)
            }

          | _ => Default("")
          }
        | _ => Default("")
        }

      | API_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => Default(`analytics/v1/profile/api_event_logs?${params}`)
          | None => Default(``)
          }
        | _ => Default("")
        }
      | ANALYTICS_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            Default(`analytics/v1/org/metrics/sankey`)
          | #Merchant => Default(`analytics/v1/merchant/metrics/sankey`)
          | #Profile => Default(`analytics/v1/profile/metrics/sankey`)
          }

        | _ => Default("")
        }
      | ANALYTICS_SCA_EXEMPTION_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            Default(`analytics/v1/org/metrics/auth_events/sankey`)
          | #Merchant => Default(`analytics/v1/merchant/metrics/auth_events/sankey`)
          | #Profile => Default(`analytics/v1/profile/metrics/auth_events/sankey`)
          }

        | _ => Default("")
        }
      /* PAYOUTS ROUTING */
      | PAYOUT_DEFAULT_FALLBACK => Default(`routing/payouts/default`)
      | PAYOUT_ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => Default(`routing/${routingId}`)
          | _ =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              Default(`routing/payouts/list/profile`)
            }
          }

        | Put =>
          switch id {
          | Some(routingId) => Default(`routing/${routingId}`)
          | _ => Default(`routing/payouts`)
          }
        | Post =>
          switch id {
          | Some(routing_id) => Default(`routing/payouts/${routing_id}/activate`)
          | _ => Default(`routing/payouts`)
          }
        | _ => Default("")
        }
      | ACTIVE_PAYOUT_ROUTING => Default(`routing/payouts/active`)

      /* THREE DS ROUTING */
      | THREE_DS => Default(`routing/decision`)

      /* THREE DS ROUTING */

      | THREE_DS_EXEMPTION_RULES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => Default(`routing/${routingId}`)
          | None => Default(`routing/active?transaction_type=three_ds_authentication&limit=100`)
          }
        | Post =>
          switch id {
          | Some(routing_id) => Default(`routing/${routing_id}/activate`)
          | _ => Default("routing")
          }
        | _ => Default("")
        }
      | THREE_DS_EXEMPTION_DELETE_RULE => Default(`routing/deactivate`)

      /* SURCHARGE ROUTING */
      | SURCHARGE => Default(`routing/decision/surcharge`)

      | HYPERSENSE => Default(`hypersense/${(hypersenseType :> string)->String.toLowerCase}`)

      /* REPORTS */
      | PAYMENT_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          Default(`analytics/v1/org/report/payments`)
        | #Merchant => Default(`analytics/v1/merchant/report/payments`)
        | #Profile => Default(`analytics/v1/profile/report/payments`)
        }
      | PAYMENTS_LIST =>
        switch methodType {
        | Post =>
          switch transactionEntity {
          | #Merchant => Default(`payments/advanced/list`)
          | #Profile => Default(`payments/profile/advanced/list`)
          | _ => Olap(`payments/list`)
          }

        | _ => Default("")
        }
      | PAYOUT_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          Default(`analytics/v1/org/report/payouts`)
        | #Merchant => Default(`analytics/v1/merchant/report/payouts`)
        | #Profile => Default(`analytics/v1/profile/report/payouts`)
        }

      | REFUND_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          Default(`analytics/v1/org/report/refunds`)
        | #Merchant => Default(`analytics/v1/merchant/report/refunds`)
        | #Profile => Default(`analytics/v1/profile/report/refunds`)
        }

      | DISPUTE_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          Default(`analytics/v1/org/report/dispute`)
        | #Merchant => Default(`analytics/v1/merchant/report/dispute`)
        | #Profile => Default(`analytics/v1/profile/report/dispute`)
        }

      | AUTHENTICATION_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          Default(`analytics/v1/org/report/authentications`)
        | #Merchant => Default(`analytics/v1/merchant/report/authentications`)
        | #Profile => Default(`analytics/v1/profile/report/authentications`)
        }

      /* EVENT LOGS */
      | SDK_EVENT_LOGS => Default(`analytics/v1/profile/sdk_event_logs`)

      | WEBHOOK_EVENTS => Olap(`events/profile/list`)
      | WEBHOOK_EVENTS_ATTEMPTS =>
        switch id {
        | Some(id) => Olap(`events/${merchantId}/${id}/attempts`)
        | None => Default(`events/${merchantId}/attempts`)
        }
      | WEBHOOKS_EVENTS_RETRY =>
        switch id {
        | Some(id) => Default(`events/${merchantId}/${id}/retry`)
        | None => Default(`events/${merchantId}/retry`)
        }
      | WEBHOOKS_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => Default(`analytics/v1/profile/outgoing_webhook_event_logs?${params}`)
          | None => Default(`analytics/v1/outgoing_webhook_event_logs`)
          }
        | _ => Default("")
        }
      | CONNECTOR_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => Default(`analytics/v1/profile/connector_event_logs?${params}`)
          | None => Default(`analytics/v1/connector_event_logs`)
          }
        | _ => Default("")
        }
      | PRISM_CONNECTOR_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => Default(`analytics/v1/profile/prism_connector_event_logs?${params}`)
          | None => Default(`analytics/v1/prism_connector_event_logs`)
          }
        | _ => Default("")
        }
      | ROUTING_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => Default(`analytics/v1/profile/routing_event_logs?${params}`)
          | None => Default(`analytics/v1/routing_event_logs`)
          }
        | _ => Default("")
        }
      /* SAMPLE DATA */
      | GENERATE_SAMPLE_DATA => Default(`user/sample_data`)

      /* VERIFY APPLE PAY */
      | VERIFY_APPLE_PAY =>
        switch id {
        | Some(merchant_id) => Default(`verify/apple_pay/${merchant_id}`)
        | None => Default(`verify/apple_pay`)
        }

      /* PAYPAL ONBOARDING */
      | PAYPAL_ONBOARDING => Default(`connector_onboarding`)
      | PAYPAL_ONBOARDING_SYNC => Default(`connector_onboarding/sync`)
      | ACTION_URL => Default(`connector_onboarding/action_url`)
      | RESET_TRACKING_ID => Default(`connector_onboarding/reset_tracking_id`)

      /* BUSINESS PROFILE */
      | BUSINESS_PROFILE =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => Default(`account/${merchantId}/business_profile/${id}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              Olap(`account/${merchantId}/profile`)
            }
          }

        | Post =>
          switch id {
          | Some(id) => Default(`account/${merchantId}/business_profile/${id}`)
          | None => Default(`account/${merchantId}/business_profile`)
          }
        | _ => Default(`account/${merchantId}/business_profile`)
        }

      /* API KEYS */
      | API_KEYS =>
        switch methodType {
        | Get => Default(`api_keys/${merchantId}/list`)
        | Post =>
          switch id {
          | Some(key_id) => Default(`api_keys/${merchantId}/${key_id}`)
          | None => Default(`api_keys/${merchantId}`)
          }
        | Delete => Default(`api_keys/${merchantId}/${id->Option.getOr("")}`)
        | _ => Default("")
        }

      /* MERCHANT ACQUIRER */
      | ACQUIRER_CONFIG_SETTINGS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(acquirerId) => Default(`profile_acquirer/${profileId}/${acquirerId}`)
          | None => Default(`profile_acquirer`)
          }
        | _ => Default("")
        }

      /* DISPUTES EVIDENCE */
      | ACCEPT_DISPUTE =>
        switch id {
        | Some(id) => Default(`disputes/accept/${id}`)
        | None => Default(`disputes`)
        }
      | DISPUTES_ATTACH_EVIDENCE =>
        switch id {
        | Some(id) => Default(`disputes/evidence/${id}`)
        | _ => Default(`disputes/evidence`)
        }

      /* PMTS COUNTRY-CURRENCY DETAILS */
      | PAYMENT_METHOD_CONFIG => Olap(`payment_methods/filter`)

      /* USER MANAGEMENT REVAMP */
      | USER_MANAGEMENT => {
          let userUrl = `user`
          switch userRoleTypes {
          | USER_LIST =>
            switch queryParameters {
            | Some(queryParams) => Olap(`${userUrl}/user/list?${queryParams}`)
            | None => Olap(`${userUrl}/user/list`)
            }
          | ROLE_LIST =>
            switch queryParameters {
            | Some(queryParams) => Olap(`${userUrl}/role/list?${queryParams}`)
            | None => Olap(`${userUrl}/role/list`)
            }
          | ROLE_ID =>
            switch id {
            | Some(key_id) => Default(`${userUrl}/role/${key_id}/v2`)
            | None => Default("")
            }
          | _ => Default("")
          }
        }

      | HYPERSWITCH_RECON =>
        switch hyperswitchReconType {
        | #FILE_UPLOAD =>
          switch methodType {
          | Post =>
            switch id {
            | Some(ingestionId) => Default(`${reconBaseURL}/ingestions/${ingestionId}/upload`)
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #ACCOUNTS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) => Default(`${reconBaseURL}/accounts/${accountId}`)
            | None => Default(`${reconBaseURL}/accounts`)
            }
          | _ => Default("")
          }
        | #TRANSACTIONS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionID) => Default(`${reconBaseURL}/transactions/${transactionID}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) => Default(`${reconBaseURL}/transactions?${queryParams}`)
              | None => Default(`${reconBaseURL}/transactions`)
              }
            }
          | _ => Default("")
          }
        | #TRANSACTIONS_LIST_V2 =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/transactions/v2/list`)
          | _ => Default("")
          }
        | #PROCESSED_ENTRIES_LIST =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/entries/list`)
          | _ => Default("")
          }
        | #PROCESSED_ENTRIES_LIST_WITH_ACCOUNT =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) =>
              switch queryParameters {
              | Some(queryParams) =>
                Default(`${reconBaseURL}/accounts/${accountId}/entries?${queryParams}`)
              | None => Default(`${reconBaseURL}/accounts/${accountId}/entries`)
              }
            | None => Default("")
            }
          | _ => Default("")
          }
        | #PROCESSED_ENTRIES_LIST_WITH_TRANSACTION =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionId) =>
              Default(`${reconBaseURL}/transactions/${transactionId}/entries`)
            | None => Default(`${reconBaseURL}/entries`)
            }
          | _ => Default("")
          }
        | #PROCESSING_ENTRIES_LIST_V2 =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/staging_entries/v2/list`)
          | _ => Default("")
          }
        | #PROCESSING_ENTRIES_LIST =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => Default(`${reconBaseURL}/staging_entries?${queryParams}`)
            | None =>
              switch id {
              | Some(processingEntryId) =>
                Default(`${reconBaseURL}/staging_entries/${processingEntryId}`)
              | None => Default(`${reconBaseURL}/staging_entries`)
              }
            }
          | Put =>
            switch id {
            | Some(processingEntryId) =>
              Default(`${reconBaseURL}/staging_entries/${processingEntryId}`)
            | None => Default("")
            }
          | _ => Default("")
          }
        | #RECON_RULES =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ruleId) => Default(`${reconBaseURL}/recon_rules/v2/${ruleId}`)
            | None => Default(`${reconBaseURL}/recon_rules/v2`)
            }
          | _ => Default("")
          }
        | #GENERATE_TRANSACTION_REPORT =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/report/transactions`)
          | _ => Default("")
          }
        | #GENERATE_EXCEPTION_REPORT =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/report/exceptions`)
          | _ => Default("")
          }
        | #INGESTION_HISTORY =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => Default(`${reconBaseURL}/ingestions/history?${queryParams}`)
            | None =>
              switch id {
              | Some(ingestionHistoryId) =>
                Default(`${reconBaseURL}/ingestions/history/${ingestionHistoryId}`)
              | None => Default(`${reconBaseURL}/ingestions/history`)
              }
            }
          | _ => Default("")
          }
        | #INGESTION_CONFIG =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ingestionId) => Default(`${reconBaseURL}/ingestions/config/${ingestionId}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) => Default(`${reconBaseURL}/ingestions/config?${queryParams}`)
              | None => Default(`${reconBaseURL}/ingestions/config`)
              }
            }
          | _ => Default("")
          }
        | #TRANSFORMATION_HISTORY =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => Default(`${reconBaseURL}/transformations/history?${queryParams}`)
            | None =>
              switch id {
              | Some(transformationHistoryId) =>
                Default(`${reconBaseURL}/transformations/history/${transformationHistoryId}`)
              | None => Default(`${reconBaseURL}/transformations/history`)
              }
            }
          | _ => Default("")
          }
        | #TRANSFORMATION_CONFIG =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transformationId) =>
              Default(`${reconBaseURL}/transformations/configs/${transformationId}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) =>
                Default(`${reconBaseURL}/transformations/configs?${queryParams}`)
              | None => Default(`${reconBaseURL}/transformations/configs`)
              }
            }
          | _ => Default("")
          }
        | #TRANSFORMATION_CONFIG_WITH_METADATA =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transformationId) =>
              Default(`${reconBaseURL}/transformations/configs/${transformationId}/metadata_schema`)
            | None => Default("")
            }
          | _ => Default("")
          }
        | #VOID_TRANSACTION =>
          switch methodType {
          | Put =>
            switch id {
            | Some(transactionId) => Default(`${reconBaseURL}/transactions/${transactionId}/void`)
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #FORCE_RECONCILE_TRANSACTION =>
          switch methodType {
          | Put =>
            switch id {
            | Some(transactionId) =>
              Default(
                `${reconBaseURL}/exception_management/transactions/${transactionId}/force_reconcile`,
              )
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #TRANSACTION_RESOLUTIONS =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionId) =>
              Default(
                `${reconBaseURL}/exception_management/transactions/${transactionId}/resolutions`,
              )
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #MANUAL_RECONCILIATION =>
          switch methodType {
          | Post =>
            switch id {
            | Some(transactionId) =>
              Default(
                `${reconBaseURL}/exception_management/transactions/${transactionId}/manual_reconciliation`,
              )
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #LINKABLE_STAGING_ENTRIES =>
          switch methodType {
          | Post =>
            switch id {
            | Some(transactionId) =>
              Default(
                `${reconBaseURL}/exception_management/transactions/${transactionId}/linkable_staging_entries/v2/list`,
              )
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #DOWNLOAD_INGESTION_HISTORY_FILE =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ingestionHistoryId) =>
              Default(`${reconBaseURL}/ingestions/history/${ingestionHistoryId}/download`)
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #DOWNLOAD_TRANSFORMATION_REPORT =>
          switch methodType {
          | Get =>
            switch (id, queryParameters) {
            | (Some(transformationHistoryId), Some(reportFormat)) =>
              Default(
                `${reconBaseURL}/transformations/history/${transformationHistoryId}/reports/${reportFormat}`,
              )
            | _ => Default(``)
            }
          | _ => Default("")
          }
        | #AUDIT_TRAIL =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => Default(`${reconBaseURL}/audit_trail?${queryParams}`)
            | None => Default(`${reconBaseURL}/audit_trail`)
            }
          | _ => Default("")
          }
        | #PROCESSING_ENTRY_RESOLUTIONS =>
          switch methodType {
          | Get =>
            switch id {
            | Some(processingEntryId) =>
              Default(
                `${reconBaseURL}/exception_management/staging_entries/${processingEntryId}/resolutions`,
              )
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #VOID_PROCESSING_ENTRY =>
          switch methodType {
          | Put =>
            switch id {
            | Some(processingEntryId) =>
              Default(`${reconBaseURL}/staging_entries/${processingEntryId}/void`)
            | None => Default(``)
            }
          | _ => Default("")
          }
        | #TRANSACTION_BULK_OPERATIONS =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/transactions/bulk_operations`)
          | _ => Default("")
          }
        | #STAGING_ENTRY_BULK_OPERATIONS =>
          switch methodType {
          | Post => Default(`${reconBaseURL}/staging_entries/bulk_operations`)
          | _ => Default("")
          }
        | #OVERVIEW_RULES =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => Default(`${reconBaseURL}/overview/transactions?${queryParams}`)
            | None => Default(`${reconBaseURL}/overview/transactions`)
            }
          | _ => Default("")
          }
        | #OVERVIEW_RULES_TIME_SERIES =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) =>
              Default(`${reconBaseURL}/overview/transactions/time_series?${queryParams}`)
            | None => Default(`${reconBaseURL}/overview/transactions/time_series`)
            }
          | _ => Default("")
          }
        | #RULE_ACCOUNT_BREAKDOWN =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) =>
              Default(`${reconBaseURL}/overview/transactions/rule_account_breakdown?${queryParams}`)
            | None => Default(`${reconBaseURL}/overview/transactions/rule_account_breakdown`)
            }
          | _ => Default("")
          }
        | #STAGING_ENTRIES_OVERVIEW =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) =>
              Default(`${reconBaseURL}/overview/staging_entries?${queryParams}`)
            | None => Default(`${reconBaseURL}/overview/staging_entries`)
            }
          | _ => Default("")
          }
        | #RECON_ENGINE_STATUS =>
          switch methodType {
          | Get => Default(`${reconBaseURL}/business_profiles/${profileId}/recon_engine/status`)
          | _ => Default("")
          }
        | #NONE => Default("")
        }

      /* INTELLIGENT ROUTING */
      | GET_REVIEW_FIELDS => Default(`dynamic-routing/simulate/baseline-review-fields`)
      | SIMULATE_INTELLIGENT_ROUTING =>
        switch queryParameters {
        | Some(queryParams) => Default(`dynamic-routing/simulate/${merchantId}?${queryParams}`)
        | None => Default(`dynamic-routing/simulate/${merchantId}`)
        }
      | INTELLIGENT_ROUTING_RECORDS =>
        switch queryParameters {
        | Some(queryParams) =>
          Default(`dynamic-routing/simulate/${merchantId}/get-records?${queryParams}`)
        | None => Default(`dynamic-routing/simulate/${merchantId}/get-records`)
        }
      | INTELLIGENT_ROUTING_GET_STATISTICS =>
        Default(`dynamic-routing/simulate/${merchantId}/get-statistics`)

      /* Revenue Recovery */
      | TRANSACTION_OVERVIEW => Default(`${recoveryAnalyticsDemo}/analytics/transaction_overview`)
      | RETRY_PERFORMANCE => Default(`${recoveryAnalyticsDemo}/analytics/retry_performance`)
      | MONTHLY_RETRY_SUCCESS => Default(`${recoveryAnalyticsDemo}/analytics/monthly_retry_success`)
      | RETRY_ATTEMPTS_TREND => Default(`${recoveryAnalyticsDemo}/analytics/retry_attempts_trend`)
      | ERROR_CATEGORY_ANALYSIS =>
        Default(`${recoveryAnalyticsDemo}/analytics/error_category_analysis`)
      | RECOVERY_INVOICES => Default(`${recoveryAnalyticsDemo}/list-invoices`)
      | RECOVERY_ATTEMPTS =>
        switch queryParameters {
        | Some(queryParams) => Default(`${recoveryAnalyticsDemo}/list-attempts/${queryParams}`)
        | None => Default(`${recoveryAnalyticsDemo}/list-attempts`)
        }

      /* USERS */
      | USERS =>
        let userUrl = `user`

        switch userType {
        // DASHBOARD LOGIN / SIGNUP
        | #CONNECT_ACCOUNT =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/connect_account?${params}`)
          | None => Default(`${userUrl}/connect_account`)
          }
        | #SIGNINV2 => Default(`${userUrl}/v2/signin`)
        | #LAUNCH_SAGE => Default(`${userUrl}/launch_sage`)
        | #CHANGE_PASSWORD => Default(`${userUrl}/change_password`)
        | #SIGNUP
        | #SIGNOUT
        | #RESET_PASSWORD
        | #VERIFY_EMAIL_REQUEST
        | #FORGOT_PASSWORD
        | #ROTATE_PASSWORD =>
          switch queryParameters {
          | Some(params) =>
            Default(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => Default(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }

        // POST LOGIN QUESTIONNAIRE
        | #SET_METADATA =>
          switch queryParameters {
          | Some(params) =>
            Default(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => Default(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }

        // USER DATA
        | #USER_DATA =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/data?${params}`)
          | None => Default(`${userUrl}/data`)
          }
        | #MERCHANT_DATA => Default(`${userUrl}/data`)
        | #USER_INFO => Default(userUrl)

        // USER GROUP ACCESS
        | #GET_GROUP_ACL => Default(`${userUrl}/role/v2`)
        | #ROLE_INFO =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/parent/list?${params}`)
          | None => Default(`${userUrl}/parent/list`)
          }

        | #GROUP_ACCESS_INFO =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/permission_info?${params}`)
          | None => Default(`${userUrl}/permission_info`)
          }

        // USER ACTIONS
        | #USER_DELETE => Default(`${userUrl}/user/delete`)
        | #USER_UPDATE => Default(`${userUrl}/update`)
        | #UPDATE_ROLE => Default(`${userUrl}/user/${(userType :> string)->String.toLowerCase}`)

        // INVITATION INSIDE DASHBOARD
        | #RESEND_INVITE =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/user/resend_invite?${params}`)
          | None => Default(`${userUrl}/user/resend_invite`)
          }
        | #ACCEPT_INVITATION_HOME => Default(`${userUrl}/user/invite/accept`)
        | #INVITE_MULTIPLE =>
          switch queryParameters {
          | Some(params) =>
            Default(`${userUrl}/user/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => Default(`${userUrl}/user/${(userType :> string)->String.toLowerCase}`)
          }

        // ACCEPT INVITE PRE_LOGIN
        | #ACCEPT_INVITATION_PRE_LOGIN => Default(`${userUrl}/user/invite/accept/pre_auth`)

        // CREATE_ORG
        | #CREATE_ORG => Default(`user/create_org`)
        // CREATE_PLATFORM
        | #CREATE_PLATFORM => Default(`user/create_platform`)
        // CREATE MERCHANT
        | #CREATE_MERCHANT =>
          switch queryParameters {
          | Some(params) =>
            Default(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => Default(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }
        | #SWITCH_ORG => Default(`${userUrl}/switch/org`)
        | #SWITCH_MERCHANT_NEW => Default(`${userUrl}/switch/merchant`)
        | #SWITCH_PROFILE | #SWITCH_PROFILE_NEW => Default(`${userUrl}/switch/profile`)

        // Org-Merchant-Profile List
        | #LIST_ORG => Olap(`${userUrl}/list/org`)
        | #LIST_MERCHANT => Olap(`${userUrl}/list/merchant`)
        | #LIST_PROFILE => Olap(`${userUrl}/list/profile`)

        // Clone connector across profiles of the same merchant
        | #CLONE_CONNECTOR => Default(`${userUrl}/clone_connector`)

        // CREATE ROLES
        | #CREATE_CUSTOM_ROLE => Default(`${userUrl}/role`)
        | #CREATE_CUSTOM_ROLE_V2 => Default(`${userUrl}/role/v2`)
        // EMAIL FLOWS
        | #FROM_EMAIL => Default(`${userUrl}/from_email`)
        | #VERIFY_EMAILV2 => Default(`${userUrl}/v2/verify_email`)
        | #ACCEPT_INVITE_FROM_EMAIL =>
          switch queryParameters {
          | Some(params) =>
            Default(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => Default(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }
        | #TERMINATE_ACCEPT_INVITE => Default(`${userUrl}/terminate_accept_invite`)

        // SPT FLOWS (Totp)
        | #BEGIN_TOTP => Default(`${userUrl}/2fa/totp/begin`)
        | #CHECK_TWO_FACTOR_AUTH_STATUS_V2 => Default(`${userUrl}/2fa/v2`)
        | #VERIFY_TOTP => Default(`${userUrl}/2fa/totp/verify`)
        | #VERIFY_RECOVERY_CODE => Default(`${userUrl}/2fa/recovery_code/verify`)
        | #GENERATE_RECOVERY_CODES => Default(`${userUrl}/2fa/recovery_code/generate`)
        | #TERMINATE_TWO_FACTOR_AUTH =>
          switch queryParameters {
          | Some(params) => Default(`${userUrl}/2fa/terminate?${params}`)
          | None => Default(`${userUrl}/2fa/terminate`)
          }

        | #CHECK_TWO_FACTOR_AUTH_STATUS => Default(`${userUrl}/2fa`)
        | #RESET_TOTP => Default(`${userUrl}/2fa/totp/reset`)

        // SPT FLOWS (SSO)
        | #GET_AUTH_LIST =>
          switch queryParameters {
          | Some(params) => Olap(`${userUrl}/auth/list?${params}`)
          | None => Olap(`${userUrl}/auth/list`)
          }
        | #SIGN_IN_WITH_SSO => Default(`${userUrl}/oidc`)
        | #AUTH_SELECT => Default(`${userUrl}/auth/select`)

        // user-management revamp
        | #LIST_ROLES_FOR_INVITE =>
          switch queryParameters {
          | Some(params) => Olap(`${userUrl}/role/list/invite?${params}`)
          | None => Default("")
          }
        | #LIST_INVITATION => Default(`${userUrl}/list/invitation`)
        | #USER_DETAILS => Olap(`${userUrl}/user`)
        | #LIST_ROLES_FOR_ROLE_UPDATE =>
          switch queryParameters {
          | Some(params) => Olap(`${userUrl}/role/list/update?${params}`)
          | None => Default("")
          }
        | #THEME =>
          switch methodType {
          | Get =>
            switch id {
            | Some(themeId) => Default(`${userUrl}/theme/${themeId}`)
            | None => Default(`${userUrl}/theme`)
            }
          | Post => Default(`${userUrl}/theme`)
          | Put =>
            switch id {
            | Some(themeId) => Default(`${userUrl}/theme/${themeId}`)
            | None => Default(`${userUrl}/theme`)
            }
          | Delete =>
            switch id {
            | Some(themeId) => Default(`${userUrl}/theme/${themeId}`)
            | None => Default(`${userUrl}/theme`)
            }
          | _ => Default("")
          }

        | #THEME_LIST =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(params) => Default(`${userUrl}/theme/list?${params}`)
            | None => Default(`${userUrl}/theme/list`)
            }
          | _ => Default("")
          }

        | #THEME_BY_LINEAGE =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(params) => Default(`${userUrl}/theme?${params}`)
            | None => Default(`${userUrl}/theme`)
            }
          | _ => Default("")
          }

        | #THEME_UPLOAD_ASSET =>
          switch methodType {
          | Post =>
            switch id {
            | Some(themeId) => Default(`${userUrl}/theme/${themeId}`)
            | None => Default(`${userUrl}/theme`)
            }
          | _ => Default("")
          }

        | #NONE => Default("")
        }

      /* TO BE CHECKED */
      | INTEGRATION_DETAILS => Default(`user/get_sandbox_integration_details`)
      | SDK_PAYMENT => Default("payments")
      | CHAT_BOT => Default(`chat/ai/data`)
      }

    | V2(entityNameForv2) =>
      getV2Url(
        ~entityName=entityNameForv2,
        ~userType,
        ~id,
        ~methodType,
        ~queryParameters,
        ~profileId,
        ~merchantId,
        ~transactionEntity,
      )
    }

    `${Window.env.apiBaseUrl}/${endpoint->resolveEndpoint}`
  }
  getUrl
}

let useHandleLogout = (~eventName="user_sign_out") => {
  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  let clearRecoilValue = ClearRecoilValueHook.useClearRecoilValue()
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastAdapter.useShowToast()
  let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  async () => {
    try {
      let logoutUrl = getURL(~entityName=V1(USERS), ~methodType=Post, ~userType=#SIGNOUT)
      let _ = await fetchApi(
        logoutUrl,
        ~method_=Post,
        ~xFeatureRoute,
        ~forceCookies,
        ~sendV1DummyApiKeyHeader,
      )
      mixpanelEvent(~eventName)
      setAuthStateToLogout()
      clearRecoilValue()
      CommonAuthUtils.clearLocalStorage()
    } catch {
    | _ => {
        showToast(
          ~toastType=ToastError,
          ~message="Logout failed. Please try again.",
          ~autoClose=true,
        )
        mixpanelEvent(~eventName="user_sign_out_failed")
      }
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
  ~isEmbeddableSession=false,
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
  | 200
  | 201 => json
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
          if !isEmbeddableSession {
            if !sessionExpired.contents {
              showToast(~toastType=ToastWarning, ~message="Session Expired", ~autoClose=false)

              handleLogout()->ignore
              AuthUtils.redirectToLogin()
              sessionExpired := true
            }
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
            ~message=errorDict->getString("message", "Error Occurred"),
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
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let {isEmbeddableSession} = React.useContext(UserInfoProvider.defaultContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastAdapter.useShowToast()
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
  let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  async (url, ~version=UserInfoTypes.V1, ~signal=?) => {
    try {
      let res = await fetchApi(
        url,
        ~method_=Get,
        ~xFeatureRoute,
        ~forceCookies,
        ~sendV1DummyApiKeyHeader,
        ~merchantId,
        ~profileId,
        ~version,
        ~isEmbeddableSession=isEmbeddableSession(),
        ~signal?,
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
        ~isEmbeddableSession=isEmbeddableSession(),
      )
    } catch {
    | _ if signal->Option.mapOr(false, AbortControllerHook.isAborted) =>
      raise(AbortControllerHook.AbortError)
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useUpdateMethod = (~showErrorToast=true) => {
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let {isEmbeddableSession} = React.useContext(UserInfoProvider.defaultContext)
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastAdapter.useShowToast()
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
  let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  async (
    url,
    body,
    method,
    ~bodyFormData=?,
    ~headers=Dict.make(),
    ~contentType=AuthHooks.Headers("application/json"),
    ~version=UserInfoTypes.V1,
    ~signal=?,
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
        ~sendV1DummyApiKeyHeader,
        ~merchantId,
        ~profileId,
        ~version,
        ~isEmbeddableSession=isEmbeddableSession(),
        ~signal?,
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
        ~isEmbeddableSession=isEmbeddableSession(),
      )
    } catch {
    | _ if signal->Option.mapOr(false, AbortControllerHook.isAborted) =>
      raise(AbortControllerHook.AbortError)
    | Exn.Error(e) =>
      catchHandler(~err={e}, ~showErrorToast, ~showToast, ~isPlayground, ~popUpCallBack)
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}

let useCancellableGetMethod = (~showErrorToast=true) => {
  let fetchDetails = useGetMethod(~showErrorToast)
  let getSignal = AbortControllerHook.useAbortController()

  async (url, ~version=UserInfoTypes.V1, ~signal=?) => {
    let requestSignal = switch signal {
    | Some(signal) => signal
    | None => getSignal()
    }
    let res = await fetchDetails(url, ~version, ~signal=requestSignal)

    if requestSignal->AbortControllerHook.isAborted {
      raise(AbortControllerHook.AbortError)
    }

    res
  }
}

let useCancellableUpdateMethod = (~showErrorToast=true) => {
  let updateDetails = useUpdateMethod(~showErrorToast)
  let getSignal = AbortControllerHook.useAbortController()

  async (
    url,
    body,
    method,
    ~bodyFormData=?,
    ~headers=Dict.make(),
    ~contentType=AuthHooks.Headers("application/json"),
    ~version=UserInfoTypes.V1,
    ~signal=?,
  ) => {
    let requestSignal = switch signal {
    | Some(signal) => signal
    | None => getSignal()
    }
    let res = await updateDetails(
      url,
      body,
      method,
      ~bodyFormData?,
      ~headers,
      ~contentType,
      ~version,
      ~signal=requestSignal,
    )

    if requestSignal->AbortControllerHook.isAborted {
      raise(AbortControllerHook.AbortError)
    }

    res
  }
}
