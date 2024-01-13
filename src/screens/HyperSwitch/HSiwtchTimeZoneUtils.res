let getUserTimeZoneString = () => {
  Js.Date.make()
  ->Js.Date.toTimeString
  ->String.split(" ")
  ->Belt.Array.get(1)
  ->Belt.Option.getWithDefault("")
}

let getUserTimeZone = () => {
  open UserTimeZoneTypes

  let userTimeZone = getUserTimeZoneString()

  switch userTimeZone {
  | "GMT+0000" => GMT
  | "GMT+0300" => EAT
  | "GMT+0100" => CET
  | "GMT+0200" => CAT
  | "GMT-0900" => HDT
  | "GMT-0800" => AKDT
  | "GMT-0400" => AST
  | "GMT-0500" => EST
  | "GMT-0600" => CST
  | "GMT-0700" => MST
  | "GMT-0300" => ADT
  | "GMT-0230" => NDT
  | "GMT+1000" => AEST
  | "GMT+1200" => NZST
  | "GMT+0800" => HKT
  | "GMT+0700" => WIB
  | "GMT+0900" => WIT
  | "GMT+0500" => PKT
  | "GMT+0530" => IST
  | "GMT+0930" => ACST
  | "GMT-1000" => HST
  | "GMT-1100" => SST
  | _ => UTC
  }
}
