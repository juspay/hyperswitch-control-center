open Typography
open ReconEngineTypes
open ReconEngineTransactionsStatusUtils

module Hero = {
  @react.component
  let make = (~txn: transactionType) => {
    let status = txn.transaction_status
    let variance = (txn.credit_amount.value -. txn.debit_amount.value)->Js.Math.abs_float
    let currency = txn.credit_amount.currency
    let isArchived = status === Archived

    <div className="w-full border border-nd_gray-150 rounded-xl bg-white p-6 relative">
      <RenderIf condition={isArchived}>
        <span
          className={`absolute top-0 right-0 ${body.sm.semibold} bg-nd_gray-50 text-nd_gray-600 px-3 py-1.5 rounded-bl-xl rounded-tr-xl`}>
          {"Archived"->React.string}
        </span>
      </RenderIf>
      <div className="flex flex-row items-start justify-between gap-6 flex-wrap">
        <div className="flex flex-col gap-3 min-w-0">
          <div className="flex flex-row items-center gap-3">
            <TagBinding
              text={status->getStatusLabel} color={status->getTagColor} variant=Attentive size=Md
            />
            <span className={`${body.sm.medium} text-nd_gray-500`}>
              {`Created ${txn.created_at->formatRelativeTime} ago`->React.string}
            </span>
          </div>
          <div className="flex flex-row items-baseline gap-4 flex-wrap">
            <span className={`${heading.xl.semibold} text-nd_gray-800 tabular-nums`}>
              {`${currency} ${txn.credit_amount.value->Float.toString}`->React.string}
            </span>
            <span className={`${body.md.medium} text-nd_gray-400`}> {"▶"->React.string} </span>
            <span className={`${heading.xl.semibold} text-nd_gray-800 tabular-nums`}>
              {`${currency} ${txn.debit_amount.value->Float.toString}`->React.string}
            </span>
            <RenderIf condition={variance > 0.001}>
              <span
                className={`${body.md.semibold} px-2.5 py-1 rounded-md bg-nd_red-50 text-nd_red-600 tabular-nums`}>
                {`±${currency} ${variance->Float.toString}`->React.string}
              </span>
            </RenderIf>
          </div>
          <p className={`${body.md.medium} text-nd_gray-500 max-w-2xl`}>
            {status->getStatusDescription->React.string}
          </p>
        </div>
        <div className="grid grid-cols-2 gap-x-8 gap-y-3 min-w-0">
          <div className="flex flex-col gap-1">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
              {"Transaction ID"->React.string}
            </span>
            <HelperComponents.CopyTextCustomComp
              customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono`}
              displayValue=Some(txn.transaction_id)
            />
          </div>
          <div className="flex flex-col gap-1">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
              {"Rule"->React.string}
            </span>
            <HSwitchOrderUtils.CopyLinkTableCell
              displayValue={txn.rule.rule_name}
              url={GlobalVars.appendDashboardPath(
                ~url=`/v1/recon-engine/rules/${txn.rule.rule_id}`,
              )}
              copyValue={Some(txn.rule.rule_id)}
              customTextCss={`${body.sm.medium} text-nd_gray-700`}
            />
          </div>
          <div className="flex flex-col gap-1">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
              {"Version"->React.string}
            </span>
            <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
              {`v${txn.version->Int.toString}`->React.string}
            </span>
          </div>
          <div className="flex flex-col gap-1">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
              {"Effective"->React.string}
            </span>
            <span className={`${body.sm.medium} text-nd_gray-700`}>
              {txn.effective_at->formatRelativeTime->React.string}
            </span>
          </div>
        </div>
      </div>
      <RenderIf condition={txn.linked_transaction->Option.isSome}>
        {switch txn.linked_transaction {
        | Some(linked) =>
          <div
            className="mt-5 flex flex-row items-center justify-between gap-3 p-3 rounded-lg bg-nd_primary_blue-50/40 border border-nd_primary_blue-100">
            <div className="flex flex-col gap-1 min-w-0">
              <span
                className={`${body.xs.semibold} text-nd_primary_blue-600 uppercase tracking-wide`}>
                {"Matched with"->React.string}
              </span>
              <HelperComponents.CopyTextCustomComp
                customTextCss={`${body.sm.semibold} text-nd_gray-800 font-mono truncate`}
                displayValue=Some(linked.transaction_id)
              />
            </div>
            <div className="flex flex-row items-center gap-2 flex-shrink-0">
              <TagBinding
                text={linked.transaction_status->getStatusLabel}
                color={linked.transaction_status->getTagColor}
                variant=Subtle
                size=Sm
              />
              <a
                className={`${body.sm.semibold} text-nd_primary_blue-600 hover:underline`}
                href={GlobalVars.appendDashboardPath(
                  ~url=`/v1/recon-engine/transactions/${linked.transaction_id}`,
                )}>
                {"Open →"->React.string}
              </a>
            </div>
          </div>
        | None => React.null
        }}
      </RenderIf>
    </div>
  }
}

module EntryRow = {
  @react.component
  let make = (~entry: entryType) => {
    open LogicUtils
    let (expanded, setExpanded) = React.useState(_ => false)
    let isDebit = (entry.entry_type :> string)->String.toLowerCase === "debit"
    let metadata = entry.metadata->ReconEngineTransactionsUtils.getFilteredMetadataFromEntries
    let hasMetadata = !(metadata->isEmptyDict)

    <div className="border-t border-nd_gray-100 first:border-t-0">
      <div className="flex flex-row items-center gap-3 px-4 py-3">
        <div
          className={`w-1.5 h-9 rounded-full ${isDebit
              ? "bg-nd_red-300"
              : "bg-nd_green-400"} flex-shrink-0`}
        />
        <div className="flex-1 flex flex-col gap-0.5 min-w-0">
          <div className="flex flex-row items-center gap-2">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
              {(isDebit ? "Debit" : "Credit")->React.string}
            </span>
            <span className={`${body.xs.medium} text-nd_gray-300`}> {"·"->React.string} </span>
            <span className={`${body.xs.medium} text-nd_gray-500 font-mono truncate`}>
              {entry.entry_id->React.string}
            </span>
          </div>
          <span className={`${body.sm.medium} text-nd_gray-700 truncate font-mono`}>
            {(entry.order_id->isNonEmptyString ? entry.order_id : "—")->React.string}
          </span>
        </div>
        <div className="flex flex-col items-end gap-1 flex-shrink-0">
          <span className={`${body.md.semibold} text-nd_gray-800 tabular-nums`}>
            {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
          </span>
          <TagBinding
            text={switch entry.discarded_status {
            | Some(status) => (status :> string)
            | None => (entry.status :> string)
            }}
            color=Neutral
            variant=Subtle
            size=Xs
          />
        </div>
        <div className="flex flex-row items-center gap-2 flex-shrink-0 pl-2">
          <RenderIf condition={hasMetadata}>
            <button
              onClick={_ => setExpanded(prev => !prev)}
              className="p-1.5 rounded-md hover:bg-nd_gray-100"
              title="Show metadata">
              <div
                className={`transition-transform duration-200 ${expanded
                    ? "rotate-180"
                    : "rotate-0"}`}>
                <Icon name="nd-chevron-down" size={20} customIconColor="#536387" />
              </div>
            </button>
          </RenderIf>
          <ReconEngineTransactionEntriesActions entry />
        </div>
      </div>
      <div
        className={`
          overflow-hidden transition-all duration-300 ease-in-out
          ${expanded && hasMetadata ? "max-h-96 opacity-100" : "max-h-0 opacity-0"}
        `}>
        <div className="px-4 pb-4">
          <div className="bg-nd_gray-50 rounded-lg px-4 py-3 max-h-60 overflow-y-auto">
            <PrettyPrintJson jsonToDisplay={metadata->JSON.Encode.object->JSON.stringify} />
          </div>
        </div>
      </div>
    </div>
  }
}

module EntriesSection = {
  @react.component
  let make = (~entries: array<entryType>) => {
    let grouped = React.useMemo(() => {
      let dict = Dict.make()
      entries->Array.forEach(entry => {
        let key = entry.account_id
        let bucket = dict->Dict.get(key)->Option.getOr([])
        dict->Dict.set(key, Array.concat(bucket, [entry]))
      })
      dict->Dict.toArray
    }, [entries])

    <section className="flex flex-col gap-5">
      <div className="flex flex-row items-center justify-between">
        <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Entries"->React.string} </p>
        <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
          {`${entries->Array.length->Int.toString} total · ${grouped
            ->Array.length
            ->Int.toString} accounts`->React.string}
        </span>
      </div>
      {grouped->Array.length === 0
        ? <div className="text-nd_gray-400 text-center py-10 border border-nd_gray-150 rounded-xl">
            {"No entries to show"->React.string}
          </div>
        : <div className="flex flex-col gap-4">
            {grouped
            ->Array.map(((accountId, list)) => {
              let accountName =
                list
                ->Array.get(0)
                ->Option.map(e => e.account_name)
                ->Option.getOr(accountId)
              <div
                key={accountId}
                className="border border-nd_gray-150 rounded-xl bg-white overflow-hidden">
                <div
                  className="px-4 py-3 border-b border-nd_gray-100 bg-nd_gray-25 flex flex-row items-center justify-between">
                  <p className={`${body.sm.semibold} text-nd_gray-700`}>
                    {accountName->React.string}
                  </p>
                  <span className={`${body.xs.medium} text-nd_gray-500`}>
                    {`${list->Array.length->Int.toString} entries`->React.string}
                  </span>
                </div>
                <div>
                  {list
                  ->Array.map(entry => <EntryRow key={entry.entry_id} entry />)
                  ->React.array}
                </div>
              </div>
            })
            ->React.array}
          </div>}
    </section>
  }
}

module AuditTimeline = {
  @react.component
  let make = (
    ~versions: array<transactionType>,
    ~selectedVersionNum: int,
    ~onSelectVersion: int => unit,
  ) => {
    open LogicUtils
    let sorted = React.useMemo(() => {
      let copy = versions->Array.copy
      copy->Array.sort((a, b) => compareLogic(b.version, a.version))
      copy
    }, [versions])

    <section className="flex flex-col gap-4">
      <div className="flex flex-col gap-1">
        <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Audit Trail"->React.string} </p>
        <p className={`${body.sm.medium} text-nd_gray-400`}>
          {"Click a version to view its entries below."->React.string}
        </p>
      </div>
      <div className="flex flex-col">
        {sorted
        ->Array.mapWithIndex((version, idx) => {
          let isLast = idx === sorted->Array.length - 1
          let isSelected = version.version === selectedVersionNum
          let status = version.transaction_status
          let reason = version.data.reason->Option.getOr("")
          let dotClass = switch status->getStatusKind {
          | MatchedKind => "bg-nd_green-500"
          | MismatchKind => "bg-nd_red-500"
          | AwaitingKind => "bg-nd_primary_blue-500"
          | PartialKind => "bg-nd_orange-400"
          | InactiveKind => "bg-nd_gray-300"
          }
          let nodeClass = isSelected
            ? "bg-nd_primary_blue-50 -mx-2 px-2 rounded-md ring-1 ring-nd_primary_blue-200"
            : "hover:bg-nd_gray-50 -mx-2 px-2 rounded-md"
          <button
            key={version.version->Int.toString}
            type_="button"
            onClick={_ => onSelectVersion(version.version)}
            className={`flex flex-row gap-3 text-left ${nodeClass} py-1.5 transition-colors`}>
            <div className="flex flex-col items-center flex-shrink-0 pt-1.5">
              <div
                className={`w-2.5 h-2.5 rounded-full ${dotClass} ring-4 ring-white outline outline-1 ${isSelected
                    ? "outline-nd_primary_blue-400"
                    : "outline-nd_gray-150"}`}
              />
              <RenderIf condition={!isLast}>
                <div className="w-px flex-1 bg-nd_gray-150 mt-1" />
              </RenderIf>
            </div>
            <div className="flex flex-col gap-1.5 pb-3 flex-1 min-w-0">
              <div className="flex flex-row items-center gap-2">
                <span className={`${body.sm.semibold} text-nd_gray-700 tabular-nums`}>
                  {`v${version.version->Int.toString}`->React.string}
                </span>
                <TagBinding
                  text={status->getStatusLabel} color={status->getTagColor} variant=Subtle size=Xs
                />
                <RenderIf condition={isSelected}>
                  <span className={`${body.xs.semibold} text-nd_primary_blue-600`}>
                    {"· viewing"->React.string}
                  </span>
                </RenderIf>
              </div>
              <span className={`${body.xs.medium} text-nd_gray-500`}>
                {version.created_at->formatRelativeTime->React.string}
              </span>
              <RenderIf condition={reason->isNonEmptyString}>
                <p
                  className={`${body.xs.medium} text-nd_gray-600 bg-nd_gray-50 rounded-md px-2.5 py-2 leading-relaxed whitespace-normal`}>
                  {reason->React.string}
                </p>
              </RenderIf>
            </div>
          </button>
        })
        ->React.array}
      </div>
    </section>
  }
}

module VersionBanner = {
  @react.component
  let make = (~latestVersion: int, ~viewingVersion: int, ~onShowLatest: unit => unit) =>
    <div
      className="flex flex-row items-center justify-between gap-3 px-4 py-2.5 rounded-lg bg-nd_orange-50 border border-nd_orange-200">
      <div className="flex flex-row items-center gap-2 min-w-0">
        <Icon name="nd-alert-circle" size=16 customIconColor="#C77400" />
        <span className={`${body.sm.medium} text-nd_orange-700`}>
          {`Viewing version ${viewingVersion->Int.toString} (older). Latest is v${latestVersion->Int.toString}.`->React.string}
        </span>
      </div>
      <button
        type_="button"
        onClick={_ => onShowLatest()}
        className={`${body.sm.semibold} text-nd_orange-700 hover:underline flex-shrink-0`}>
        {"Show latest →"->React.string}
      </button>
    </div>
}

@react.component
let make = (~id) => {
  open LogicUtils
  open APIUtils
  open ReconEngineTransactionsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (allVersions, setAllVersions) = React.useState(_ => [])
  let (fetchedEntries, setFetchedEntries) = React.useState(_ => [])
  let (selectedVersionNum, setSelectedVersionNum) = React.useState(_ => -1)

  let load = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transactionVersions = await getTransactions(~queryParameters=Some(`transaction_id=${id}`))
      transactionVersions->Array.sort(sortByVersion)
      let current =
        transactionVersions->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)

      let entriesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_TRANSACTION,
        ~id=Some(current.transaction_id),
      )
      let entriesRes = await fetchDetails(entriesUrl)
      let entries = entriesRes->getArrayDataFromJson(transactionsEntryItemToObjMapperFromDict)

      let _accounts = await getAccounts()
      setAllVersions(_ => transactionVersions)
      setFetchedEntries(_ => entries)
      setSelectedVersionNum(_ => current.version)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
    }
  }

  React.useEffect0(() => {
    load()->ignore
    None
  })

  /* The lowest-version row is treated as "current" (matches existing fetch behavior).
     The user can rewind via the audit timeline; entries are re-derived from that version's
     snapshot, enriched with metadata from the global entries fetch. */
  let currentTransaction = React.useMemo(() => {
    allVersions->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
  }, [allVersions])

  let viewingTransaction = React.useMemo(() => {
    allVersions
    ->Array.find(v => v.version === selectedVersionNum)
    ->Option.getOr(currentTransaction)
  }, (allVersions, selectedVersionNum, currentTransaction))

  let viewingEntries = React.useMemo(() => {
    viewingTransaction.entries->Array.map(snapshot => {
      let found =
        fetchedEntries
        ->Array.find(e => snapshot.entry_id === e.entry_id)
        ->Option.getOr(Dict.make()->transactionsEntryItemToObjMapperFromDict)
      {...found, account_name: snapshot.account.account_name}
    })
  }, (viewingTransaction, fetchedEntries))

  let isViewingOlderVersion =
    allVersions->Array.length > 1 && selectedVersionNum !== currentTransaction.version

  <div className="absolute left-0 min-w-full max-w-full bg-nd_gray-25 min-h-[calc(100vh-4rem)]">
    <div className="flex flex-col gap-6 px-4 md:px-10 py-4">
      <div className="flex flex-col gap-3">
        <BreadCrumbNavigation
          path=[{title: "Transactions", link: "/v1/recon-engine/transactions"}] currentPageTitle=id
        />
        <PageUtils.PageHeading
          title="Transaction Detail"
          customTitleStyle={heading.lg.semibold}
          customHeadingStyle="py-0"
        />
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="This transaction does not exist in our records." renderType=NotFound
        />}>
        <div className="flex flex-col gap-6">
          <Hero txn={currentTransaction} />
          <div className="flex flex-col xl:flex-row gap-6 items-start">
            <div className="flex-1 min-w-0 w-full flex flex-col gap-4">
              <RenderIf condition={isViewingOlderVersion}>
                <VersionBanner
                  latestVersion={currentTransaction.version}
                  viewingVersion={selectedVersionNum}
                  onShowLatest={() => setSelectedVersionNum(_ => currentTransaction.version)}
                />
              </RenderIf>
              <EntriesSection entries={viewingEntries} />
            </div>
            <div className="w-full xl:w-80 flex-shrink-0">
              <div
                className="border border-nd_gray-150 rounded-xl bg-white p-5 xl:sticky xl:top-6 max-h-[calc(100vh-2rem)] overflow-y-auto">
                <AuditTimeline
                  versions={allVersions}
                  selectedVersionNum
                  onSelectVersion={v => setSelectedVersionNum(_ => v)}
                />
              </div>
            </div>
          </div>
        </div>
      </PageLoaderWrapper>
    </div>
  </div>
}
