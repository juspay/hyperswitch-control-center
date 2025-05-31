open AuthRateRoutingTypes
open LogicUtils

let allFormFields = [
  MinAggregateSize,
  DefaultSuccessRate,
  MaxAggregateSize,
  MaxTotalCount,
  SplitPercentage,
]

let requiredFormFields = [MinAggregateSize, DefaultSuccessRate, MaxAggregateSize, MaxTotalCount]

let getFormFieldKey = (field: formFields) => {
  switch field {
  | MinAggregateSize => "min_aggregates_size"
  | DefaultSuccessRate => "default_success_rate"
  | MaxAggregateSize => "max_aggregates_size"
  | MaxTotalCount => "max_total_count"
  | SplitPercentage => "split_percentage"
  }
}

let getFormFieldName = (field: formFields) => {
  switch field {
  | MinAggregateSize => "config.min_aggregates_size"
  | DefaultSuccessRate => "config.default_success_rate"
  | MaxAggregateSize => "config.max_aggregates_size"
  | MaxTotalCount => "config.current_block_threshold.max_total_count"
  | SplitPercentage => "split_percentage"
  }
}

let getFormFieldLabel = (field: formFields) => {
  switch field {
  | MinAggregateSize => "Min aggregate size"
  | DefaultSuccessRate => "Default success rate"
  | MaxAggregateSize => "Max aggregate size"
  | MaxTotalCount => "Max total count"
  | SplitPercentage => "Rollout traffic percentage"
  }
}

let defaultConfigsValue = {
  config: {
    min_aggregates_size: 5,
    default_success_rate: 100,
    max_aggregates_size: 8,
    current_block_threshold: {
      max_total_count: 5,
    },
  },
  split_percentage: 100,
}

let initialValues = defaultConfigsValue->Identity.genericTypeToJson

let getCurrentBlockThreshold = dict => {
  let maxTotalCount = dict->getDictfromDict("current_block_threshold")->getInt("max_total_count", 0)
  {
    max_total_count: maxTotalCount,
  }
}

let configMapper = dict => {
  let config = dict->getDictfromDict("algorithm")->getDictfromDict("config")

  {
    min_aggregates_size: config->getInt("min_aggregates_size", 0),
    default_success_rate: config->getInt("default_success_rate", 0),
    max_aggregates_size: config->getInt("max_aggregates_size", 0),
    current_block_threshold: getCurrentBlockThreshold(config),
  }
}

let formFieldsMapper = (json, split_percentage) => {
  let dict = json->getDictFromJsonObject

  {
    config: configMapper(dict),
    split_percentage: dict->getInt("split_percentage", split_percentage),
  }
}
