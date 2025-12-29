@react.component
let make = () => {
  open InsightsContainerUtils
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let {newAnalyticsSmartRetries, newAnalyticsRefunds} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {updateExistingKeys, updateFilterAsync} = React.useContext(FilterContext.filterContext)
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {resolvedUserInfo: {analyticsEntity}, checkUserEntity} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
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
      let body = InsightsUtils.requestBody(
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
          <InsightsPaymentAnalytics />
        </div>,
    },
  ]

  if newAnalyticsSmartRetries {
    tabs->Array.push({
      title: "Smart Retries",
      renderContent: () => <InsightsSmartRetryAnalytics />,
    })
  }

  if newAnalyticsRefunds {
    tabs->Array.push({
      title: "Refunds",
      renderContent: () => <InsightsRefundsAnalytics />,
    })
  }

  let applySampleDateFilters = async isSampleDateEnabled => {
    try {
      setScreenState(_ => Loading)
      let sampleDateRange: HSwitchRemoteFilter.filterBody = {
        start_time: "2024-09-04T00:00:00.000Z",
        end_time: "2024-10-03T00:00:00.000Z",
      }
      let values = InsightsUtils.getSampleDateRange(
        ~useSampleDates=isSampleDateEnabled,
        ~sampleDateRange,
      )
      values->Dict.set(sampleDataKey, isSampleDateEnabled->getStringFromBool)
      let _ = await updateFilterAsync(~delay=1000, values)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  <PageLoaderWrapper key={(analyticsEntity :> string)} screenState>
    <div>
      <InsightsHelper.SampleDataBanner applySampleDateFilters />
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
            ~sampleDataIsEnabled=isSampleDataEnabled,
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
          disabled=isSampleDataEnabled
          disabledDisplayName="Hyperswitch_test"
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
