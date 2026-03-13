module SmartRetryCard = {
  open InsightsHelper
  open InsightsPaymentsOverviewSectionTypes
  open InsightsPaymentsOverviewSectionUtils
  open InsightsUtils
  @react.component
  let make = (~responseKey: overviewColumns, ~data) => {
    open LogicUtils
    open CurrencyFormatUtils
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let currency = filterValueJson->getString((#currency: InsightsTypes.filters :> string), "")
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
              {`Saved ${valueFormatter(primaryValue, config.valueType, ~currency)}`->React.string}
            </div>
            <RenderIf condition={comparison === EnableComparison}>
              <StatisticsCard
                value
                direction
                isOverviewComponent=true
                tooltipValue={`${valueFormatter(secondaryValue, config.valueType)} USD`}
              />
            </RenderIf>
          </div>
          <div className="opacity-50 text-sm"> {config.description->React.string} </div>
        </div>
      </div>
    </Card>
  }
}
