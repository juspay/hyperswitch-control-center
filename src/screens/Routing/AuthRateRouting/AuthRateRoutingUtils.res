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

let getFormFieldValue = (field: formFields) => {
  switch field {
  | MinAggregateSize => "min_aggregates_size"
  | DefaultSuccessRate => "default_success_rate"
  | MaxAggregateSize => "max_aggregates_size"
  | MaxTotalCount => "current_block_threshold.max_total_count"
  | SplitPercentage => "split_percentage"
  }
}

let getFormFieldLabel = (field: formFields) => {
  switch field {
  | MinAggregateSize => "Min Aggregate Size"
  | DefaultSuccessRate => "Default Success Rate"
  | MaxAggregateSize => "Max Aggregate Size"
  | MaxTotalCount => "Max Total Count"
  | SplitPercentage => "Split Percentage"
  }
}

let defaultConfigsValue = {
  min_aggregates_size: 5,
  default_success_rate: 100,
  max_aggregates_size: 8,
  current_block_threshold: {
    max_total_count: 5,
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

let configFieldsMapper = (dict, split_percentage) => {
  {
    min_aggregates_size: dict->getInt("max_aggregates_size", 0),
    default_success_rate: dict->getInt("default_success_rate", 0),
    max_aggregates_size: dict->getInt("max_aggregates_size", 0),
    current_block_threshold: getCurrentBlockThreshold(dict),
    split_percentage: dict->getInt("split_percentage", split_percentage),
  }
}
