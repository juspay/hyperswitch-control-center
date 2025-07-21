module ReconOnboardingLanding = {
  @react.component
  let make = () => {
    open PageUtils

    let {setCreateNewMerchant, activeProduct} = React.useContext(
      ProductSelectionProvider.defaultContext,
    )
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
    let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
      #tenant_admin,
      #org_admin,
    ])

    let mixpanelEvent = MixpanelHook.useSendEvent()
    let onTryDemoClick = () => {
      setCreateNewMerchant(ProductTypes.Recon(V2))
    }

    let handleClick = () => {
      if activeProduct == Recon(V2) {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/recon/configuration"))
      } else {
        onTryDemoClick()
      }
    }

    let showSidebar = () => {
      setShowSideBar(_ => true)
    }

    React.useEffect(() => {
      showSidebar()
      None
    }, [])

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
        <ACLButton
          authorization={userHasCreateMerchantAccess}
          text="Try Demo"
          onClick={_ => {
            mixpanelEvent(~eventName="recon_try_demo")
            handleClick()
          }}
          rightIcon={CustomIcon(<Icon name="nd-angle-right" size=15 />)}
          customTextPaddingClass="pr-0"
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
      className={`flex flex-row cursor-pointer items-center py-5 px-4 gap-2 min-w-44 justify-between h-8 ${bgClass} border rounded-lg border-nd_gray-150 shadow-sm`}>
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
      <RenderIf condition={showDropdownArrow}>
        <Icon className={`${arrowClassName} ml-1`} name="nd-angle-down" size=12 />
      </RenderIf>
    </div>
  }
}

module Card = {
  @react.component
  let make = (~title: string, ~value: string) => {
    <div
      className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
      <p className="text-nd_gray-400 text-xs leading-4 font-medium"> {title->React.string} </p>
      <p className="text-nd_gray-800 font-semibold leading-8 text-2xl"> {value->React.string} </p>
    </div>
  }
}

module ReconCards = {
  @react.component
  let make = () => {
    <div className="grid grid-cols-3 gap-6 mt-2">
      <Card title="Automatic Reconciliation Rate" value="90%" />
      <Card title="Total Reconciled Amount" value="$ 2,500,011" />
      <Card title="Unreconciled Amount" value="$ 300,007" />
      <Card title="Reconciled Orders" value="1800" />
      <Card title="Unreconciled Orders" value="150" />
      <Card title="Data Missing" value="50" />
    </div>
  }
}

module StackedBarGraphs = {
  @react.component
  let make = () => {
    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1600px)")
    <div className="grid grid-cols-2 gap-6">
      <div
        className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className="text-nd_gray-400 text-xs leading-5 font-medium">
          {"Total Orders"->React.string}
        </p>
        <p className="text-nd_gray-800 font-semibold text-2xl leading-8">
          {"2000"->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions(
              {
                categories: ["Total Orders"],
                data: [
                  {
                    name: "Missing",
                    data: [50.0],
                    color: "#FEBBB2",
                  },
                  {
                    name: "Mismatch",
                    data: [150.0],
                    color: "#7F7F7F",
                  },
                  {
                    name: "Matched",
                    data: [1800.0],
                    color: "#1F77B4",
                  },
                ],
                labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(
                  ~statType=Default,
                ),
              },
              ~yMax=2000,
              ~labelItemDistance={isMiniLaptopView ? 45 : 90},
            )}
          />
        </div>
      </div>
      <div
        className="flex flex-col space-y-2 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
        <p className="text-nd_gray-400 text-xs leading-5 font-medium">
          {"Total Amount"->React.string}
        </p>
        <p className="text-nd_gray-800 font-semibold text-2xl leading-8">
          {"$ 2,879,147"->React.string}
        </p>
        <div className="w-full">
          <StackedBarGraph
            options={StackedBarGraphUtils.getStackedBarGraphOptions(
              {
                categories: ["Total Amount"],
                data: [
                  {
                    name: "Missing",
                    data: [79129.0],
                    color: "#FEBBB2",
                  },
                  {
                    name: "Mismatch",
                    data: [300007.0],
                    color: "#A0872C",
                  },
                  {
                    name: "Matched",
                    data: [2500011.0],
                    color: "#17BECF",
                  },
                ],
                labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(
                  ~statType=FormattedAmount,
                  ~currency="$",
                ),
              },
              ~yMax=2879147,
              ~labelItemDistance={isMiniLaptopView ? 10 : 40},
            )}
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
      <Card title="Exceptions Transactions" value="150" />
      <Card title="Average Aging Time" value="4.36" />
      <Card title="Total Exception Value" value="$ 300,007" />
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

    let navigateToExceptions = () => {
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url="v2/recon/reports?tab=exceptions"),
      )
    }

    let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
    let dropdownContainerStyle = "rounded-md border border-1 !w-full"
    <div className="flex flex-col gap-6 w-full">
      <div className="relative flex items-center justify-between w-full">
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
          <div className="flex flex-row items-center gap-3">
            <Icon name="nd-alert-triangle" size=24 />
            <p className="text-nd_gray-700 font-semibold leading-5 text-center text-sm">
              {"150 Exceptions Found"->React.string}
            </p>
          </div>
        </div>
        <div
          className="flex items-center gap-1.5 cursor-pointer"
          onClick={_ => navigateToExceptions()}>
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
    let exceptionsAgingOptions: ColumnGraphTypes.columnGraphPayload = {
      title: {
        text: "",
      },
      data: [
        {
          showInLegend: false,
          name: "Exceptions Aging",
          colorByPoint: true,
          data: [
            {
              name: "1 Day",
              y: 13711.0,
              color: "#DB88C1",
            },
            {
              name: "2 Day",
              y: 44579.0,
              color: "#DB88C1",
            },
            {
              name: "3 Day",
              y: 40510.0,
              color: "#DB88C1",
            },
            {
              name: "4 Day",
              y: 48035.0,
              color: "#DB88C1",
            },
            {
              name: "5 Day",
              y: 51640.0,
              color: "#DB88C1",
            },
            {
              name: "6 Day",
              y: 51483.0,
              color: "#DB88C1",
            },
            {
              name: "7 Day",
              y: 50049.0,
              color: "#DB88C1",
            },
          ],
          color: "",
        },
      ],
      tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
        ~title="Exceptions Aging",
        ~metricType=FormattedAmount,
      ),
      yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
        ~statType=FormattedAmount,
        ~currency="$",
      ),
    }

    let unmatchedTransactionsOptions: ColumnGraphTypes.columnGraphPayload = {
      title: {
        text: "",
      },
      data: [
        {
          showInLegend: false,
          name: "Unmatched Transactions",
          colorByPoint: true,
          data: [
            {
              name: "Status Mismatch",
              y: 50.0,
              color: "#BCBD22",
            },
            {
              name: "Amount Mismatch",
              y: 50.0,
              color: "#72BEF4",
            },
            {
              name: "Both",
              y: 50.0,
              color: "#4B6D8C",
            },
          ],
          color: "",
        },
      ],
      tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
        ~title="Unmatched Transactions",
        ~metricType=Default,
      ),
      yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(~statType=Default),
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
          <p className="text-nd_gray-600 text-sm leading-5 font-medium">
            {"Exceptions Aging"->React.string}
          </p>
          <div className="w-full">
            <ColumnGraph options={ColumnGraphUtils.getColumnGraphOptions(exceptionsAgingOptions)} />
          </div>
        </div>
        <div
          className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
          <p className="text-nd_gray-600 text-sm leading-5 font-medium">
            {"Unmatched Transactions"->React.string}
          </p>
          <div className="w-full">
            <ColumnGraph
              options={ColumnGraphUtils.getColumnGraphOptions(unmatchedTransactionsOptions)}
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
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

    React.useEffect(() => {
      mixpanelEvent(~eventName="recon_analytics_overview")
      setShowSideBar(_ => true)
      None
    }, [])

    <div>
      <ReconciliationOverview />
      <Exceptions />
    </div>
  }
}
