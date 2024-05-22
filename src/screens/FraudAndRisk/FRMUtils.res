open FRMInfo
open FRMTypes

@val external btoa: string => string = "btoa"
@val external atob: string => string = "atob"

let leadingSpaceStrParser = (. ~value, ~name as _) => {
  let str = value->JSON.Decode.string->Option.getOr("")
  str->String.replaceRegExp(%re("/^[\s]+/"), "")->JSON.Encode.string
}

let base64Parse = (. ~value, ~name as _) => {
  value->JSON.Decode.string->Option.getOr("")->btoa->JSON.Encode.string
}

let base64Format = (. ~value, ~name as _) => {
  value->JSON.Decode.string->Option.getOr("")->atob->JSON.Encode.string
}

let toggleDefaultStyle = "mb-2 relative inline-flex flex-shrink-0 h-6 w-12 border-2 rounded-full  transition-colors ease-in-out duration-200 focus:outline-none focus-visible:ring-2  focus-visible:ring-white focus-visible:ring-opacity-75 items-center"

let accordionDefaultStyle = "border pointer-events-none inline-block h-3 w-3 rounded-full bg-white dark:bg-white shadow-lg transform ring-0 transition ease-in-out duration-200"
let size = "w-14 h-14 rounded-full"

let generateInitialValuesDict = (~selectedFRMName, ~isLiveMode, ()) => {
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
  json->JSON.Decode.array->Option.getOr([])->ConnectorListMapper.convertFRMConfigJsonToObj
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

let parseConnectorConfig = dict => {
  open LogicUtils
  let pmDict = Dict.make()
  let connectorPaymentMethods = dict->getArrayFromDict("payment_methods_enabled", [])
  connectorPaymentMethods->Array.forEach(item => {
    let (pmName, pmTypes) = item->getPaymentMethod
    pmDict->Dict.set(pmName, pmTypes)
  })

  (getString(dict, "connector_name", ""), pmDict)
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

let getConnectorConfig = connectors => {
  let configDict = Dict.make()

  connectors->Array.forEach(connector => {
    let (connectorName, paymentMethodsDict) = connector->parseConnectorConfig
    updateConfigDict(configDict, connectorName, paymentMethodsDict)
  })

  configDict
}

let filterList = (items, ~removeFromList, ()) => {
  open LogicUtils
  items->Array.filter(dict => {
    let isConnector = dict->getString("connector_type", "") !== "payment_vas"
    let isThreedsConnector = dict->getString("connector_type", "") !== "authentication_processor"

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

let generateFRMPaymentMethodsConfig = paymentMethodsDict => {
  open ConnectorTypes
  paymentMethodsDict
  ->Dict.keysToArray
  ->Array.map(paymentMethodName => {
    let paymentMethodTypesArr =
      paymentMethodsDict
      ->Dict.get(paymentMethodName)
      ->Option.getOr([])
      ->Array.map(paymentMethodType => {
        {
          payment_method_type: paymentMethodType,
          flow: "pre",
          action: "cancel_txn",
        }
      })

    {
      payment_method: paymentMethodName,
      payment_method_types: paymentMethodTypesArr,
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
