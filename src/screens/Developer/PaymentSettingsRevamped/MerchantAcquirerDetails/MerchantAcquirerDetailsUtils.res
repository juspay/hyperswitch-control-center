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
  ~customInput=InputFields.textInput(~inputMode="numeric", ~maxLength=20, ~autoComplete="off"),
  ~parse=(~value, ~name as _) =>
    value
    ->JSON.Decode.string
    ->Option.getOr("")
    ->String.replaceRegExp(%re("/[^0-9]/g"), "")
    ->JSON.Encode.string,
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
): array<acquirerBucket> =>
  bucket->mapOptionOrDefault([], b => {
    let buckets =
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
    buckets->Array.sort((first, second) =>
      if first.is_default && !second.is_default {
        -1.
      } else if !first.is_default && second.is_default {
        1.
      } else {
        compareLogic(second.id, first.id)
      }
    )
    buckets
  })

let networkTagColors: array<TagBinding.tagColor> = [
  Primary,
  Warning,
  Purple,
  Success,
  Error,
  Neutral,
]

let getNetworkTagColor = (~index: int): TagBinding.tagColor => {
  networkTagColors->getValueFromArray(mod(index, networkTagColors->Array.length), Neutral)
}

let stampProfileId = (body: Dict.t<JSON.t>, ~profileId: string) => {
  body->Dict.set("profile_id", profileId->JSON.Encode.string)
  body
}

let normalizeNumericStringFields = (body: Dict.t<JSON.t>) => {
  [AcquirerIca]->Array.forEach(field => {
    let key = (field :> string)
    let value = body->getFloat(key, 0.0)
    if value > 0.0 {
      body->Dict.set(key, value->Float.toString->JSON.Encode.string)
    }
  })
  body
}

let validateForm = (~requiredKeys: array<acquirerField>, values: JSON.t): JSON.t => {
  let errors = []
  let valuesDict = values->getDictFromJsonObject
  let setErr = (key, msg) => errors->Array.push((key, msg->JSON.Encode.string))

  requiredKeys->Array.forEach(field => {
    let key = (field :> string)
    let present = valuesDict->getString(key, "")->isNonEmptyString
    if !present {
      setErr(key, "This field is required")
    }
  })

  let binStr = valuesDict->getString((AcquirerBin :> string), "")
  if binStr->isNonEmptyString {
    if binStr->String.length < 4 || binStr->String.length > 20 {
      setErr((AcquirerBin :> string), "Acquirer BIN must be between 4 and 20 digits")
    }
  }

  valuesDict
  ->getOptionFloat((AcquirerFraudRate :> string))
  ->mapOptionOrDefault((), rate =>
    if rate < 0.0 || rate > 100.0 {
      setErr((AcquirerFraudRate :> string), "Fraud rate should be between 0 and 100")
    }
  )

  errors->getJsonFromArrayOfJson
}
