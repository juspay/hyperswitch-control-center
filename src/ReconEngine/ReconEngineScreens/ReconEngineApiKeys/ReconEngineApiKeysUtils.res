open LogicUtils
open ReconEngineApiKeysTypes

let decodeExpiration = json =>
  json->JSON.Decode.string->Option.mapOr(Never, value => DateTime(value))

let encodeExpiration = expiration => {
  switch expiration {
  | Never => JSON.Encode.null
  | DateTime(value) => value->Date.fromString->Date.toISOString->JSON.Encode.string
  }
}

let decodeStatus = status => {
  switch status {
  | "active" => Active
  | "revoked" => Revoked
  | "expired" => Expired
  | _ => UnknownStatus
  }
}

let getItems = json => {
  json
  ->getDictFromJsonObject
  ->getArrayFromDict("api_keys", [])
  ->Array.map(json => {
    let dict = json->getDictFromJsonObject
    {
      id: dict->getString("id", ""),
      name: dict->getString("name", ""),
      description: dict->getString("description", ""),
      prefix: dict->getString("prefix", ""),
      status: dict->getString("status", "")->decodeStatus,
      createdAt: dict->getString("created_at", ""),
      expiresAt: dict->Dict.get("expires_at")->Option.getOr(JSON.Encode.null)->decodeExpiration,
    }
  })
}

let expirationChoiceFromJson = json => {
  switch json->getStringFromJson("") {
  | "custom" => CustomDate
  | _ => NeverExpires
  }
}

let getExpiration = dict => {
  let choice = dict->Dict.get("expiration")->Option.mapOr(NeverExpires, expirationChoiceFromJson)
  switch choice {
  | NeverExpires => Never
  | CustomDate => DateTime(dict->getString("expiration_date", ""))
  }
}

let makeCreateBody = values => {
  let dict = values->getDictFromJsonObject
  [
    ("name", dict->getString("name", "")->JSON.Encode.string),
    ("description", dict->getString("description", "")->JSON.Encode.string),
    ("expires_at", dict->getExpiration->encodeExpiration),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let makeUpdateBody = (~action, ~values) => {
  switch action {
  | Edit =>
    let dict = values->getDictFromJsonObject
    [
      ("update_type", "details_update"->JSON.Encode.string),
      ("name", dict->getString("name", "")->JSON.Encode.string),
      ("description", dict->getString("description", "")->JSON.Encode.string),
    ]
  | Revoke => [("update_type", "revoke_update"->JSON.Encode.string)]
  }
  ->Dict.fromArray
  ->JSON.Encode.object
}

let validateDetails = values => {
  let dict = values->getDictFromJsonObject
  let errors = Dict.make()
  let setError = (field, message) => errors->Dict.set(field, message->JSON.Encode.string)
  let name = dict->getString("name", "")
  if name->String.trim->isEmptyString {
    setError("name", "Enter a name for this API key")
  } else if name->String.length > 64 {
    setError("name", "Name must be 64 characters or fewer")
  }
  if dict->getString("description", "")->String.length > 256 {
    setError("description", "Description must be 256 characters or fewer")
  }
  errors->JSON.Encode.object
}

let validate = values => {
  let dict = values->getDictFromJsonObject
  let errors = validateDetails(values)->getDictFromJsonObject
  switch dict->getExpiration {
  | Never => ()
  | DateTime(value) =>
    let timestamp = value->Date.fromString->Date.getTime
    if timestamp->Js.Float.isNaN || timestamp <= Date.now() {
      errors->Dict.set("expiration_date", "Choose a future expiration date"->JSON.Encode.string)
    }
  }
  errors->JSON.Encode.object
}

let nameField = (~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label="Name",
    ~name="name",
    ~placeholder="e.g. Reporting integration",
    ~customInput=InputFields.textInput(~maxLength=64, ~isDisabled),
    ~isRequired=true,
  )

let descriptionField = (~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label="Description",
    ~name="description",
    ~placeholder="What will this key be used for?",
    ~customInput=InputFields.textInput(~maxLength=256, ~isDisabled),
  )

let expirationField = (~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label="Expiration",
    ~name="expiration",
    ~customInput=InputFields.selectInput(
      ~disableSelect=isDisabled,
      ~options=[
        {SelectBox.label: "Never", value: (NeverExpires :> string)},
        {SelectBox.label: "Custom date", value: (CustomDate :> string)},
      ],
      ~buttonText="Select expiration",
    ),
  )

let expirationDateField = (~isDisabled) =>
  FormRenderer.makeFieldInfo(
    ~label="Expiration date",
    ~name="expiration_date",
    ~isRequired=true,
    ~customInput=(~input, ~placeholder as _) =>
      <DatePickerAdapter
        input
        isDisabled
        disablePastDates=true
        format="YYYY-MM-DDTHH:mm:ss.SSS[Z]"
        currentDateHourFormat="23"
        currentDateMinuteFormat="59"
        currentDateSecondsFormat="59"
      />,
  )
