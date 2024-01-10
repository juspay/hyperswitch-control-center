type people = {set: (. Js.Json.t) => unit}

type mixpanel = {people: people}

@module("mixpanel-browser")
external mixpanel: mixpanel = "default"

@send external distinctIdWrapper: (mixpanel, unit) => string = "get_distinct_id"
let getDistinctId = distinctIdWrapper(mixpanel)

@send external identifyWrapper: (mixpanel, string) => unit = "identify"
let identify = identifyWrapper(mixpanel)

let wasInitialied = ref(false)

@module("mixpanel-browser")
external initOrig: (string, {..}) => unit = "init"

let init = (str, obj) => {
  wasInitialied := true
  initOrig(str, obj)
}

@module("mixpanel-browser")
external trackOrig: (string, {..}) => unit = "track"

let track = (str, obj) => {
  if wasInitialied.contents {
    trackOrig(str, obj)
  }
}

@module("mixpanel-browser")
external trackEventOrig: string => unit = "track"
