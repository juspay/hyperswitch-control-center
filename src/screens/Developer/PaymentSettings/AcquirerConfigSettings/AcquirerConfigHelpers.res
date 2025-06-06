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
  "mcc",
  "merchant_country_code",
  "acquirer_assigned_merchant_id",
  "acquirer_bin",
  "acquirer_fraud_rate",
  "merchant_acquirer_id",
]

let fieldStyles = {
  "errorClass": HSwitchUtils.errorClass,
  "labelClass": "!text-fs-15 !text-grey-700 font-semibold",
  "fieldWrapperClass": "max-w-xl",
  "containerClass": "mt-5",
}

let validateAcquirerConfigForm = (values, keys, ~isDisabled) => {
  let errors = Dict.make()

  if !isDisabled {
    let valuesDict = values->getDictFromJsonObject
    let setFieldError = (key, errorMessage) => {
      Dict.set(errors, key, errorMessage)
    }

    let validateField = (key, value) => {
      switch key {
      | "acquirer_fraud_rate" =>
        let fraudRate = valuesDict->getFloat(key, 0.0)
        if fraudRate < 0.0 || fraudRate > 100.0 {
          key->setFieldError("Fraud rate should be between 0 and 100")
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
  }

  errors
  ->Dict.toArray
  ->Array.map(((key, value)) => (key, value->JSON.Encode.string))
  ->Dict.fromArray
  ->JSON.Encode.object
}

let acquirerConfigTypeMapper = (json: JSON.t): acquirerConfig => {
  let dict = json->getDictFromJsonObject
  {
    merchant_acquirer_id: dict->getString("merchant_acquirer_id", ""),
    acquirer_assigned_merchant_id: dict->getString("acquirer_assigned_merchant_id", ""),
    merchant_name: dict->getString("merchant_name", ""),
    mcc: dict->getString("mcc", ""),
    merchant_country_code: dict->getString("merchant_country_code", ""),
    network: dict->getString("network", ""),
    acquirer_bin: dict->getString("acquirer_bin", ""),
    acquirer_fraud_rate: dict->getFloat("acquirer_fraud_rate", 0.0),
  }
}
