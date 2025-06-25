open LogicUtils
open AcquirerConfigTypes

let networkDropDownOptions: array<SelectBox.dropdownOption> = [
  {value: "Visa", label: "Visa"},
  {value: "Mastercard", label: "Mastercard"},
  {value: "AmericanExpress", label: "American Express"},
  {value: "Discover", label: "Discover"},
  {value: "JCB", label: "JCB"},
  {value: "DinersClub", label: "Diners Club"},
  {value: "UnionPay", label: "UnionPay"},
  {value: "RuPay", label: "RuPay"},
  {value: "Maestro", label: "Maestro"},
  {value: "CartesBancaires", label: "Cartes Bancaires"},
  {value: "Interac", label: "Interac"},
  {value: "Star", label: "Star"},
  {value: "Pulse", label: "Pulse"},
  {value: "Accel", label: "Accel"},
  {value: "Nyce", label: "Nyce"},
]

let countryDropDownOptions: array<SelectBox.dropdownOption> =
  CountryUtils.countriesList->Array.map(CountryUtils.getCountryOption)

let formKeys = [
  "network",
  "merchant_name",
  "merchant_country_code",
  "acquirer_assigned_merchant_id",
  "acquirer_bin",
  "acquirer_fraud_rate",
]

let fieldStyles = {
  "errorClass": HSwitchUtils.errorClass,
  "labelClass": "!text-fs-15 !text-grey-700 font-semibold",
  "fieldWrapperClass": "max-w-xl",
  "containerClass": "mt-5",
}

let validateAcquirerConfigForm = (values, keys) => {
  let errors = []

  let valuesDict = values->getDictFromJsonObject
  let setFieldError = (key, msg) => errors->Array.push((key, msg->JSON.Encode.string))

  let validateField = (key, value) => {
    switch key {
    | "acquirer_fraud_rate" =>
      let fraudRate = valuesDict->getFloat(key, 0.0)
      if fraudRate < 0.0 || fraudRate > 100.0 {
        key->setFieldError("Fraud rate should be between 0 and 100")
      }
    | "acquirer_bin" =>
      let binValue = valuesDict->getFloat(key, 0.0)
      let binString = binValue->Float.toString
      let binLength = binString->String.length

      if binValue <= 0.0 {
        key->setFieldError("This field is required")
      } else if binValue !== Float.fromInt(Float.toInt(binValue)) {
        key->setFieldError("Acquirer BIN must be a whole number")
      } else if binLength < 5 || binLength > 20 {
        key->setFieldError("Acquirer BIN must be between 5 and 20 digits")
      }
    | _ =>
      if value === "" {
        key->setFieldError("This field is required")
      } else if value->String.length > 60 {
        key->setFieldError("Length should be less than 60 characters")
      }
    }
  }

  keys->Array.forEach(key => {
    let value = valuesDict->getString(key, "")
    validateField(key, value)
  })

  errors->getJsonFromArrayOfJson
}

let acquirerConfigTypeMapper = (json: JSON.t): acquirerConfig => {
  let dict = json->getDictFromJsonObject
  {
    id: dict->getString("profile_acquirer_id", ""),
    acquirer_assigned_merchant_id: dict->getString("acquirer_assigned_merchant_id", ""),
    merchant_name: dict->getString("merchant_name", ""),
    merchant_country_code: dict->getString("merchant_country_code", ""),
    network: dict->getString("network", ""),
    acquirer_bin: dict->getString("acquirer_bin", ""),
    acquirer_fraud_rate: dict->getFloat("acquirer_fraud_rate", 0.0),
  }
}

let getInitialValuesFromConfig = (config: acquirerConfig): JSON.t => {
  [
    ("acquirer_assigned_merchant_id", config.acquirer_assigned_merchant_id->JSON.Encode.string),
    ("merchant_name", config.merchant_name->JSON.Encode.string),
    ("merchant_country_code", config.merchant_country_code->JSON.Encode.string),
    ("network", config.network->JSON.Encode.string),
    ("acquirer_bin", config.acquirer_bin->JSON.Encode.string),
    ("acquirer_fraud_rate", config.acquirer_fraud_rate->JSON.Encode.float),
  ]->getJsonFromArrayOfJson
}
