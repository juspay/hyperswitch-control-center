open LogicUtils

let requiredString = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getString(fieldName, "")->isEmptyString ? Some(errorMsg) : None
}

let positiveFloat = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getFloat(fieldName, -1.0) <= 0.0 ? Some(errorMsg) : None
}

let validateFields = (
  data: Dict.t<JSON.t>,
  rules: array<ReconEngineExceptionTransactionTypes.validationRule>,
): JSON.t => {
  rules
  ->Array.filterMap(((fieldName, validator)) => {
    switch validator(data) {
    | Some(errorMessage) => Some((fieldName, errorMessage->JSON.Encode.string))
    | None => None
    }
  })
  ->Dict.fromArray
  ->JSON.Encode.object
}
