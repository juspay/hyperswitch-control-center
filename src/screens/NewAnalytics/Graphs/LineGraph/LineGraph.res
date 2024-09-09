type viewType = Graph | Table

module TabSwitch = {
  @react.component
  let make = () => {
    let (viewType, setViewType) = React.useState(_ => Graph)

    <div className="border border-[#E5E5E5] flex w-fit rounded-lg cursor-pointer">
      <div
        className={`rounded-l-lg pl-3 pr-2 pt-2 ${viewType == Graph
            ? "bg-white"
            : "bg-[#F6F6F6]"} `}
        onClick={_ => setViewType(_ => Graph)}>
        <Icon
          className={viewType == Graph ? "text-[#1E1E1E]" : ""}
          name={viewType == Graph ? "graph-dark" : "graph"}
          size=25
        />
      </div>
      <div className="h-full border-l border-[#E5E5E5]" />
      <div
        className={`rounded-r-lg pl-3 pr-2 pt-2 ${viewType == Table ? "bg-white" : "bg-[#F6F6F6]"}`}
        onClick={_ => setViewType(_ => Table)}>
        <Icon
          className={viewType == Table ? "text-[#1E1E1E]" : "text-[#A0A0A0]"}
          name="table-view"
          size=25
        />
      </div>
    </div>
  }
}

module InfoSection = {
  @react.component
  let make = () => {
    open HeadlessUI
    let (arrow, setArrow) = React.useState(_ => false)

    <div className="w-full px-7 py-8 flex justify-between">
      <div className="flex gap-2 items-center">
        <div className="text-3xl font-[600]"> {"165K"->React.string} </div>
        <div className="bg-[#0E92551A] w-fit h-fit rounded-2xl text-[#12B76A] flex px-2 pt-0.5">
          <Icon className="mt-0.5 -mr-1" name="arrow-increasing" size=25 />
          <div className="font-[600]"> {"8%"->React.string} </div>
        </div>
      </div>
      <div className="flex gap-3">
        <Menu \"as"="div" className="relative inline-block text-left">
          {_menuProps =>
            <div>
              <Menu.Button
                className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-4 py-2 font-medium rounded-lg hover:bg-opacity-80 bg-white border border-[#E5E5E5]">
                {_buttonProps => {
                  <>
                    {"By Amount"->React.string}
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
                  className="absolute right-0 z-50 w-fit mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                  {props => {
                    if props["open"] {
                      setArrow(_ => true)
                    } else {
                      setArrow(_ => false)
                    }
                    <>
                      <div className="px-1 py-1 ">
                        {[]
                        ->Array.mapWithIndex((option, i) =>
                          <Menu.Item key={i->Int.toString}>
                            {props =>
                              <div className="relative">
                                <button
                                  onClick={_ => ()}
                                  className={
                                    let activeClasses = if props["active"] {
                                      "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                                    } else {
                                      "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                                    }
                                    `${activeClasses} font-medium text-start`
                                  }>
                                  <div className="mr-5"> {""->React.string} </div>
                                </button>
                                <RenderIf condition={true}>
                                  <Icon
                                    className={`absolute top-2 right-2 `} name="check" size=15
                                  />
                                </RenderIf>
                              </div>}
                          </Menu.Item>
                        )
                        ->React.array}
                      </div>
                    </>
                  }}
                </Menu.Items>}
              </Transition>
            </div>}
        </Menu>
        <TabSwitch />
      </div>
    </div>
  }
}

module NoteSection = {
  @react.component
  let make = () => {
    <div
      className="w-fit mx-7 mb-7 mt-3 py-3 px-4 bg-[#F7D59B4D] rounded-lg flex gap-2 font-medium">
      <Icon name="info-vacent " size=16 />
      <p className="text-[#474D59] text-sm">
        {"Highest amount received was USD9,700 for the month of Aug. Lowest amount issued was ₹2,900 for the month of Aug"->React.string}
      </p>
    </div>
  }
}

@react.component
let make = () => {
  open GraphUtils
  open Highcharts
  open LineGraphUtils

  <div>
    <h2 className="font-[600] text-xl text-[#333333] pb-5">
      {"Payments Processed"->React.string}
    </h2>
    <Card>
      <InfoSection />
      <div className="mx-3">
        <Chart options highcharts />
      </div>
      <NoteSection />
    </Card>
  </div>
}
