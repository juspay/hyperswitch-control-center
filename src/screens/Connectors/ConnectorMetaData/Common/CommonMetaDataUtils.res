open CommonMetaDataTypes
let inputTypeMapperr = ipType => {
  switch ipType {
  | "Text" => Text
  | "Toggle" => Toggle
  | "Select" => Select
  | _ => Text
  }
}

let inputFieldMapper = dict => {
  open LogicUtils
  {
    name: dict->getString("name", ""),
    label: dict->getString("label", ""),
    placeholder: dict->getString("placeholder", ""),
    required: dict->getBool("required", true),
    options: dict->getStrArray("options"),
    \"type": dict->getString("type", "")->inputTypeMapperr,
  }
}
