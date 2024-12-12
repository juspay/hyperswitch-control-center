@react.component
let make = () => {
  open NewAnalyticsContainerUtils
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let {newAnalyticsSmartRetries} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let tempRecallAmountMetrics = async () => {
    try {
      //Currency Conversion is failing in Backend for the first time so to fix that we are the calling the api for one time and ignoring the error
      setScreenState(_ => Loading)
      let url = getURL(~entityName=ANALYTICS_PAYMENTS_V2, ~methodType=Post, ~id=Some("payments"))
      let date = (Date.make()->Date.toString->DayJs.getDayJsForString).format(
        "YYYY-MM-DDTHH:mm:00[Z]",
      )
      let body = NewAnalyticsUtils.requestBody(
        ~startTime=date,
        ~endTime=date,
        ~metrics=[#sessionized_payment_processed_amount],
      )
      let _ = await updateDetails(url, body, Post)
      setScreenState(_ => Success)
    } catch {
    | _ =>
      // Ignore the error
      setScreenState(_ => Success)
    }
  }
  React.useEffect(() => {
    tempRecallAmountMetrics()->ignore
    None
  }, [])

  React.useEffect(() => {
    let url = (getPageFromIndex(tabIndex) :> string)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
    None
  }, [tabIndex])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~compareToStartTimeKey,
    ~compareToEndTimeKey,
    ~origin="analytics",
    ~enableCompareTo=Some(true),
    ~range=6,
    ~comparisonKey,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  let defaultTabs: array<Tabs.tab> = [
    {
      title: "Payments",
      renderContent: () =>
        <div className="mt-5">
          <NewRefundsAnalytics />
        </div>,
    },
  ]

  let tabs = if newAnalyticsSmartRetries {
    defaultTabs->Array.concat([
      {
        title: "Smart Retries",
        renderContent: () => <NewSmartRetryAnalytics />,
      },
    ])
  } else {
    defaultTabs
  }

  <PageLoaderWrapper screenState>
    <div>
      <PageUtils.PageHeading title="Insights" />
      <div
        className="-ml-1 sticky top-0 z-30 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
        <DynamicFilter
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={initialFixedFilterFields(
            ~compareWithStartTime=startTimeVal,
            ~compareWithEndTime=endTimeVal,
          )}
          defaultFilterKeys=[
            startTimeFilterKey,
            endTimeFilterKey,
            compareToStartTimeKey,
            compareToEndTimeKey,
            comparisonKey,
          ]
          tabNames=[]
          key="0"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
      <Tabs
        initialIndex={url->getPageIndex}
        tabs
        onTitleClick={tabId => setTabIndex(_ => tabId)}
        disableIndicationArrow=true
        showBorder=true
        includeMargin=false
        lightThemeColor="black"
        defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
        textStyle="text-blue-600"
        selectTabBottomBorderColor="bg-blue-600"
      />
    </div>
  </PageLoaderWrapper>
}
