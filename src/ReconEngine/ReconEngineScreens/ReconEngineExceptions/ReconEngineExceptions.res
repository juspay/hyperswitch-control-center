open Typography
open ReconEngineTypes
open ReconEngineExceptionsStatusUtils

module Shell = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineFilterUtils

    let url = RescriptReactRouter.useUrl()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let getTransactions = ReconEngineHooks.useGetTransactions()
    let getURL = APIUtils.useGetURL()
    let fetchDetails = APIUtils.useGetMethod()

    let {
      filterValueJson,
      filterValue,
      updateExistingKeys,
      filterKeys,
      setfilterKeys,
    } = React.useContext(FilterContext.filterContext)

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (accounts, setAccounts) = React.useState(_ => [])
    let (rules, setRules) = React.useState(_ => [])
    let (exceptions, setExceptions) = React.useState(_ => [])
    let (smartView, setSmartView) = React.useState(_ => AllOpen)
    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (hasNoRules, setHasNoRules) = React.useState(_ => false)

    /* Selection is URL-driven so deep links work (?id=<txn_id>). */
    let urlSearchDict = url.search->getDictFromUrlSearchParams
    let selectedTransactionId = urlSearchDict->getOptionValFromDict("id")

    let setSelectedException = (txnIdOpt: option<string>) => {
      let basePath = GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/recon")
      let nextUrl = switch txnIdOpt {
      | Some(txnId) => `${basePath}?id=${txnId}`
      | None => basePath
      }
      RescriptReactRouter.push(nextUrl)
    }

    let onSmartViewChange = (view: smartView) => {
      setSmartView(_ => view)
      let statusCsv =
        view
        ->smartViewStatuses
        ->getTransactionStatusValueFromStatusList
        ->Array.joinWith(",")
      updateExistingKeys(Dict.fromArray([("status", `[${statusCsv}]`)]))
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
      ~range=180,
      ~origin="recon_engine_exception_transaction",
      (),
    )

    let loadAccounts = async () => {
      try {
        let result = await getAccounts()
        setAccounts(_ => result)
      } catch {
      | _ => ()
      }
    }

    let loadRules = async () => {
      try {
        let rulesUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#RECON_RULES,
          ~methodType=Get,
        )
        let res = await fetchDetails(rulesUrl)
        let ruleDetails = res->getArrayDataFromJson(ReconEngineRulesUtils.ruleItemToObjMapper)
        setRules(_ => ruleDetails)
        setHasNoRules(_ => ruleDetails->Array.length === 0)
      } catch {
      | _ => ()
      }
    }

    let fetchExceptions = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let enhanced = Dict.copy(filterValueJson)
        let rawStatus = filterValueJson->getArrayFromDict("status", [])

        /* Smart view's status set wins when the user hasn't picked anything. */
        let effectiveStatus = if rawStatus->Array.length === 0 {
          smartView
          ->smartViewStatuses
          ->getTransactionStatusValueFromStatusList
          ->getJsonFromArrayOfString
        } else {
          rawStatus
          ->Array.map(v => v->getStringFromJson(""))
          ->getJsonFromArrayOfString
        }
        enhanced->Dict.set("status", effectiveStatus)

        /* source/target accounts and rule are also accepted by the backend as repeated
         query params but we filter client-side once for a single fetch. */
        enhanced->Dict.set("source_account", JSON.Encode.array([]))
        enhanced->Dict.set("target_account", JSON.Encode.array([]))
        enhanced->Dict.set("rule_id", JSON.Encode.array([]))

        let query = buildQueryStringFromFilters(~filterValueJson=enhanced)
        let result = await getTransactions(~queryParameters=Some(query))

        let sorted = result->Array.toSorted((a, b) => {
          compareLogic(b.created_at, a.created_at)
        })

        setExceptions(_ => sorted)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load exceptions"))
      }
    }

    /* On mount: import any legacy `?status=`/`?rule_id=` deep links from Overview into
     the FilterContext so the screen lands on the correct preset. */
    React.useEffect0(() => {
      let urlSearch = url.search
      if urlSearch->isNonEmptyString {
        let urlParams = urlSearch->getDictFromUrlSearchParams
        let filtersToApply = Dict.make()
        let additionalKeys = []

        urlParams->getMappedValueFromDict("status", (), value => {
          let formattedValue = value->String.includes(",") ? `[${value}]` : value
          filtersToApply->Dict.set("status", formattedValue)
          additionalKeys->Array.push("status")
        })
        urlParams->getMappedValueFromDict("rule_id", (), value => {
          let formattedValue = value->String.includes(",") ? `[${value}]` : `[${value}]`
          filtersToApply->Dict.set("rule_id", formattedValue)
          additionalKeys->Array.push("rule_id")
        })

        if !(filtersToApply->isEmptyDict) {
          updateExistingKeys(filtersToApply)
          additionalKeys->Array.forEach(key => {
            if !(filterKeys->Array.includes(key)) {
              setfilterKeys(prev => prev->Array.concat([key]))
            }
          })
        }
      }
      setInitialFilters()
      loadAccounts()->ignore
      loadRules()->ignore
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchExceptions()->ignore
      }
      None
    }, (filterValue, smartView))

    /* Apply client-side search + chip + stale-view filters once data is loaded. */
    let visibleExceptions = React.useMemo(() => {
      let sourceFilter =
        filterValueJson
        ->getArrayFromDict("source_account", [])
        ->Array.map(j => j->getStringFromJson(""))
      let targetFilter =
        filterValueJson
        ->getArrayFromDict("target_account", [])
        ->Array.map(j => j->getStringFromJson(""))
      let ruleFilter =
        filterValueJson
        ->getArrayFromDict("rule_id", [])
        ->Array.map(j => j->getStringFromJson(""))

      exceptions->Array.filter(txn => {
        let matchesSearch =
          searchText->isEmptyString ||
          isContainingStringLowercase(txn.transaction_id, searchText) ||
          txn.entries->Array.some(e => isContainingStringLowercase(e.order_id, searchText))
        let touchesSource =
          sourceFilter->Array.length === 0 ||
            txn.entries->Array.some(
              e => e.entry_type === Credit && sourceFilter->Array.includes(e.account.account_id),
            )
        let touchesTarget =
          targetFilter->Array.length === 0 ||
            txn.entries->Array.some(
              e => e.entry_type === Debit && targetFilter->Array.includes(e.account.account_id),
            )
        let matchesRule =
          ruleFilter->Array.length === 0 || ruleFilter->Array.includes(txn.rule.rule_id)
        let staleEnough = !(smartView->isStaleView) || ageInDays(txn.created_at) > 7.0
        matchesSearch && touchesSource && touchesTarget && matchesRule && staleEnough
      })
    }, (exceptions, searchText, filterValueJson, smartView))

    let activeException = React.useMemo(() => {
      switch selectedTransactionId {
      | Some(id) => exceptions->Array.find(t => t.transaction_id === id)
      | None => visibleExceptions->Array.get(0)
      }
    }, (selectedTransactionId, exceptions, visibleExceptions))

    let viewCounts = React.useMemo(() => {
      exceptions->countByView
    }, [exceptions])

    let visibleCount = visibleExceptions->Array.length
    let totalCount = exceptions->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Recon Exceptions"->React.string}
          </p>
          <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
            {`· ${visibleCount->Int.toString} of ${totalCount->Int.toString}`->React.string}
          </span>
        </div>
        <div className="flex flex-row gap-2 items-center">
          <Button
            text="Export"
            leftIcon={CustomIcon(<Icon name="nd-download-down" size=14 />)}
            buttonType=Secondary
            buttonSize=Small
            onClick={_ => ()}
          />
          <Button
            text="Generate Report"
            buttonType=Primary
            buttonSize=Small
            buttonState=Disabled
            onClick={_ =>
              mixpanelEvent(~eventName="recon_engine_exceptions_generate_reports_clicked")}
          />
        </div>
      </div>

    if hasNoRules {
      <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
        {header}
        <div className="flex-1 flex flex-col items-center justify-center gap-3">
          <div className="w-14 h-14 rounded-full bg-nd_gray-50 grid place-items-center">
            <Icon name="nd-alert-circle" size=28 customIconColor="#A1A8B8" />
          </div>
          <p className={`${heading.sm.semibold} text-nd_gray-700`}>
            {"No recon rules configured"->React.string}
          </p>
          <p className={`${body.md.medium} text-nd_gray-500 max-w-md text-center`}>
            {"Create a rule from the Rules Library before exceptions can appear here."->React.string}
          </p>
        </div>
      </div>
    } else {
      <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
        {header}
        <ReconEngineExceptionsSmartViewsRail
          activeView={smartView} onChange={onSmartViewChange} counts={viewCounts}
        />
        <div className="flex flex-row flex-1 min-h-0">
          <ReconEngineExceptionsListPane
            screenState
            exceptions={visibleExceptions}
            rules
            accounts
            activeTransactionId={activeException->Option.map(t => t.transaction_id)}
            onSelect={txn => setSelectedException(Some(txn.transaction_id))}
            selectedRows
            setSelectedRows
            searchText
            setSearchText
            filterKeys
            updateExistingKeys
          />
          <ReconEngineExceptionsDetailPane
            activeException onClearSelection={_ => setSelectedException(None)}
          />
        </div>
        <RenderIf condition={selectedRows->Array.length > 0}>
          <ReconEngineTransactionsBulkActions
            selectedRows
            setSelectedRows
            showVoidButton=true
            refreshList={() => fetchExceptions()->ignore}
          />
        </RenderIf>
      </div>
    }
  }
}

@react.component
let make = () => {
  <FilterContext key="recon-engine-exceptions" index="recon-engine-exceptions">
    <Shell />
  </FilterContext>
}
