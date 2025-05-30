type timezoneType = {
  isoAlpha3: string,
  timeZones: array<string>,
  countryName: CountryUtils.countries,
  isoAlpha2: CountryUtils.countiesCode,
  phoneCode: string,
  flag: string,
  currency: string,
}

let defaultTimeZone = {
  isoAlpha3: "",
  timeZones: [],
  countryName: UnitedStatesOfAmerica,
  isoAlpha2: US,
  phoneCode: "+1",
  flag: "🇺🇸",
  currency: "USD",
}

let country = [
  {
    isoAlpha3: "AFG",
    timeZones: ["Asia/Kabul"],
    countryName: Afghanistan,
    isoAlpha2: AF,
    phoneCode: "+93",
    flag: "🇦🇫",
    currency: "AFN",
  },
  {
    isoAlpha3: "ALB",
    timeZones: ["Europe/Tirane"],
    countryName: Albania,
    isoAlpha2: AL,
    phoneCode: "+355",
    flag: "🇦🇱",
    currency: "ALL",
  },
  {
    isoAlpha3: "DZA",
    timeZones: ["Africa/Algiers"],
    countryName: Algeria,
    isoAlpha2: DZ,
    phoneCode: "+213",
    flag: "🇩🇿",
    currency: "DZD",
  },
  {
    isoAlpha3: "ARG",
    timeZones: [
      "America/Argentina/Buenos_Aires",
      "America/Argentina/Cordoba",
      "America/Argentina/Salta",
      "America/Argentina/Jujuy",
      "America/Argentina/Tucuman",
      "America/Argentina/Catamarca",
      "America/Argentina/La_Rioja",
      "America/Argentina/San_Juan",
      "America/Argentina/Mendoza",
      "America/Argentina/San_Luis",
      "America/Argentina/Rio_Gallegos",
      "America/Argentina/Ushuaia",
    ],
    countryName: Argentina,
    isoAlpha2: AR,
    phoneCode: "+54",
    flag: "🇦🇷",
    currency: "ARS",
  },
  {
    isoAlpha3: "ARM",
    timeZones: ["Asia/Yerevan"],
    countryName: Armenia,
    isoAlpha2: AM,
    phoneCode: "+374",
    flag: "🇦🇲",
    currency: "AMD",
  },
  {
    isoAlpha3: "AUS",
    timeZones: [
      "Australia/Lord_Howe",
      "Antarctica/Macquarie",
      "Australia/Hobart",
      "Australia/Currie",
      "Australia/Melbourne",
      "Australia/Sydney",
      "Australia/Broken_Hill",
      "Australia/Brisbane",
      "Australia/Lindeman",
      "Australia/Adelaide",
      "Australia/Darwin",
      "Australia/Perth",
      "Australia/Eucla",
    ],
    countryName: Australia,
    isoAlpha2: AU,
    phoneCode: "+61",
    flag: "🇦🇺",
    currency: "AUD",
  },
  {
    isoAlpha3: "AUT",
    timeZones: ["Europe/Vienna"],
    countryName: Austria,
    isoAlpha2: AT,
    phoneCode: "+43",
    flag: "🇦🇹",
    currency: "EUR",
  },
  {
    isoAlpha3: "AZE",
    timeZones: ["Asia/Baku"],
    countryName: Azerbaijan,
    isoAlpha2: AZ,
    phoneCode: "+994",
    flag: "🇦🇿",
    currency: "AZN",
  },
  {
    isoAlpha3: "BHR",
    timeZones: ["Asia/Bahrain"],
    countryName: Bahrain,
    isoAlpha2: BH,
    phoneCode: "+973",
    flag: "🇧🇭",
    currency: "BHD",
  },
  {
    isoAlpha3: "BGD",
    timeZones: ["Asia/Dhaka"],
    countryName: Bangladesh,
    isoAlpha2: BD,
    phoneCode: "+880",
    flag: "🇧🇩",
    currency: "BDT",
  },
  {
    isoAlpha3: "BLR",
    timeZones: ["Europe/Minsk"],
    countryName: Belarus,
    isoAlpha2: BY,
    phoneCode: "+375",
    flag: "🇧🇾",
    currency: "BYN",
  },
  {
    isoAlpha3: "BEL",
    timeZones: ["Europe/Brussels"],
    countryName: Belgium,
    isoAlpha2: BE,
    phoneCode: "+32",
    flag: "🇧🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "BLZ",
    timeZones: ["America/Belize"],
    countryName: Belize,
    isoAlpha2: BZ,
    phoneCode: "+501",
    flag: "🇧🇿",
    currency: "BZD",
  },
  {
    isoAlpha3: "BTN",
    timeZones: ["Asia/Thimphu"],
    countryName: Bhutan,
    isoAlpha2: BT,
    phoneCode: "+975",
    flag: "🇧🇹",
    currency: "BTN",
  },
  {
    isoAlpha3: "BOL",
    timeZones: ["America/La_Paz"],
    countryName: BoliviaPlurinationalState,
    isoAlpha2: BO,
    phoneCode: "+591",
    flag: "🇧🇴",
    currency: "BOB",
  },
  {
    isoAlpha3: "BIH",
    timeZones: ["Europe/Sarajevo"],
    countryName: BosniaAndHerzegovina,
    isoAlpha2: BA,
    phoneCode: "+387",
    flag: "🇧🇦",
    currency: "BAM",
  },
  {
    isoAlpha3: "BWA",
    timeZones: ["Africa/Gaborone"],
    countryName: Botswana,
    isoAlpha2: BW,
    phoneCode: "+267",
    flag: "🇧🇼",
    currency: "BWP",
  },
  {
    isoAlpha3: "BRA",
    timeZones: [
      "America/Noronha",
      "America/Belem",
      "America/Fortaleza",
      "America/Recife",
      "America/Araguaina",
      "America/Maceio",
      "America/Bahia",
      "America/Sao_Paulo",
      "America/Campo_Grande",
      "America/Cuiaba",
      "America/Santarem",
      "America/Porto_Velho",
      "America/Boa_Vista",
      "America/Manaus",
      "America/Eirunepe",
      "America/Rio_Branco",
    ],
    countryName: Brazil,
    isoAlpha2: BR,
    phoneCode: "+55",
    flag: "🇧🇷",
    currency: "BRL",
  },
  {
    isoAlpha3: "BRN",
    timeZones: ["Asia/Brunei"],
    countryName: BruneiDarussalam,
    isoAlpha2: BN,
    phoneCode: "+673",
    flag: "🇧🇳",
    currency: "BND",
  },
  {
    isoAlpha3: "BGR",
    timeZones: ["Europe/Sofia"],
    countryName: Bulgaria,
    isoAlpha2: BG,
    phoneCode: "+359",
    flag: "🇧🇬",
    currency: "BGN",
  },
  {
    isoAlpha3: "KHM",
    timeZones: ["Asia/Phnom_Penh"],
    countryName: Cambodia,
    isoAlpha2: KH,
    phoneCode: "+855",
    flag: "🇰🇭",
    currency: "KHR",
  },
  {
    isoAlpha3: "CMR",
    timeZones: ["Africa/Douala"],
    countryName: Cameroon,
    isoAlpha2: CM,
    phoneCode: "+237",
    flag: "🇨🇲",
    currency: "XAF",
  },
  {
    isoAlpha3: "CAN",
    timeZones: [
      "America/St_Johns",
      "America/Halifax",
      "America/Glace_Bay",
      "America/Moncton",
      "America/Goose_Bay",
      "America/Blanc-Sablon",
      "America/Toronto",
      "America/Nipigon",
      "America/Thunder_Bay",
      "America/Iqaluit",
      "America/Pangnirtung",
      "America/Atikokan",
      "America/Winnipeg",
      "America/Rainy_River",
      "America/Resolute",
      "America/Rankin_Inlet",
      "America/Regina",
      "America/Swift_Current",
      "America/Edmonton",
      "America/Cambridge_Bay",
      "America/Yellowknife",
      "America/Inuvik",
      "America/Creston",
      "America/Dawson_Creek",
      "America/Fort_Nelson",
      "America/Vancouver",
      "America/Whitehorse",
      "America/Dawson",
    ],
    countryName: Canada,
    isoAlpha2: CA,
    phoneCode: "+1",
    flag: "🇨🇦",
    currency: "CAD",
  },
  {
    isoAlpha3: "CHL",
    timeZones: ["America/Santiago", "Pacific/Easter"],
    countryName: Chile,
    isoAlpha2: CL,
    phoneCode: "+56",
    flag: "🇨🇱",
    currency: "CLP",
  },
  {
    isoAlpha3: "CHN",
    timeZones: ["Asia/Shanghai", "Asia/Urumqi"],
    countryName: China,
    isoAlpha2: CN,
    phoneCode: "+86",
    flag: "🇨🇳",
    currency: "CNY",
  },
  {
    isoAlpha3: "COL",
    timeZones: ["America/Bogota"],
    countryName: Colombia,
    isoAlpha2: CO,
    phoneCode: "+57",
    flag: "🇨🇴",
    currency: "COP",
  },
  {
    isoAlpha3: "COD",
    timeZones: ["Africa/Kinshasa", "Africa/Lubumbashi"],
    countryName: CongoDemocraticRepublic,
    isoAlpha2: CD,
    phoneCode: "+243",
    flag: "🇨🇩",
    currency: "CDF",
  },
  {
    isoAlpha3: "CRI",
    timeZones: ["America/Costa_Rica"],
    countryName: CostaRica,
    isoAlpha2: CR,
    phoneCode: "+506",
    flag: "🇨🇷",
    currency: "CRC",
  },
  {
    isoAlpha3: "CIV",
    timeZones: ["Africa/Abidjan"],
    countryName: CotedIvoire,
    isoAlpha2: CI,
    phoneCode: "+225",
    flag: "🇨🇮",
    currency: "XOF",
  },
  {
    isoAlpha3: "HRV",
    timeZones: ["Europe/Zagreb"],
    countryName: Croatia,
    isoAlpha2: HR,
    phoneCode: "+385",
    flag: "🇭🇷",
    currency: "HRK",
  },
  {
    isoAlpha3: "CUB",
    timeZones: ["America/Havana"],
    countryName: Cuba,
    isoAlpha2: CU,
    phoneCode: "+53",
    flag: "🇨🇺",
    currency: "CUP",
  },
  {
    isoAlpha3: "CZE",
    timeZones: ["Europe/Prague"],
    countryName: Czechia,
    isoAlpha2: CZ,
    phoneCode: "+420",
    flag: "🇨🇿",
    currency: "CZK",
  },
  {
    isoAlpha3: "DNK",
    timeZones: ["Europe/Copenhagen"],
    countryName: Denmark,
    isoAlpha2: DK,
    phoneCode: "+45",
    flag: "🇩🇰",
    currency: "DKK",
  },
  {
    isoAlpha3: "DJI",
    timeZones: ["Africa/Djibouti"],
    countryName: Djibouti,
    isoAlpha2: DJ,
    phoneCode: "+253",
    flag: "🇩🇯",
    currency: "DJF",
  },
  {
    isoAlpha3: "DOM",
    timeZones: ["America/Santo_Domingo"],
    countryName: DominicanRepublic,
    isoAlpha2: DO,
    phoneCode: "+1",
    flag: "🇩🇴",
    currency: "DOP",
  },
  {
    isoAlpha3: "ECU",
    timeZones: ["America/Guayaquil", "Pacific/Galapagos"],
    countryName: Ecuador,
    isoAlpha2: EC,
    phoneCode: "+593",
    flag: "🇪🇨",
    currency: "USD",
  },
  {
    isoAlpha3: "EGY",
    timeZones: ["Africa/Cairo"],
    countryName: Egypt,
    isoAlpha2: EG,
    phoneCode: "+20",
    flag: "🇪🇬",
    currency: "EGP",
  },
  {
    isoAlpha3: "SLV",
    timeZones: ["America/El_Salvador"],
    countryName: ElSalvador,
    isoAlpha2: SV,
    phoneCode: "+503",
    flag: "🇸🇻",
    currency: "USD",
  },
  {
    isoAlpha3: "ERI",
    timeZones: ["Africa/Asmara"],
    countryName: Eritrea,
    isoAlpha2: ER,
    phoneCode: "+291",
    flag: "🇪🇷",
    currency: "ERN",
  },
  {
    isoAlpha3: "EST",
    timeZones: ["Europe/Tallinn"],
    countryName: Estonia,
    isoAlpha2: EE,
    phoneCode: "+372",
    flag: "🇪🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "ETH",
    timeZones: ["Africa/Addis_Ababa"],
    countryName: Ethiopia,
    isoAlpha2: ET,
    phoneCode: "+251",
    flag: "🇪🇹",
    currency: "ETB",
  },
  {
    isoAlpha3: "FRO",
    timeZones: ["Atlantic/Faroe"],
    countryName: FaroeIslands,
    isoAlpha2: FO,
    phoneCode: "+298",
    flag: "🇫🇴",
    currency: "DKK",
  },
  {
    isoAlpha3: "FIN",
    timeZones: ["Europe/Helsinki"],
    countryName: Finland,
    isoAlpha2: FI,
    phoneCode: "+358",
    flag: "🇫🇮",
    currency: "EUR",
  },
  {
    isoAlpha3: "FRA",
    timeZones: ["Europe/Paris"],
    countryName: France,
    isoAlpha2: FR,
    phoneCode: "+33",
    flag: "🇫🇷",
    currency: "EUR",
  },
  {
    isoAlpha3: "GEO",
    timeZones: ["Asia/Tbilisi"],
    countryName: Georgia,
    isoAlpha2: GE,
    phoneCode: "+995",
    flag: "🇬🇪",
    currency: "GEL",
  },
  {
    isoAlpha3: "DEU",
    timeZones: ["Europe/Berlin", "Europe/Busingen"],
    countryName: Germany,
    isoAlpha2: DE,
    phoneCode: "+49",
    flag: "🇩🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "GRC",
    timeZones: ["Europe/Athens"],
    countryName: Greece,
    isoAlpha2: GR,
    phoneCode: "+30",
    flag: "🇬🇷",
    currency: "EUR",
  },
  {
    isoAlpha3: "GRL",
    timeZones: ["America/Godthab", "America/Danmarkshavn", "America/Scoresbysund", "America/Thule"],
    countryName: Greenland,
    isoAlpha2: GL,
    phoneCode: "+299",
    flag: "🇬🇱",
    currency: "DKK",
  },
  {
    isoAlpha3: "GTM",
    timeZones: ["America/Guatemala"],
    countryName: Guatemala,
    isoAlpha2: GT,
    phoneCode: "+502",
    flag: "🇬🇹",
    currency: "GTQ",
  },
  {
    isoAlpha3: "HTI",
    timeZones: ["America/Port-au-Prince"],
    countryName: Haiti,
    isoAlpha2: HT,
    phoneCode: "+509",
    flag: "🇭🇹",
    currency: "HTG",
  },
  {
    isoAlpha3: "HND",
    timeZones: ["America/Tegucigalpa"],
    countryName: Honduras,
    isoAlpha2: HN,
    phoneCode: "+504",
    flag: "🇭🇳",
    currency: "HNL",
  },
  {
    isoAlpha3: "HKG",
    timeZones: ["Asia/Hong_Kong"],
    countryName: HongKong,
    isoAlpha2: HK,
    phoneCode: "+852",
    flag: "🇭🇰",
    currency: "HKD",
  },
  {
    isoAlpha3: "HUN",
    timeZones: ["Europe/Budapest"],
    countryName: Hungary,
    isoAlpha2: HU,
    phoneCode: "+36",
    flag: "🇭🇺",
    currency: "HUF",
  },
  {
    isoAlpha3: "ISL",
    timeZones: ["Atlantic/Reykjavik"],
    countryName: Iceland,
    isoAlpha2: IS,
    phoneCode: "+354",
    flag: "🇮🇸",
    currency: "ISK",
  },
  {
    isoAlpha3: "IND",
    timeZones: ["Asia/Kolkata", "Asia/Calcutta"],
    countryName: India,
    isoAlpha2: IN,
    phoneCode: "+91",
    flag: "🇮🇳",
    currency: "INR",
  },
  {
    isoAlpha3: "IDN",
    timeZones: ["Asia/Jakarta", "Asia/Pontianak", "Asia/Makassar", "Asia/Jayapura"],
    countryName: Indonesia,
    isoAlpha2: ID,
    phoneCode: "+62",
    flag: "🇮🇩",
    currency: "IDR",
  },
  {
    isoAlpha3: "IRN",
    timeZones: ["Asia/Tehran"],
    countryName: IranIslamicRepublic,
    isoAlpha2: IR,
    phoneCode: "+98",
    flag: "🇮🇷",
    currency: "IRR",
  },
  {
    isoAlpha3: "IRQ",
    timeZones: ["Asia/Baghdad"],
    countryName: Iraq,
    isoAlpha2: IQ,
    phoneCode: "+964",
    flag: "🇮🇶",
    currency: "IQD",
  },
  {
    isoAlpha3: "IRL",
    timeZones: ["Europe/Dublin"],
    countryName: Ireland,
    isoAlpha2: IE,
    phoneCode: "+353",
    flag: "🇮🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "ISR",
    timeZones: ["Asia/Jerusalem"],
    countryName: Israel,
    isoAlpha2: IL,
    phoneCode: "+972",
    flag: "🇮🇱",
    currency: "ILS",
  },
  {
    isoAlpha3: "ITA",
    timeZones: ["Europe/Rome"],
    countryName: Italy,
    isoAlpha2: IT,
    phoneCode: "+39",
    flag: "🇮🇹",
    currency: "EUR",
  },
  {
    isoAlpha3: "JAM",
    timeZones: ["America/Jamaica"],
    countryName: Jamaica,
    isoAlpha2: JM,
    phoneCode: "+1",
    flag: "🇯🇲",
    currency: "JMD",
  },
  {
    isoAlpha3: "JPN",
    timeZones: ["Asia/Tokyo"],
    countryName: Japan,
    isoAlpha2: JP,
    phoneCode: "+81",
    flag: "🇯🇵",
    currency: "JPY",
  },
  {
    isoAlpha3: "JOR",
    timeZones: ["Asia/Amman"],
    countryName: Jordan,
    isoAlpha2: JO,
    phoneCode: "+962",
    flag: "🇯🇴",
    currency: "JOD",
  },
  {
    isoAlpha3: "KAZ",
    timeZones: ["Asia/Almaty", "Asia/Qyzylorda", "Asia/Aqtobe", "Asia/Aqtau", "Asia/Oral"],
    countryName: Kazakhstan,
    isoAlpha2: KZ,
    phoneCode: "+7",
    flag: "🇰🇿",
    currency: "KZT",
  },
  {
    isoAlpha3: "KEN",
    timeZones: ["Africa/Nairobi"],
    countryName: Kenya,
    isoAlpha2: KE,
    phoneCode: "+254",
    flag: "🇰🇪",
    currency: "KES",
  },
  {
    isoAlpha3: "KOR",
    timeZones: ["Asia/Seoul"],
    countryName: KoreaRepublic,
    isoAlpha2: KR,
    phoneCode: "+82",
    flag: "🇰🇷",
    currency: "KRW",
  },
  {
    isoAlpha3: "KWT",
    timeZones: ["Asia/Kuwait"],
    countryName: Kuwait,
    isoAlpha2: KW,
    phoneCode: "+965",
    flag: "🇰🇼",
    currency: "KWD",
  },
  {
    isoAlpha3: "KGZ",
    timeZones: ["Asia/Bishkek"],
    countryName: Kyrgyzstan,
    isoAlpha2: KG,
    phoneCode: "+996",
    flag: "🇰🇬",
    currency: "KGS",
  },
  {
    isoAlpha3: "LAO",
    timeZones: ["Asia/Vientiane"],
    countryName: LaoPeoplesDemocraticRepublic,
    isoAlpha2: LA,
    phoneCode: "+856",
    flag: "🇱🇦",
    currency: "LAK",
  },
  {
    isoAlpha3: "LVA",
    timeZones: ["Europe/Riga"],
    countryName: Latvia,
    isoAlpha2: LV,
    phoneCode: "+371",
    flag: "🇱🇻",
    currency: "EUR",
  },
  {
    isoAlpha3: "LBN",
    timeZones: ["Asia/Beirut"],
    countryName: Lebanon,
    isoAlpha2: LB,
    phoneCode: "+961",
    flag: "🇱🇧",
    currency: "LBP",
  },
  {
    isoAlpha3: "LBY",
    timeZones: ["Africa/Tripoli"],
    countryName: Libya,
    isoAlpha2: LY,
    phoneCode: "+218",
    flag: "🇱🇾",
    currency: "LYD",
  },
  {
    isoAlpha3: "LIE",
    timeZones: ["Europe/Vaduz"],
    countryName: Liechtenstein,
    isoAlpha2: LI,
    phoneCode: "+423",
    flag: "🇱🇮",
    currency: "CHF",
  },
  {
    isoAlpha3: "LTU",
    timeZones: ["Europe/Vilnius"],
    countryName: Lithuania,
    isoAlpha2: LT,
    phoneCode: "+370",
    flag: "🇱🇹",
    currency: "EUR",
  },
  {
    isoAlpha3: "LUX",
    timeZones: ["Europe/Luxembourg"],
    countryName: Luxembourg,
    isoAlpha2: LU,
    phoneCode: "+352",
    flag: "🇱🇺",
    currency: "EUR",
  },
  {
    isoAlpha3: "MAC",
    timeZones: ["Asia/Macau"],
    countryName: Macao,
    isoAlpha2: MO,
    phoneCode: "+853",
    flag: "🇲🇴",
    currency: "MOP",
  },
  {
    isoAlpha3: "MKD",
    timeZones: ["Europe/Skopje"],
    countryName: MacedoniaTheFormerYugoslavRepublic,
    isoAlpha2: MK,
    phoneCode: "+389",
    flag: "🇲🇰",
    currency: "MKD",
  },
  {
    isoAlpha3: "MYS",
    timeZones: ["Asia/Kuala_Lumpur", "Asia/Kuching"],
    countryName: Malaysia,
    isoAlpha2: MY,
    phoneCode: "+60",
    flag: "🇲🇾",
    currency: "MYR",
  },
  {
    isoAlpha3: "MDV",
    timeZones: ["Indian/Maldives"],
    countryName: Maldives,
    isoAlpha2: MV,
    phoneCode: "+960",
    flag: "🇲🇻",
    currency: "MVR",
  },
  {
    isoAlpha3: "MLI",
    timeZones: ["Africa/Bamako"],
    countryName: Mali,
    isoAlpha2: ML,
    phoneCode: "+223",
    flag: "🇲🇱",
    currency: "XOF",
  },
  {
    isoAlpha3: "MLT",
    timeZones: ["Europe/Malta"],
    countryName: Malta,
    isoAlpha2: MT,
    phoneCode: "+356",
    flag: "🇲🇹",
    currency: "EUR",
  },
  {
    isoAlpha3: "MEX",
    timeZones: [
      "America/Mexico_City",
      "America/Cancun",
      "America/Merida",
      "America/Monterrey",
      "America/Matamoros",
      "America/Mazatlan",
      "America/Chihuahua",
      "America/Ojinaga",
      "America/Hermosillo",
      "America/Tijuana",
      "America/Bahia_Banderas",
    ],
    countryName: Mexico,
    isoAlpha2: MX,
    phoneCode: "+52",
    flag: "🇲🇽",
    currency: "MXN",
  },
  {
    isoAlpha3: "MDA",
    timeZones: ["Europe/Chisinau"],
    countryName: MoldovaRepublic,
    isoAlpha2: MD,
    phoneCode: "+373",
    flag: "🇲🇩",
    currency: "MDL",
  },
  {
    isoAlpha3: "MCO",
    timeZones: ["Europe/Monaco"],
    countryName: Monaco,
    isoAlpha2: MC,
    phoneCode: "+377",
    flag: "🇲🇨",
    currency: "EUR",
  },
  {
    isoAlpha3: "MNG",
    timeZones: ["Asia/Ulaanbaatar", "Asia/Hovd", "Asia/Choibalsan"],
    countryName: Mongolia,
    isoAlpha2: MN,
    phoneCode: "+976",
    flag: "🇲🇳",
    currency: "MNT",
  },
  {
    isoAlpha3: "MNE",
    timeZones: ["Europe/Podgorica"],
    countryName: Montenegro,
    isoAlpha2: ME,
    phoneCode: "+382",
    flag: "🇲🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "MAR",
    timeZones: ["Africa/Casablanca"],
    countryName: Morocco,
    isoAlpha2: MA,
    phoneCode: "+212",
    flag: "🇲🇦",
    currency: "MAD",
  },
  {
    isoAlpha3: "MMR",
    timeZones: ["Asia/Rangoon"],
    countryName: Myanmar,
    isoAlpha2: MM,
    phoneCode: "+95",
    flag: "🇲🇲",
    currency: "MMK",
  },
  {
    isoAlpha3: "NPL",
    timeZones: ["Asia/Kathmandu"],
    countryName: Nepal,
    isoAlpha2: NP,
    phoneCode: "+977",
    flag: "🇳🇵",
    currency: "NPR",
  },
  {
    isoAlpha3: "NLD",
    timeZones: ["Europe/Amsterdam"],
    countryName: Netherlands,
    isoAlpha2: NL,
    phoneCode: "+31",
    flag: "🇳🇱",
    currency: "EUR",
  },
  {
    isoAlpha3: "NZL",
    timeZones: ["Pacific/Auckland", "Pacific/Chatham"],
    countryName: NewZealand,
    isoAlpha2: NZ,
    phoneCode: "+64",
    flag: "🇳🇿",
    currency: "NZD",
  },
  {
    isoAlpha3: "NIC",
    timeZones: ["America/Managua"],
    countryName: Nicaragua,
    isoAlpha2: NI,
    phoneCode: "+505",
    flag: "🇳🇮",
    currency: "NIO",
  },
  {
    isoAlpha3: "NGA",
    timeZones: ["Africa/Lagos"],
    countryName: Nigeria,
    isoAlpha2: NG,
    phoneCode: "+234",
    flag: "🇳🇬",
    currency: "NGN",
  },
  {
    isoAlpha3: "NOR",
    timeZones: ["Europe/Oslo"],
    countryName: Norway,
    isoAlpha2: NO,
    phoneCode: "+47",
    flag: "🇳🇴",
    currency: "NOK",
  },
  {
    isoAlpha3: "OMN",
    timeZones: ["Asia/Muscat"],
    countryName: Oman,
    isoAlpha2: OM,
    phoneCode: "+968",
    flag: "🇴🇲",
    currency: "OMR",
  },
  {
    isoAlpha3: "PAK",
    timeZones: ["Asia/Karachi"],
    countryName: Pakistan,
    isoAlpha2: PK,
    phoneCode: "+92",
    flag: "🇵🇰",
    currency: "PKR",
  },
  {
    isoAlpha3: "PAN",
    timeZones: ["America/Panama"],
    countryName: Panama,
    isoAlpha2: PA,
    phoneCode: "+507",
    flag: "🇵🇦",
    currency: "PAB",
  },
  {
    isoAlpha3: "PRY",
    timeZones: ["America/Asuncion"],
    countryName: Paraguay,
    isoAlpha2: PY,
    phoneCode: "+595",
    flag: "🇵🇾",
    currency: "PYG",
  },
  {
    isoAlpha3: "PER",
    timeZones: ["America/Lima"],
    countryName: Peru,
    isoAlpha2: PE,
    phoneCode: "+51",
    flag: "🇵🇪",
    currency: "PEN",
  },
  {
    isoAlpha3: "PHL",
    timeZones: ["Asia/Manila"],
    countryName: Philippines,
    isoAlpha2: PH,
    phoneCode: "+63",
    flag: "🇵🇭",
    currency: "PHP",
  },
  {
    isoAlpha3: "POL",
    timeZones: ["Europe/Warsaw"],
    countryName: Poland,
    isoAlpha2: PL,
    phoneCode: "+48",
    flag: "🇵🇱",
    currency: "PLN",
  },
  {
    isoAlpha3: "PRT",
    timeZones: ["Europe/Lisbon", "Atlantic/Madeira", "Atlantic/Azores"],
    countryName: Portugal,
    isoAlpha2: PT,
    phoneCode: "+351",
    flag: "🇵🇹",
    currency: "EUR",
  },
  {
    isoAlpha3: "PRI",
    timeZones: ["America/Puerto_Rico"],
    countryName: PuertoRico,
    isoAlpha2: PR,
    phoneCode: "+1787",
    flag: "🇵🇷",
    currency: "USD",
  },
  {
    isoAlpha3: "QAT",
    timeZones: ["Asia/Qatar"],
    countryName: Qatar,
    isoAlpha2: QA,
    phoneCode: "+974",
    flag: "🇶🇦",
    currency: "QAR",
  },
  {
    isoAlpha3: "REU",
    timeZones: ["Indian/Reunion"],
    countryName: Reunion,
    isoAlpha2: RE,
    phoneCode: "+262",
    flag: "🇷🇪",
    currency: "EUR",
  },
  {
    isoAlpha3: "ROU",
    timeZones: ["Europe/Bucharest"],
    countryName: Romania,
    isoAlpha2: RO,
    phoneCode: "+40",
    flag: "🇷🇴",
    currency: "RON",
  },
  {
    isoAlpha3: "RUS",
    timeZones: [
      "Europe/Kaliningrad",
      "Europe/Moscow",
      "Europe/Simferopol",
      "Europe/Volgograd",
      "Europe/Astrakhan",
      "Europe/Samara",
      "Europe/Ulyanovsk",
      "Asia/Yekaterinburg",
      "Asia/Omsk",
      "Asia/Novosibirsk",
      "Asia/Barnaul",
      "Asia/Novokuznetsk",
      "Asia/Krasnoyarsk",
      "Asia/Irkutsk",
      "Asia/Chita",
      "Asia/Yakutsk",
      "Asia/Khandyga",
      "Asia/Vladivostok",
      "Asia/Ust-Nera",
      "Asia/Magadan",
      "Asia/Sakhalin",
      "Asia/Srednekolymsk",
      "Asia/Kamchatka",
      "Asia/Anadyr",
    ],
    countryName: RussianFederation,
    isoAlpha2: RU,
    phoneCode: "+7",
    flag: "🇷🇺",
    currency: "RUB",
  },
  {
    isoAlpha3: "RWA",
    timeZones: ["Africa/Kigali"],
    countryName: Rwanda,
    isoAlpha2: RW,
    phoneCode: "+250",
    flag: "🇷🇼",
    currency: "RWF",
  },
  {
    isoAlpha3: "SAU",
    timeZones: ["Asia/Riyadh"],
    countryName: SaudiArabia,
    isoAlpha2: SA,
    phoneCode: "+966",
    flag: "🇸🇦",
    currency: "SAR",
  },
  {
    isoAlpha3: "SEN",
    timeZones: ["Africa/Dakar"],
    countryName: Senegal,
    isoAlpha2: SN,
    phoneCode: "+221",
    flag: "🇸🇳",
    currency: "XOF",
  },
  {
    isoAlpha3: "SRB",
    timeZones: ["Europe/Belgrade"],
    countryName: Serbia,
    isoAlpha2: RS,
    phoneCode: "+381",
    flag: "🇷🇸",
    currency: "RSD",
  },
  {
    isoAlpha3: "SGP",
    timeZones: ["Asia/Singapore"],
    countryName: Singapore,
    isoAlpha2: SG,
    phoneCode: "+65",
    flag: "🇸🇬",
    currency: "SGD",
  },
  {
    isoAlpha3: "SVK",
    timeZones: ["Europe/Bratislava"],
    countryName: Slovakia,
    isoAlpha2: SK,
    phoneCode: "+421",
    flag: "🇸🇰",
    currency: "EUR",
  },
  {
    isoAlpha3: "SVN",
    timeZones: ["Europe/Ljubljana"],
    countryName: Slovenia,
    isoAlpha2: SI,
    phoneCode: "+386",
    flag: "🇸🇮",
    currency: "EUR",
  },
  {
    isoAlpha3: "SOM",
    timeZones: ["Africa/Mogadishu"],
    countryName: Somalia,
    isoAlpha2: SO,
    phoneCode: "+252",
    flag: "🇸🇴",
    currency: "SOS",
  },
  {
    isoAlpha3: "ZAF",
    timeZones: ["Africa/Johannesburg"],
    countryName: SouthAfrica,
    isoAlpha2: ZA,
    phoneCode: "+27",
    flag: "🇿🇦",
    currency: "ZAR",
  },
  {
    isoAlpha3: "ESP",
    timeZones: ["Europe/Madrid", "Africa/Ceuta", "Atlantic/Canary"],
    countryName: Spain,
    isoAlpha2: ES,
    phoneCode: "+34",
    flag: "🇪🇸",
    currency: "EUR",
  },
  {
    isoAlpha3: "LKA",
    timeZones: ["Asia/Colombo"],
    countryName: SriLanka,
    isoAlpha2: LK,
    phoneCode: "+94",
    flag: "🇱🇰",
    currency: "LKR",
  },
  {
    isoAlpha3: "SWE",
    timeZones: ["Europe/Stockholm"],
    countryName: Sweden,
    isoAlpha2: SE,
    phoneCode: "+46",
    flag: "🇸🇪",
    currency: "SEK",
  },
  {
    isoAlpha3: "CHE",
    timeZones: ["Europe/Zurich"],
    countryName: Switzerland,
    isoAlpha2: CH,
    phoneCode: "+41",
    flag: "🇨🇭",
    currency: "CHF",
  },
  {
    isoAlpha3: "SYR",
    timeZones: ["Asia/Damascus"],
    countryName: SyrianArabRepublic,
    isoAlpha2: SY,
    phoneCode: "+963",
    flag: "🇸🇾",
    currency: "SYP",
  },
  {
    isoAlpha3: "TWN",
    timeZones: ["Asia/Taipei"],
    countryName: TaiwanProvinceOfChina,
    isoAlpha2: TW,
    phoneCode: "+886",
    flag: "🇹🇼",
    currency: "TWD",
  },
  {
    isoAlpha3: "TJK",
    timeZones: ["Asia/Dushanbe"],
    countryName: Tajikistan,
    isoAlpha2: TJ,
    phoneCode: "+992",
    flag: "🇹🇯",
    currency: "TJS",
  },
  {
    isoAlpha3: "THA",
    timeZones: ["Asia/Bangkok"],
    countryName: Thailand,
    isoAlpha2: TH,
    phoneCode: "+66",
    flag: "🇹🇭",
    currency: "THB",
  },
  {
    isoAlpha3: "TTO",
    timeZones: ["America/Port_of_Spain"],
    countryName: TrinidadAndTobago,
    isoAlpha2: TT,
    phoneCode: "+1868",
    flag: "🇹🇹",
    currency: "TTD",
  },
  {
    isoAlpha3: "TUN",
    timeZones: ["Africa/Tunis"],
    countryName: Tunisia,
    isoAlpha2: TN,
    phoneCode: "+216",
    flag: "🇹🇳",
    currency: "TND",
  },
  {
    isoAlpha3: "TUR",
    timeZones: ["Europe/Istanbul"],
    countryName: Turkey,
    isoAlpha2: TR,
    phoneCode: "+90",
    flag: "🇹🇷",
    currency: "TRY",
  },
  {
    isoAlpha3: "TKM",
    timeZones: ["Asia/Ashgabat"],
    countryName: Turkmenistan,
    isoAlpha2: TM,
    phoneCode: "+993",
    flag: "🇹🇲",
    currency: "TMT",
  },
  {
    isoAlpha3: "UKR",
    timeZones: ["Europe/Kiev", "Europe/Uzhgorod", "Europe/Zaporozhye"],
    countryName: Ukraine,
    isoAlpha2: UA,
    phoneCode: "+380",
    flag: "🇺🇦",
    currency: "UAH",
  },
  {
    isoAlpha3: "ARE",
    timeZones: ["Asia/Dubai"],
    countryName: UnitedArabEmirates,
    isoAlpha2: AE,
    phoneCode: "+971",
    flag: "🇦🇪",
    currency: "AED",
  },
  {
    isoAlpha3: "GBR",
    timeZones: ["Europe/London"],
    countryName: UnitedKingdomOfGreatBritainAndNorthernIreland,
    isoAlpha2: GB,
    phoneCode: "+44",
    flag: "🇬🇧",
    currency: "GBP",
  },
  {
    isoAlpha3: "USA",
    timeZones: [
      "America/New_York",
      "America/Detroit",
      "America/Kentucky/Louisville",
      "America/Kentucky/Monticello",
      "America/Indiana/Indianapolis",
      "America/Indiana/Vincennes",
      "America/Indiana/Winamac",
      "America/Indiana/Marengo",
      "America/Indiana/Petersburg",
      "America/Indiana/Vevay",
      "America/Chicago",
      "America/Indiana/Tell_City",
      "America/Indiana/Knox",
      "America/Menominee",
      "America/North_Dakota/Center",
      "America/North_Dakota/New_Salem",
      "America/North_Dakota/Beulah",
      "America/Denver",
      "America/Boise",
      "America/Phoenix",
      "America/Los_Angeles",
      "America/Anchorage",
      "America/Juneau",
      "America/Sitka",
      "America/Metlakatla",
      "America/Yakutat",
      "America/Nome",
      "America/Adak",
      "Pacific/Honolulu",
    ],
    countryName: UnitedStatesOfAmerica,
    isoAlpha2: US,
    phoneCode: "+1",
    flag: "🇺🇸",
    currency: "USD",
  },
  {
    isoAlpha3: "URY",
    timeZones: ["America/Montevideo"],
    countryName: Uruguay,
    isoAlpha2: UY,
    phoneCode: "+598",
    flag: "🇺🇾",
    currency: "UYU",
  },
  {
    isoAlpha3: "UZB",
    timeZones: ["Asia/Samarkand", "Asia/Tashkent"],
    countryName: Uzbekistan,
    isoAlpha2: UZ,
    phoneCode: "+998",
    flag: "🇺🇿",
    currency: "UZS",
  },
  {
    isoAlpha3: "VEN",
    timeZones: ["America/Caracas"],
    countryName: VenezuelaBolivarianRepublic,
    isoAlpha2: VE,
    phoneCode: "+58",
    flag: "🇻🇪",
    currency: "VES",
  },
  {
    isoAlpha3: "VNM",
    timeZones: ["Asia/Ho_Chi_Minh"],
    countryName: Vietnam,
    isoAlpha2: VN,
    phoneCode: "+84",
    flag: "🇻🇳",
    currency: "VND",
  },
  {
    isoAlpha3: "YEM",
    timeZones: ["Asia/Aden"],
    countryName: Yemen,
    isoAlpha2: YE,
    phoneCode: "+967",
    flag: "🇾🇪",
    currency: "YER",
  },
  {
    isoAlpha3: "ZWE",
    timeZones: ["Africa/Harare"],
    countryName: Zimbabwe,
    isoAlpha2: ZW,
    phoneCode: "+263",
    flag: "🇿🇼",
    currency: "ZWL",
  },
]
