open LogicUtils
open ConnectProcessorsTypes

let processorFieldsConfig = dict => {
  {
    processor_type: dict->getString("processor_type", ""),
    secret_key: dict->getString("secret_key", ""),
    client_verification_key: dict->getString("client_verification_key", ""),
  }
}

let validateProcessorFields = values => {
  let data = values->getDictFromJsonObject->processorFieldsConfig

  data.processor_type->isNonEmptyString &&
  data.secret_key->isNonEmptyString &&
  data.client_verification_key->isNonEmptyString
    ? Button.Normal
    : Button.Disabled
}
