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

module ReconOverviewContent = {
  @react.component
  let make = () => {
    <div>
      <div className="relative">
        <PageUtils.PageHeading
          title={"Reconciliation Overview"}
          customTitleStyle="!text-2xl !leading-8 !font-semibold !text-nd_gray-700 !tracking-normal"
        />
        <div className="flex flex-row gap-6 absolute bottom-0 right-0">
          <Form>
            <div className="flex flex-row gap-6">
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeMultiInputFieldInfo(
                  ~label="",
                  ~comboCustomInput=InputFields.dateRangeField(
                    ~startKey="startDate",
                    ~endKey="endDate",
                    ~format="YYYY-MM-DD",
                    ~showTime=false,
                    ~disablePastDates={false},
                    ~disableFutureDates={true},
                    ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth, LastSixMonths],
                    ~dateRangeLimit=400,
                    ~disableApply=true,
                    ~isTooltipVisible=false,
                    ~customButtonStyle="!w-1/2",
                  ),
                  ~inputFields=[],
                )}
              />
            </div>
          </Form>
        </div>
      </div>
    </div>
  }
}

module SkeletonLoader = {
  @react.component
  let make = (~setShowSkeleton) => {
    let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

    let onConnectSampleDataClick = () => {
      setShowSideBar(_ => false)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/configuration"))
      setShowSkeleton(_ => false)
    }

    <div>
      <div
        className="absolute top-76-px left-0 w-full py-3 px-10 bg-orange-50 flex justify-between items-center">
        <div className="flex gap-4 items-center">
          <Icon name="nd-information-triangle" />
          <p className="text-nd_gray-600 text-base leading-6 font-medium">
            {"Get started with sample analytics"->React.string}
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
      <div className="flex flex-col gap-8 w-full">
        <div className="flex items-center justify-between w-full mt-8">
          <PageUtils.PageHeading
            title={"Reconciliation Overview"}
            customTitleStyle=" !text-2xl !leading-8 !font-semibold !text-nd_gray-700 !tracking-normal"
          />
          <div className="border border-nd_gray-200 py-2 px-3.5 rounded-lg flex items-center gap-2">
            <div className="w-104-px h-3 bg-nd_gray-50 rounded-lg" />
            <Icon name="nd-chevron-arrow-down" className="text-nd_gray-500" />
          </div>
        </div>
        <div className="grid grid-cols-3 gap-6">
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Automatic Reconciliation Rate"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Total Reconciled Amount"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Unreconciled Amount"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Total Orders"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Total Reconciled Orders"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Unreconciled Orders"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-6">
          <div
            className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-500 text-sm leading-5 font-medium">
              {"Reconciliation Summary"->React.string}
            </p>
            <div className="flex flex-row items-center pr-4 justify-between w-full">
              <div className="flex flex-[1] flex-col gap-10 h-full py-4">
                <p className="text-nd_gray-400 text-xs leading-4 font-medium">
                  {"Merchant"->React.string}
                </p>
                <p className="text-nd_gray-400 text-xs leading-4 font-medium">
                  {"Gateway"->React.string}
                </p>
              </div>
              <div
                className="flex flex-[5] flex-col gap-2 items-center justify-center bg-nd_gray-25 rounded-2xl h-full">
                <p className="text-nd_gray-500 text-xs leading-4 font-medium">
                  {"Connect sample data to preview"->React.string}
                </p>
              </div>
            </div>
          </div>
          <div
            className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-500 text-sm leading-5 font-medium">
              {"Amount Discrepancy Summary"->React.string}
            </p>
            <div className="flex flex-row items-center pr-4 justify-between w-full">
              <div className="flex flex-[1] flex-col gap-10 h-full py-4">
                <p className="text-nd_gray-400 text-xs leading-4 font-medium">
                  {"Merchant"->React.string}
                </p>
                <p className="text-nd_gray-400 text-xs leading-4 font-medium">
                  {"Gateway"->React.string}
                </p>
              </div>
              <div
                className="flex flex-[5] flex-col gap-2 items-center justify-center bg-nd_gray-25 rounded-2xl h-full">
                <p className="text-nd_gray-500 text-xs leading-4 font-medium">
                  {"Connect sample data to preview"->React.string}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-6 w-full">
        <div className="flex items-center justify-between w-full mt-12">
          <PageUtils.PageHeading
            title={"Exceptions"}
            customTitleStyle=" !text-2xl !leading-8 !font-semibold !text-nd_gray-600 !tracking-normal"
          />
        </div>
        <div className="grid grid-cols-3 gap-6">
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Unmatched Transactions"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Data Missing"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Awaiting approval"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Manual adjustment rate"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Discrepancy resolution time"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
          <div
            className="flex flex-col gap-4 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-400 text-xs leading-4 font-medium">
              {"Number of unresolved discrepancies"->React.string}
            </p>
            <div className="h-3 bg-nd_gray-200 rounded-lg w-104-px" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-6">
          <div
            className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-500 text-sm leading-5 font-medium">
              {"Exceptions Aging"->React.string}
            </p>
            <div
              className="flex items-center justify-center w-full h-full bg-nd_gray-25 rounded-2xl">
              <p className="text-nd_gray-500 text-xs leading-4 font-medium">
                {"Connect sample data to preview"->React.string}
              </p>
            </div>
          </div>
          <div
            className="flex flex-col gap-6 items-start border rounded-xl border-nd_gray-150 px-4 pt-3 pb-4">
            <p className="text-nd_gray-500 text-sm leading-5 font-medium">
              {"Status Mismatch & Amount Mismatch"->React.string}
            </p>
            <div className="flex items-center justify-center w-full h-full">
              <div
                className="w-[200px] h-[200px] border-solid border-20-px border-nd_gray-200 rounded-full flex items-center justify-center">
                <p className="text-nd_gray-400 font-medium text-sm w-24 text-center">
                  {"Connect sample data to preview"->React.string}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  }
}

module ReconOverview = {
  @react.component
  let make = (~showSkeleton, ~setShowSkeleton) => {
    switch showSkeleton {
    | true => <SkeletonLoader setShowSkeleton />
    | false => <ReconOverviewContent />
    }
  }
}
