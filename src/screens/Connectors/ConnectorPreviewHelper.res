module InfoField = {
  @react.component
  let make = (~label, ~str) => {
    <div>
      <h2 className="text-lg font-semibold"> {label->React.string} </h2>
      <h3 className=" break-words"> {str->React.string} </h3>
    </div>
  }
}

module CredsInfoField = {
  @react.component
  let make = (~authKeys, ~connectorAccountFields) => {
    open LogicUtils
    let dict = authKeys->Identity.genericTypeToDictOfJson
    dict
    ->Dict.keysToArray
    ->Array.filter(ele => ele !== "auth_type")
    ->Array.map(field => {
      let value = dict->getString(field, "")
      let label = connectorAccountFields->getString(field, "")
      <InfoField label str=value />
    })
    ->React.array
  }
}

module CashtoCodeCredsInfo = {
  @react.component
  let make = (~authKeys: ConnectorTypes.currencyAuthKey) => {
    open LogicUtils
    let dict = authKeys.auth_key_map->Identity.genericTypeToDictOfJson
    dict
    ->Dict.keysToArray
    ->Array.map(ele => {
      let data = dict->getDictfromDict(ele)
      let keys = data->Dict.keysToArray

      {
        <>
          <InfoField label="Currency" str=ele />
          {keys
          ->Array.map(ele => {
            let value = data->getString(ele, "")
            <InfoField label={ele->snakeToTitle} str=value />
          })
          ->React.array}
        </>
      }
    })
    ->React.array
  }
}

module PreviewCreds = {
  @react.component
  let make = (~connectorAccountFields, ~connectorInfo: ConnectorTypes.connectorPayload) => {
    switch connectorInfo.account_details {
    | HeaderKey(authKeys) => <CredsInfoField authKeys connectorAccountFields />
    | BodyKey(bodyKey) => <CredsInfoField authKeys=bodyKey connectorAccountFields />
    | SignatureKey(signatureKey) => <CredsInfoField authKeys=signatureKey connectorAccountFields />
    | MultiAuthKey(multiAuthKey) => <CredsInfoField authKeys=multiAuthKey connectorAccountFields />
    | CertificateAuth(certificateAuth) =>
      <CredsInfoField authKeys=certificateAuth connectorAccountFields />
    | CurrencyAuthKey(currencyAuthKey) => <CashtoCodeCredsInfo authKeys=currencyAuthKey />
    | UnKnownAuthType(_) => React.null
    }
  }
}
