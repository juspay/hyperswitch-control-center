open Typography
open ReconEngineTypes

module Shell = {
  @react.component
  let make = () => {
    open APIUtils
    open LogicUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let getTransactions = ReconEngineHooks.useGetTransactions()
    let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()
    let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (rules, setRules) = React.useState(_ => [])
    let (accounts, setAccounts) = React.useState(_ => [])
    let (transactions, setTransactions) = React.useState(_ => [])
    let (ingestions, setIngestions) = React.useState(_ => [])
    let (transformations, setTransformations) = React.useState(_ => [])

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=180,
      ~origin="recon_engine_overview",
      (),
    )

    /* Status set for the headline transactions fetch — same set the old overview
     used so the KPI denominators stay comparable to historic numbers. */
    let statusQuery = {
      let statuses: array<domainTransactionStatus> = [
        Posted(Manual),
        Matched(Auto),
        Matched(Manual),
        Matched(Force),
        Expected,
        Missing,
        PartiallyReconciled,
        OverAmount(Mismatch),
        OverAmount(Expected),
        UnderAmount(Mismatch),
        UnderAmount(Expected),
        DataMismatch,
      ]
      let csv =
        statuses
        ->ReconEngineFilterUtils.getTransactionStatusValueFromStatusList
        ->Array.filter(s => s !== "")
        ->Array.joinWith(",")
      `status=${csv}`
    }

    let fetchAll = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let rulesUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#RECON_RULES,
          ~methodType=Get,
        )

        let dateQuery = ReconEngineFilterUtils.buildQueryStringFromFilters(~filterValueJson)
        let txQuery = dateQuery === "" ? statusQuery : `${dateQuery}&${statusQuery}`
        let dateOpt = dateQuery === "" ? None : Some(dateQuery)

        /* Kick off all five requests in parallel; each updates its own slice of
         state as it lands so the page progressively reveals. */
        let rulesP = async () => {
          try {
            let res = await fetchDetails(rulesUrl)
            setRules(_ => res->getArrayDataFromJson(ReconEngineRulesUtils.ruleItemToObjMapper))
          } catch {
          | _ => ()
          }
        }
        let accountsP = async () => {
          try {
            let res = await getAccounts()
            setAccounts(_ => res)
          } catch {
          | _ => ()
          }
        }
        let txP = async () => {
          let res = await getTransactions(~queryParameters=Some(txQuery))
          setTransactions(_ => res)
        }
        let ingP = async () => {
          try {
            let res = await getIngestionHistory(~queryParameters=dateOpt)
            setIngestions(_ => res)
          } catch {
          | _ => ()
          }
        }
        let trP = async () => {
          try {
            let res = await getTransformationHistory(~queryParameters=dateOpt)
            setTransformations(_ => res)
          } catch {
          | _ => ()
          }
        }

        let _ = await Promise.all([rulesP(), accountsP(), txP(), ingP(), trP()])
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load overview"))
      }
    }

    React.useEffect0(() => {
      setInitialFilters()
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchAll()->ignore
      }
      None
    }, [filterValue])

    let dateDropDownTriggerMixpanelCallback = () =>
      mixpanelEvent(~eventName="recon_engine_overview_date_filter_opened")

    let totalTxnCount = transactions->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0 border-b border-nd_gray-100">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Recon overview"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${totalTxnCount->Int.toString} transaction${totalTxnCount === 1
                ? ""
                : "s"} in window`->React.string}
          </span>
        </div>
        <div className="flex flex-row items-center gap-2">
          <DynamicFilter
            title="ReconEngineOverviewRevampFilters"
            initialFilters=[]
            options=[]
            popupFilterFields=[]
            initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
              null,
              ~events=dateDropDownTriggerMixpanelCallback,
            )}
            defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
            tabNames=filterKeys
            key="ReconEngineOverviewRevampFilters"
            updateUrlWith=updateExistingKeys
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
            setOffset={_ => ()}
          />
        </div>
      </div>

    let body =
      <div className="flex flex-row flex-1 min-h-0">
        <div className="flex-1 min-w-0 overflow-y-auto pb-8">
          <div className="flex flex-col gap-6">
            <ReconEngineOverviewKpiStrip transactions />
            <ReconEngineOverviewPipeline ingestions transformations transactions />
            <ReconEngineOverviewRulePerformance rules accounts transactions />
            <ReconEngineOverviewAccountHealth accounts />
          </div>
        </div>
        <ReconEngineOverviewActivityRail />
      </div>

    <div
      className="absolute left-0 min-w-full max-w-full flex flex-col h-[calc(100vh-4rem)] bg-nd_gray-25">
      {header}
      <PageLoaderWrapper screenState> {body} </PageLoaderWrapper>
    </div>
  }
}

@react.component
let make = () => {
  <FilterContext key="recon-engine-overview-revamp" index="recon-engine-overview-revamp">
    <Shell />
  </FilterContext>
}
