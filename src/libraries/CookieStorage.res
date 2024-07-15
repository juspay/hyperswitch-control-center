@set external setCookie: (DOMUtils.document, string) => unit = "cookie"
@get external getCookie: DOMUtils.document => Js.Nullable.t<string> = "cookie"

let getCookieDict = () => {
  getCookie(DOMUtils.document)
  ->Nullable.toOption
  ->Option.getOr("")
  ->String.split(";")
  ->Array.map(value => {
    let arr = value->String.split("=")
    let key = arr->Array.get(0)->Option.getOr("")->String.trim
    let value = arr->Array.get(1)->Option.getOr("")->String.trim
    (key, value)
  })
  ->Dict.fromArray
}

let getCookieVal = key => {
  getCookieDict()->Dict.get(key)->Option.getOr("")
}

let setCookieVal = cookie => {
  setCookie(DOMUtils.document, cookie)
}

let getDomainOfCookie = domain => {
  switch domain {
  | Some(domain) => domain
  | None => Window.Location.hostname
  }
}

let deleteCookie = (~cookieName, ~domain=?, ()) => {
  let domainClause = `domain=${getDomainOfCookie(domain)}`
  setCookieVal(`${cookieName}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;${domainClause}`)
  setCookieVal(`${cookieName}=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;`)
}
