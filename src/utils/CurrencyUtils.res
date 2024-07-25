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
  | BMD => "Bermudian dollar"
  | BND => "Brunei dollar"
  | BOB => "Boliviano"
  | BRL => "Brazilian real"
  | BSD => "Bahamian dollar"
  | BWP => "Botswana pula"
  | BZD => "Belize dollar"
  | CAD => "Canadian dollar"
  | CHF => "Swiss franc"
  | COP => "Colombian peso"
  | CRC => "Costa Rican colon"
  | CUP => "Cuban peso"
  | CZK => "Czech koruna"
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
  | GTQ => "Guatemalan quetzal"
  | GYD => "Guyanese dollar"
  | HKD => "Hong Kong dollar"
  | HNL => "Honduran lempira"
  | HTG => "Haitian gourde"
  | HUF => "Hungarian forint"
  | IDR => "Indonesian rupiah"
  | ILS => "Israeli new shekel"
  | INR => "Indian rupee"
  | JMD => "Jamaican dollar"
  | JOD => "Jordanian dinar"
  | JPY => "Japanese yen"
  | KES => "Kenyan shilling"
  | KGS => "Kyrgyzstani som"
  | KHR => "Cambodian riel"
  | KRW => "South Korean won"
  | KWD => "Kuwaiti dinar"
  | KYD => "Cayman Islands dollar"
  | KZT => "Kazakhstani tenge"
  | LAK => "Lao kip"
  | LBP => "Lebanese pound"
  | LKR => "Sri Lankan rupee"
  | LRD => "Liberian dollar"
  | LSL => "Lesotho loti"
  | MAD => "Moroccan dirham"
  | MDL => "Moldovan leu"
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
  | QAR => "Qatari riyal"
  | RON => "Romanian leu"
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
  | TRY => "Turkish lira"
  | TTD => "Trinidad and Tobago dollar"
  | TWD => "New Taiwan dollar"
  | TZS => "Tanzanian shilling"
  | USD => "United States dollar"
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
  | JMD => [JM]
  | JOD => [JO]
  | JPY => [JP]
  | KES => [KE]
  | KGS => [KG]
  | KHR => [KH]
  | KRW => [KP, KR]
  | KWD => [KW]
  | KYD => [KY]
  | KZT => [KZ]
  | LAK => [LA]
  | LBP => [LB]
  | LKR => [LK]
  | LRD => [LR]
  | LSL => [LS]
  | MAD => [MA, EH]
  | MDL => [MD]
  | MKD => [MK]
  | MMK => [MM]
  | MNT => [MN]
  | MOP => [MO]
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
  | QAR => [QA]
  | RON => [RO]
  | CNY => [CN]
  | RUB => [RU]
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
  | TRY => [TR]
  | TTD => [TT]
  | TWD => [TW]
  | TZS => [TZ]
  | USD => [AS, BQ, IO, EC, SV, GU, HT, MH, FM, MP, PW, PA, PR, TL, TC, US, VG, VI]
  }
}
