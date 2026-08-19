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
    | (Get, None) => oltp("v1/customers/list")
    | (Get, Some(customerId)) => oltp(`v1/customers/${customerId}`)
    | _ => oltp("")
    }
  | CUSTOMERS_COUNT =>
    switch (methodType, id) {
    | (Get, None) => oltp("v1/customers/list_with_count")
    | (Get, Some(customerId)) => oltp(`v1/customers/${customerId}`)
    | _ => oltp("")
    }
  | V2_CONNECTOR =>
    switch methodType {
    | Get =>
      switch id {
      | Some(connectorID) => oltp(`${connectorBaseURL}/${connectorID}`)
      | None => oltp(`v2/profiles/${profileId}/connector-accounts`)
      }
    | Put =>
      switch id {
      | Some(connectorID) => oltp(`${connectorBaseURL}/${connectorID}`)
      | None => oltp(connectorBaseURL)
      }
    | Post =>
      switch id {
      | Some(connectorID) => oltp(`${connectorBaseURL}/${connectorID}`)
      | None => oltp(connectorBaseURL)
      }
    | _ => oltp("")
    }
  | V2_ORDERS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParameters {
        | Some(queryParams) => oltp(`${paymentsBaseURL}/${key_id}?${queryParams}`)
        | None => oltp(`${paymentsBaseURL}/${key_id}`)
        }
      | None =>
        switch queryParameters {
        | Some(queryParams) => oltp(`${paymentsBaseURL}/list?${queryParams}`)
        | None => oltp(`${paymentsBaseURL}/list?limit=100`)
        }
      }
    | _ => oltp("")
    }
  | V2_RECOVERY_INVOICES_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) =>
        switch queryParameters {
        | Some(queryParams) => oltp(`${paymentsBaseURL}/${key_id}?${queryParams}`)
        | None => oltp(`${paymentsBaseURL}/${key_id}/get-revenue-recovery-intent`)
        }
      | None =>
        switch queryParameters {
        | Some(queryParams) => oltp(`${paymentsBaseURL}/recovery-list?${queryParams}`)
        | None => oltp(`${paymentsBaseURL}/recovery-list?limit=100`)
        }
      }
    | _ => oltp("")
    }
  /* REPORTS */
  | REVENUE_RECOVERY_REPORT =>
    switch transactionEntity {
    | #Tenant
    | #Organization =>
      oltp(`v2/analytics/org/report/payments`)
    | #Merchant => oltp(`v2/analytics/merchant/report/payments`)
    | #Profile => oltp(`v2/analytics/profile/report/payments`)
    }
  | V2_ATTEMPTS_LIST =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => oltp(`${paymentsBaseURL}/${key_id}/list_attempts`)
      | None => oltp("")
      }
    | _ => oltp("")
    }
  | PROCESS_TRACKER =>
    switch methodType {
    | Get =>
      switch id {
      | Some(key_id) => oltp(`v2/process_tracker/revenue_recovery_workflow/${key_id}`)
      | None => oltp("v2/process_tracker/revenue_recovery_workflow")
      }
    | _ => oltp("")
    }
  | V2_ORDER_FILTERS => oltp("v2/payments/profile/filter")
  | V2_ORDERS_AGGREGATE =>
    switch methodType {
    | Get =>
      switch queryParameters {
      | Some(queryParams) =>
        switch transactionEntity {
        | #Merchant => oltp(`v2/payments/aggregate?${queryParams}`)
        | #Profile => oltp(`v2/payments/profile/aggregate?${queryParams}`)
        | _ => oltp(`v2/payments/aggregate?${queryParams}`)
        }
      | None => oltp(``)
      }
    | _ => oltp(``)
    }
  | PAYMENT_METHOD_LIST =>
    switch id {
    | Some(customerId) => oltp(`v1/customers/${customerId}/saved-payment-methods`)
    | None => oltp("")
    }
  | TOTAL_TOKEN_COUNT => oltp(`v1/customers/total-payment-methods`)
  | RETRIEVE_PAYMENT_METHOD =>
    switch id {
    | Some(paymentMethodId) => oltp(`v1/payment-methods/${paymentMethodId}/details`)
    | None => oltp("")
    }
  /* MERCHANT ACCOUNT DETAILS (Get,Post and Put) */
  | MERCHANT_ACCOUNT => oltp(`v2/merchant-accounts/${merchantId}`)
  | USERS =>
    let userUrl = `user`
    switch userType {
    | #CREATE_MERCHANT =>
      switch queryParameters {
      | Some(params) => oltp(`v2/${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
      | None => oltp(`v2/${userUrl}/${(userType :> string)->String.toLowerCase}`)
      }
    | #LIST_MERCHANT => oltp(`v2/${userUrl}/list/merchant`)
    | #SWITCH_MERCHANT_NEW => oltp(`v2/${userUrl}/switch/merchant`)
    | #SWITCH_PROFILE_NEW => oltp(`v2/${userUrl}/switch/profile`)

    | #LIST_PROFILE => oltp(`v2/${userUrl}/list/profile`)
    | _ => oltp("")
    }
  /* API KEYS */
  | API_KEYS =>
    switch methodType {
    | Get => oltp(`v2/api-keys/list`)
    | Post
    | Put
    | Delete =>
      switch id {
      | Some(key_id) => oltp(`v2/api-keys/${key_id}`)
      | None => oltp(`v2/api-keys`)
      }
    | _ => oltp("")
    }
  | BUSINESS_PROFILE =>
    switch methodType {
    | Get =>
      switch id {
      | Some(id) => oltp(`v2/profiles/${id}`)
      | None => oltp(`v2/profiles`)
      }

    | Post =>
      switch id {
      | Some(id) => oltp(`v2/profiles/${id}`)
      | None => oltp(`v2/profiles`)
      }
    | Put =>
      switch id {
      | Some(id) => oltp(`v2/profiles/${id}`)
      | None => oltp(`v2/profiles`)
      }

    | _ => oltp(`v2/profiles`)
    }
  | REFUNDS =>
    switch methodType {
    | Post => oltp(`v2/refunds`)
    | _ => oltp("")
    }
  }
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

    let endpoint: endpoint = switch entityName {
    | V1(entityNameType) =>
      switch entityNameType {
      /* GLOBAL SEARCH */
      | GLOBAL_SEARCH =>
        switch methodType {
        | Post =>
          switch id {
          | Some(topic) => oltp(`analytics/v1/search/${topic}`)
          | None => oltp(`analytics/v1/search`)
          }
        | _ => oltp("")
        }

      /* BLOCKLIST */
      | BLOCKLIST_BATCH =>
        switch methodType {
        | Get =>
          switch id {
          | Some(jobId) => oltp(`blocklist/batch/${jobId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => oltp(`blocklist/batch?${queryParams}`)
            | None => oltp(`blocklist/batch`)
            }
          }
        | Post => oltp(`blocklist/batch`)
        | _ => oltp("")
        }

      /* MERCHANT ACCOUNT DETAILS (Get and Post) */
      | MERCHANT_ACCOUNT => oltp(`accounts/${merchantId}`)

      /* ORGANIZATION UPDATE */
      | ORGANIZATION_RETRIEVE =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => oltp(`organization/${id}`)
          | None => oltp(``)
          }
        | Put =>
          switch id {
          | Some(id) => oltp(`organization/${id}`)
          | None => oltp(`organization`)
          }
        | _ => oltp("")
        }

      /* CUSTOMERS DETAILS */
      | CUSTOMERS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(customerId) => oltp(`customers/${customerId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => olap(`customers/list?${queryParams}`)
            | None => olap(`customers/list?limit=500`)
            }
          }
        | _ => oltp("")
        }
      | CUSTOMERS_COUNT =>
        switch methodType {
        | Get =>
          switch id {
          | Some(customerId) => oltp(`customers/${customerId}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) => oltp(`customers/list_with_count?${queryParams}`)
            | None => oltp(`customers/list_with_count`)
            }
          }
        | _ => oltp("")
        }
      | PAYMENT_METHODS =>
        switch methodType {
        | Get => oltp("payment_methods")
        | _ => oltp("")
        }
      | PAYMENT_METHODS_DETAILS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => oltp(`payment_methods/${id}`)
          | None => oltp(`payment_methods`)
          }
        | _ => oltp("")
        }

      /* CONNECTORS & FRAUD AND RISK MANAGEMENT */
      | FRAUD_RISK_MANAGEMENT | CONNECTOR =>
        switch methodType {
        | Get =>
          switch id {
          | Some(connectorID) => oltp(`${connectorBaseURL}/${connectorID}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              olap(`account/${merchantId}/profile/connectors`)
            }
          }
        | Post | Delete =>
          switch connector {
          | Some(_con) => oltp(`account/connectors/verify`)
          | None =>
            switch id {
            | Some(connectorID) => oltp(`${connectorBaseURL}/${connectorID}`)
            | None => oltp(connectorBaseURL)
            }
          }
        | _ => oltp("")
        }

      /* OPERATIONS */
      | REFUND_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => oltp(`refunds/v2/filter`)
          | #Profile => oltp(`refunds/v2/profile/filter`)
          | _ => oltp(`refunds/v2/filter`)
          }

        | _ => oltp("")
        }
      | ORDER_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Merchant => oltp(`payments/v2/filter`)
          | #Profile => oltp(`payments/v2/profile/filter`)
          | _ => oltp(`payments/v2/filter`)
          }

        | _ => oltp("")
        }
      | DISPUTE_FILTERS =>
        switch methodType {
        | Get =>
          switch transactionEntity {
          | #Profile => oltp(`disputes/profile/filter`)
          | #Merchant
          | _ =>
            oltp(`disputes/filter`)
          }

        | _ => oltp("")
        }
      | PAYOUTS_FILTERS =>
        switch methodType {
        | Post =>
          switch transactionEntity {
          | #Merchant => olap(`payouts/filter`)
          | #Profile => olap(`payouts/profile/filter`)
          | _ => olap(`payouts/filter`)
          }

        | _ => oltp("")
        }
      | ORDERS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(key_id) =>
            switch queryParameters {
            | Some(queryParams) => oltp(`payments/${key_id}?${queryParams}`)
            | None => oltp(`payments/${key_id}`)
            }

          | None =>
            switch transactionEntity {
            | #Merchant => olap(`payments/list?limit=100`)
            | #Profile => olap(`payments/profile/list?limit=100`)
            | _ => olap(`payments/list?limit=100`)
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => olap(`payments/list`)
          | #Profile => olap(`payments/profile/list`)
          | _ => olap(`payments/list`)
          }

        | _ => oltp("")
        }
      | PAYMENT_CANCEL =>
        switch (methodType, id) {
        | (Post, Some(payment_id)) => oltp(`payments/${payment_id}/cancel`)
        | _ => oltp("")
        }
      | PAYMENT_CAPTURE =>
        switch (methodType, id) {
        | (Post, Some(payment_id)) => oltp(`payments/${payment_id}/capture`)
        | _ => oltp("")
        }
      | ORDERS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Merchant => oltp(`payments/aggregate?${queryParams}`)
            | #Profile => oltp(`payments/profile/aggregate?${queryParams}`)
            | _ => oltp(`payments/aggregate?${queryParams}`)
            }
          | None => oltp(`payments/aggregate`)
          }
        | _ => oltp(`payments/aggregate`)
        }
      | MANUAL_STATUS_UPDATE =>
        switch methodType {
        | Post =>
          switch id {
          | Some(payment_id) => oltp(`payments/${payment_id}/manual-status-update`)
          | None => oltp("")
          }
        | _ => oltp("")
        }
      | REFUNDS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(key_id) =>
            switch queryParameters {
            | Some(queryParams) => oltp(`refunds/${key_id}?${queryParams}`)
            | None => oltp(`refunds/${key_id}`)
            }

          | None =>
            switch queryParameters {
            | Some(queryParams) =>
              switch transactionEntity {
              | #Merchant => oltp(`refunds/list?${queryParams}`)
              | #Profile => oltp(`refunds/profile/list?limit=100`)
              | _ => oltp(`refunds/list?limit=100`)
              }
            | None => oltp(`refunds/list?limit=100`)
            }
          }
        | Post =>
          switch id {
          | Some(_keyid) =>
            switch transactionEntity {
            | #Merchant => olap(`refunds/list`)
            | #Profile => olap(`refunds/profile/list`)
            | _ => olap(`refunds/list`)
            }
          | None => oltp(`refunds`)
          }
        | _ => oltp("")
        }
      | REFUNDS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => oltp(`refunds/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              oltp(`refunds/aggregate?${queryParams}`)
            }
          | None => oltp(`refunds/aggregate`)
          }
        | _ => oltp(`refunds/aggregate`)
        }
      | DISPUTES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(dispute_id) => oltp(`disputes/${dispute_id}`)
          | None =>
            switch queryParameters {
            | Some(queryParams) =>
              switch transactionEntity {
              | #Profile => olap(`disputes/profile/list?${queryParams}&limit=10000`)
              | #Merchant
              | _ =>
                olap(`disputes/list?${queryParams}&limit=10000`)
              }
            | None =>
              switch transactionEntity {
              | #Profile => olap(`disputes/profile/list?limit=10000`)
              | #Merchant
              | _ =>
                olap(`disputes/list?limit=10000`)
              }
            }
          }
        | _ => oltp("")
        }
      | DISPUTES_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => oltp(`disputes/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              oltp(`disputes/aggregate?${queryParams}`)
            }
          | None => oltp(`disputes/aggregate`)
          }
        | _ => oltp(`disputes/aggregate`)
        }
      | PAYOUTS_AGGREGATE =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(queryParams) =>
            switch transactionEntity {
            | #Profile => oltp(`payouts/profile/aggregate?${queryParams}`)
            | #Merchant
            | _ =>
              oltp(`payouts/aggregate?${queryParams}`)
            }
          | None => oltp(`payouts/aggregate`)
          }
        | _ => oltp(`payouts/aggregate`)
        }
      | PAYOUTS =>
        switch methodType {
        | Get =>
          switch id {
          | Some(payout_id) =>
            switch queryParameters {
            | Some(queryParams) => oltp(`payouts/${payout_id}?${queryParams}`)
            | None => oltp(`payouts/${payout_id}`)
            }
          | None =>
            switch transactionEntity {
            | #Merchant => olap(`payouts/list?limit=100`)
            | #Profile => olap(`payouts/profile/list?limit=10000`)
            | _ => olap(`payouts/list?limit=100`)
            }
          }
        | Post =>
          switch transactionEntity {
          | #Merchant => olap(`payouts/list`)
          | #Profile => olap(`payouts/profile/list`)
          | _ => olap(`payouts/list`)
          }

        | _ => oltp("")
        }

      /* ROUTING */
      | DEFAULT_FALLBACK => oltp(`routing/default`)
      | ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => oltp(`routing/${routingId}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              olap(`routing/list/profile`)
            }
          }
        | Post =>
          switch id {
          | Some(routing_id) => oltp(`routing/${routing_id}/activate`)
          | _ => oltp(`routing`)
          }
        | _ => oltp("")
        }
      | ACTIVE_ROUTING => oltp(`routing/active`)
      | CREATE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch queryParameters {
          | Some(param) =>
            oltp(
              `account/${merchantId}/business_profile/${profileId}/dynamic_routing/success_based/create?${param}`,
            )
          | None => oltp("")
          }
        | _ => oltp("")
        }
      | ACTIVATE_AUTH_RATE_ROUTING =>
        switch methodType {
        | Post =>
          switch id {
          | Some(id) => oltp(`routing/${id}/activate`)
          | None => oltp("")
          }
        | _ => oltp("")
        }
      | SET_VOLUME_SPLIT =>
        switch methodType {
        | Post =>
          switch queryParameters {
          | Some(param) =>
            oltp(
              `account/${merchantId}/business_profile/${profileId}/dynamic_routing/set_volume_split?${param}`,
            )
          | None => oltp("")
          }
        | _ => oltp("")
        }
      | GET_VOLUME_SPLIT =>
        switch methodType {
        | Get =>
          oltp(
            `account/${merchantId}/business_profile/${profileId}/dynamic_routing/get_volume_split`,
          )
        | _ => oltp("")
        }

      /* OIDC */
      | OIDC_AUTHORIZE =>
        switch methodType {
        | Get => oltp(`oidc/authorize`)
        | _ => oltp("")
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
              oltp(`analytics/v2/org/metrics/${domain}`)
            | #Merchant => oltp(`analytics/v2/merchant/metrics/${domain}`)
            | #Profile => oltp(`analytics/v2/profile/metrics/${domain}`)
            }

          | _ => oltp("")
          }
        | _ => oltp("")
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
              oltp(`analytics/v1/org/${domain}/info`)
            | #Merchant => oltp(`analytics/v1/merchant/${domain}/info`)
            | #Profile => oltp(`analytics/v1/profile/${domain}/info`)
            }

          | _ => oltp("")
          }
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              oltp(`analytics/v1/org/metrics/${domain}`)
            | #Merchant => oltp(`analytics/v1/merchant/metrics/${domain}`)
            | #Profile => oltp(`analytics/v1/profile/metrics/${domain}`)
            }

          | _ => oltp("")
          }
        | _ => oltp("")
        }
      | ANALYTICS_AUTHENTICATION_V2 =>
        switch methodType {
        | Get =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            oltp(`analytics/v1/org/auth_events/info`)
          | #Merchant => oltp(`analytics/v1/merchant/auth_events/info`)
          | #Profile => oltp(`analytics/v1/profile/auth_events/info`)
          }
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            oltp(`analytics/v1/org/metrics/auth_events`)
          | #Merchant => oltp(`analytics/v1/merchant/metrics/auth_events`)
          | #Profile => oltp(`analytics/v1/profile/metrics/auth_events`)
          }

        | _ => oltp("")
        }
      | ANALYTICS_AUTHENTICATION_V2_FILTERS =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            oltp(`analytics/v1/org/filters/auth_events`)
          | #Merchant => oltp(`analytics/v1/merchant/filters/auth_events`)
          | #Profile => oltp(`analytics/v1/profile/filters/auth_events`)
          }
        | _ => oltp("")
        }
      | ANALYTICS_FILTERS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(domain) =>
            switch analyticsEntity {
            | #Tenant
            | #Organization =>
              oltp(`analytics/v1/org/filters/${domain}`)
            | #Merchant => oltp(`analytics/v1/merchant/filters/${domain}`)
            | #Profile => oltp(`analytics/v1/profile/filters/${domain}`)
            }

          | _ => oltp("")
          }
        | _ => oltp("")
        }

      | API_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => oltp(`analytics/v1/profile/api_event_logs?${params}`)
          | None => oltp(``)
          }
        | _ => oltp("")
        }
      | ANALYTICS_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            oltp(`analytics/v1/org/metrics/sankey`)
          | #Merchant => oltp(`analytics/v1/merchant/metrics/sankey`)
          | #Profile => oltp(`analytics/v1/profile/metrics/sankey`)
          }

        | _ => oltp("")
        }
      | ANALYTICS_SCA_EXEMPTION_SANKEY =>
        switch methodType {
        | Post =>
          switch analyticsEntity {
          | #Tenant
          | #Organization =>
            oltp(`analytics/v1/org/metrics/auth_events/sankey`)
          | #Merchant => oltp(`analytics/v1/merchant/metrics/auth_events/sankey`)
          | #Profile => oltp(`analytics/v1/profile/metrics/auth_events/sankey`)
          }

        | _ => oltp("")
        }
      /* PAYOUTS ROUTING */
      | PAYOUT_DEFAULT_FALLBACK => oltp(`routing/payouts/default`)
      | PAYOUT_ROUTING =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => oltp(`routing/${routingId}`)
          | _ =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              oltp(`routing/payouts/list/profile`)
            }
          }

        | Put =>
          switch id {
          | Some(routingId) => oltp(`routing/${routingId}`)
          | _ => oltp(`routing/payouts`)
          }
        | Post =>
          switch id {
          | Some(routing_id) => oltp(`routing/payouts/${routing_id}/activate`)
          | _ => oltp(`routing/payouts`)
          }
        | _ => oltp("")
        }
      | ACTIVE_PAYOUT_ROUTING => oltp(`routing/payouts/active`)

      /* THREE DS ROUTING */
      | THREE_DS => oltp(`routing/decision`)

      /* THREE DS ROUTING */

      | THREE_DS_EXEMPTION_RULES =>
        switch methodType {
        | Get =>
          switch id {
          | Some(routingId) => oltp(`routing/${routingId}`)
          | None => oltp(`routing/active?transaction_type=three_ds_authentication&limit=100`)
          }
        | Post =>
          switch id {
          | Some(routing_id) => oltp(`routing/${routing_id}/activate`)
          | _ => oltp("routing")
          }
        | _ => oltp("")
        }
      | THREE_DS_EXEMPTION_DELETE_RULE => oltp(`routing/deactivate`)

      /* SURCHARGE ROUTING */
      | SURCHARGE => oltp(`routing/decision/surcharge`)

      | HYPERSENSE => oltp(`hypersense/${(hypersenseType :> string)->String.toLowerCase}`)

      /* REPORTS */
      | PAYMENT_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          oltp(`analytics/v1/org/report/payments`)
        | #Merchant => oltp(`analytics/v1/merchant/report/payments`)
        | #Profile => oltp(`analytics/v1/profile/report/payments`)
        }
      | PAYMENTS_LIST =>
        switch methodType {
        | Post =>
          switch transactionEntity {
          | #Merchant => oltp(`payments/advanced/list`)
          | #Profile => oltp(`payments/profile/advanced/list`)
          | _ => olap(`payments/list`)
          }

        | _ => oltp("")
        }
      | PAYOUT_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          oltp(`analytics/v1/org/report/payouts`)
        | #Merchant => oltp(`analytics/v1/merchant/report/payouts`)
        | #Profile => oltp(`analytics/v1/profile/report/payouts`)
        }

      | REFUND_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          oltp(`analytics/v1/org/report/refunds`)
        | #Merchant => oltp(`analytics/v1/merchant/report/refunds`)
        | #Profile => oltp(`analytics/v1/profile/report/refunds`)
        }

      | DISPUTE_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          oltp(`analytics/v1/org/report/dispute`)
        | #Merchant => oltp(`analytics/v1/merchant/report/dispute`)
        | #Profile => oltp(`analytics/v1/profile/report/dispute`)
        }

      | AUTHENTICATION_REPORT =>
        switch transactionEntity {
        | #Tenant
        | #Organization =>
          oltp(`analytics/v1/org/report/authentications`)
        | #Merchant => oltp(`analytics/v1/merchant/report/authentications`)
        | #Profile => oltp(`analytics/v1/profile/report/authentications`)
        }

      /* EVENT LOGS */
      | SDK_EVENT_LOGS => oltp(`analytics/v1/profile/sdk_event_logs`)

      | WEBHOOK_EVENTS => olap(`events/profile/list`)
      | WEBHOOK_EVENTS_ATTEMPTS =>
        switch id {
        | Some(id) => olap(`events/${merchantId}/${id}/attempts`)
        | None => oltp(`events/${merchantId}/attempts`)
        }
      | WEBHOOKS_EVENTS_RETRY =>
        switch id {
        | Some(id) => oltp(`events/${merchantId}/${id}/retry`)
        | None => oltp(`events/${merchantId}/retry`)
        }
      | WEBHOOKS_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => oltp(`analytics/v1/profile/outgoing_webhook_event_logs?${params}`)
          | None => oltp(`analytics/v1/outgoing_webhook_event_logs`)
          }
        | _ => oltp("")
        }
      | CONNECTOR_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => oltp(`analytics/v1/profile/connector_event_logs?${params}`)
          | None => oltp(`analytics/v1/connector_event_logs`)
          }
        | _ => oltp("")
        }
      | PRISM_CONNECTOR_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => oltp(`analytics/v1/profile/prism_connector_event_logs?${params}`)
          | None => oltp(`analytics/v1/prism_connector_event_logs`)
          }
        | _ => oltp("")
        }
      | ROUTING_EVENT_LOGS =>
        switch methodType {
        | Get =>
          switch queryParameters {
          | Some(params) => oltp(`analytics/v1/profile/routing_event_logs?${params}`)
          | None => oltp(`analytics/v1/routing_event_logs`)
          }
        | _ => oltp("")
        }
      /* SAMPLE DATA */
      | GENERATE_SAMPLE_DATA => oltp(`user/sample_data`)

      /* VERIFY APPLE PAY */
      | VERIFY_APPLE_PAY =>
        switch id {
        | Some(merchant_id) => oltp(`verify/apple_pay/${merchant_id}`)
        | None => oltp(`verify/apple_pay`)
        }

      /* PAYPAL ONBOARDING */
      | PAYPAL_ONBOARDING => oltp(`connector_onboarding`)
      | PAYPAL_ONBOARDING_SYNC => oltp(`connector_onboarding/sync`)
      | ACTION_URL => oltp(`connector_onboarding/action_url`)
      | RESET_TRACKING_ID => oltp(`connector_onboarding/reset_tracking_id`)

      /* BUSINESS PROFILE */
      | BUSINESS_PROFILE =>
        switch methodType {
        | Get =>
          switch id {
          | Some(id) => oltp(`account/${merchantId}/business_profile/${id}`)
          | None =>
            switch userEntity {
            | #Tenant
            | #Organization
            | #Merchant
            | #Profile =>
              olap(`account/${merchantId}/profile`)
            }
          }

        | Post =>
          switch id {
          | Some(id) => oltp(`account/${merchantId}/business_profile/${id}`)
          | None => oltp(`account/${merchantId}/business_profile`)
          }
        | _ => oltp(`account/${merchantId}/business_profile`)
        }

      /* API KEYS */
      | API_KEYS =>
        switch methodType {
        | Get => oltp(`api_keys/${merchantId}/list`)
        | Post =>
          switch id {
          | Some(key_id) => oltp(`api_keys/${merchantId}/${key_id}`)
          | None => oltp(`api_keys/${merchantId}`)
          }
        | Delete => oltp(`api_keys/${merchantId}/${id->Option.getOr("")}`)
        | _ => oltp("")
        }

      /* MERCHANT ACQUIRER */
      | ACQUIRER_CONFIG_SETTINGS =>
        switch methodType {
        | Post =>
          switch id {
          | Some(acquirerId) => oltp(`profile_acquirer/${profileId}/${acquirerId}`)
          | None => oltp(`profile_acquirer`)
          }
        | _ => oltp("")
        }

      /* DISPUTES EVIDENCE */
      | ACCEPT_DISPUTE =>
        switch id {
        | Some(id) => oltp(`disputes/accept/${id}`)
        | None => oltp(`disputes`)
        }
      | DISPUTES_ATTACH_EVIDENCE =>
        switch id {
        | Some(id) => oltp(`disputes/evidence/${id}`)
        | _ => oltp(`disputes/evidence`)
        }

      /* PMTS COUNTRY-CURRENCY DETAILS */
      | PAYMENT_METHOD_CONFIG => olap(`payment_methods/filter`)

      /* USER MANAGEMENT REVAMP */
      | USER_MANAGEMENT => {
          let userUrl = `user`
          switch userRoleTypes {
          | USER_LIST =>
            switch queryParameters {
            | Some(queryParams) => olap(`${userUrl}/user/list?${queryParams}`)
            | None => olap(`${userUrl}/user/list`)
            }
          | ROLE_LIST =>
            switch queryParameters {
            | Some(queryParams) => olap(`${userUrl}/role/list?${queryParams}`)
            | None => olap(`${userUrl}/role/list`)
            }
          | ROLE_ID =>
            switch id {
            | Some(key_id) => oltp(`${userUrl}/role/${key_id}/v2`)
            | None => oltp("")
            }
          | _ => oltp("")
          }
        }

      | HYPERSWITCH_RECON =>
        switch hyperswitchReconType {
        | #FILE_UPLOAD =>
          switch methodType {
          | Post =>
            switch id {
            | Some(ingestionId) => recon(`ingestions/${ingestionId}/upload`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #ACCOUNTS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) => recon(`accounts/${accountId}`)
            | None => recon(`accounts`)
            }
          | _ => oltp("")
          }
        | #TRANSACTIONS_LIST =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionID) => recon(`transactions/${transactionID}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) => recon(`transactions?${queryParams}`)
              | None => recon(`transactions`)
              }
            }
          | _ => oltp("")
          }
        | #TRANSACTIONS_LIST_V2 =>
          switch methodType {
          | Post => recon(`transactions/v2/list`)
          | _ => oltp("")
          }
        | #PROCESSED_ENTRIES_LIST_WITH_ACCOUNT =>
          switch methodType {
          | Get =>
            switch id {
            | Some(accountId) =>
              switch queryParameters {
              | Some(queryParams) => recon(`accounts/${accountId}/entries?${queryParams}`)
              | None => recon(`accounts/${accountId}/entries`)
              }
            | None => oltp("")
            }
          | _ => oltp("")
          }
        | #PROCESSED_ENTRIES_LIST_WITH_TRANSACTION =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionId) => recon(`transactions/${transactionId}/entries`)
            | None => recon(`entries`)
            }
          | _ => oltp("")
          }
        | #PROCESSING_ENTRIES_LIST_V2 =>
          switch methodType {
          | Post => recon(`staging_entries/v2/list`)
          | _ => oltp("")
          }
        | #PROCESSING_ENTRIES_LIST =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`staging_entries?${queryParams}`)
            | None =>
              switch id {
              | Some(processingEntryId) => recon(`staging_entries/${processingEntryId}`)
              | None => recon(`staging_entries`)
              }
            }
          | Put =>
            switch id {
            | Some(processingEntryId) => recon(`staging_entries/${processingEntryId}`)
            | None => oltp("")
            }
          | _ => oltp("")
          }
        | #RECON_RULES =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ruleId) => recon(`recon_rules/v2/${ruleId}`)
            | None => recon(`recon_rules/v2`)
            }
          | _ => oltp("")
          }
        | #INGESTION_HISTORY =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`ingestions/history?${queryParams}`)
            | None =>
              switch id {
              | Some(ingestionHistoryId) => recon(`ingestions/history/${ingestionHistoryId}`)
              | None => recon(`ingestions/history`)
              }
            }
          | _ => oltp("")
          }
        | #INGESTION_CONFIG =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ingestionId) => recon(`ingestions/config/${ingestionId}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) => recon(`ingestions/config?${queryParams}`)
              | None => recon(`ingestions/config`)
              }
            }
          | _ => oltp("")
          }
        | #TRANSFORMATION_HISTORY =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`transformations/history?${queryParams}`)
            | None =>
              switch id {
              | Some(transformationHistoryId) =>
                recon(`transformations/history/${transformationHistoryId}`)
              | None => recon(`transformations/history`)
              }
            }
          | _ => oltp("")
          }
        | #TRANSFORMATION_CONFIG =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transformationId) => recon(`transformations/configs/${transformationId}`)
            | None =>
              switch queryParameters {
              | Some(queryParams) => recon(`transformations/configs?${queryParams}`)
              | None => recon(`transformations/configs`)
              }
            }
          | _ => oltp("")
          }
        | #TRANSFORMATION_CONFIG_WITH_METADATA =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transformationId) =>
              recon(`transformations/configs/${transformationId}/metadata_schema`)
            | None => oltp("")
            }
          | _ => oltp("")
          }
        | #VOID_TRANSACTION =>
          switch methodType {
          | Put =>
            switch id {
            | Some(transactionId) => recon(`transactions/${transactionId}/void`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #FORCE_RECONCILE_TRANSACTION =>
          switch methodType {
          | Put =>
            switch id {
            | Some(transactionId) =>
              recon(`exception_management/transactions/${transactionId}/force_reconcile`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #TRANSACTION_RESOLUTIONS =>
          switch methodType {
          | Get =>
            switch id {
            | Some(transactionId) =>
              recon(`exception_management/transactions/${transactionId}/resolutions`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #MANUAL_RECONCILIATION =>
          switch methodType {
          | Post =>
            switch id {
            | Some(transactionId) =>
              recon(`exception_management/transactions/${transactionId}/manual_reconciliation`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #LINKABLE_STAGING_ENTRIES =>
          switch methodType {
          | Post =>
            switch id {
            | Some(transactionId) =>
              recon(
                `exception_management/transactions/${transactionId}/linkable_staging_entries/v2/list`,
              )
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #DOWNLOAD_INGESTION_HISTORY_FILE =>
          switch methodType {
          | Get =>
            switch id {
            | Some(ingestionHistoryId) => recon(`ingestions/history/${ingestionHistoryId}/download`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #AUDIT_TRAIL =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`audit_trail?${queryParams}`)
            | None => recon(`audit_trail`)
            }
          | _ => oltp("")
          }
        | #PROCESSING_ENTRY_RESOLUTIONS =>
          switch methodType {
          | Get =>
            switch id {
            | Some(processingEntryId) =>
              recon(`exception_management/staging_entries/${processingEntryId}/resolutions`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #VOID_PROCESSING_ENTRY =>
          switch methodType {
          | Put =>
            switch id {
            | Some(processingEntryId) => recon(`staging_entries/${processingEntryId}/void`)
            | None => oltp(``)
            }
          | _ => oltp("")
          }
        | #TRANSACTION_BULK_OPERATIONS =>
          switch methodType {
          | Post => recon(`transactions/bulk_operations`)
          | _ => oltp("")
          }
        | #STAGING_ENTRY_BULK_OPERATIONS =>
          switch methodType {
          | Post => recon(`staging_entries/bulk_operations`)
          | _ => oltp("")
          }
        | #OVERVIEW_RULES =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`overview/transactions?${queryParams}`)
            | None => recon(`overview/transactions`)
            }
          | _ => oltp("")
          }
        | #OVERVIEW_RULES_TIME_SERIES =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`overview/transactions/time_series?${queryParams}`)
            | None => recon(`overview/transactions/time_series`)
            }
          | _ => oltp("")
          }
        | #RULE_ACCOUNT_BREAKDOWN =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) =>
              recon(`overview/transactions/rule_account_breakdown?${queryParams}`)
            | None => recon(`overview/transactions/rule_account_breakdown`)
            }
          | _ => oltp("")
          }
        | #STAGING_ENTRIES_OVERVIEW =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(queryParams) => recon(`overview/staging_entries?${queryParams}`)
            | None => recon(`overview/staging_entries`)
            }
          | _ => oltp("")
          }
        | #NONE => oltp("")
        }

      /* INTELLIGENT ROUTING */
      | GET_REVIEW_FIELDS => oltp(`dynamic-routing/simulate/baseline-review-fields`)
      | SIMULATE_INTELLIGENT_ROUTING =>
        switch queryParameters {
        | Some(queryParams) => oltp(`dynamic-routing/simulate/${merchantId}?${queryParams}`)
        | None => oltp(`dynamic-routing/simulate/${merchantId}`)
        }
      | INTELLIGENT_ROUTING_RECORDS =>
        switch queryParameters {
        | Some(queryParams) =>
          oltp(`dynamic-routing/simulate/${merchantId}/get-records?${queryParams}`)
        | None => oltp(`dynamic-routing/simulate/${merchantId}/get-records`)
        }
      | INTELLIGENT_ROUTING_GET_STATISTICS =>
        oltp(`dynamic-routing/simulate/${merchantId}/get-statistics`)

      /* Revenue Recovery */
      | TRANSACTION_OVERVIEW => revenueRecovery(`analytics/transaction_overview`)
      | RETRY_PERFORMANCE => revenueRecovery(`analytics/retry_performance`)
      | MONTHLY_RETRY_SUCCESS => revenueRecovery(`analytics/monthly_retry_success`)
      | RETRY_ATTEMPTS_TREND => revenueRecovery(`analytics/retry_attempts_trend`)
      | ERROR_CATEGORY_ANALYSIS => revenueRecovery(`analytics/error_category_analysis`)
      | RECOVERY_INVOICES => revenueRecovery(`list-invoices`)
      | RECOVERY_ATTEMPTS =>
        switch queryParameters {
        | Some(queryParams) => revenueRecovery(`list-attempts/${queryParams}`)
        | None => revenueRecovery(`list-attempts`)
        }

      /* USERS */
      | USERS =>
        let userUrl = `user`

        switch userType {
        // DASHBOARD LOGIN / SIGNUP
        | #CONNECT_ACCOUNT =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/connect_account?${params}`)
          | None => oltp(`${userUrl}/connect_account`)
          }
        | #SIGNINV2 => oltp(`${userUrl}/v2/signin`)
        | #LAUNCH_SAGE => oltp(`${userUrl}/launch_sage`)
        | #CHANGE_PASSWORD => oltp(`${userUrl}/change_password`)
        | #SIGNUP
        | #SIGNOUT
        | #RESET_PASSWORD
        | #VERIFY_EMAIL_REQUEST
        | #FORGOT_PASSWORD
        | #ROTATE_PASSWORD =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }

        // POST LOGIN QUESTIONNAIRE
        | #SET_METADATA =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }

        // USER DATA
        | #USER_DATA =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/data?${params}`)
          | None => oltp(`${userUrl}/data`)
          }
        | #MERCHANT_DATA => oltp(`${userUrl}/data`)
        | #USER_INFO => oltp(userUrl)

        // USER GROUP ACCESS
        | #GET_GROUP_ACL => oltp(`${userUrl}/role/v2`)
        | #ROLE_INFO =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/parent/list?${params}`)
          | None => oltp(`${userUrl}/parent/list`)
          }

        | #GROUP_ACCESS_INFO =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/permission_info?${params}`)
          | None => oltp(`${userUrl}/permission_info`)
          }

        // USER ACTIONS
        | #USER_DELETE => oltp(`${userUrl}/user/delete`)
        | #USER_UPDATE => oltp(`${userUrl}/update`)
        | #UPDATE_ROLE => oltp(`${userUrl}/user/${(userType :> string)->String.toLowerCase}`)

        // INVITATION INSIDE DASHBOARD
        | #RESEND_INVITE =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/user/resend_invite?${params}`)
          | None => oltp(`${userUrl}/user/resend_invite`)
          }
        | #ACCEPT_INVITATION_HOME => oltp(`${userUrl}/user/invite/accept`)
        | #INVITE_MULTIPLE =>
          switch queryParameters {
          | Some(params) =>
            oltp(`${userUrl}/user/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => oltp(`${userUrl}/user/${(userType :> string)->String.toLowerCase}`)
          }

        // ACCEPT INVITE PRE_LOGIN
        | #ACCEPT_INVITATION_PRE_LOGIN => oltp(`${userUrl}/user/invite/accept/pre_auth`)

        // CREATE_ORG
        | #CREATE_ORG => oltp(`user/create_org`)
        // CREATE_PLATFORM
        | #CREATE_PLATFORM => oltp(`user/create_platform`)
        // CREATE MERCHANT
        | #CREATE_MERCHANT =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }
        | #SWITCH_ORG => oltp(`${userUrl}/switch/org`)
        | #SWITCH_MERCHANT_NEW => oltp(`${userUrl}/switch/merchant`)
        | #SWITCH_PROFILE | #SWITCH_PROFILE_NEW => oltp(`${userUrl}/switch/profile`)

        // Org-Merchant-Profile List
        | #LIST_ORG => olap(`${userUrl}/list/org`)
        | #LIST_MERCHANT => olap(`${userUrl}/list/merchant`)
        | #LIST_PROFILE => olap(`${userUrl}/list/profile`)

        // Clone connector across profiles of the same merchant
        | #CLONE_CONNECTOR => oltp(`${userUrl}/clone_connector`)

        // CREATE ROLES
        | #CREATE_CUSTOM_ROLE => oltp(`${userUrl}/role`)
        | #CREATE_CUSTOM_ROLE_V2 => oltp(`${userUrl}/role/v2`)
        // EMAIL FLOWS
        | #FROM_EMAIL => oltp(`${userUrl}/from_email`)
        | #VERIFY_EMAILV2 => oltp(`${userUrl}/v2/verify_email`)
        | #ACCEPT_INVITE_FROM_EMAIL =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}?${params}`)
          | None => oltp(`${userUrl}/${(userType :> string)->String.toLowerCase}`)
          }
        | #TERMINATE_ACCEPT_INVITE => oltp(`${userUrl}/terminate_accept_invite`)

        // SPT FLOWS (Totp)
        | #BEGIN_TOTP => oltp(`${userUrl}/2fa/totp/begin`)
        | #CHECK_TWO_FACTOR_AUTH_STATUS_V2 => oltp(`${userUrl}/2fa/v2`)
        | #VERIFY_TOTP => oltp(`${userUrl}/2fa/totp/verify`)
        | #VERIFY_RECOVERY_CODE => oltp(`${userUrl}/2fa/recovery_code/verify`)
        | #GENERATE_RECOVERY_CODES => oltp(`${userUrl}/2fa/recovery_code/generate`)
        | #TERMINATE_TWO_FACTOR_AUTH =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/2fa/terminate?${params}`)
          | None => oltp(`${userUrl}/2fa/terminate`)
          }

        | #CHECK_TWO_FACTOR_AUTH_STATUS => oltp(`${userUrl}/2fa`)
        | #RESET_TOTP => oltp(`${userUrl}/2fa/totp/reset`)

        // SPT FLOWS (SSO)
        | #GET_AUTH_LIST =>
          switch queryParameters {
          | Some(params) => olap(`${userUrl}/auth/list?${params}`)
          | None => olap(`${userUrl}/auth/list`)
          }
        | #SIGN_IN_WITH_SSO => oltp(`${userUrl}/oidc`)
        | #AUTH_URL =>
          switch queryParameters {
          | Some(params) => oltp(`${userUrl}/auth/url?${params}`)
          | None => oltp(`${userUrl}/auth/url`)
          }
        | #AUTH_SELECT => oltp(`${userUrl}/auth/select`)

        // user-management revamp
        | #LIST_ROLES_FOR_INVITE =>
          switch queryParameters {
          | Some(params) => olap(`${userUrl}/role/list/invite?${params}`)
          | None => oltp("")
          }
        | #LIST_INVITATION => oltp(`${userUrl}/list/invitation`)
        | #USER_DETAILS => olap(`${userUrl}/user`)
        | #LIST_ROLES_FOR_ROLE_UPDATE =>
          switch queryParameters {
          | Some(params) => olap(`${userUrl}/role/list/update?${params}`)
          | None => oltp("")
          }
        | #THEME =>
          switch methodType {
          | Get =>
            switch id {
            | Some(themeId) => oltp(`${userUrl}/theme/${themeId}`)
            | None => oltp(`${userUrl}/theme`)
            }
          | Post => oltp(`${userUrl}/theme`)
          | Put =>
            switch id {
            | Some(themeId) => oltp(`${userUrl}/theme/${themeId}`)
            | None => oltp(`${userUrl}/theme`)
            }
          | Delete =>
            switch id {
            | Some(themeId) => oltp(`${userUrl}/theme/${themeId}`)
            | None => oltp(`${userUrl}/theme`)
            }
          | _ => oltp("")
          }

        | #THEME_LIST =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(params) => oltp(`${userUrl}/theme/list?${params}`)
            | None => oltp(`${userUrl}/theme/list`)
            }
          | _ => oltp("")
          }

        | #THEME_BY_LINEAGE =>
          switch methodType {
          | Get =>
            switch queryParameters {
            | Some(params) => oltp(`${userUrl}/theme?${params}`)
            | None => oltp(`${userUrl}/theme`)
            }
          | _ => oltp("")
          }

        | #THEME_UPLOAD_ASSET =>
          switch methodType {
          | Post =>
            switch id {
            | Some(themeId) => oltp(`${userUrl}/theme/${themeId}`)
            | None => oltp(`${userUrl}/theme`)
            }
          | _ => oltp("")
          }

        | #NONE => oltp("")
        }

      /* TO BE CHECKED */
      | INTEGRATION_DETAILS => oltp(`user/get_sandbox_integration_details`)
      | SDK_PAYMENT => oltp("payments")
      | CHAT_BOT => oltp(`chat/ai/data`)
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

    `${getBaseUrl(endpoint.service)}/${endpoint.path}`
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
