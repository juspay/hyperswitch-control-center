type timezoneData = {
  offset: string,
  region: string,
  title: string,
}

type timeZoneType =
  | GMT
  | EAT
  | CET
  | WAT
  | CAT
  | EET
  | CEST
  | SAST
  | HDT
  | AKDT
  | AST
  | EST
  | CDT
  | CST
  | MDT
  | MST
  | EDT
  | ADT
  | PDT
  | NDT
  | AEST
  | NZST
  | EEST
  | HKT
  | WIB
  | WIT
  | IDT
  | PKT
  | IST
  | WITA
  | PST
  | KST
  | JST
  | WEST
  | ACST
  | AWST
  | BST
  | MSK
  | ChST
  | HST
  | SST
  | UTC
type timeZoneRecordType = {
  timeZoneAlias: string,
  timeZoneOffset: string,
}

type timeRecord = {
  key: timeZoneType,
  value: timeZoneRecordType,
}
