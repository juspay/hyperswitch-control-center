@react.component
let make = () => {
  open NewAnalyticsContainerUtils
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let {newAnalyticsSmartRetries, newAnalyticsRefunds} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let isSampleDataEnabled =
    filterValueJson->getString(sampleDataKey, "false")->LogicUtils.getBoolFromString(false)
  let {userInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let tempRecallAmountMetrics = async () => {
    try {
      //Currency Conversion is failing in Backend for the first time so to fix that we are the calling the api for one time and ignoring the error
      setScreenState(_ => Loading)
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
        ~methodType=Post,
        ~id=Some("payments"),
      )
      let date = (Date.make()->Date.toString->DayJs.getDayJsForString).format(
        "YYYY-MM-DDTHH:mm:00[Z]",
      )
      let body = NewAnalyticsUtils.requestBody(
        ~startTime=date,
        ~endTime=date,
        ~metrics=[#sessionized_payment_processed_amount],
        ~filter=None,
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
    ~isInsightsPage=true,
    ~enableCompareTo=Some(true),
    ~range=6,
    ~comparisonKey,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  //This is to trigger the mixpanel event to see active analytics users
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      mixpanelEvent(~eventName="new_analytics_payment_date_filter")
    }
    None
  }, (startTimeVal, endTimeVal))
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="new_analytics_payment_date_filter_opened")
  }
  let tabs: array<Tabs.tab> = [
    {
      title: "Payments",
      renderContent: () =>
        <div className="mt-5">
          <NewPaymentAnalytics />
        </div>,
    },
  ]

  if newAnalyticsSmartRetries {
    tabs->Array.push({
      title: "Smart Retries",
      renderContent: () => <NewSmartRetryAnalytics />,
    })
  }

  if newAnalyticsRefunds {
    tabs->Array.push({
      title: "Refunds",
      renderContent: () => <NewRefundsAnalytics />,
    })
  }

  <PageLoaderWrapper key={(analyticsEntity :> string)} screenState>
    <div>
      <NewAnalyticsHelper.SampleDataBanner />
      <PageUtils.PageHeading customTitleStyle="mt-4" title="Insights" />
      <div className="-ml-1 top-0 z-20 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
        <DynamicFilter
          title="NewAnalytics"
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={initialFixedFilterFields(
            ~compareWithStartTime=startTimeVal,
            ~compareWithEndTime=endTimeVal,
            ~events=dateDropDownTriggerMixpanelCallback,
            ~sampleDataIsEnabled=filterValueJson
            ->getString(sampleDataKey, "false")
            ->getBoolFromString(false),
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
      <Portal to="NewAnalyticsOMPView">
        <OMPSwitchHelper.OMPViews
          views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
          selectedEntity={analyticsEntity}
          onChange={updateAnalytcisEntity}
          entityMapper=UserInfoUtils.analyticsEntityMapper
        />
      </Portal>
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
