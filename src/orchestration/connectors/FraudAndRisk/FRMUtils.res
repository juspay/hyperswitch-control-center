open FRMInfo
open FRMTypes

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

let generateInitialValuesDict = (~selectedFRMName, ~isLiveMode) => {
  let frmAccountDetailsDict =
    [
      ("auth_type", selectedFRMName->getFRMAuthType->JSON.Encode.string),
    ]->LogicUtils.getJsonFromArrayOfJson

  [
    ("connector_name", selectedFRMName->ConnectorUtils.getConnectorNameString->JSON.Encode.string),
    ("connector_type", "payment_vas"->JSON.Encode.string),
    ("disabled", false->JSON.Encode.bool),
    ("test_mode", !isLiveMode->JSON.Encode.bool),
    ("connector_account_details", frmAccountDetailsDict),
    ("frm_configs", []->JSON.Encode.array),
  ]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let parseFRMConfig = json => {
  json->JSON.Decode.array->Option.getOr([])->ConnectorInterfaceUtils.convertFRMConfigJsonToObj
}

let getPaymentMethod = paymentMethod => {
  open LogicUtils

  let paymentMethodDict = paymentMethod->getDictFromJsonObject
  let paymentMethodTypeArr = paymentMethodDict->getArrayFromDict("payment_method_types", [])

  let pmTypesArr =
    paymentMethodTypeArr->Array.map(item =>
      item->getDictFromJsonObject->getString("payment_method_type", "")
    )

  (paymentMethodDict->getString("payment_method", ""), pmTypesArr->getUniqueArray)
}

let parseConnectorConfig = (connector: ConnectorTypes.connectorPayloadCommonType) => {
  let connectorName = connector.connector_name
  let connectorPaymentMethods = connector.payment_methods_enabled
  let pmDict = Dict.make()
  connectorPaymentMethods->Array.forEach(item => {
    let pmTypes =
      item.payment_method_subtypes
      ->Array.map(item => item.payment_method_subtype)
      ->LogicUtils.getUniqueArray
    let (pmName, pmTypes) = (item.payment_method_type, pmTypes)

    pmDict->Dict.set(pmName, pmTypes)
  })
  (connectorName, pmDict)
}

let updatePaymentMethodsDict = (prevPaymentMethodsDict, pmName, currentPmTypes) => {
  open LogicUtils
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

let getConnectorConfig = (connectors: array<ConnectorTypes.connectorPayloadCommonType>) => {
  let configDict = Dict.make()

  connectors->Array.forEach(connector => {
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
  ->Array.map(paymentMethodName => {
    {
      payment_method: paymentMethodName,
      flow: getFlowTypeNameString(PreAuth),
    }
  })
}

let ignoreFields = json => {
  json
  ->LogicUtils.getDictFromJsonObject
  ->Dict.toArray
  ->Array.filter(entry => {
    let (key, _val) = entry
    !(ignoredField->Array.includes(key))
  })
  ->Dict.fromArray
  ->JSON.Encode.object
}
