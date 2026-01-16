open LogicUtils
open ReconEngineTypes

let requiredString = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getString(fieldName, "")->isEmptyString ? Some(errorMsg) : None
}

let positiveFloat = (fieldName: string, errorMsg: string) => {
  (data: Dict.t<JSON.t>) => data->getFloat(fieldName, -1.0) <= 0.0 ? Some(errorMsg) : None
}

let validateFields = (
  data: Dict.t<JSON.t>,
  rules: array<ReconEngineExceptionsTypes.validationRule>,
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

let validateReasonField = (values: JSON.t) => {
  let data = values->getDictFromJsonObject
  let errors = Dict.make()

  let errorMessage = if data->getString("reason", "")->isEmptyString {
    "Remark cannot be empty!"
  } else {
    ""
  }
  if errorMessage->isNonEmptyString {
    Dict.set(errors, "Error", errorMessage->JSON.Encode.string)
  }

  errors->JSON.Encode.object
}

let validateStringField = (value: string, rules: array<stringValidationRule>): option<string> => {
  rules->Array.reduce(None, (acc, rule) => {
    switch acc {
    | Some(_) => acc
    | None =>
      switch rule {
      | MinLength(minLen) =>
        value->String.length < minLen
          ? Some(`Minimum length is ${minLen->Int.toString} characters`)
          : None
      | MaxLength(maxLen) =>
        value->String.length > maxLen
          ? Some(`Maximum length is ${maxLen->Int.toString} characters`)
          : None
      }
    }
  })
}

let validateNumberField = (value: string, rules: array<numberValidationRule>): option<string> => {
  switch value->Float.fromString {
  | None => Some("Must be a valid number")
  | Some(numValue) =>
    rules->Array.reduce(None, (acc, rule) => {
      switch acc {
      | Some(_) => acc
      | None =>
        switch rule {
        | MinValue(minVal) =>
          numValue < minVal ? Some(`Minimum value is ${minVal->Float.toString}`) : None
        | MaxValue(maxVal) =>
          numValue > maxVal ? Some(`Maximum value is ${maxVal->Float.toString}`) : None
        }
      }
    })
  }
}

let validateMinorUnitField = (value: string, rules: array<minorUnitValidationRule>): option<
  string,
> => {
  switch value->Int.fromString {
  | None => Some("Must be a valid integer")
  | Some(intValue) =>
    rules->Array.reduce(None, (acc, rule) => {
      switch acc {
      | Some(_) => acc
      | None =>
        switch rule {
        | PositiveOnly => intValue < 0 ? Some("Must be a positive value") : None
        | MinValueMinorUnit(minVal) =>
          intValue < minVal ? Some(`Minimum value is ${minVal->Int.toString}`) : None
        | MaxValueMinorUnit(maxVal) =>
          intValue > maxVal ? Some(`Maximum value is ${maxVal->Int.toString}`) : None
        }
      }
    })
  }
}

let validateCurrencyField = (value: string): option<string> => {
  open CurrencyUtils
  let upperValue = value->String.toUpperCase
  let isValid =
    currencyList->Array.some(currency => currency->getCurrencyCodeStringFromVariant == upperValue)
  isValid ? None : Some("Must be a valid currency code (e.g., USD, EUR, INR)")
}

let validateDateTimeField = (value: string): option<string> => {
  let dateTimePattern = %re("/^\d{2}-\d{2}-\d{4}(\s\d{2}:\d{2}:\d{2})?$/")
  dateTimePattern->RegExp.test(value)
    ? None
    : Some("Must be in format DD-MM-YYYY or DD-MM-YYYY HH:mm:ss")
}

let validateBalanceDirectionField = (
  value: string,
  credit_values: array<string>,
  debit_values: array<string>,
): option<string> => {
  let isValid = credit_values->Array.includes(value) || debit_values->Array.includes(value)
  if isValid {
    None
  } else {
    let allowedValues = credit_values->Array.concat(debit_values)->Array.joinWith(", ")
    Some(`Must be one of: ${allowedValues}`)
  }
}

let validateMetadataFieldValue = (
  key: string,
  value: string,
  metadataSchema: metadataSchemaType,
): option<string> => {
  if metadataSchema.id->isNonEmptyString {
    let field =
      metadataSchema.schema_data.fields.metadata_fields->Array.find(f => f.identifier == key)
    let checkEmptyValue = value->String.trim->isEmptyString

    switch field {
    | None => None
    | Some(f) =>
      if f.required && checkEmptyValue {
        Some("This field is required")
      } else if checkEmptyValue {
        None
      } else {
        switch f.field_type {
        | StringField(rules) => validateStringField(value, rules)
        | NumberField(rules) => validateNumberField(value, rules)
        | MinorUnitField(rules) => validateMinorUnitField(value, rules)
        | CurrencyField => validateCurrencyField(value)
        | DateTimeField => validateDateTimeField(value)
        | BalanceDirectionField({credit_values, debit_values}) =>
          validateBalanceDirectionField(value, credit_values, debit_values)
        }
      }
    }
  } else {
    None
  }
}

let validateMetadataField = (~metadataRows: array<ReconEngineExceptionsTypes.metadataRow>) => {
  (_value: option<string>, _allValues: JSON.t) => {
    let hasValueWithoutKey =
      metadataRows->Array.some(row => row.value->isNonEmptyString && row.key->isEmptyString)
    if hasValueWithoutKey {
      Promise.resolve(Nullable.make("Please provide keys for all metadata fields with values"))
    } else {
      Promise.resolve(Nullable.null)
    }
  }
}
