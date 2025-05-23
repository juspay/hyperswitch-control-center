type formFields =
  MinAggregateSize | DefaultSuccessRate | MaxAggregateSize | MaxTotalCount | SplitPercentage

type currentBlockThreshold = {max_total_count: int}

type routingConfig = {
  min_aggregates_size: int,
  default_success_rate: int,
  max_aggregates_size: int,
  current_block_threshold: currentBlockThreshold,
}

type routingConfigForm = {
  ...routingConfig,
  split_percentage: int,
}
