module ReconOnboardingLanding = {
  @react.component
  let make = (~setShowOnBoarding: ('a => bool) => unit) => {
    open PageUtils
    <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
      <img alt="reconOnboarding" src="/Recon/landing.svg" className="rounded-3xl" />
      <div className="flex flex-col gap-8 items-center">
        <div
          className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
          {"Reconciliation"->React.string}
        </div>
        <PageHeading
          customHeadingStyle="gap-3 flex flex-col items-center"
          title="Settlement reconciliation automation"
          customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
          customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
          subTitle="Built for 10x financial & transactional accuracy"
        />
        <Button
          text="Get Started"
          onClick={_ => setShowOnBoarding(_ => false)}
          rightIcon={CustomIcon(<Icon name="nd-angle-right" size=15 />)}
          customTextPaddingClass="pr-1"
          buttonType=Primary
          buttonSize=Large
          buttonState=Normal
        />
      </div>
    </div>
  }
}

module ListBaseComp = {
  @react.component
  let make = (
    ~heading="",
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
    ~showDropdownArrow=true,
    ~placeHolder="Select Processor",
  ) => {
    let {globalUIConfig: {sidebarColor: {secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let arrowClassName = isDarkBg
      ? `${arrow
            ? "rotate-180"
            : "-rotate-0"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `${arrow
            ? "rotate-0"
            : "rotate-180"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`

    let bgClass = subHeading->String.length > 0 ? "bg-white" : "bg-nd_gray-50"

    <div
      className={`flex flex-row cursor-pointer items-center py-5 px-4 gap-2 min-w-44 justify-between h-8 ${bgClass} border rounded-lg border-nd_gray-100 shadow-sm`}>
      <div className="flex flex-row items-center gap-2">
        <RenderIf condition={subHeading->String.length > 0}>
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {subHeading->React.string}
          </p>
        </RenderIf>
        <RenderIf condition={subHeading->String.length == 0}>
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {placeHolder->React.string}
          </p>
        </RenderIf>
      </div>
      {showDropdownArrow
        ? <Icon className={`${arrowClassName} ml-1`} name="arrow-without-tail-new" size=15 />
        : React.null}
    </div>
  }
}

module Card = {
  @react.component
  let make = (
    ~title: string,
    ~subTitle: string,
    ~value: float,
    ~statType: LogicUtilsTypes.valueType,
  ) => {
    let _ = LogicUtils.valueFormatter(value, statType)
    <div
      className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className="text-nd_gray-400 text-xs leading-4 font-medium"> {title->React.string} </p>
      <p className="text-nd_gray-800 font-semibold leading-8 text-2xl">
        {subTitle->React.string}
      </p>
    </div>
  }
}

module ReconCards = {
  @react.component
  let make = () => {
    <div className="grid grid-cols-3 gap-6 mt-2">
      <Card title="Automatic Reconciliation Rate" subTitle="90%" value={90.0} statType=Rate />
      <Card
        title="Total Reconciled Amount" subTitle="$ 1,000,000" value={1000000.0} statType=No_Type
      />
      <Card title="Unreconciled Amount" subTitle="$ 20,000" value={20000.0} statType=No_Type />
      <Card title="Total Orders" subTitle="1823" value={1823.0} statType=No_Type />
      <Card title="Total Reconciled Orders" subTitle="1640" value={1640.0} statType=No_Type />
      <Card title="Unreconciled Orders" subTitle="183" value={183.0} statType=No_Type />
    </div>
  }
}

module StackedBarGraphs = {
  @react.component
  let make = () => {
    <div className="grid grid-cols-2 gap-6">
      <div
        className="flex flex-col space-y-0 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className="text-nd_gray-500 text-sm leading-5 font-medium">
          {"Reconciliation Summary"->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions({
              categories: ["Reconciliation Summary"],
              data: [
                {
                  name: "Transactions Missing",
                  data: [50.0],
                  color: "#FEBBB2",
                },
                {
                  name: "Transactions Mismatch",
                  data: [190.0],
                  color: "#7F7F7F",
                },
                {
                  name: "Transactions Matched",
                  data: [220.0],
                  color: "#1F77B4",
                },
              ],
              labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(),
            })}
          />
        </div>
      </div>
      <div
        className="flex flex-col space-y-0 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className="text-nd_gray-500 text-sm leading-5 font-medium">
          {"Amount Discrepancy Summary"->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions({
              categories: ["Amount Discrepancy Summary"],
              data: [
                {
                  name: "Transactions Missing",
                  data: [50.0],
                  color: "#E377C2",
                },
                {
                  name: "Transactions Mismatch",
                  data: [190.0],
                  color: "#A0872C",
                },
                {
                  name: "Transactions Matched",
                  data: [220.0],
                  color: "#17BECF",
                },
              ],
              labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(),
            })}
          />
        </div>
      </div>
    </div>
  }
}

module ExceptionCards = {
  @react.component
  let make = () => {
    <div className="grid grid-cols-3 gap-6">
      <Card title="Unreconciled Transactions" subTitle="183" value={183.0} statType=No_Type />
      <Card title="Unmatched Transactions" subTitle="160" value={160.0} statType=No_Type />
      <Card title="Data Missing" subTitle="23" value={23.0} statType=No_Type />
      <Card title="Manual adjustment rate" subTitle="80%" value={80.0} statType=No_Type />
      <Card title="Discrepancy resolution time" subTitle="2 Days" value={2.0} statType=No_Type />
      <Card title="Number of unresolved discrepancies" subTitle="5" value={5.0} statType=No_Type />
    </div>
  }
}

module ReconciliationOverview = {
  @react.component
  let make = () => {
    open OMPSwitchTypes
    open ReconOnboardingUtils

    let (selectedReconId, setSelectedReconId) = React.useState(_ => "Recon_235")
    let (reconList, _) = React.useState(_ => [{id: "Recon_235", name: "Recon_235"}])
    let (arrow, setArrow) = React.useState(_ => false)

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        setSelectedReconId(_ => value)
      },
      onFocus: _ => (),
      value: selectedReconId->JSON.Encode.string,
      checked: true,
    }

    let toggleChevronState = () => {
      setArrow(prev => !prev)
    }

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
    let dropdownContainerStyle = "rounded-md border border-1 !w-full"
    <div className="flex flex-col gap-6 w-full">
      <div className="relative flex items-center justify-between w-full mt-8">
        <PageUtils.PageHeading
          title={"Reconciliation Overview"}
          customTitleStyle="!text-2xl !leading-8 !font-semibold !text-nd_gray-700 !tracking-normal"
        />
        <div className="flex flex-row gap-6 absolute bottom-0 right-0">
          <Form>
            <div className="flex flex-row gap-6">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText=""
                input
                deselectDisable=true
                customButtonStyle="!rounded-lg"
                options={reconList->generateDropdownOptionsCustomComponent}
                marginTop="mt-10"
                hideMultiSelectButtons=true
                addButton=false
                baseComponent={<ListBaseComp heading="Recon" subHeading=selectedReconId arrow />}
                customDropdownOuterClass="!border-none !w-full"
                fullLength=true
                toggleChevronState
                customScrollStyle
                dropdownContainerStyle
                shouldDisplaySelectedOnTop=true
                customSelectionIcon={CustomIcon(<Icon name="nd-check" />)}
              />
            </div>
          </Form>
        </div>
      </div>
      <div
        className="bg-nd_red-50 rounded-xl px-6 py-3 flex flex-row items-center justify-between self-stretch">
        <div className="flex flex-row gap-4 items-center">
          <div className="flex flex-row items-center gap-3 pr-4 border-r border-nd_br_red-subtle">
            <Icon name="nd-alert-triangle" size=24 />
            <p className="text-nd_gray-700 font-semibold leading-5 text-center text-sm">
              {"32 Exceptions Found"->React.string}
            </p>
          </div>
          <p className="text-nd_gray-700 font-semibold leading-5 text-center text-sm">
            {"12 "->React.string}
            <span className="text-nd_gray-500 font-medium leading-4 text-xs">
              {"Critical Issues"->React.string}
            </span>
          </p>
        </div>
        <div className="flex items-center gap-1.5">
          <p className="text-nd_primary_blue-500 font-semibold leading-6 text-center text-sm">
            {"View Details"->React.string}
          </p>
          <Icon name="nd-angle-right" size=16 className="text-nd_primary_blue-500" />
        </div>
      </div>
      <ReconCards />
      <StackedBarGraphs />
    </div>
  }
}

module Exceptions = {
  @react.component
  let make = () => {
    let columnGraphOptions: ColumnGraphTypes.columnGraphPayload = {
      title: {
        text: "",
      },
      data: [
        {
          name: "Browsers",
          colorByPoint: true,
          data: [
            {
              name: "1 Day",
              y: 10000.0,
              color: "#7856FF",
            },
            {
              name: "2 Day",
              y: 8000.0,
              color: "#FEBBB2",
            },
            {
              name: "3 Day",
              y: 6000.0,
              color: "#3BA974",
            },
          ],
        },
      ],
      tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
        ~title="Exceptions Aging",
        ~metricType=Amount,
      ),
    }

    <div className="flex flex-col gap-6 w-full">
      <div className="flex items-center justify-between w-full mt-12">
        <PageUtils.PageHeading
          title={"Exceptions"}
          customTitleStyle=" !text-2xl !leading-8 !font-semibold !text-nd_gray-600 !tracking-normal"
        />
      </div>
      <ExceptionCards />
      <div className="grid grid-cols-2 gap-6">
        <div
          className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
          <p className="text-nd_gray-500 text-sm leading-5 font-medium">
            {"Exceptions Aging"->React.string}
          </p>
          <div className="w-full">
            <ColumnGraph options={ColumGraphUtils.getColumnGraphOptions(columnGraphOptions)} />
          </div>
        </div>
        <div
          className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
          <p className="text-nd_gray-500 text-sm leading-5 font-medium">
            {"Status Mismatch & Amount Mismatch"->React.string}
          </p>
          <div className="w-full">
            <PieGraph
              options={PieGraphUtils.getCategoryWisePieChartPayload(
                ~data=[
                  {name: "Status", total: 80.0},
                  {name: "Amount", total: 64.0},
                  {name: "Both", total: 16.0},
                ],
                ~chartSize="200",
                ~toolTipStyle={
                  title: "Total Mismatch",
                  valueFormatterType: Amount,
                },
              )->PieGraphUtils.getPieChartOptions}
            />
          </div>
        </div>
      </div>
    </div>
  }
}

module ReconOverviewContent = {
  @react.component
  let make = () => {
    <div>
      <div
        className="absolute z-10 top-76-px left-0 w-full py-3 px-10 bg-orange-50 flex justify-between items-center">
        <div className="flex gap-4 items-center">
          <Icon name="nd-information-triangle" size=24 />
          <p className="text-nd_gray-600 text-base leading-6 font-medium">
            {"You're viewing sample analytics to help you understand how the reports will look with real data"->React.string}
          </p>
        </div>
        <Button
          text="Get Production Access"
          buttonType=Primary
          buttonSize=Medium
          buttonState=Normal
          onClick={_ => ()}
        />
      </div>
      <ReconciliationOverview />
      <Exceptions />
    </div>
  }
}

module SkeletonCard = {
  @react.component
  let make = (~title) => {
    <div
      className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className="text-nd_gray-400 text-xs leading-4 font-medium"> {title->React.string} </p>
      <p className="text-nd_gray-900 leading-8 text-2xl font-semibold"> {"--"->React.string} </p>
    </div>
  }
}

module SkeletonReconciliationOverview = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-4 w-full">
      <div className="flex items-center justify-between w-full">
        <PageUtils.PageHeading
          title={"Reconciliation Overview"}
          customTitleStyle="!text-2xl !leading-8 !font-semibold !text-nd_gray-700 !tracking-normal"
        />
        <div className="border border-nd_gray-200 py-1 px-4 rounded-lg flex items-center gap-10">
          <p className="text-nd_gray-500 leading-8 text-lg font-semibold">
            {"--------"->React.string}
          </p>
          <Icon name="nd-chevron-arrow-down" className="text-nd_gray-500" />
        </div>
      </div>
      <div className="grid grid-cols-3 gap-5">
        <SkeletonCard title="Automatic Reconciliation Rate" />
        <SkeletonCard title="Total Reconciled Amount" />
        <SkeletonCard title="Unreconciled Amount" />
        <SkeletonCard title="Total Orders" />
        <SkeletonCard title="Total Reconciled Orders" />
        <SkeletonCard title="Unreconciled Orders" />
      </div>
      <div className="grid grid-cols-2 gap-6">
        <div
          className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
          <p className="text-nd_gray-500 text-sm leading-5 font-medium">
            {"Reconciliation Summary"->React.string}
          </p>
          <div className="flex flex-row items-center justify-center w-full h-130-px">
            <div className="flex-[5]" />
            <p className="flex-[10] text-nd_gray-500 text-sm leading-4 font-medium">
              {"Connect data to preview"->React.string}
            </p>
          </div>
        </div>
        <div
          className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
          <p className="text-nd_gray-500 text-sm leading-5 font-medium">
            {"Amount Discrepancy Summary"->React.string}
          </p>
          <div className="flex flex-row items-center justify-center w-full h-130-px">
            <div className="flex-[7]" />
            <p className="flex-[10] text-nd_gray-500 text-sm leading-4 font-medium">
              {"Connect data to preview"->React.string}
            </p>
          </div>
        </div>
      </div>
    </div>
  }
}

module SkeletonExceptions = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-3 w-full">
      <div className="flex items-center justify-between w-full mt-3">
        <PageUtils.PageHeading
          title={"Exceptions"}
          customTitleStyle=" !text-2xl !leading-8 !font-semibold !text-nd_gray-600 !tracking-normal"
        />
      </div>
      <div className="grid grid-cols-3 gap-5">
        <SkeletonCard title="Unmatched Transactions" />
        <SkeletonCard title="Data Missing" />
        <SkeletonCard title="Awaiting approval" />
        <SkeletonCard title="Manual adjustment rate" />
        <SkeletonCard title="Discrepancy resolution time" />
        <SkeletonCard title="Number of unresolved discrepancies" />
      </div>
    </div>
  }
}

module SkeletonLoader = {
  @react.component
  let make = () => {
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

    let onConnectSampleDataClick = () => {
      setShowSideBar(_ => false)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/configuration"))
    }

    <div className="relative h-774-px overflow-hidden">
      <div
        className="absolute w-full h-774-px bg-white/60 flex flex-col justify-center items-center">
        <div
          className="w-[482px] h-[482px] flex flex-col gap-10 rounded-full items-center justify-center bg-white p-14">
          <div className="flex flex-col gap-4 items-center">
            <Icon name="nd-info-circle" size=24 className="text-nd_gray-500" />
            <p className="text-nd_gray-600 text-base text-center leading-6 font-medium">
              {"You can see sample analytics to help you understand how the reports will look with real data"->React.string}
            </p>
          </div>
          <Button
            text="Connect sample data"
            buttonType=Primary
            buttonSize=Medium
            buttonState=Normal
            onClick={_ => onConnectSampleDataClick()}
          />
        </div>
      </div>
      <SkeletonReconciliationOverview />
      <SkeletonExceptions />
    </div>
  }
}

module ReconOverview = {
  @react.component
  let make = (~showSkeleton) => {
    switch showSkeleton {
    | true => <SkeletonLoader />
    | false => <ReconOverviewContent />
    }
  }
}
