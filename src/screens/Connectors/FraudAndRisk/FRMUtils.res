open FRMInfo
open FRMTypes
open ConnectorUtils
open LogicUtils

@val external btoa: string => string = "btoa"
@val external atob: string => string = "atob"

let leadingSpaceStrParser = (~value, ~name as _) => {
  let str = value->JSON.Decode.string->Option.getOr("")
  str->String.replaceRegExp(%re("/^[\s]+/"), "")->JSON.Encode.string
}

let base64Parse = (~value, ~name as _) => {
  value->JSON.Decode.string->Option.getOr("")->btoa->JSON.Encode.string
}

let base64Format = (~value, ~name as _) => {
  value->JSON.Decode.string->Option.getOr("")->atob->JSON.Encode.string
}

let toggleDefaultStyle = "mb-2 relative inline-flex flex-shrink-0 h-6 w-12 border-2 rounded-full  transition-colors ease-in-out duration-200 focus:outline-none focus-visible:ring-2  focus-visible:ring-white focus-visible:ring-opacity-75 items-center"

let accordionDefaultStyle = "border pointer-events-none inline-block h-3 w-3 rounded-full bg-white dark:bg-white shadow-lg transform ring-0 transition ease-in-out duration-200"
let size = "w-14 h-14"

let generateInitialValuesDict = (~selectedFRMName, ~isLiveMode, ~profileId) => {
  let frmAccountDetailsDict =
    [("auth_type", selectedFRMName->getFRMAuthType->JSON.Encode.string)]->getJsonFromArrayOfJson

  [
    ("connector_name", selectedFRMName->getConnectorNameString->JSON.Encode.string),
    ("connector_type", "payment_vas"->JSON.Encode.string),
    ("disabled", false->JSON.Encode.bool),
    ("test_mode", !isLiveMode->JSON.Encode.bool),
    ("connector_account_details", frmAccountDetailsDict),
    ("frm_configs", []->JSON.Encode.array),
    ("profile_id", profileId->JSON.Encode.string),
  ]->getJsonFromArrayOfJson
}

let parseFRMConfig = json => {
  json->JSON.Decode.array->Option.getOr([])->ConnectorInterfaceUtils.convertFRMConfigJsonToObj
}

let getPaymentMethod = paymentMethod => {
  let paymentMethodDict = paymentMethod->getDictFromJsonObject
  let paymentMethodTypeArr = paymentMethodDict->getArrayFromDict("payment_method_types", [])

  let pmTypesArr =
    paymentMethodTypeArr->Array.map(item =>
      item->getDictFromJsonObject->getString("payment_method_type", "")
    )

  (paymentMethodDict->getString("payment_method", ""), pmTypesArr->getUniqueArray)
}
let validateRequiredFields = (
  valuesFlattenJson,
  ~fields: array<ConnectorTypes.connectorIntegrationField>,
  ~errors,
) => {
  fields->Array.forEach(field => {
    let key = field.name
    let value = valuesFlattenJson->getString(key, "")

    if field.isRequired->Option.getOr(true) && value->isEmptyString {
      Dict.set(errors, key, `Please enter ${field.label->Option.getOr("")}`->JSON.Encode.string)
    }
  })
}

let validate = (~values, ~selectedFRMInfo: ConnectorTypes.integrationFields) => {
  let errors = Dict.make()
  let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
  valuesFlattenJson->validateRequiredFields(
    ~fields=selectedFRMInfo.validate->Option.getOr([]),
    ~errors,
  )

  errors->JSON.Encode.object
}

let parseConnectorConfig = (connector: ConnectorTypes.connectorPayloadCommonType) => {
  let connectorName = connector.connector_name
  let connectorPaymentMethods = connector.payment_methods_enabled
  let pmDict = Dict.make()

  let sortedArray = connectorPaymentMethods->Array.toSorted((a, b) => {
    if a.payment_method_type->getPaymentMethodFromString == Card {
      -1.
    } else if b.payment_method_type->getPaymentMethodFromString == Card {
      1.
    } else {
      0.
    }
  })

  sortedArray->Array.forEach(item => {
    let pmTypes =
      item.payment_method_subtypes
      ->Array.map(item => item.payment_method_subtype)
      ->getUniqueArray
    let (pmName, pmTypes) = (item.payment_method_type, pmTypes)

    pmDict->Dict.set(pmName, pmTypes)
  })
  (connectorName, pmDict)
}

let updatePaymentMethodsDict = (prevPaymentMethodsDict, pmName, currentPmTypes) => {
  switch prevPaymentMethodsDict->Dict.get(pmName) {
  | Some(prevPmTypes) => {
      let pmTypesArr = prevPmTypes->Array.concat(currentPmTypes)
      prevPaymentMethodsDict->Dict.set(pmName, pmTypesArr->getUniqueArray)
    }

  | _ => prevPaymentMethodsDict->Dict.set(pmName, currentPmTypes)
  }
}

let updateConfigDict = (configDict, connectorName, paymentMethodsDict) => {
  switch configDict->Dict.get(connectorName) {
  | Some(prevPaymentMethodsDict) =>
    paymentMethodsDict
    ->Dict.keysToArray
    ->Array.forEach(pmName =>
      updatePaymentMethodsDict(
        prevPaymentMethodsDict,
        pmName,
        paymentMethodsDict->Dict.get(pmName)->Option.getOr([]),
      )
    )

  | _ => configDict->Dict.set(connectorName, paymentMethodsDict)
  }
}

let filterConnectorArrayByPaymentMethod = (
  ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
) => {
  let filteredArray = connectorList->Array.filter(connector => {
    connector.payment_methods_enabled->Array.some(item =>
      item.payment_method_type->getPaymentMethodFromString == Card
    )
  })
  filteredArray
}

let getConnectorConfig = (connectors: array<ConnectorTypes.connectorPayloadCommonType>) => {
  let configDict = Dict.make()
  let filteredConnectors = filterConnectorArrayByPaymentMethod(~connectorList=connectors)
  filteredConnectors->Array.forEach(connector => {
    let (connectorName, paymentMethodsDict) = connector->parseConnectorConfig
    updateConfigDict(configDict, connectorName, paymentMethodsDict)
  })

  configDict
}

let filterList = (items: array<ConnectorTypes.connectorPayloadCommonType>, ~removeFromList) => {
  items->Array.filter(item => {
    let isConnector = item.connector_type !== PaymentVas
    let isThreedsConnector = item.connector_type !== AuthenticationProcessor

    switch removeFromList {
    | Connector => !isConnector
    | FRMPlayer => isConnector
    | ThreedsAuthenticator => isThreedsConnector
    }
  })
}

let createAllOptions = connectorsConfig => {
  open ConnectorTypes
  connectorsConfig
  ->Dict.keysToArray
  ->Array.map(connectorName => {
    gateway: connectorName,
    payment_methods: [],
  })
}

let generateFRMPaymentMethodsConfig = (paymentMethodsDict): array<
  ConnectorTypes.frm_payment_method,
> => {
  open ConnectorTypes
  paymentMethodsDict
  ->Dict.keysToArray
  ->Array.filter(item => item->getPaymentMethodFromString == Card)
  ->Array.map(paymentMethodName => {
    {
      payment_method: paymentMethodName,
      flow: getFlowTypeNameString(PreAuth),
    }
  })
}

let ignoreFields = json => {
  json
  ->getDictFromJsonObject
  ->Dict.toArray
  ->Array.filter(entry => {
    let (key, _val) = entry
    !(ignoredField->Array.includes(key))
  })
  ->Dict.fromArray
  ->JSON.Encode.object
}
