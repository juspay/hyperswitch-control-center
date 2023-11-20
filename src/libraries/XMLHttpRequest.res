module XHR = {
  type t

  @send external addEventListener: (t, string, unit => unit) => unit = "addEventListener"
  @send external setRequestHeader: (t, string, string) => unit = "setRequestHeader"
  @send external open_: (t, string, string) => unit = "open"
  @send external send: (t, string) => unit = "send"

  @get external readyState: t => int = "readyState"
  @get external response: t => string = "response"
  @get external status: t => int = "status"

  @get external responseText: t => string = "responseText"
}

@new
external new: unit => XHR.t = "XMLHttpRequest"
