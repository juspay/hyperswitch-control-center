open LogicUtils
open ConnectProcessorsTypes

let processorFieldsConfig = dict => {
  {
    processor_type: dict->getString("processor_type", ""),
    secret_key: dict->getString("secret_key", ""),
    client_verification_key: dict->getString("client_verification_key", ""),
  }
}

let validateProcessorFields = (values: JSON.t) => {
  let data = values->getDictFromJsonObject->processorFieldsConfig
  let errors = Dict.make()

  let errorMessage = if data.processor_type->isEmptyString {
    "Processor cannot be empty!"
  } else {
    ""
  }
  if errorMessage->isNonEmptyString {
    Dict.set(errors, "Error", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}
