module SmartRetryCard = {
  open NewAnalyticsHelper
  open NewPaymentsOverviewSectionTypes
  open NewPaymentsOverviewSectionUtils
  open NewAnalyticsUtils
  @react.component
  let make = (~responseKey: overviewColumns, ~data) => {
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
              {`Saved ${valueFormatter(primaryValue, config.valueType)}`->React.string}
            </div>
            <div className="scale-[0.9]">
              <StatisticsCard value direction />
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
    let config = getInfo(~responseKey)

    let primaryValue = getValueFromObj(data, 0, responseKey->getStringFromVariant)
    let secondaryValue = getValueFromObj(data, 1, responseKey->getStringFromVariant)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl">
              {valueFormatter(primaryValue, config.valueType)->React.string}
            </div>
            <div className="scale-[0.9]">
              <StatisticsCard value direction />
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
