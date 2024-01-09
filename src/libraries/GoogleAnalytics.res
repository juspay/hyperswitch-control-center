type eventType = {
  category: string,
  action: string,
  label: string,
}

type pageViewType = {hitType: string, page: string}

type analyticsType = {
  initialize: (. string) => unit,
  event: (. eventType) => unit,
  send: (. pageViewType) => unit,
}

@module("react-ga4")
external analytics: analyticsType = "default"

let send = object => {
  analytics.send(. object)
}
