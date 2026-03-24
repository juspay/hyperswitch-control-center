open UserInfoTypes

/**
 * Centralized URL routing utilities for handling V1/V2 version-based routes.
 * Use these functions instead of inline switch statements on version.
 */
let v2Prefix = "/v2/orchestration"

/**
 * Routes for the Connectors module
 */
module Connectors = {
  let list = (version: version) =>
    switch version {
    | V1 => "/connectors"
    | V2 => "/v2/orchestration/connectors"
    }
}

/**
 * Routes for the API Keys/Developer module
 */
module ApiKeys = {
  let list = (version: version) =>
    switch version {
    | V1 => "/developer-api-keys"
    | V2 => "/v2/orchestration/developer-api-keys"
    }
}

/**
 * Routes for the Payments module
 */
module Payments = {
  let list = (version: version) =>
    switch version {
    | V1 => "/payments"
    | V2 => "/v2/orchestration/payments"
    }

  let detail = (version: version, paymentId: string) =>
    switch version {
    | V1 => `/payments/${paymentId}`
    | V2 => `/v2/orchestration/payments/${paymentId}`
    }
}

/**
 * Routes for the Home/Overview module
 */
module Home = {
  let overview = (version: version) =>
    switch version {
    | V1 => "/home"
    | V2 => "/v2/orchestration/home"
    }
}

/**
 * Routes for Payment Settings
 */
module PaymentSettings = {
  let settings = (version: version) =>
    switch version {
    | V1 => "/payment-settings"
    | V2 => "/v2/orchestration/payment-settings"
    }
}

/**
 * Generic function to get V2 orchestration path
 * Use for routes that only exist in V2
 */
let v2Only = (~path: string) => `/v2/orchestration/${path}`
