module InfoField = {
  @react.component
  let make = (~label, ~str, ~showLabelAndFieldVertically, ~customValueCss="") => {
    let (containerCss, labelCss, valueCss) = showLabelAndFieldVertically
      ? ("flex-col w-full ", "w-full", "w-full")
      : ("", "flex-[1]", "flex-[3]")

    <div className={`flex ${containerCss} items-center w-full`}>
      <h2 className={`${labelCss} text-base font-semibold text-grey-700 opacity-70`}>
        {label->React.string}
      </h2>
      <h3
        className={`${valueCss} ${customValueCss} border p-1.5 bg-gray-50 rounded-lg overflow-scroll whitespace-nowrap`}>
        {str->React.string}
      </h3>
    </div>
  }
}

module CredsInfoField = {
  @react.component
  let make = (
    ~authKeys,
    ~connectorAccountFields,
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~showLabelAndFieldVertically,
    ~showConnectorLabelField,
  ) => {
    open LogicUtils
    let dict = authKeys->Identity.genericTypeToDictOfJson
    let authFields =
      dict
      ->Dict.keysToArray
      ->Array.filter(ele => ele !== "auth_type")
      ->Array.map(field => {
        let value = dict->getString(field, "")
        let label = connectorAccountFields->getString(field, "")
        <InfoField label str=value showLabelAndFieldVertically />
      })

    let connectorLabelField = {
      <InfoField
        label="Connector Label"
        str=connectorInfo.connector_label
        showLabelAndFieldVertically
        customValueCss="font-semibold text-base"
      />
    }
    showConnectorLabelField
      ? Array.concat(authFields, [connectorLabelField])->React.array
      : authFields->React.array
  }
}

module CashtoCodeCredsInfo = {
  @react.component
  let make = (~authKeys: ConnectorTypes.currencyAuthKey, ~showLabelAndFieldVertically) => {
    open LogicUtils
    let dict = authKeys.auth_key_map->Identity.genericTypeToDictOfJson
    dict
    ->Dict.keysToArray
    ->Array.map(ele => {
      let data = dict->getDictfromDict(ele)
      let keys = data->Dict.keysToArray

      {
        <>
          <InfoField label="Currency" str=ele showLabelAndFieldVertically />
          {keys
          ->Array.map(ele => {
            let value = data->getString(ele, "")
            <InfoField label={ele->snakeToTitle} str=value showLabelAndFieldVertically />
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
  let make = (
    ~connectorAccountFields,
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~showLabelAndFieldVertically=false,
    ~showConnectorLabelField=true,
  ) => {
    switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) =>
      <CredsInfoField
        authKeys
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | BodyKey(bodyKey) =>
      <CredsInfoField
        authKeys=bodyKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | SignatureKey(signatureKey) =>
      <CredsInfoField
        authKeys=signatureKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | MultiAuthKey(multiAuthKey) =>
      <CredsInfoField
        authKeys=multiAuthKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | CertificateAuth(certificateAuth) =>
      <CredsInfoField
        authKeys=certificateAuth
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | CurrencyAuthKey(currencyAuthKey) =>
      <CashtoCodeCredsInfo authKeys=currencyAuthKey showLabelAndFieldVertically />
    | NoKey(noKeyAuth) =>
      <CredsInfoField
        authKeys=noKeyAuth
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | UnKnownAuthType(_) => React.null
    }
  }
}
