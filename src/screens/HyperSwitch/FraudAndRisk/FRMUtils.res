open FRMInfo
open FRMTypes

@val external btoa: string => string = "btoa"
@val external atob: string => string = "atob"

let leadingSpaceStrParser = (. ~value, ~name as _) => {
  let str = value->Js.Json.decodeString->Belt.Option.getWithDefault("")
  str->String.replaceRegExp(%re("/^[\s]+/"), "")->Js.Json.string
}

let base64Parse = (. ~value, ~name as _) => {
  value->Js.Json.decodeString->Belt.Option.getWithDefault("")->btoa->Js.Json.string
}

let base64Format = (. ~value, ~name as _) => {
  value->Js.Json.decodeString->Belt.Option.getWithDefault("")->atob->Js.Json.string
}

let toggleDefaultStyle = "mb-2 relative inline-flex flex-shrink-0 h-6 w-12 border-2 rounded-full  transition-colors ease-in-out duration-200 focus:outline-none focus-visible:ring-2  focus-visible:ring-white focus-visible:ring-opacity-75 items-center"

let accordionDefaultStyle = "border pointer-events-none inline-block h-3 w-3 rounded-full bg-white dark:bg-white shadow-lg transform ring-0 transition ease-in-out duration-200"
let size = "w-14 h-14 rounded-full"

let generateInitialValuesDict = (~selectedFRMInfo, ~isLiveMode, ()) => {
  let frmAccountDetailsDict =
    [("auth_type", selectedFRMInfo.name->getFRMAuthType->Js.Json.string)]
    ->Dict.fromArray
    ->Js.Json.object_

  [
    ("connector_name", selectedFRMInfo.name->getFRMNameString->Js.Json.string),
    ("connector_type", "payment_vas"->Js.Json.string),
    ("disabled", false->Js.Json.boolean),
    ("test_mode", !isLiveMode->Js.Json.boolean),
    ("connector_account_details", frmAccountDetailsDict),
    ("frm_configs", []->Js.Json.array),
  ]
  ->Dict.fromArray
  ->Js.Json.object_
}

let parseFRMConfig = json => {
  json
  ->Js.Json.decodeArray
  ->Belt.Option.getWithDefault([])
  ->ConnectorTableUtils.convertFRMConfigJsonToObj
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
        paymentMethodsDict->Dict.get(pmName)->Belt.Option.getWithDefault([]),
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

    switch removeFromList {
    | Connector => !isConnector
    | FRMPlayer => isConnector
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
      ->Belt.Option.getWithDefault([])
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
  ->Js.Json.object_
}
