open AuthRateRoutingTypes
open LogicUtils

let allFormFields = [BucketSize, ExplorationPercent, RolloutPercent]

let requiredFormFields = [BucketSize, ExplorationPercent, RolloutPercent]

let getFormFieldKey = (field: formFields) => {
  switch field {
  | BucketSize => "defaultBucketSize"
  | ExplorationPercent => "defaultHedgingPercent"
  | RolloutPercent => "split_percentage"
  }
}

let getFormFieldName = (field: formFields) => {
  switch field {
  | BucketSize => "decision_engine_configs.defaultBucketSize"
  | ExplorationPercent => "decision_engine_configs.defaultHedgingPercent"
  | RolloutPercent => "split_percentage"
  }
}

let getFormFieldLabel = (field: formFields) => {
  switch field {
  | BucketSize => "Bucket size"
  | ExplorationPercent => "Exploration percentage"
  | RolloutPercent => "Rollout percentage"
  }
}

let defaultConfigsValue = {
  decision_engine_configs: {
    defaultBucketSize: 200,
    defaultHedgingPercent: 5,
  },
  split_percentage: 100,
}

let initialValues = defaultConfigsValue->Identity.genericTypeToJson

let decisionEngineConfigMapper = dict => {
  let decisionEngineConfig =
    dict->getDictfromDict("algorithm")->getDictfromDict("decision_engine_configs")

  {
    defaultBucketSize: decisionEngineConfig->getInt("defaultBucketSize", 0),
    defaultHedgingPercent: decisionEngineConfig->getInt("defaultHedgingPercent", 0),
  }
}

let formFieldsMapper = (json, split_percentage) => {
  let dict = json->getDictFromJsonObject

  {
    decision_engine_configs: decisionEngineConfigMapper(dict),
    split_percentage: dict->getInt("split_percentage", split_percentage),
  }
}
