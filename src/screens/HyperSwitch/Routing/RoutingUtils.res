open RoutingTypes
open LogicUtils
external toWasm: Dict.t<JSON.t> => wasmModule = "%identity"

let defaultThreeDsObjectValue: routingOutputType = {
  override_3ds: "three_ds",
}
let currentTimeInUTC = Js.Date.fromFloat(Js.Date.now())->Js.Date.toUTCString
let getCurrentUTCTime = () => {
  let currentDate = Js.Date.now()->Js.Date.fromFloat
  let month = currentDate->Js.Date.getUTCMonth +. 1.0
  let day = currentDate->Js.Date.getUTCDate
  let currMonth = month < 10.0 ? `0${month->Float.toString}` : month->Float.toString
  let currDay = day < 10.0 ? `0${day->Float.toString}` : day->Float.toString
  let currYear = currentDate->Js.Date.getUTCFullYear->Float.toString

  `${currYear}-${currMonth}-${currDay}`
}

let routingTypeMapper = routingType => {
  switch routingType {
  | "single" => SINGLE
  | "priority" => PRIORITY
  | "volume_split" => VOLUME_SPLIT
  | "advanced" => ADVANCED
  | "cost" => COST
  | "default" => DEFAULTFALLBACK
  | _ => NO_ROUTING
  }
}

let routingTypeName = routingType => {
  switch routingType {
  | SINGLE => "single"
  | VOLUME_SPLIT => "volume"
  | ADVANCED => "rule"
  | COST => "cost"
  | PRIORITY => "rank"
  | DEFAULTFALLBACK => "default"
  | NO_ROUTING => ""
  }
}

let getRoutingPayload = (data, routingType, name, description, profileId) => {
  let connectorsOrder =
    [("data", data->JSON.Encode.array), ("type", routingType->JSON.Encode.string)]->Dict.fromArray

  [
    ("name", name->JSON.Encode.string),
    ("description", description->JSON.Encode.string),
    ("profile_id", profileId->JSON.Encode.string),
    ("algorithm", connectorsOrder->JSON.Encode.object),
  ]->Dict.fromArray
}

let getModalObj = (routingType, text) => {
  switch routingType {
  | ADVANCED => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the advanced configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | VOLUME_SPLIT => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the volume based configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | PRIORITY => {
      conType: "Activate current configured configuration?",
      conText: {
        React.string(
          `If you want to activate the ${text} configuration, the simple configuration, set previously will be lost. Are you sure you want to activate it?`,
        )
      },
    }
  | DEFAULTFALLBACK => {
      conType: "Save the Current Changes ?",
      conText: {
        React.string(`Do you want to save the current changes ?`)
      },
    }
  | _ => {
      conType: "Activate Logic",
      conText: {React.string("Are you sure you want to ACTIVATE the logic?")},
    }
  }
}

let getContent = routetype =>
  switch routetype {
  | DEFAULTFALLBACK => {
      heading: "Default fallback ",
      subHeading: "Fallback is a priority order of all the configured processors which is used to route traffic standalone or when other routing rules are not applicable. You can reorder the list with simple drag and drop",
    }
  | PRIORITY => {
      heading: "Rank Based Configuration",
      subHeading: "Fallback is activated when the above routing conditions happen to be false.",
    }
  | VOLUME_SPLIT => {
      heading: "Volume Based Configuration",
      subHeading: "Route traffic across various processors by volume distribution",
    }
  | ADVANCED => {
      heading: "Rule Based Configuration",
      subHeading: "Route traffic across processors with advanced logic rules on the basis of various payment parameters",
    }
  | COST => {
      heading: "Cost Based Configuration",
      subHeading: "Helps you optimise your overall payment costs with a single click by leveraging the differential processing fees across various processors",
    }
  | _ => {
      heading: "",
      subHeading: "",
    }
  }

//Volume
let getGatewayTypes = (arr: array<JSON.t>) => {
  let tempArr = arr->Array.map(value => {
    let val = value->getDictFromJsonObject
    let connectorDict = val->getDictfromDict("connector")
    let tempval = {
      distribution: val->getInt("split", 0),
      disableFallback: val->getBool("disableFallback", false),
      gateway_name: connectorDict->getString("merchant_connector_id", ""),
    }
    tempval
  })
  tempArr
}

// Advanced
let valueTypeMapper = dict => {
  let value = switch Dict.get(dict, "value")->Option.map(JSON.Classify.classify) {
  | Some(Array(arr)) => StringArray(arr->getStrArrayFromJsonArray)
  | Some(String(st)) => String(st)
  | Some(Number(num)) => Int(num->Float.toInt)
  | _ => String("")
  }
  value
}

let threeDsTypeMapper = dict => {
  let getRoutingOutputval = dict->getString("override_3ds", "three_ds")
  let val = {
    override_3ds: getRoutingOutputval,
  }
  val
}

let constructNameDescription = routingType => {
  let routingText = routingType->routingTypeName
  Dict.fromArray([
    (
      "name",
      `${routingText->LogicUtils.capitalizeString} Based Routing-${getCurrentUTCTime()}`->JSON.Encode.string,
    ),
    (
      "description",
      `This is a ${routingText} based routing created at ${currentTimeInUTC}`->JSON.Encode.string,
    ),
  ])
}

let currentTabNameRecoilAtom = Recoil.atom(. "currentTabName", "ActiveTab")

module SaveAndActivateButton = {
  @react.component
  let make = (
    ~onSubmit: (JSON.t, 'a) => promise<Nullable.t<JSON.t>>,
    ~handleActivateConfiguration,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let handleSaveAndActivate = async _ev => {
      try {
        let onSubmitResponse = await onSubmit(formState.values, false)
        let currentActivatedFromJson =
          onSubmitResponse->Nullable.toOption->Option.getOr(JSON.Encode.null)
        let currentActivatedId =
          currentActivatedFromJson->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
        let _ = await handleActivateConfiguration(Some(currentActivatedId))
      } catch {
      | Js.Exn.Error(e) =>
        let _ = Js.Exn.message(e)->Option.getOr("Failed to save and activate configuration!")
      }
    }
    <Button
      text={"Save and Activate Rule"}
      buttonType={Primary}
      buttonSize=Button.Small
      onClick={_ => {
        handleSaveAndActivate()->ignore
      }}
      customButtonStyle="w-1/5 rounded-sm"
    />
  }
}
module ConfigureRuleButton = {
  @react.component
  let make = (~setShowModal) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    <Button
      text={"Configure Rule"}
      buttonType=Primary
      buttonState={!formState.hasValidationErrors ? Normal : Disabled}
      onClick={_ => {
        setShowModal(_ => true)
      }}
      customButtonStyle="w-1/5"
    />
  }
}

let validateNameAndDescription = (~dict, ~errors) => {
  ["name", "description"]->Array.forEach(field => {
    if dict->LogicUtils.getString(field, "")->String.trim === "" {
      errors->Dict.set(field, `Please provide ${field} field`->JSON.Encode.string)
    }
  })
}

let checkIfValuePresent = dict => {
  let valueFromObject = dict->getDictfromDict("value")

  valueFromObject
  ->getArrayFromDict("value", [])
  ->Array.filter(ele => {
    ele != ""->JSON.Encode.string
  })
  ->Array.length > 0 ||
  valueFromObject->getString("value", "")->String.length > 0 ||
  valueFromObject->getFloat("value", -1.0) !== -1.0 ||
  (valueFromObject->getDictfromDict("value")->getString("key", "")->String.length > 0 &&
    valueFromObject->getDictfromDict("value")->getString("value", "")->String.length > 0)
}

let validateConditionJson = (json, keys) => {
  switch json->JSON.Decode.object {
  | Some(dict) =>
    keys->Array.every(key => dict->Dict.get(key)->Option.isSome) && dict->checkIfValuePresent
  | None => false
  }
}

let validateConditionsFor3ds = dict => {
  let conditionsArray = dict->LogicUtils.getArrayFromDict("statements", [])

  conditionsArray->Array.every(value => {
    value->validateConditionJson(["comparison", "lhs"])
  })
}

let getRecordsObject = json => {
  switch JSON.Classify.classify(json) {
  | Object(jsonDict) => jsonDict->getArrayFromDict("records", [])
  | Array(jsonArray) => jsonArray
  | _ => []
  }
}
