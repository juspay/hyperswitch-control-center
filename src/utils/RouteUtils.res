open UserInfoTypes

/**
 * Centralized URL routing utility for handling V1/V2 version-based routes.
 *
 * Usage:
 *   RouteUtils.getPath(~path="/connectors", version)
 *   RouteUtils.getPath(~path="/payments", version)
 *   RouteUtils.getPath(~path=`/payments/${paymentId}`, version)
 */

let v2Prefix = "/v2/orchestration"

let getPath = (~path: string, version: version) =>
  switch version {
  | V1 => path
  | V2 => v2Prefix ++ path
  }
