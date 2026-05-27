open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module Row = {
  @react.component
  let make = (
    ~entry: processingEntryType,
    ~active: bool,
    ~onSelect: processingEntryType => unit,
  ) => {
    let rowBg = active ? "bg-nd_primary_blue-50/60" : "hover:bg-nd_gray-50"
    let isCredit = entry.entry_type === "credit"
    let dirColor = isCredit ? "text-nd_green-600" : "text-nd_red-600"
    let dirLabel = isCredit ? "CR" : "DR"
    let dirStripe = isCredit ? "border-nd_green-400" : "border-nd_red-500"
    let kind = entry.status->getEntryKind
    let tagVariant: TagBinding.tagVariant = switch kind {
    | EntryNeedsReview => Attentive
    | _ => Subtle
    }

    <tr
      className={`group ${rowBg} border-b border-nd_gray-100 cursor-pointer transition-colors`}
      onClick={_ => onSelect(entry)}>
      <td className="py-3 pl-6 pr-4 w-12 align-middle">
        <span
          className={`${body.xs.semibold} ${dirColor} pl-2 border-l-[3px] ${dirStripe} tracking-wider`}>
          {dirLabel->React.string}
        </span>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <span className={`${body.sm.medium} text-nd_gray-700 font-mono truncate block`}>
          {entry.staging_entry_id->React.string}
        </span>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <span className={`${body.sm.medium} text-nd_gray-700 truncate block`}>
          {entry.account.account_name->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-36 align-middle">
        <span className={`${body.sm.semibold} text-nd_gray-800 tabular-nums`}>
          {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-28 align-middle">
        <span
          className={`${body.sm.medium} text-nd_gray-500 font-mono truncate block max-w-[120px]`}>
          {(entry.order_id === "" ? "—" : entry.order_id)->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-24 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
          {entry.effective_at->formatRelativeTime->React.string}
        </span>
      </td>
      <td className="py-3 pr-6 pl-4 w-44 align-middle">
        <div className="flex flex-col gap-1 min-w-0">
          <TagBinding
            text={entry.status->getEntryLabel}
            color={entry.status->getEntryTagColor}
            variant=tagVariant
            size=Xs
          />
          {switch entry.status {
          | NeedsManualReview =>
            <span className={`${body.xs.medium} text-nd_orange-500 truncate`}>
              {entry.data.needs_manual_review_type->getNeedsReviewShort->React.string}
            </span>
          | _ => React.null
          }}
        </div>
      </td>
    </tr>
  }
}

module Toolbar = {
  @react.component
  let make = (
    ~searchText: string,
    ~setSearchText: (string => string) => unit,
    ~accounts: array<accountType>,
    ~filterKeys: array<string>,
    ~updateExistingKeys: Dict.t<string> => unit,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let accountOptions = accounts->Array.map(a => {
      FilterSelectBox.label: a.account_name,
      value: a.account_id,
    })

    let dateDropDownTriggerMixpanelCallback = () =>
      mixpanelEvent(~eventName="recon_engine_accounts_transformed_entries_date_filter_opened")

    <div
      className="flex flex-row items-center gap-2 px-6 py-3 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <div
        className="flex flex-row items-center gap-2 px-3 h-9 max-w-64 min-w-64 rounded-lg border border-nd_gray-150 bg-white">
        <Icon name="search" size=14 customIconColor="#A1A8B8" />
        <input
          type_="text"
          value={searchText}
          onChange={ev => {
            let value = (ev->ReactEvent.Form.target)["value"]
            setSearchText(_ => value)
          }}
          placeholder="Search entry ID, order ID or account"
          className={`flex-1 bg-transparent outline-none border-none placeholder:text-nd_gray-400 ${body.sm.medium} text-nd_gray-800`}
        />
      </div>
      <div className="-ml-1 flex flex-row items-center grow">
        <DynamicFilter
          title="ReconEngineTransformedEntriesFilters"
          initialFilters={ReconEngineDataTransformedEntriesUtils.initialDisplayFilters(
            ~accountOptions,
          )}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineTransformedEntriesFilters"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
          setOffset={_ => ()}
        />
      </div>
    </div>
  }
}

module ColumnHeader = {
  @react.component
  let make = () =>
    <thead>
      <tr className="bg-nd_gray-50 border-b border-nd_gray-150 text-nd_gray-400">
        <th className="py-2.5 pl-6 pr-4 w-12 text-left" />
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Entry"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Account"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-36`}>
          {"Amount"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-28`}>
          {"Order"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-24`}>
          {"Date"->React.string}
        </th>
        <th
          className={`py-2.5 pr-6 pl-4 text-left ${body.xs.semibold} uppercase tracking-wider w-44`}>
          {"Status"->React.string}
        </th>
      </tr>
    </thead>
}

@react.component
let make = (
  ~screenState,
  ~entries: array<processingEntryType>,
  ~accounts: array<accountType>,
  ~activeId: option<string>,
  ~onSelect: processingEntryType => unit,
  ~searchText: string,
  ~setSearchText: (string => string) => unit,
  ~filterKeys: array<string>,
  ~updateExistingKeys: Dict.t<string> => unit,
) => {
  let listBody =
    entries->Array.length === 0
      ? <div className="text-nd_gray-400 p-10">
          <NoDataFound
            message="No entries match these filters"
            renderType={Painting}
            customMessageCss={`w-full text-nd_gray-500`}
          />
        </div>
      : <div className="flex-1 overflow-y-auto">
          <table className="w-full border-separate border-spacing-0">
            <ColumnHeader />
            <tbody>
              {entries
              ->Array.map(entry =>
                <Row key={entry.id} entry active={activeId === Some(entry.id)} onSelect />
              )
              ->React.array}
            </tbody>
          </table>
        </div>

  <section className="flex-1 flex flex-col min-w-0 bg-white border-r border-nd_gray-150">
    <Toolbar searchText setSearchText accounts filterKeys updateExistingKeys />
    <PageLoaderWrapper screenState> {listBody} </PageLoaderWrapper>
  </section>
}
