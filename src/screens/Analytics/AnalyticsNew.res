module MetricsState = {
  @react.component
  let make = (
    ~singleStatEntity,
    ~filterKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~moduleName,
  ) => {
    <DynamicSingleStat
      entity=singleStatEntity
      startTimeFilterKey
      endTimeFilterKey
      filterKeys
      moduleName
      showPercentage=false
      statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
    />
  }
}

@react.component
let make = () => {
  "Hello"->React.string
}
