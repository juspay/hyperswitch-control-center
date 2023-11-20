// import * as Sentry from "@sentry/react";
// import { Integrations } from "@sentry/tracing";
type integration
type scope

type sentryInitArg = {
  dsn: string,
  integrations: array<integration>,
  tracesSampleRate: float,
  release: string,
  environment?: string,
}

@module("@sentry/react")
external init: sentryInitArg => unit = "init"

module Tracing = {
  @new @module("@sentry/tracing")
  external newBrowserTracing: unit => integration = "BrowserTracing"
}

@module("@sentry/browser")
external setUser: 'a => unit = "setUser"

// @module("@sentry/browser")
// external configureScope: scope => unit = "configureScope"

module ErrorBoundary = {
  type fallbackArg = {
    error: Js.Exn.t,
    componentStack: array<string>,
    resetError: unit => unit,
  }

  @module("@sentry/react") @react.component
  external make: (
    ~fallback: fallbackArg => React.element,
    ~children: React.element,
  ) => React.element = "ErrorBoundary"
}
