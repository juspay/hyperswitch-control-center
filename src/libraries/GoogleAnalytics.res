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

let initialize = tag_ID => {
  analytics.initialize(. tag_ID)
}

let event = (~category, ~label, ~action) => {
  analytics.event(. {
    category,
    action,
    label,
  })
}

let send = object => {
  analytics.send(. object)
}
