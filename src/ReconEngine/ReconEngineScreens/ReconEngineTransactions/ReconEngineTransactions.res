open Typography
open ReconEngineTypes
open ReconEngineTransactionsStatusUtils

module Shell = {
  @react.component
  let make = () => {
    open LogicUtils
    open ReconEngineFilterUtils

    let url = RescriptReactRouter.useUrl()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let getTransactions = ReconEngineHooks.useGetTransactions()

    let {filterValueJson, filterValue, updateExistingKeys, filterKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
    let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

    let (accounts, setAccounts) = React.useState(_ => [])
    let (transactions, setTransactions) = React.useState(_ => [])
    let (smartView, setSmartView) = React.useState(_ => AllTransactions)
    let (selectedRows, setSelectedRows) = React.useState(_ => [])
    let (searchText, setSearchText) = React.useState(_ => "")
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    /* Selection is URL-driven so deep links work (?id=<txn_id>). */
    let urlSearchDict = url.search->getDictFromUrlSearchParams
    let selectedTransactionId = urlSearchDict->getOptionValFromDict("id")

    let setSelectedTransaction = (txnIdOpt: option<string>) => {
      let basePath = GlobalVars.appendDashboardPath(~url="/v1/recon-engine/transactions")
      let nextUrl = switch txnIdOpt {
      | Some(txnId) => `${basePath}?id=${txnId}`
      | None => basePath
      }
      RescriptReactRouter.push(nextUrl)
    }

    let onSmartViewChange = (view: smartView) => {
      setSmartView(_ => view)
      /* Push the view's statuses into the FilterContext so the rest of the UI re-fetches.
         UrlFetchUtils.getFilterValue expects the [v1,v2,...] shape (unquoted), so we
         build that directly instead of JSON.stringify-ing an array of JSON strings. */
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
      ~origin="recon_engine_transactions",
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

    let fetchTransactions = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let enhanced = Dict.copy(filterValueJson)
        let rawStatus = filterValueJson->getArrayFromDict("status", [])
        let mergedStatus = getMergedMatchedTransactionStatusFilter(rawStatus)

        /* If the user hasn't picked statuses, fall back to the smart view's status set. */
        let effectiveStatus = if mergedStatus->Array.length === 0 {
          smartView
          ->smartViewStatuses
          ->getTransactionStatusValueFromStatusList
          ->getJsonFromArrayOfString
        } else {
          mergedStatus
          ->Array.map(v => v->getStringFromJson(""))
          ->getJsonFromArrayOfString
        }
        enhanced->Dict.set("status", effectiveStatus)

        /* Strip out the account chip values; we filter accounts client-side so a single
         fetch suffices regardless of how many accounts are picked. */
        enhanced->Dict.set("source_account", JSON.Encode.array([]))
        enhanced->Dict.set("target_account", JSON.Encode.array([]))

        let query = buildQueryStringFromFilters(~filterValueJson=enhanced)
        let result = await getTransactions(~queryParameters=Some(query))

        let sorted = result->Array.toSorted((a, b) => {
          let byCreated = compareLogic(b.created_at, a.created_at)
          if byCreated !== 0. {
            byCreated
          } else {
            compareLogic(b.effective_at, a.effective_at)
          }
        })

        setTransactions(_ => sorted)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load transactions"))
      }
    }

    React.useEffect0(() => {
      setInitialFilters()
      loadAccounts()->ignore
      None
    })

    React.useEffect(() => {
      if !(filterValue->isEmptyDict) {
        fetchTransactions()->ignore
      }
      None
    }, (filterValue, smartView))

    /* Apply client-side search + account-chip + stale-view filters. */
    let visibleTransactions = React.useMemo(() => {
      let sourceFilter =
        filterValueJson
        ->getArrayFromDict("source_account", [])
        ->Array.map(j => j->getStringFromJson(""))
      let targetFilter =
        filterValueJson
        ->getArrayFromDict("target_account", [])
        ->Array.map(j => j->getStringFromJson(""))

      transactions->Array.filter(txn => {
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
        let staleEnough = !(smartView->isStaleView) || ageInDays(txn.created_at) > 7.0
        matchesSearch && touchesSource && touchesTarget && staleEnough
      })
    }, (transactions, searchText, filterValueJson, smartView))

    let activeTransaction = React.useMemo(() => {
      switch selectedTransactionId {
      | Some(id) => transactions->Array.find(t => t.transaction_id === id)
      | None => visibleTransactions->Array.get(0)
      }
    }, (selectedTransactionId, transactions, visibleTransactions))

    let viewCounts = React.useMemo(() => {
      transactions->countByStatusKind
    }, [transactions])

    let visibleCount = visibleTransactions->Array.length
    let totalCount = transactions->Array.length

    let header =
      <div
        className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {"Transactions"->React.string}
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
            onClick={_ => mixpanelEvent(~eventName="recon_engine_transactions_export_clicked")}
          />
          <Button
            text="Generate Report"
            buttonType=Primary
            buttonSize=Small
            buttonState=Disabled
            onClick={_ =>
              mixpanelEvent(~eventName="recon_engine_transactions_generate_reports_clicked")}
          />
        </div>
      </div>

    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      {header}
      <ReconEngineTransactionsSmartViewsRail
        activeView={smartView} onChange={onSmartViewChange} counts={viewCounts}
      />
      <div className="flex flex-row flex-1 min-h-0">
        <ReconEngineTransactionsListPane
          screenState
          transactions={visibleTransactions}
          accounts
          activeTransactionId={activeTransaction->Option.map(t => t.transaction_id)}
          onSelect={txn => setSelectedTransaction(Some(txn.transaction_id))}
          selectedRows
          setSelectedRows
          searchText
          setSearchText
          filterKeys
          updateExistingKeys
        />
        <ReconEngineTransactionsDetailPane
          accounts activeTransaction onClearSelection={_ => setSelectedTransaction(None)}
        />
      </div>
      <RenderIf condition={selectedRows->Array.length > 0}>
        <ReconEngineTransactionsBulkActions
          selectedRows
          setSelectedRows
          showPostButton=true
          refreshList={() => fetchTransactions()->ignore}
        />
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  <FilterContext key="recon-engine-transactions" index="recon-engine-transactions">
    <Shell />
  </FilterContext>
}
