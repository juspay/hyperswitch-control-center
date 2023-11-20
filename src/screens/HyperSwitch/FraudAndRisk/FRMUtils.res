open FRMInfo
open FRMTypes

@val external btoa: string => string = "btoa"
@val external atob: string => string = "atob"

let base64Parse = (. ~value, ~name as _) => {
  value->Js.Json.decodeString->Belt.Option.getWithDefault("")->btoa->Js.Json.string
}

let base64Format = (. ~value, ~name as _) => {
  value->Js.Json.decodeString->Belt.Option.getWithDefault("")->atob->Js.Json.string
}

external toJson: 'a => Js.Json.t = "%identity"

let toggleDefaultStyle = "mb-2 relative inline-flex flex-shrink-0 h-6 w-12 border-2 rounded-full  transition-colors ease-in-out duration-200 focus:outline-none focus-visible:ring-2  focus-visible:ring-white focus-visible:ring-opacity-75 items-center"

let accordionDefaultStyle = "border pointer-events-none inline-block h-3 w-3 rounded-full bg-white dark:bg-white shadow-lg transform ring-0 transition ease-in-out duration-200"
let size = "w-14 h-14 rounded-full"

let generateInitialValuesDict = (~selectedFRMInfo, ~isLiveMode=false, ()) => {
  let frmAccountDetailsDict =
    [("auth_type", selectedFRMInfo.name->getFRMAuthType->Js.Json.string)]
    ->Js.Dict.fromArray
    ->Js.Json.object_

  [
    ("connector_name", selectedFRMInfo.name->getFRMNameString->Js.Json.string),
    ("connector_type", "payment_vas"->Js.Json.string),
    ("disabled", false->Js.Json.boolean),
    ("test_mode", !isLiveMode->Js.Json.boolean),
    ("connector_account_details", frmAccountDetailsDict),
    ("frm_configs", []->Js.Json.array),
  ]
  ->Js.Dict.fromArray
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
    paymentMethodTypeArr->Js.Array2.map(item =>
      item->getDictFromJsonObject->getString("payment_method_type", "")
    )

  (paymentMethodDict->getString("payment_method", ""), pmTypesArr->getUniqueArray)
}

let parseConnectorConfig = dict => {
  open LogicUtils
  let pmDict = Js.Dict.empty()
  let connectorPaymentMethods = dict->getArrayFromDict("payment_methods_enabled", [])
  connectorPaymentMethods->Js.Array2.forEach(item => {
    let (pmName, pmTypes) = item->getPaymentMethod
    pmDict->Js.Dict.set(pmName, pmTypes)
  })

  (getString(dict, "connector_name", ""), pmDict)
}

let updatePaymentMethodsDict = (prevPaymentMethodsDict, pmName, currentPmTypes) => {
  open LogicUtils
  switch prevPaymentMethodsDict->Js.Dict.get(pmName) {
  | Some(prevPmTypes) => {
      let pmTypesArr = prevPmTypes->Js.Array2.concat(currentPmTypes)
      prevPaymentMethodsDict->Js.Dict.set(pmName, pmTypesArr->getUniqueArray)
    }

  | _ => prevPaymentMethodsDict->Js.Dict.set(pmName, currentPmTypes)
  }
}

let updateConfigDict = (configDict, connectorName, paymentMethodsDict) => {
  switch configDict->Js.Dict.get(connectorName) {
  | Some(prevPaymentMethodsDict) =>
    paymentMethodsDict
    ->Js.Dict.keys
    ->Js.Array2.forEach(pmName =>
      updatePaymentMethodsDict(
        prevPaymentMethodsDict,
        pmName,
        paymentMethodsDict->Js.Dict.get(pmName)->Belt.Option.getWithDefault([]),
      )
    )

  | _ => configDict->Js.Dict.set(connectorName, paymentMethodsDict)
  }
}

let getConnectorConfig = connectors => {
  let configDict = Js.Dict.empty()

  connectors->Js.Array2.forEach(connector => {
    let (connectorName, paymentMethodsDict) = connector->parseConnectorConfig
    updateConfigDict(configDict, connectorName, paymentMethodsDict)
  })

  configDict
}

let filterList = (items, ~removeFromList=FRMPlayer, ()) => {
  open LogicUtils
  items->Js.Array2.filter(dict => {
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
  ->Js.Dict.keys
  ->Js.Array2.map(connectorName => {
    gateway: connectorName,
    payment_methods: [],
  })
}

let generateFRMPaymentMethodsConfig = paymentMethodsDict => {
  open ConnectorTypes
  paymentMethodsDict
  ->Js.Dict.keys
  ->Js.Array2.map(paymentMethodName => {
    let paymentMethodTypesArr =
      paymentMethodsDict
      ->Js.Dict.get(paymentMethodName)
      ->Belt.Option.getWithDefault([])
      ->Js.Array2.map(paymentMethodType => {
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
  ->Js.Dict.entries
  ->Js.Array2.filter(entry => {
    let (key, _val) = entry
    !(ignoredField->Js.Array2.includes(key))
  })
  ->Js.Dict.fromArray
  ->Js.Json.object_
}

let getMixpanelForFRMOnSubmit = (
  ~frmName,
  ~currentStep,
  ~isUpdateFlow,
  ~url: RescriptReactRouter.url,
  ~hyperswitchMixPanel: HSMixPanel.functionType,
) => {
  let currentStepName =
    currentStep->ConnectorUtils.getStepName->LogicUtils.stringReplaceAll(" ", "")
  if frmName->getFRMNameTypeFromString !== UnknownFRM("Not known") {
    //* Generic Name 'global' given for mixpanel events for calculating total
    [frmName, "global"]->Js.Array2.forEach(item =>
      hyperswitchMixPanel(
        ~pageName=url.path->LogicUtils.getListHead,
        ~contextName=item,
        ~actionName={
          `${isUpdateFlow ? "update_" : ""}step_${currentStepName}`
        },
        (),
      )
    )
  }
}
