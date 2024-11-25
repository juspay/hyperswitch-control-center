module SmartRetryCard = {
  open NewAnalyticsHelper
  open NewPaymentsOverviewSectionTypes
  open NewPaymentsOverviewSectionUtils
  open NewAnalyticsUtils
  @react.component
  let make = (~responseKey: overviewColumns, ~data) => {
    open LogicUtils
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let config = getInfo(~responseKey)
    let primaryValue = getValueFromObj(data, 0, responseKey->getStringFromVariant)
    let secondaryValue = getValueFromObj(data, 1, responseKey->getStringFromVariant)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)
    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto">
        <div className="font-semibold  dark:text-white"> {config.titleText->React.string} </div>
        <div className={"flex flex-col gap-1 justify-center  text-black h-full"}>
          <img alt="connector-list" className="h-20 w-fit" src="/assets/smart-retry.svg" />
          <div className="flex gap-1 items-center">
            <div className="font-semibold  text-2xl dark:text-white">
              {`Saved ${valueFormatter(primaryValue, config.valueType)} USD`->React.string} // TODO:Currency need to be picked from filter
            </div>
            <div className="scale-[0.9]">
              <RenderIf condition={comparison === EnableComparison}>
                <StatisticsCard value direction />
              </RenderIf>
            </div>
          </div>
          <div className="opacity-50 text-sm"> {config.description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}

module OverViewStat = {
  open NewAnalyticsHelper
  open NewAnalyticsUtils
  open NewPaymentsOverviewSectionTypes
  open NewPaymentsOverviewSectionUtils
  @react.component
  let make = (~responseKey, ~data) => {
    open LogicUtils
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let config = getInfo(~responseKey)

    let primaryValue = getValueFromObj(data, 0, responseKey->getStringFromVariant)
    let secondaryValue = getValueFromObj(data, 1, responseKey->getStringFromVariant)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl">
              {
                let value = valueFormatter(primaryValue, config.valueType)
                let suffix = config.valueType == Amount ? "USD" : ""

                `${value} ${suffix}`->React.string
              }
            </div>
            <div className="scale-[0.9]">
              <RenderIf condition={comparison === EnableComparison}>
                <StatisticsCard value direction />
              </RenderIf>
            </div>
          </div>
        </div>
        <div className={"flex flex-col gap-1  text-black"}>
          <div className="font-semibold  dark:text-white"> {config.titleText->React.string} </div>
          <div className="opacity-50 text-sm"> {config.description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}
