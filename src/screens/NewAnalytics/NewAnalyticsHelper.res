let tableBorderClass = "border-2 border-solid  border-jp-gray-940 border-collapse border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"
module Card = {
  @react.component
  let make = (~children) => {
    <div
      className={`h-full flex flex-col justify-between border rounded-lg dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox`}>
      {children}
    </div>
  }
}

module NoData = {
  @react.component
  let make = (~height="h-96") => {
    <div
      className={`${height} border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
      {"No entires in selected time period."->React.string}
    </div>
  }
}

module Shimmer = {
  @react.component
  let make = (~className="w-full h-96", ~layoutId) => {
    <FramerMotion.Motion.Div
      className={`${className} bg-gradient-to-r from-gray-100 via-gray-200 to-gray-100`}
      initial={{backgroundPosition: "-200% 0"}}
      animate={{backgroundPosition: "200% 0"}}
      transition={{duration: 1.5, ease: "easeInOut", repeat: 10000}}
      style={{backgroundSize: "200% 100%"}}
      layoutId
    />
  }
}

module TabSwitch = {
  @react.component
  let make = (~viewType, ~setViewType) => {
    open NewAnalyticsTypes

    let (icon1Bg, icon1Color, icon1Name) = switch viewType {
    | Graph => ("bg-white", "text-grey-dark", "graph-dark")
    | Table => ("bg-grey-light", "", "graph")
    }

    let (icon2Bg, icon2Color, icon2Name) = switch viewType {
    | Graph => ("bg-grey-light", "text-grey-medium", "table-view")
    | Table => ("bg-white", "text-grey-dark", "table-view")
    }

    <div className="border border-gray-outline flex w-fit rounded-lg cursor-pointer h-fit">
      <div
        className={`rounded-l-lg pl-3 pr-2 pt-2 pb-0.5 ${icon1Bg}`}
        onClick={_ => setViewType(Graph)}>
        <Icon className={icon1Color} name={icon1Name} size=25 />
      </div>
      <div className="h-full border-l border-gray-outline" />
      <div className={`rounded-r-lg pl-3 pr-2 pt-2 ${icon2Bg}`} onClick={_ => setViewType(Table)}>
        <Icon className={icon2Color} name=icon2Name size=25 />
      </div>
    </div>
  }
}

module Tabs = {
  open NewAnalyticsTypes
  @react.component
  let make = (
    ~option: optionType,
    ~setOption: optionType => unit,
    ~options: array<optionType>,
    ~showSingleTab=true,
  ) => {
    let getStyle = (value: string, index) => {
      let textStyle =
        value === option.value
          ? "bg-white text-grey-dark font-medium"
          : "bg-grey-light text-grey-medium"

      let borderStyle = index === 0 ? "" : "border-l"

      let borderRadius = if options->Array.length == 1 {
        "rounded-lg"
      } else if index === 0 {
        "rounded-l-lg"
      } else if index === options->Array.length - 1 {
        "rounded-r-lg"
      } else {
        ""
      }

      `${textStyle} ${borderStyle} ${borderRadius}`
    }

    <RenderIf condition={showSingleTab || options->Array.length > 1}>
      <div
        className="border border-gray-outline flex w-fit rounded-lg cursor-pointer text-sm h-fit">
        {options
        ->Array.mapWithIndex((tabValue, index) =>
          <div
            key={index->Int.toString}
            className={`px-3 py-2 ${tabValue.value->getStyle(index)} selection:bg-white`}
            onClick={_ => setOption(tabValue)}>
            {tabValue.label->React.string}
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
  }
}

module CustomDropDown = {
  open NewAnalyticsTypes
  @react.component
  let make = (
    ~buttonText: optionType,
    ~options: array<optionType>,
    ~setOption: optionType => unit,
    ~positionClass="right-0",
    ~disabled=false,
  ) => {
    open HeadlessUI
    let (arrow, setArrow) = React.useState(_ => false)

    <Menu \"as"="div" className="relative inline-block text-left">
      {_ =>
        <div>
          {if disabled {
            <div
              className="inline-flex whitespace-pre leading-5 justify-center text-sm px-4 py-2 font-medium rounded-lg bg-gray-50 border text-gray-500 cursor-not-allowed">
              {buttonText.label->React.string}
              <Icon className="ml-1 mt-1 opacity-40" name="arrow-without-tail" size=15 />
            </div>
          } else {
            <Menu.Button
              className="inline-flex whitespace-pre leading-5 justify-center text-sm px-4 py-2 font-medium rounded-lg hover:bg-opacity-80 bg-white border">
              {_ => {
                <>
                  {buttonText.label->React.string}
                  <Icon
                    className={arrow
                      ? `rotate-0 transition duration-[250ms] ml-1 mt-1 opacity-60`
                      : `rotate-180 transition duration-[250ms] ml-1 mt-1 opacity-60`}
                    name="arrow-without-tail"
                    size=15
                  />
                </>
              }}
            </Menu.Button>
          }}
          {if !disabled {
            <Transition
              \"as"="span"
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              leaveTo="transform opacity-0 scale-95">
              {<Menu.Items
                className={`absolute ${positionClass} z-50 w-max mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none`}>
                {props => {
                  setArrow(_ => props["open"])

                  <div className="p-1">
                    {options
                    ->Array.mapWithIndex((option, i) =>
                      <Menu.Item key={i->Int.toString}>
                        {props =>
                          <div className="relative">
                            <button
                              onClick={_ => setOption(option)}
                              className={
                                let activeClasses = if props["active"] {
                                  "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                                } else {
                                  "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                                }
                                `${activeClasses} font-medium text-start`
                              }>
                              <div className="mr-5"> {option.label->React.string} </div>
                            </button>
                          </div>}
                      </Menu.Item>
                    )
                    ->React.array}
                  </div>
                }}
              </Menu.Items>}
            </Transition>
          } else {
            React.null
          }}
        </div>}
    </Menu>
  }
}

module StatisticsCard = {
  open NewAnalyticsTypes
  @react.component
  let make = (~value, ~tooltipValue as _, ~direction, ~isOverviewComponent=false) => {
    let (bgColor, textColor) = switch direction {
    | Upward => ("bg-green-light", "text-green-dark")
    | Downward => ("bg-red-light", "text-red-dark")
    | No_Change => ("bg-gray-100", "text-gray-500")
    }

    let icon = switch direction {
    | Downward => <img alt="image" className="h-6 w-5 mb-1 mr-1" src={`/icons/arrow.svg`} />
    | Upward | No_Change => <Icon className="mt-1 -mr-1" name="arrow-increasing" size=25 />
    }

    let wrapperClass = isOverviewComponent ? "scale-[0.9]" : ""

    <div
      className={`${wrapperClass} ${bgColor} ${textColor} w-fit h-fit rounded-2xl flex px-2 pt-0.5`}>
      <div className="-mb-0.5 flex">
        {icon}
        <div className="font-semibold text-sm pt-0.5 pr-0.5">
          {`${value->LogicUtils.valueFormatter(Rate)}`->React.string}
        </div>
      </div>
    </div>
  }
}

module NoteSection = {
  @react.component
  let make = (~text) => {
    <div className="w-fit mx-7 mb-7 mt-3 py-3 px-4 bg-yellow-bg rounded-lg flex gap-2 font-medium">
      <Icon name="info-vacent" size=16 />
      <p className="text-grey-text text-sm"> {text->React.string} </p>
    </div>
  }
}

module ModuleHeader = {
  @react.component
  let make = (~title) => {
    <h2 className="font-semibold text-xl text-jp-gray-900 pb-5"> {title->React.string} </h2>
  }
}

module SmartRetryToggle = {
  open LogicUtils
  open NewAnalyticsContainerUtils
  @react.component
  let make = () => {
    let {updateExistingKeys, filterValue, filterValueJson} = React.useContext(
      FilterContext.filterContext,
    )
    let (isEnabled, setIsEnabled) = React.useState(_ => false)
    let isSampleDataEnabled =
      filterValueJson
      ->getString(sampleDataKey, "false")
      ->LogicUtils.getBoolFromString(false)

    React.useEffect(() => {
      let value = filterValueJson->getString(smartRetryKey, "true")->getBoolFromString(true)
      setIsEnabled(_ => value)
      None
    }, [filterValueJson])

    let onClick = _ => {
      let updatedValue = !isEnabled
      let newValue = filterValue->Dict.copy
      newValue->Dict.set(smartRetryKey, updatedValue->getStringFromBool)
      newValue->updateExistingKeys
    }

    <div
      className="w-fit px-3 py-2 border rounded-lg bg-white gap-2 items-center h-fit inline-flex whitespace-pre leading-5 justify-center">
      <BoolInput.BaseComponent
        isSelected={isEnabled}
        setIsSelected={onClick}
        isDisabled=isSampleDataEnabled
        boolCustomClass="rounded-lg !bg-primary"
        toggleBorder="border-primary"
      />
      <p
        className="!text-base text-grey-700 gap-2 inline-flex whitespace-pre justify-center font-medium text-start">
        <span className="text-sm font-medium">
          {"Include Payment Retries data"->React.string}
        </span>
        <ToolTip
          description="Your data will consist of all the payment retries that contributed to the success rate"
          toolTipFor={<div className="cursor-pointer">
            <Icon name="info-vacent" size=13 className="mt-1" />
          </div>}
          toolTipPosition=ToolTip.Top
          newDesign=true
        />
      </p>
    </div>
  }
}

module SampleDataToggle = {
  open LogicUtils
  open NewAnalyticsContainerUtils
  open HSwitchRemoteFilter
  @react.component
  let make = () => {
    let {updateExistingKeys, filterValue, filterValueJson} = React.useContext(
      FilterContext.filterContext,
    )
    let onClickFunc = (
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~compareToStartTimeKey="",
      ~compareToEndTimeKey="",
      ~comparisonKey="",
      ~range=7,
      ~defaultDate=getDateFilteredObject(~range),
    ) => {
      let inititalSearchParam = Dict.make()
      let timeRange = {
        let (compareToStartTime, compareToEndTime) = DateRangeUtils.getComparisionTimePeriod(
          ~startDate=defaultDate.start_time,
          ~endDate=defaultDate.end_time,
        )
        [
          (startTimeFilterKey, defaultDate.start_time),
          (endTimeFilterKey, defaultDate.end_time),
          (compareToStartTimeKey, compareToStartTime),
          (compareToEndTimeKey, compareToEndTime),
          (comparisonKey, (DateRangeUtils.EnableComparison :> string)),
        ]
      }
      timeRange->Array.forEach(item => {
        let (key, defaultValue) = item
        switch inititalSearchParam->Dict.get(key) {
        | Some(_) => ()
        | None => inititalSearchParam->Dict.set(key, defaultValue)
        }
      })
      inititalSearchParam->updateExistingKeys
    }

    let (isEnabled, setIsEnabled) = React.useState(_ =>
      filterValueJson->getString(sampleDataKey, "false")->getBoolFromString(false)
    )
    let sampleStartDate = "2024-09-05T00:00:00.000Z"
    let sampleEndDate = "2024-10-03T00:00:00.000Z"
    let sampleDates: filterBody = {
      start_time: sampleStartDate,
      end_time: sampleEndDate,
    }

    let onClick = _ => {
      let updatedValue = !isEnabled
      let newValue = filterValue->Dict.copy
      newValue->Dict.set(sampleDataKey, updatedValue->getStringFromBool)
      newValue->updateExistingKeys

      setIsEnabled(value => !value)
      if updatedValue {
        onClickFunc(
          ~startTimeFilterKey="startTime",
          ~endTimeFilterKey="endTime",
          ~compareToStartTimeKey="compareToStartTime",
          ~compareToEndTimeKey="compareToEndTime",
          ~comparisonKey="comparison",
          ~range=7,
          ~defaultDate=sampleDates,
        )
      }
    }

    <BoolInput.BaseComponent
      isSelected={isEnabled}
      setIsSelected=onClick
      isDisabled=false
      boolCustomClass="rounded-lg !bg-primary"
      toggleBorder="border-primary"
    />
  }
}

module SampleDataBanner = {
  @react.component
  let make = () => {
    open LogicUtils
    open NewAnalyticsContainerUtils
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let isSampleDataEnabled =
      filterValueJson
      ->getString(sampleDataKey, "false")
      ->LogicUtils.getBoolFromString(false)
    let scrollCss = isSampleDataEnabled ? "sticky z-[30] top-0 " : "relative "

    <div className={`${scrollCss} py-2 px-10 bg-orange-50 flex justify-between items-center`}>
      <div className="flex gap-4 items-center">
        <p className="text-nd_gray-600 text-base leading-6 font-medium">
          {"Currently viewing sample data. Toggle it off to return to your real insights."->React.string}
        </p>
      </div>
      <div>
        <SampleDataToggle />
      </div>
    </div>
  }
}

module OverViewStat = {
  open NewAnalyticsUtils
  open NewAnalyticsTypes
  @react.component
  let make = (~responseKey, ~data, ~getInfo, ~getValueFromObj, ~getStringFromVariant) => {
    open LogicUtils
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let comparison = filterValueJson->getString("comparison", "")->DateRangeUtils.comparisonMapprer
    let currency = filterValueJson->getString((#currency: NewAnalyticsTypes.filters :> string), "")

    let primaryValue = getValueFromObj(data, 0, responseKey->getStringFromVariant)
    let secondaryValue = getValueFromObj(data, 1, responseKey->getStringFromVariant)

    let (value, direction) = calculatePercentageChange(~primaryValue, ~secondaryValue)

    let config = getInfo(~responseKey)
    let displyValue = valueFormatter(primaryValue, config.valueType, ~currency)

    <Card>
      <div className="p-6 flex flex-col gap-4 justify-between h-full gap-auto relative">
        <div className="flex justify-between w-full items-end">
          <div className="flex gap-1 items-center">
            <div className="font-bold text-3xl"> {displyValue->React.string} </div>
            <div className="scale-[0.9]">
              <RenderIf condition={comparison === EnableComparison}>
                <StatisticsCard
                  value
                  direction
                  tooltipValue={valueFormatter(secondaryValue, config.valueType, ~currency)}
                />
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
