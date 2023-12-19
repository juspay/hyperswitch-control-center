let paypalAPICall = async (~updateDetails, ~connectorId, ~profileId) => {
  open APIUtils
  try {
    let paypalBody =
      [
        ("connector", "paypal"->Js.Json.string),
        ("connector_id", connectorId->Js.Json.string),
        ("profile_id", profileId->Js.Json.string),
      ]
      ->Js.Dict.fromArray
      ->Js.Json.object_
    let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/sync`
    let response = await updateDetails(url, paypalBody, Fetch.Post)
    let responseValue =
      response->LogicUtils.getDictFromJsonObject->LogicUtils.getJsonObjectFromDict("paypal")
    responseValue
  } catch {
  | _ => Js.Json.null
  }
}

let paypalAccountStatusAtom: Recoil.recoilAtom<ConnectorTypes.setupAccountStatus> = Recoil.atom(.
  "paypalAccountStatusAtom",
  ConnectorTypes.Account_not_found,
)

let handleConnectorIntegrated = (
  ~dictValue,
  ~setInitialValues,
  ~connector,
  ~handleStateToNextPage,
) => {
  let values = dictValue->LogicUtils.getJsonObjectFromDict("connector_integrated")
  let bodyTypeValue =
    dictValue
    ->LogicUtils.getDictfromDict("connector_integrated")
    ->LogicUtils.getDictfromDict("connector_account_details")
    ->LogicUtils.getString("auth_type", "")
  let body = ConnectorUtils.generateInitialValuesDict(
    ~values,
    ~connector,
    ~bodyType=bodyTypeValue,
    ~isPayoutFlow=false,
    (),
  )
  setInitialValues(_ => body)
  handleStateToNextPage()->ignore
}

let handleObjectResponse = (
  ~dict,
  // ~setRetryTime,
  ~setSetupAccountStatus,
  ~setInitialValues,
  ~connector,
  ~handleStateToNextPage,
) => {
  let dictkey = dict->Js.Dict.keys->Belt.Array.get(0)->Belt.Option.getWithDefault("")

  switch dictkey->ConnectorUtils.stringToVariantMapper {
  | Ppcp_custom_denied =>
    // let retryTime = dict->LogicUtils.getInt(dictkey, 0)
    // setRetryTime(_ => retryTime)
    setSetupAccountStatus(._ => dictkey->ConnectorUtils.stringToVariantMapper)
  | Connector_integrated =>
    handleConnectorIntegrated(
      ~dictValue=dict,
      ~setInitialValues,
      ~connector,
      ~handleStateToNextPage,
    )
  | _ => setSetupAccountStatus(._ => dictkey->ConnectorUtils.stringToVariantMapper)
  }
}

let getBodyType = (isUpdateFlow, configuartionType, setupAccountStatus) => {
  open ConnectorTypes
  let bodyType = switch (isUpdateFlow, setupAccountStatus) {
  | (false, _) | (true, Account_not_found) => "TemporaryAuth"
  | (true, _) =>
    switch configuartionType {
    | Manual => "BodyKey"
    | Automatic | NotSelected => "SignatureKey"
    }
  }
  bodyType
}

let generateConnectorPayloadPayPal = (
  ~profileId,
  ~connectorId,
  ~connector,
  ~isUpdateFlow,
  ~configuartionType,
  ~setupAccountStatus,
  ~connectorLabel,
) => {
  open ConnectorUtils
  let initialValues =
    [
      ("profile_id", profileId->Js.Json.string),
      ("connector_name", connector->Js.String2.toLowerCase->Js.Json.string),
      ("connector_type", "payment_processor"->Js.Json.string),
      ("disabled", true->Js.Json.boolean),
      ("test_mode", true->Js.Json.boolean),
      ("status", "inactive"->Js.Json.string),
      ("connector_label", connectorLabel->Js.Json.string),
    ]
    ->Js.Dict.fromArray
    ->Js.Json.object_

  let body =
    generateInitialValuesDict(
      ~values={initialValues},
      ~connector,
      ~bodyType=getBodyType(isUpdateFlow, configuartionType, setupAccountStatus),
      ~isPayoutFlow=false,
      (),
    )->ignoreFields(connectorId, connectorIgnoredField)
  body
}
