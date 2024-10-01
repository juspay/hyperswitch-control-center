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
    <Card>
      <div
        className={`${height} border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
        {`No entires in selected time period.`->React.string}
      </div>
    </Card>
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

    <div className="border border-gray-outline flex w-fit rounded-lg cursor-pointer">
      <div
        className={`rounded-l-lg pl-3 pr-2 pt-2 pb-1 ${icon1Bg}`} onClick={_ => setViewType(Graph)}>
        <Icon className={icon1Color} name={icon1Name} size=25 />
      </div>
      <div className="h-full border-l border-gray-outline" />
      <div
        className={`rounded-r-lg pl-3 pr-2 pt-2 pb-1 ${icon2Bg}`} onClick={_ => setViewType(Table)}>
        <Icon className={icon2Color} name=icon2Name size=25 />
      </div>
    </div>
  }
}

module Tabs = {
  open NewAnalyticsTypes
  @react.component
  let make = (~option: optionType, ~setOption: optionType => unit, ~options: array<optionType>) => {
    let getStyle = (value: string, index) => {
      let textStyle =
        value === option.value
          ? "bg-white text-grey-dark font-medium"
          : "bg-grey-light text-grey-medium"

      let borderStyle = index === 0 ? "" : "border-l"

      let borderRadius =
        index === 0 ? "rounded-l-lg" : index === options->Array.length - 1 ? "rounded-r-lg" : ""

      `${textStyle} ${borderStyle} ${borderRadius}`
    }

    <div className="border border-gray-outline flex w-fit rounded-lg cursor-pointer text-sm ">
      {options
      ->Array.mapWithIndex((tabValue, index) =>
        <div
          className={`px-3 py-2 ${tabValue.value->getStyle(index)} selection:bg-white`}
          onClick={_ => setOption(tabValue)}>
          {tabValue.label->React.string}
        </div>
      )
      ->React.array}
    </div>
  }
}

module CustomDropDown = {
  open NewAnalyticsTypes
  @react.component
  let make = (
    ~buttonText: optionType,
    ~options: array<optionType>,
    ~setOption: optionType => unit,
  ) => {
    open HeadlessUI
    let (arrow, setArrow) = React.useState(_ => false)
    <Menu \"as"="div" className="relative inline-block text-left">
      {_ =>
        <div>
          <Menu.Button
            className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-4 py-2 font-medium rounded-lg hover:bg-opacity-80 bg-white border border-outline">
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
          <Transition
            \"as"="span"
            enter="transition ease-out duration-100"
            enterFrom="transform opacity-0 scale-95"
            enterTo="transform opacity-100 scale-100"
            leave="transition ease-in duration-75"
            leaveFrom="transform opacity-100 scale-100"
            leaveTo="transform opacity-0 scale-95">
            {<Menu.Items
              className="absolute right-0 z-50 w-max mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
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
        </div>}
    </Menu>
  }
}

module StatisticsCard = {
  open NewAnalyticsTypes
  @react.component
  let make = (~value, ~direction) => {
    let (bgColor, textColor) = switch direction {
    | Upward => ("bg-green-light", "text-green-dark")
    | Downward => ("bg-red-light", "text-red-dark")
    }
    <div className={`${bgColor} ${textColor} w-fit h-fit rounded-2xl flex px-2 pt-0.5`}>
      <div className="-mb-0.5 flex">
        <Icon className="mt-1 -mr-1" name="arrow-increasing" size=25 />
        <div className="font-semibold"> {`${value}%`->React.string} </div>
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

module GraphHeader = {
  open NewAnalyticsTypes
  @react.component
  let make = (~title, ~showTabSwitch, ~viewType, ~setViewType=_ => ()) => {
    <div className="w-full px-7 py-8 flex justify-between">
      <div className="flex gap-2 items-center">
        <div className="text-3xl font-600"> {title->React.string} </div>
        <StatisticsCard value="8" direction={Upward} />
      </div>
      <RenderIf condition={showTabSwitch}>
        <div className="flex gap-2">
          <TabSwitch viewType setViewType />
        </div>
      </RenderIf>
    </div>
  }
}
