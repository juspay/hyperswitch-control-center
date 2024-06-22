let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay", "apple_pay_v2"]
let connectorMetaDataNameMapper = name => {
  switch name {
  | _ => `metadata.${name}`
  }
}

let connectorMetaDataValueInput = (~connectorMetaDataFields: CommonMetaDataTypes.inputField) => {
  open CommonMetaDataHelper
  let {\"type", name, options} = connectorMetaDataFields
  let formName = connectorMetaDataNameMapper(name)

  {
    switch \"type" {
    | Text => textInput(~field={connectorMetaDataFields}, ~formName)
    | Select =>
      selectInput(
        ~field={connectorMetaDataFields},
        ~options={options->SelectBox.makeOptions},
        ~formName,
      )
    | Toggle => toggleInput(~field={connectorMetaDataFields}, ~formName)
    | MultiSelect => multiSelectInput(~field={connectorMetaDataFields}, ~formName)
    | _ => textInput(~field={connectorMetaDataFields}, ~formName)
    }
  }
}
