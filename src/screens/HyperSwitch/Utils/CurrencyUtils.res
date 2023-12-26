type currencyCode =
  | AED
  | ALL
  | AMD
  | ANG
  | ARS
  | AUD
  | AWG
  | AZN
  | BBD
  | BDT
  | BHD
  | BMD
  | BND
  | BOB
  | BRL
  | BSD
  | BWP
  | BZD
  | CAD
  | CHF
  | COP
  | CRC
  | CUP
  | CZK
  | DKK
  | DOP
  | DZD
  | EGP
  | ETB
  | EUR
  | FJD
  | GBP
  | GHS
  | GIP
  | GMD
  | GTQ
  | GYD
  | HKD
  | HNL
  | HTG
  | HUF
  | IDR
  | ILS
  | INR
  | JMD
  | JOD
  | JPY
  | KES
  | KGS
  | KHR
  | KRW
  | KWD
  | KYD
  | KZT
  | LAK
  | LBP
  | LKR
  | LRD
  | LSL
  | MAD
  | MDL
  | MKD
  | MMK
  | MNT
  | MOP
  | MUR
  | MVR
  | MWK
  | MXN
  | MYR
  | NAD
  | NGN
  | NIO
  | NOK
  | NPR
  | NZD
  | OMR
  | PEN
  | PGK
  | PHP
  | PKR
  | PLN
  | QAR
  | RON
  | CNY
  | RUB
  | SAR
  | SCR
  | SEK
  | SGD
  | SLL
  | SOS
  | SSP
  | SVC
  | SZL
  | THB
  | TRY
  | TTD
  | TWD
  | TZS
  | USD

let currencyList = [
  AED,
  ALL,
  AMD,
  ANG,
  ARS,
  AUD,
  AWG,
  AZN,
  BBD,
  BDT,
  BHD,
  BMD,
  BND,
  BOB,
  BRL,
  BSD,
  BWP,
  BZD,
  CAD,
  CHF,
  COP,
  CRC,
  CUP,
  CZK,
  DKK,
  DOP,
  DZD,
  EGP,
  ETB,
  EUR,
  FJD,
  GBP,
  GHS,
  GIP,
  GMD,
  GTQ,
  GYD,
  HKD,
  HNL,
  HTG,
  HUF,
  IDR,
  ILS,
  INR,
  JMD,
  JOD,
  JPY,
  KES,
  KGS,
  KHR,
  KRW,
  KWD,
  KYD,
  KZT,
  LAK,
  LBP,
  LKR,
  LRD,
  LSL,
  MAD,
  MDL,
  MKD,
  MMK,
  MNT,
  MOP,
  MUR,
  MVR,
  MWK,
  MXN,
  MYR,
  NAD,
  NGN,
  NIO,
  NOK,
  NPR,
  NZD,
  OMR,
  PEN,
  PGK,
  PHP,
  PKR,
  PLN,
  QAR,
  RON,
  CNY,
  RUB,
  SAR,
  SCR,
  SEK,
  SGD,
  SLL,
  SOS,
  SSP,
  SVC,
  SZL,
  THB,
  TRY,
  TTD,
  TWD,
  TZS,
  USD,
]

let getCurrencyCodeStringFromVariant = currencyCode => {
  switch currencyCode {
  | AED => "AED"
  | ALL => "ALL"
  | AMD => "AMD"
  | ANG => "ANG"
  | ARS => "ARS"
  | AUD => "AUD"
  | AWG => "AWG"
  | AZN => "AZN"
  | BBD => "BBD"
  | BDT => "BDT"
  | BHD => "BHD"
  | BMD => "BMD"
  | BND => "BND"
  | BOB => "BOB"
  | BRL => "BRL"
  | BSD => "BSD"
  | BWP => "BWP"
  | BZD => "BZD"
  | CAD => "CAD"
  | CHF => "CHF"
  | COP => "COP"
  | CRC => "CRC"
  | CUP => "CUP"
  | CZK => "CZK"
  | DKK => "DKK"
  | DOP => "DOP"
  | DZD => "DZD"
  | EGP => "EGP"
  | ETB => "ETB"
  | EUR => "EUR"
  | FJD => "FJD"
  | GBP => "GBP"
  | GHS => "GHS"
  | GIP => "GIP"
  | GMD => "GMD"
  | GTQ => "GTQ"
  | GYD => "GYD"
  | HKD => "HKD"
  | HNL => "HNL"
  | HTG => "HTG"
  | HUF => "HUF"
  | IDR => "IDR"
  | ILS => "ILS"
  | INR => "INR"
  | JMD => "JMD"
  | JOD => "JOD"
  | JPY => "JPY"
  | KES => "KES"
  | KGS => "KGS"
  | KHR => "KHR"
  | KRW => "KRW"
  | KWD => "KWD"
  | KYD => "KYD"
  | KZT => "KZT"
  | LAK => "LAK"
  | LBP => "LBP"
  | LKR => "LKR"
  | LRD => "LRD"
  | LSL => "LSL"
  | MAD => "MAD"
  | MDL => "MDL"
  | MKD => "MKD"
  | MMK => "MMK"
  | MNT => "MNT"
  | MOP => "MOP"
  | MUR => "MUR"
  | MVR => "MVR"
  | MWK => "MWK"
  | MXN => "MXN"
  | MYR => "MYR"
  | NAD => "NAD"
  | NGN => "NGN"
  | NIO => "NIO"
  | NOK => "NOK"
  | NPR => "NPR"
  | NZD => "NZD"
  | OMR => "OMR"
  | PEN => "PEN"
  | PGK => "PGK"
  | PHP => "PHP"
  | PKR => "PKR"
  | PLN => "PLN"
  | QAR => "QAR"
  | RON => "RON"
  | CNY => "CNY"
  | RUB => "RUB"
  | SAR => "SAR"
  | SCR => "SCR"
  | SEK => "SEK"
  | SGD => "SGD"
  | SLL => "SLL"
  | SOS => "SOS"
  | SSP => "SSP"
  | SVC => "SVC"
  | SZL => "SZL"
  | THB => "THB"
  | TRY => "TRY"
  | TTD => "TTD"
  | TWD => "TWD"
  | TZS => "TZS"
  | USD => "USD"
  }
}
