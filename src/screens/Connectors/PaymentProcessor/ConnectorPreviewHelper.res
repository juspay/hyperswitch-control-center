module InfoField = {
  @react.component
  let make = (~label, ~str) => {
    <div className="flex items-center">
      <h2 className="flex-[1] text-base font-semibold text-grey-700 opacity-70">
        {label->React.string}
      </h2>
      <h3 className="flex-[3] border p-1.5 bg-gray-50 rounded-lg overflow-scroll whitespace-nowrap">
        {str->React.string}
      </h3>
    </div>
  }
}

module LabelInfoField = {
  @react.component
  let make = (~label, ~str) => {
    <div className="flex items-center">
      <h2 className="flex-[1] text-base font-semibold text-grey-700 opacity-70">
        {label->React.string}
      </h2>
      <h3
        className="flex-[3] font-semibold text-base border p-1.5 bg-gray-50 rounded-lg overflow-scroll whitespace-nowrap">
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
        <InfoField label str=value />
      })
    let connectorLabelField = {
      <LabelInfoField label="Connector Label" str=connectorInfo.connector_label />
    }
    Array.concat(authFields, [connectorLabelField])->React.array
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
    switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) => <CredsInfoField authKeys connectorAccountFields connectorInfo />
    | BodyKey(bodyKey) => <CredsInfoField authKeys=bodyKey connectorAccountFields connectorInfo />
    | SignatureKey(signatureKey) =>
      <CredsInfoField authKeys=signatureKey connectorAccountFields connectorInfo />
    | MultiAuthKey(multiAuthKey) =>
      <CredsInfoField authKeys=multiAuthKey connectorAccountFields connectorInfo />
    | CertificateAuth(certificateAuth) =>
      <CredsInfoField authKeys=certificateAuth connectorAccountFields connectorInfo />
    | CurrencyAuthKey(currencyAuthKey) => <CashtoCodeCredsInfo authKeys=currencyAuthKey />
    | NoKey(noKeyAuth) => <CredsInfoField authKeys=noKeyAuth connectorAccountFields connectorInfo />
    | UnKnownAuthType(_) => React.null
    }
  }
}

module AdditionalDetailsPreview = {
  @react.component
  let make = (
    ~connectorWebHookDetails,
    ~connectorMetaDataFields,
    ~connectorInfo: ConnectorTypes.connectorPayload,
  ) => {
    open LogicUtils
    open ConnectorMetaDataUtils

    let metaDataDict = connectorInfo.metadata->Identity.genericTypeToDictOfJson
    let connectorWebHookJson = connectorInfo.connector_webhook_details

    let metaDataFields =
      connectorMetaDataFields
      ->Dict.keysToArray
      ->Array.filter(ele => !Array.includes(metaDataInputKeysToIgnore, ele))

    let metaDataFields = metaDataFields->Array.mapWithIndex((field, index) => {
      let fields =
        connectorMetaDataFields
        ->getDictfromDict(field)
        ->JSON.Encode.object
        ->convertMapObjectToDict
        ->CommonConnectorUtils.inputFieldMapper

      let fieldValue = metaDataDict->getString(field, "")

      if fieldValue->isNonEmptyString {
        <div key={index->Int.toString}>
          <InfoField label={fields.label} str={fieldValue} />
        </div>
      } else {
        React.null
      }
    })

    let webHookFields = if !(connectorWebHookJson->isNullJson) {
      connectorWebHookDetails
      ->Dict.keysToArray
      ->Array.filter(field => {
        let value = connectorWebHookJson->Identity.genericTypeToDictOfJson->getString(field, "")
        value->isNonEmptyString
      })
      ->Array.map(field => {
        let label = connectorWebHookDetails->getString(field, "")
        let value = connectorWebHookJson->Identity.genericTypeToDictOfJson->getString(field, "")
        <InfoField label str=value />
      })
    } else {
      []
    }

    Array.concat(metaDataFields, webHookFields)->React.array
  }
}
