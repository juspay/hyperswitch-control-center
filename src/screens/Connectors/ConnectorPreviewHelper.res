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
    let json = authKeys->Identity.genericTypeToDictOfJson
    json
    ->Dict.keysToArray
    ->Array.filter(ele => ele !== "auth_type")
    ->Array.map(field => {
      let value = json->getString(field, "")
      let label = connectorAccountFields->getString(field, "")
      <InfoField label str=value />
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
    | CurrencyAuthKey(currencyAuthKey) => <> </>
    | UnKnownAuthType(_) => <> </>
    }
  }
}
