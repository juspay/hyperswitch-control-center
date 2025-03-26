open VerticalStepIndicatorTypes
open ReconConfigurationTypes
open LogicUtils

let sections = [
  {
    id: (#orderDataConnection: sections :> string),
    name: "Order Data Connection",
    icon: "nd-inbox",
    subSections: None,
  },
  {
    id: (#connectProcessors: sections :> string),
    name: "Connect Processors",
    icon: "nd-plugin",
    subSections: None,
  },
  {
    id: (#finish: sections :> string),
    name: "Finish",
    icon: "nd-flag",
    subSections: None,
  },
]

let getSectionVariantFromString = (section: string): sections =>
  switch section {
  | "orderDataConnection" => #orderDataConnection
  | "connectProcessors" => #connectProcessors
  | "finish" => #finish
  | _ => #orderDataConnection
  }

let itemToObjMapperForReconStatusData: Dict.t<JSON.t> => reconDataType = dict => {
  let reconStatusDict = dict->getDictfromDict("ReconStatus")
  {
    is_order_data_set: reconStatusDict->getBool("is_order_data_set", false),
    is_processor_data_set: reconStatusDict->getBool("is_processor_data_set", false),
  }
}

let defaultReconStatusData: reconDataType = {
  {
    is_order_data_set: false,
    is_processor_data_set: false,
  }
}

let getRequestBody = (~isOrderDataSet: bool, ~isProcessorDataSet: bool) => {
  {
    "ReconStatus": {
      is_order_data_set: isOrderDataSet,
      is_processor_data_set: isProcessorDataSet,
    },
  }
}
