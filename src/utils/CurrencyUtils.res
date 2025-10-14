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
  | BIF
  | BMD
  | BND
  | BOB
  | BRL
  | BSD
  | BWP
  | BZD
  | CAD
  | CHF
  | CLF
  | CLP
  | COP
  | CRC
  | CUP
  | CZK
  | DJF
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
  | GNF
  | GTQ
  | GYD
  | HKD
  | HNL
  | HTG
  | HUF
  | IDR
  | ILS
  | INR
  | IQD
  | IRR
  | JMD
  | JOD
  | JPY
  | KES
  | KGS
  | KHR
  | KMF
  | KRW
  | KWD
  | KYD
  | KZT
  | LAK
  | LBP
  | LKR
  | LRD
  | LSL
  | LYD
  | MAD
  | MDL
  | MGA
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
  | PYG
  | QAR
  | RON
  | RWF
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
  | TND
  | TRY
  | TTD
  | TWD
  | TZS
  | UGX
  | USD
  | VND
  | VUV
  | XAF
  | XOF
  | XPF

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
  CLP,
  COP,
  CRC,
  CUP,
  CZK,
  DJF,
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
  GNF,
  GTQ,
  GYD,
  HKD,
  HNL,
  HTG,
  HUF,
  IDR,
  ILS,
  INR,
  IRR,
  JMD,
  JOD,
  JPY,
  KES,
  KGS,
  KHR,
  KMF,
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
  MGA,
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
  PYG,
  QAR,
  RON,
  RWF,
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
  UGX,
  USD,
  VND,
  VUV,
  XAF,
  XOF,
  XPF,
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
  | BIF => "BIF"
  | BMD => "BMD"
  | BND => "BND"
  | BOB => "BOB"
  | BRL => "BRL"
  | BSD => "BSD"
  | BWP => "BWP"
  | BZD => "BZD"
  | CAD => "CAD"
  | CHF => "CHF"
  | CLF => "CLF"
  | CLP => "CLP"
  | COP => "COP"
  | CRC => "CRC"
  | CUP => "CUP"
  | CZK => "CZK"
  | DJF => "DJF"
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
  | GNF => "GNF"
  | GTQ => "GTQ"
  | GYD => "GYD"
  | HKD => "HKD"
  | HNL => "HNL"
  | HTG => "HTG"
  | HUF => "HUF"
  | IDR => "IDR"
  | ILS => "ILS"
  | INR => "INR"
  | IQD => "IQD"
  | IRR => "IRR"
  | JMD => "JMD"
  | JOD => "JOD"
  | JPY => "JPY"
  | KES => "KES"
  | KGS => "KGS"
  | KHR => "KHR"
  | KMF => "KMF"
  | KRW => "KRW"
  | KWD => "KWD"
  | KYD => "KYD"
  | KZT => "KZT"
  | LAK => "LAK"
  | LBP => "LBP"
  | LKR => "LKR"
  | LRD => "LRD"
  | LSL => "LSL"
  | LYD => "LYD"
  | MAD => "MAD"
  | MDL => "MDL"
  | MGA => "MGA"
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
  | PYG => "PYG"
  | QAR => "QAR"
  | RON => "RON"
  | RWF => "RWF"
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
  | TND => "TND"
  | TRY => "TRY"
  | TTD => "TTD"
  | TWD => "TWD"
  | TZS => "TZS"
  | UGX => "UGX"
  | USD => "USD"
  | VND => "VND"
  | VUV => "VUV"
  | XAF => "XAF"
  | XOF => "XOF"
  | XPF => "XPF"
  }
}

let getCurrencyCodeFromString: string => currencyCode = currencyCode => {
  switch currencyCode {
  | "AED" => AED
  | "ALL" => ALL
  | "AMD" => AMD
  | "ANG" => ANG
  | "ARS" => ARS
  | "AUD" => AUD
  | "AWG" => AWG
  | "AZN" => AZN
  | "BBD" => BBD
  | "BDT" => BDT
  | "BHD" => BHD
  | "BMD" => BMD
  | "BND" => BND
  | "BOB" => BOB
  | "BRL" => BRL
  | "BSD" => BSD
  | "BWP" => BWP
  | "BZD" => BZD
  | "CAD" => CAD
  | "CHF" => CHF
  | "COP" => COP
  | "CRC" => CRC
  | "CUP" => CUP
  | "CZK" => CZK
  | "DKK" => DKK
  | "DOP" => DOP
  | "DZD" => DZD
  | "EGP" => EGP
  | "ETB" => ETB
  | "EUR" => EUR
  | "FJD" => FJD
  | "GBP" => GBP
  | "GHS" => GHS
  | "GIP" => GIP
  | "GMD" => GMD
  | "GTQ" => GTQ
  | "GYD" => GYD
  | "HKD" => HKD
  | "HNL" => HNL
  | "HTG" => HTG
  | "HUF" => HUF
  | "IDR" => IDR
  | "ILS" => ILS
  | "INR" => INR
  | "JMD" => JMD
  | "JOD" => JOD
  | "JPY" => JPY
  | "KES" => KES
  | "KGS" => KGS
  | "KHR" => KHR
  | "KRW" => KRW
  | "KWD" => KWD
  | "KYD" => KYD
  | "KZT" => KZT
  | "LAK" => LAK
  | "LBP" => LBP
  | "LKR" => LKR
  | "LRD" => LRD
  | "LSL" => LSL
  | "MAD" => MAD
  | "MDL" => MDL
  | "MKD" => MKD
  | "MMK" => MMK
  | "MNT" => MNT
  | "MOP" => MOP
  | "MUR" => MUR
  | "MVR" => MVR
  | "MWK" => MWK
  | "MXN" => MXN
  | "MYR" => MYR
  | "NAD" => NAD
  | "NGN" => NGN
  | "NIO" => NIO
  | "NOK" => NOK
  | "NPR" => NPR
  | "NZD" => NZD
  | "OMR" => OMR
  | "PEN" => PEN
  | "PGK" => PGK
  | "PHP" => PHP
  | "PKR" => PKR
  | "PLN" => PLN
  | "QAR" => QAR
  | "RON" => RON
  | "CNY" => CNY
  | "RUB" => RUB
  | "SAR" => SAR
  | "SCR" => SCR
  | "SEK" => SEK
  | "SGD" => SGD
  | "SLL" => SLL
  | "SOS" => SOS
  | "SSP" => SSP
  | "SVC" => SVC
  | "SZL" => SZL
  | "THB" => THB
  | "TRY" => TRY
  | "TTD" => TTD
  | "TWD" => TWD
  | "TZS" => TZS
  | _ => USD
  }
}

let getCurrencyNameFromCode = currencyCode => {
  switch currencyCode {
  | AED => "United Arab Emirates dirham"
  | ALL => "Albanian lek"
  | AMD => "Armenian dram"
  | ANG => "Netherlands Antillean guilder"
  | ARS => "Argentine peso"
  | AUD => "Australian dollar"
  | AWG => "Aruban florin"
  | AZN => "Azerbaijani manat"
  | BBD => "Barbados dollar"
  | BDT => "Bangladeshi taka"
  | BHD => "Bahraini dinar"
  | BIF => "Burundian franc"
  | BMD => "Bermudian dollar"
  | BND => "Brunei dollar"
  | BOB => "Boliviano"
  | BRL => "Brazilian real"
  | BSD => "Bahamian dollar"
  | BWP => "Botswana pula"
  | BZD => "Belize dollar"
  | CAD => "Canadian dollar"
  | CHF => "Swiss franc"
  | CLF => "Chilean unit of account (UF)"
  | CLP => "Chilean peso"
  | COP => "Colombian peso"
  | CRC => "Costa Rican colón"
  | CUP => "Cuban peso"
  | CZK => "Czech koruna"
  | DJF => "Djiboutian franc"
  | DKK => "Danish krone"
  | DOP => "Dominican peso"
  | DZD => "Algerian dinar"
  | EGP => "Egyptian pound"
  | ETB => "Ethiopian birr"
  | EUR => "Euro"
  | FJD => "Fiji dollar"
  | GBP => "Pound sterling"
  | GHS => "Ghanaian cedi"
  | GIP => "Gibraltar pound"
  | GMD => "Gambian dalasi"
  | GNF => "Guinean franc"
  | GTQ => "Guatemalan quetzal"
  | GYD => "Guyanese dollar"
  | HKD => "Hong Kong dollar"
  | HNL => "Honduran lempira"
  | HTG => "Haitian gourde"
  | HUF => "Hungarian forint"
  | IDR => "Indonesian rupiah"
  | ILS => "Israeli new shekel"
  | INR => "Indian rupee"
  | IQD => "Iraqi dinar"
  | IRR => "Iranian rial"
  | JMD => "Jamaican dollar"
  | JOD => "Jordanian dinar"
  | JPY => "Japanese yen"
  | KES => "Kenyan shilling"
  | KGS => "Kyrgyzstani som"
  | KHR => "Cambodian riel"
  | KMF => "Comorian franc"
  | KRW => "South Korean won"
  | KWD => "Kuwaiti dinar"
  | KYD => "Cayman Islands dollar"
  | KZT => "Kazakhstani tenge"
  | LAK => "Lao kip"
  | LBP => "Lebanese pound"
  | LKR => "Sri Lankan rupee"
  | LRD => "Liberian dollar"
  | LSL => "Lesotho loti"
  | LYD => "Libyan dinar"
  | MAD => "Moroccan dirham"
  | MDL => "Moldovan leu"
  | MGA => "Malagasy ariary"
  | MKD => "Macedonian denar"
  | MMK => "Myanmar kyat"
  | MNT => "Mongolian tögrög"
  | MOP => "Macanese pataca"
  | MUR => "Mauritian rupee"
  | MVR => "Maldivian rufiyaa"
  | MWK => "Malawian kwacha"
  | MXN => "Mexican peso"
  | MYR => "Malaysian ringgit"
  | NAD => "Namibian dollar"
  | NGN => "Nigerian naira"
  | NIO => "Nicaraguan córdoba"
  | NOK => "Norwegian krone"
  | NPR => "Nepalese rupee"
  | NZD => "New Zealand dollar"
  | OMR => "Omani rial"
  | PEN => "Peruvian sol"
  | PGK => "Papua New Guinean kina"
  | PHP => "Philippine peso"
  | PKR => "Pakistani rupee"
  | PLN => "Polish złoty"
  | PYG => "Paraguayan guaraní"
  | QAR => "Qatari riyal"
  | RON => "Romanian leu"
  | RWF => "Rwandan franc"
  | CNY => "Renminbi"
  | RUB => "Russian ruble"
  | SAR => "Saudi riyal"
  | SCR => "Seychelles rupee"
  | SEK => "Swedish krona"
  | SGD => "Singapore dollar"
  | SLL => "Sierra Leonean leone"
  | SOS => "Somali shilling"
  | SSP => "South Sudanese pound"
  | SVC => "Salvadoran colón"
  | SZL => "Swazi lilangeni"
  | THB => "Thai baht"
  | TND => "Tunisian dinar"
  | TRY => "Turkish lira"
  | TTD => "Trinidad and Tobago dollar"
  | TWD => "New Taiwan dollar"
  | TZS => "Tanzanian shilling"
  | UGX => "Ugandan shilling"
  | USD => "United States dollar"
  | VND => "Vietnamese dong"
  | VUV => "Vanuatu vatu"
  | XAF => "Central African CFA franc"
  | XOF => "West African CFA franc"
  | XPF => "CFP franc"
  }
}

let getCountryListFromCurrency = currencyCode => {
  open CountryUtils
  switch currencyCode {
  | AED => [AE]
  | ALL => [AL]
  | AMD => [AM]
  | ANG => [CW, SX]
  | ARS => [AR]
  | AUD => [AU, CX, CC]
  | AWG => [AW]
  | AZN => [AZ]
  | BBD => [BB]
  | BDT => [BD]
  | BHD => [BH]
  | BMD => [BM]
  | BND => [BN]
  | BOB => [BO]
  | BRL => [BR]
  | BSD => [BS]
  | BWP => [BW]
  | BZD => [BZ]
  | CAD => [CA]
  | CHF => [LI, CH]
  | CLF => [CL]
  | CLP => [CL]
  | COP => [CO]
  | CRC => [CR]
  | CUP => [CU]
  | CZK => [CZ]
  | DKK => [DK, FO, GL]
  | DOP => [DO]
  | DZD => [DZ]
  | EGP => [EG]
  | ETB => [ET]
  | EUR => [
      AD,
      AT,
      AX,
      BE,
      CY,
      EE,
      FI,
      FR,
      DE,
      GR,
      GP,
      IE,
      IT,
      LV,
      LT,
      LU,
      MT,
      MQ,
      YT,
      MC,
      ME,
      NL,
      PT,
      RE,
      BL,
      MF,
      PM,
      SM,
      SK,
      SI,
      ES,
      VA,
      GF,
      TF,
      MF,
    ]
  | FJD => [FJ]
  | GBP => [GB, GG, IM, JE]
  | GHS => [GH]
  | GIP => [GI]
  | GMD => [GM]
  | GTQ => [GT]
  | GYD => [GY]
  | HKD => [HK]
  | HNL => [HN]
  | HTG => [HT]
  | HUF => [HU]
  | IDR => [ID]
  | ILS => [IL, PS]
  | INR => [IN]
  | IQD => [IQ]
  | IRR => [IR]
  | JMD => [JM]
  | JOD => [JO]
  | JPY => [JP]
  | KES => [KE]
  | KGS => [KG]
  | KHR => [KH]
  | KMF => [KM]
  | KRW => [KP, KR]
  | KWD => [KW]
  | KYD => [KY]
  | KZT => [KZ]
  | LAK => [LA]
  | LBP => [LB]
  | LKR => [LK]
  | LRD => [LR]
  | LSL => [LS]
  | LYD => [LY]
  | MAD => [MA, EH]
  | MDL => [MD]
  | MKD => [MK]
  | MMK => [MM]
  | MNT => [MN]
  | MOP => [MO]
  | MGA => [MG]
  | MUR => [MU]
  | MVR => [MV]
  | MWK => [MW]
  | MXN => [MX]
  | MYR => [MY]
  | NAD => [NA]
  | NGN => [NG]
  | NIO => [NI]
  | NOK => [BV, NO, SJ]
  | NPR => [NP]
  | NZD => [NZ, CK, NU, PN, TK]
  | OMR => [OM]
  | PEN => [PE]
  | PGK => [PG]
  | PHP => [PH]
  | PKR => [PK]
  | PLN => [PL]
  | PYG => [PY]
  | QAR => [QA]
  | RON => [RO]
  | CNY => [CN]
  | RUB => [RU]
  | RWF => [RW]
  | SAR => [SA]
  | SCR => [SC]
  | SEK => [SE]
  | SGD => [SG]
  | SLL => [SL]
  | SOS => [SO]
  | SSP => [SS]
  | SVC => [SV]
  | SZL => [SZ]
  | THB => [TH]
  | TND => [TN]
  | TRY => [TR]
  | TTD => [TT]
  | TWD => [TW]
  | TZS => [TZ]
  | UGX => [UG]
  | USD => [AS, BQ, IO, EC, SV, GU, HT, MH, FM, MP, PW, PA, PR, TL, TC, US, VG, VI]
  | VND => [VN]
  | VUV => [VU]
  | XAF => [CM, CF, TD, CG, GQ, GA]
  | XOF => [BJ, BF, CI, GW, ML, NE, SN, TG]
  | XPF => [NC, PF, WF]
  | BIF => [BI]
  | DJF => [DJ]
  | GNF => [GN]
  }
}

let getCurrencyConversionFactor = currency => {
  let currencyCode = getCurrencyCodeFromString(currency)
  let conversionFactor = switch (currencyCode: currencyCode) {
  // Zero-decimal currencies
  | JPY
  | KRW
  | BIF
  | CLP
  | DJF
  | GNF
  | IQD
  | IRR
  | KMF
  | MGA
  | PYG
  | RWF
  | UGX
  | VND
  | VUV
  | XAF
  | XOF
  | XPF => 1
  // Three-decimal currencies
  | BHD
  | JOD
  | KWD
  | OMR
  | LYD
  | TND => 1000
  // Four-decimal currencies
  | CLF => 10000
  // Two-decimal currencies (default)
  | _ => 100
  }
  conversionFactor->Int.toFloat
}

let convertCurrencyFromLowestDenomination = (~amount: float, ~currency: string) => {
  let conversionFactor = getCurrencyConversionFactor(currency)
  amount /. conversionFactor
}

let convertCurrencyToLowestDenomination = (~amount: float, ~currency: string) => {
  let conversionFactor = getCurrencyConversionFactor(currency)
  amount *. conversionFactor
}
