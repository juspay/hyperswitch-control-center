let metaDataInputKeysToIgnore = [
  "google_pay",
  "apple_pay",
  "zen_apple_pay",
  "paypal_sdk",
  "account_id",
  "boleto",
  "pix",
  "pix_emv",
  "pix_qr",
  "pix_automatico_qr",
  "pix_automatico_push",
]

// A metadata key whose value is a set of inputs rather than one input, e.g. JPMorgan's
// `merchant_id` keyed by currency. Its inputs submit as `metadata.<key>.<name>`.
let getMetadataGroupFields = (key, dict): array<CommonConnectorTypes.inputField> => {
  open LogicUtils
  switch dict->getOptionString("name") {
  | Some(_) => []
  | None =>
    let members = dict->Dict.valuesToArray->Array.map(convertMapObjectToDict)
    members->Array.every(member => member->getOptionString("name")->Option.isSome)
      ? members
        // Each input is optional on its own; `validateMetadataGroups` requires at least one
        ->Array.map(member => {
          let field = member->CommonConnectorUtils.inputFieldMapper
          {...field, name: `${key}.${field.name}`, required: false}
        })
        // Config comes from a HashMap, so its key order isn't stable across wasm builds
        ->Array.toSorted((a, b) => String.localeCompare(a.name, b.name))
      : []
  }
}

let getMetadataInputDicts = connectorMetaDataFields => {
  open LogicUtils
  connectorMetaDataFields
  ->Dict.keysToArray
  ->Array.filter(key => !Array.includes(metaDataInputKeysToIgnore, key))
  ->Array.map(key => (
    key,
    connectorMetaDataFields->getDictfromDict(key)->JSON.Encode.object->convertMapObjectToDict,
  ))
}

let getMetadataInputFields = connectorMetaDataFields => {
  let (fields, groupFields) =
    connectorMetaDataFields
    ->getMetadataInputDicts
    ->Array.reduce(([], []), ((fields, groupFields), (key, dict)) => {
      switch getMetadataGroupFields(key, dict) {
      | [] => (fields->Array.concat([dict->CommonConnectorUtils.inputFieldMapper]), groupFields)
      | members => (fields, groupFields->Array.concat(members))
      }
    })
  // Grouped inputs are listed after the regular ones
  fields->Array.concat(groupFields)
}

let validateMetadataGroups = (~connectorMetaDataFields, ~valuesFlattenJson) => {
  open LogicUtils
  let errors = Dict.make()
  connectorMetaDataFields
  ->getMetadataInputDicts
  ->Array.forEach(((key, dict)) => {
    switch getMetadataGroupFields(key, dict) {
    | [] => ()
    | members =>
      let hasAnyValue =
        members->Array.some(({name}) =>
          valuesFlattenJson->getString(`metadata.${name}`, "")->String.trim->isNonEmptyString
        )
      if !hasAnyValue {
        errors->Dict.set(
          `metadata.${key}`,
          `Please enter at least one ${key->snakeToTitle}`->JSON.Encode.string,
        )
      }
    }
  })
  errors
}

let connectorMetaDataNameMapper = name => {
  switch name {
  | _ => `metadata.${name}`
  }
}
let getField = (~inputType: CommonConnectorTypes.inputType, ~name, ~connectorMetaDataFields) => {
  open CommonConnectorHelper
  switch (inputType, name) {
  | (Select, "metadata.merchant_config_currency") => currencyField(~name)
  | (Text, _) => textInput(~field={connectorMetaDataFields}, ~formName=name)
  | (Number, _) => numberInput(~field={connectorMetaDataFields}, ~formName=name)
  | (Select, _) =>
    selectInput(~field={connectorMetaDataFields}, ~formName=name, ~fixedDropDownDirection=TopRight)
  | (Toggle, _) => toggleInput(~field={connectorMetaDataFields}, ~formName=name)
  | (MultiSelect, _) => multiSelectInput(~field={connectorMetaDataFields}, ~formName=name)
  | _ => textInput(~field={connectorMetaDataFields}, ~formName=name)
  }
}

let connectorMetaDataValueInput = (~connectorMetaDataFields: CommonConnectorTypes.inputField) => {
  let {\"type": inputType, name} = connectorMetaDataFields
  let formName = connectorMetaDataNameMapper(name)

  getField(~inputType, ~name=formName, ~connectorMetaDataFields)
}

let validateMetadataRequiredFields = (~connector: ConnectorTypes.connectorTypes, ~values) => {
  switch connector {
  | Processors(PAYSAFE) => PaySafeUtils.payConnectorValidation(~values)
  | _ => Dict.make()
  }
}
