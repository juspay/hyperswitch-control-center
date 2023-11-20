type relativeTime

@module("dayjs/plugin/relativeTime")
external relativeTime: relativeTime = "default"

@module("dayjs/plugin/isToday")
external isToday: relativeTime = "default"

@module("dayjs/plugin/customParseFormat")
external customParseFormat: relativeTime = "default"

type rec dayJs = {
  isValid: (. unit) => bool,
  toString: (. unit) => string,
  toDate: (. unit) => Js.Date.t,
  add: (. int, string) => dayJs,
  isSame: (. string, string) => bool,
  subtract: (. int, string) => dayJs,
  diff: (. string, string) => int,
  year: (. unit) => int,
  date: (. int) => dayJs,
  endOf: (. string) => dayJs,
  format: (. string) => string,
  fromNow: (. unit) => string,
  month: (. unit) => int,
  isToday: (. unit) => bool,
}

type extendable = {extend: (. relativeTime) => unit}

@module("dayjs")
external dayJs: extendable = "default"

@module("dayjs")
external getDayJs: unit => dayJs = "default"

@module("dayjs")
external getDayJsForString: string => dayJs = "default"

@module("dayjs")
external getDayJsFromCustromFormat: (string, string, bool) => dayJs = "default"

let getDayJsForJsDate = date => {
  date->Js.Date.toString->getDayJsForString
}
