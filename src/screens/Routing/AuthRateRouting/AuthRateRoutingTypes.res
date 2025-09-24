type formFields = BucketSize | ExplorationPercent | RolloutPercent

type currentBlockThreshold = {max_total_count: int}

type decisionEngineConfigs = {
  defaultBucketSize: int,
  defaultHedgingPercent: int,
}

type payloadConfig = {decision_engine_configs: decisionEngineConfigs}

type decisionEngineFormFields = {
  decision_engine_configs: decisionEngineConfigs,
  split_percentage: int,
}
