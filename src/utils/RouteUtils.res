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
  let path = "/connectors"
  let list = (version: version) =>
    switch version {
    | V1 => path
    | V2 => v2Prefix ++ path
    }
}

/**
 * Routes for the API Keys/Developer module
 */
module ApiKeys = {
  let path = "/developer-api-keys"
  let list = (version: version) =>
    switch version {
    | V1 => path
    | V2 => v2Prefix ++ path
    }
}

/**
 * Routes for the Payments module
 */
module Payments = {
  let path = "/payments"
  let list = (version: version) =>
    switch version {
    | V1 => path
    | V2 => v2Prefix ++ path
    }

  let detail = (version: version, paymentId: string) =>
    switch version {
    | V1 => `${path}/${paymentId}`
    | V2 => `${v2Prefix}${path}/${paymentId}`
    }
}

/**
 * Routes for the Home/Overview module
 */
module Home = {
  let path = "/home"
  let overview = (version: version) =>
    switch version {
    | V1 => path
    | V2 => v2Prefix ++ path
    }
}

/**
 * Routes for Payment Settings
 */
module PaymentSettings = {
  let path = "/payment-settings"
  let settings = (version: version) =>
    switch version {
    | V1 => path
    | V2 => v2Prefix ++ path
    }
}

/**
 * Generic function to get V2 orchestration path
 * Use for routes that only exist in V2
 */
let v2Only = (~path: string) => `/v2/orchestration/${path}`
