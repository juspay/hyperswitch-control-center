module PreviewRow = {
  @react.component
  let make = (~title, ~subTitle="") => {
    <div>
      <p className="text-base text-gray-400 font-medium mb-2"> {title->React.string} </p>
      <p className="font-semibold text-gray-700"> {subTitle->React.string} </p>
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

      <PreviewRow title=label subTitle=value />
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
          <PreviewRow title="Currency" subTitle=ele />
          {keys
          ->Array.map(ele => {
            let value = data->getString(ele, "")
            <PreviewRow title={ele->snakeToTitle} subTitle={value} />
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
    switch connectorInfo.connector_account_details {
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
