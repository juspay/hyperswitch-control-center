open LogicUtils
open MerchantAcquirerDetailsTypes
open FormRenderer

let merchantNameField = makeFieldInfo(
  ~label="Acquirer merchant name",
  ~name="merchant_name",
  ~placeholder="e.g. Demo Merchant",
  ~isRequired=true,
)

let merchantIdField = makeFieldInfo(
  ~label="Acquirer Merchant ID",
  ~name="acquirer_assigned_merchant_id",
  ~placeholder="e.g. 00004500000",
  ~isRequired=true,
)

let networkField = (~options) =>
  makeFieldInfo(
    ~label="Card Network",
    ~name="network",
    ~placeholder="Select Network",
    ~customInput=InputFields.selectInput(
      ~options,
      ~buttonText="Select Network",
      ~deselectDisable=true,
    ),
    ~isRequired=true,
  )

let binField = makeFieldInfo(
  ~label="Acquirer BIN",
  ~name="acquirer_bin",
  ~placeholder="e.g. 56688",
  ~customInput=InputFields.numericTextInput(~removeLeadingZeroes=true, ~maxLength=20, ~precision=0),
  ~isRequired=true,
)

let icaField = makeFieldInfo(
  ~label="Acquirer ICA (optional)",
  ~name="acquirer_ica",
  ~placeholder="e.g. 56688",
  ~customInput=InputFields.numericTextInput(~removeLeadingZeroes=true, ~maxLength=20, ~precision=0),
  ~isRequired=false,
)

let fraudRateField = makeFieldInfo(
  ~label="Fraud Rate (%) (optional)",
  ~name="acquirer_fraud_rate",
  ~placeholder="e.g. 25",
  ~customInput=InputFields.numericTextInput(~removeLeadingZeroes=true, ~maxLength=20, ~precision=6),
  ~isRequired=false,
)

let countryField = makeFieldInfo(
  ~label="Acquirer Country (optional)",
  ~name="acquirer_country_code",
  ~placeholder="Select Acquirer Country",
  ~customInput=InputFields.selectInput(
    ~options=AcquirerConfigUtils.countryDropDownOptions,
    ~buttonText="Select Acquirer Country",
    ~deselectDisable=true,
  ),
  ~isRequired=false,
)

let parseAcquirerConfigBucket = (
  bucket: option<BusinessProfileInterfaceTypes.acquirerConfigBucket>,
): array<acquirerBucket> => {
  switch bucket {
  | Some(b) =>
    b.configs
    ->Dict.toArray
    ->Array.map(((bucketId, entries)) => {
      let merchantName =
        entries
        ->Array.findMap(e => e.merchant_name->Option.flatMap(getNonEmptyString))
        ->Option.getOr("")
      let merchantId =
        entries
        ->Array.findMap(e => e.acquirer_assigned_merchant_id->Option.flatMap(getNonEmptyString))
        ->Option.getOr("")
      {
        id: bucketId,
        merchant_name: merchantName,
        acquirer_assigned_merchant_id: merchantId,
        is_default: bucketId === b.default_acquirer_config,
        networks: entries,
      }
    })
  | None => []
  }
}

let networkTagColors: array<TagBinding.tagColor> = [
  Primary,
  Warning,
  Purple,
  Success,
  Error,
  Neutral,
]

let getNetworkTagColor = (~index: int): TagBinding.tagColor => {
  networkTagColors
  ->Array.get(mod(index, networkTagColors->Array.length))
  ->Option.getOr(Neutral)
}

let stampProfileId = (body: Dict.t<JSON.t>, ~profileId: string) => {
  body->Dict.set("profile_id", profileId->JSON.Encode.string)
  body
}

let normalizeNumericStringFields = (body: Dict.t<JSON.t>) => {
  ["acquirer_bin", "acquirer_ica"]->Array.forEach(key => {
    let value = body->getFloat(key, 0.0)
    if value > 0.0 {
      body->Dict.set(key, value->Float.toString->JSON.Encode.string)
    }
  })
  body
}

let valueAsString = (valuesDict: Dict.t<JSON.t>, key: string): string =>
  switch valuesDict->Dict.get(key) {
  | Some(json) =>
    switch json->JSON.Classify.classify {
    | String(s) => s
    | Number(n) => n->Float.toString
    | _ => ""
    }
  | None => ""
  }

let validateForm = (~requiredKeys, values: JSON.t): JSON.t => {
  let errors = []
  let valuesDict = values->getDictFromJsonObject
  let setErr = (key, msg) => errors->Array.push((key, msg->JSON.Encode.string))

  requiredKeys->Array.forEach(key => {
    if valuesDict->valueAsString(key) === "" {
      setErr(key, "This field is required")
    }
  })

  let bin = valuesDict->valueAsString("acquirer_bin")
  if bin !== "" && (bin->String.length < 5 || bin->String.length > 20) {
    setErr("acquirer_bin", "Acquirer BIN must be between 5 and 20 digits")
  }
  
  switch valuesDict->getOptionFloat("acquirer_fraud_rate") {
  | Some(rate) if rate < 0.0 || rate > 100.0 =>
    setErr("acquirer_fraud_rate", "Fraud rate should be between 0 and 100")
  | _ => ()
  }

  errors->getJsonFromArrayOfJson
}
