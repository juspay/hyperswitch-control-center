open InsightsTypes

open RetryStrategiesAnalyticsUtils

module RetryUpliftCard = {
  open RetryStrategiesAnalyticsTypes
  open LogicUtils
  @react.component
  let make = (
    ~title: string,
    ~rate: float,
    ~changeValue: float,
    ~changeDirection: statisticsDirection,
    ~recovered: array<recoveredType>,
  ) => {
    let getLegendBg = declineType => {
      switch declineType {
      | #soft_declines => "bg-[#E9BE74]"
      | #hard_declines => "bg-[#F8B3AA]"
      }
    }

    let percentageChange = {
      let (bgColor, textColor, icon) = switch changeDirection {
      | Upward => ("bg-green-light", "text-green-dark", "nd-arrow-up-no-underline")
      | Downward => ("bg-red-light", "text-red-dark", "nd-arrow-down-no-underline")
      | No_Change => ("bg-gray-100", "text-gray-500", "nd-arrow-up-no-underline")
      }

      <div className={`flex gap-2 ${bgColor} rounded-lg py-1 px-2`}>
        <Icon name={icon} size=12 />
        <p className={`${textColor} font-medium`}>
          {changeValue->valueFormatter(Rate)->React.string}
        </p>
      </div>
    }

    <div className="rounded-xl border border-gray-200 p-4 w-full bg-white">
      <div className="flex items-center justify-between mb-3">
        <p className="text-sm text-gray-500 flex items-center"> {title->React.string} </p>
      </div>
      <div className="flex items-center space-x-3 mb-3">
        <p className="text-3xl font-semibold text-gray-800">
          {rate->valueFormatter(Rate)->React.string}
        </p>
        {percentageChange}
      </div>
      <div className="border-t border-dashed border-gray-200 my-4" />
      <p className="text-sm text-gray-500 mb-2"> {"Recovered Orders From :"->React.string} </p>
      <div className="flex flex-wrap gap-4 text-sm text-gray-600">
        {recovered
        ->Belt.Array.map(recoveredType =>
          <div className="flex items-center space-x-2">
            <span className={`w-3 h-3 ${getLegendBg(recoveredType.declineType)} rounded-[4px]`} />
            <div className="flex gap-2">
              <span className="font-medium">
                {(recoveredType.declineType: declineTypes :> string)->snakeToTitle->React.string}
              </span>
              <span className="text-gray-500">
                {`| ${recoveredType.value->valueFormatter(Rate)}`->React.string}
              </span>
            </div>
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~entity: moduleEntity) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (retryStrategiesData, setRetryStrategiesData) = React.useState(_ => JSON.Encode.array([]))

  let getRetryStrategies = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let primaryResponse = {
        "static_retries": {
          "auth_rate_percent": 75.1,
          "delta_percent": 2.62,
          "recovered_orders": {
            "soft_declines_percent": 2.62,
            "hard_declines_percent": 0.0,
          },
        },
        "smart_retries": {
          "auth_rate_percent": 81.35,
          "delta_percent": 8.87,
          "recovered_orders": {
            "soft_declines_percent": 8.87,
            "hard_declines_percent": 0.0,
          },
        },
        "smart_retries_booster": {
          "auth_rate_percent": 84.41,
          "delta_percent": 11.93,
          "recovered_orders": {
            "soft_declines_percent": 8.87,
            "hard_declines_percent": 3.06,
          },
          "is_premium": true,
        },
      }->Identity.genericTypeToJson

      setRetryStrategiesData(_ => primaryResponse)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getRetryStrategies()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-56 rounded-lg" />}
    customUI={<InsightsHelper.NoData />}>
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      <RetryUpliftCard
        title={StaticRetries->getTitleForColumn}
        rate={(retryStrategiesData->itemToObjectMapper).static_retries.auth_rate_percent}
        changeValue={(retryStrategiesData->itemToObjectMapper).static_retries.delta_percent}
        changeDirection=No_Change
        recovered=[
          {
            declineType: #soft_declines,
            value: (
              retryStrategiesData->itemToObjectMapper
            ).static_retries.recovered_orders.soft_declines_percent,
          },
        ]
      />
      <RetryUpliftCard
        title={SmartRetries->getTitleForColumn}
        rate={(retryStrategiesData->itemToObjectMapper).smart_retries.auth_rate_percent}
        changeValue={(retryStrategiesData->itemToObjectMapper).smart_retries.delta_percent}
        changeDirection=Upward
        recovered=[
          {
            declineType: #soft_declines,
            value: (
              retryStrategiesData->itemToObjectMapper
            ).smart_retries.recovered_orders.soft_declines_percent,
          },
        ]
      />
      <RetryUpliftCard
        title={SmartRetriesBooster->getTitleForColumn}
        rate={(retryStrategiesData->itemToObjectMapper).smart_retries_booster.auth_rate_percent}
        changeValue={(retryStrategiesData->itemToObjectMapper).smart_retries_booster.delta_percent}
        changeDirection=Upward
        recovered=[
          {
            declineType: #soft_declines,
            value: (
              retryStrategiesData->itemToObjectMapper
            ).smart_retries_booster.recovered_orders.soft_declines_percent,
          },
          {
            declineType: #hard_declines,
            value: (
              retryStrategiesData->itemToObjectMapper
            ).smart_retries_booster.recovered_orders.hard_declines_percent,
          },
        ]
      />
    </div>
  </PageLoaderWrapper>
}
