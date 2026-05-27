open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

let accountNameFor = (accounts: array<accountType>, accountId: string): string =>
  accounts
  ->Array.find(a => a.account_id === accountId)
  ->Option.map(a => a.account_name)
  ->Option.getOr("—")

module Row = {
  @react.component
  let make = (
    ~ingestion: ingestionHistoryType,
    ~accounts: array<accountType>,
    ~active: bool,
    ~onSelect: ingestionHistoryType => unit,
  ) => {
    let status = ingestion.status
    let sourceKind = ingestion.upload_type->sourceTypeFromRawString
    let rowBg = active ? "bg-nd_primary_blue-50/60" : "hover:bg-nd_gray-50"
    let tagVariant: TagBinding.tagVariant = switch status {
    | Failed => Attentive
    | _ => Subtle
    }

    <tr
      className={`group ${rowBg} border-b border-nd_gray-100 cursor-pointer transition-colors`}
      onClick={_ => onSelect(ingestion)}>
      <td className="py-3 pl-6 pr-4 w-12 align-middle">
        <div className="w-7 h-7 rounded-md bg-nd_gray-50 grid place-items-center flex-shrink-0">
          <Icon name={sourceKind->sourceTypeIcon} size=14 customIconColor="#606B85" />
        </div>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <span
          className={`${body.sm.semibold} text-nd_gray-800 font-mono truncate block max-w-[420px]`}>
          {ingestion.file_name->React.string}
        </span>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <div className="flex flex-col gap-0.5 min-w-0">
          <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
            {accountNameFor(accounts, ingestion.account_id)->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-400 truncate`}>
            {`${sourceKind->sourceTypeLabel} · ${ingestion.ingestion_name}`->React.string}
          </span>
        </div>
      </td>
      <td className="py-3 px-4 w-28 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
          {ingestion.created_at->formatRelativeTime->React.string}
        </span>
      </td>
      <td className="py-3 pr-6 pl-4 w-36 align-middle">
        <TagBinding
          text={status->getIngestionLabel}
          color={status->getIngestionTagColor}
          variant=tagVariant
          size=Xs
        />
      </td>
    </tr>
  }
}

module Toolbar = {
  @react.component
  let make = (
    ~searchText: string,
    ~setSearchText: (string => string) => unit,
    ~filterKeys: array<string>,
    ~updateExistingKeys: Dict.t<string> => unit,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let dateDropDownTriggerMixpanelCallback = () =>
      mixpanelEvent(~eventName="recon_engine_ingestion_history_date_filter_opened")

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
          placeholder="Search by file name, account or source"
          className={`flex-1 bg-transparent outline-none border-none placeholder:text-nd_gray-400 ${body.sm.medium} text-nd_gray-800`}
        />
      </div>
      <div className="-ml-1 flex flex-row items-center grow">
        <DynamicFilter
          title="ReconEngineSourcesFilters"
          initialFilters={ReconEngineDataSourcesUtils.initialIngestionDisplayFilters()}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineSourcesFilters"
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
          {"File"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Source"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-28`}>
          {"Received"->React.string}
        </th>
        <th
          className={`py-2.5 pr-6 pl-4 text-left ${body.xs.semibold} uppercase tracking-wider w-36`}>
          {"Status"->React.string}
        </th>
      </tr>
    </thead>
}

@react.component
let make = (
  ~screenState,
  ~items: array<ingestionHistoryType>,
  ~accounts: array<accountType>,
  ~activeId: option<string>,
  ~onSelect: ingestionHistoryType => unit,
  ~searchText: string,
  ~setSearchText: (string => string) => unit,
  ~filterKeys: array<string>,
  ~updateExistingKeys: Dict.t<string> => unit,
) => {
  let listBody =
    items->Array.length === 0
      ? <div className="text-nd_gray-400 p-10">
          <NoDataFound
            message="No files match these filters"
            renderType={Painting}
            customMessageCss={`w-full text-nd_gray-500`}
          />
        </div>
      : <div className="flex-1 overflow-y-auto">
          <table className="w-full border-separate border-spacing-0">
            <ColumnHeader />
            <tbody>
              {items
              ->Array.map(ingestion =>
                <Row
                  key={ingestion.ingestion_history_id}
                  ingestion
                  accounts
                  active={activeId === Some(ingestion.ingestion_history_id)}
                  onSelect
                />
              )
              ->React.array}
            </tbody>
          </table>
        </div>

  <section className="flex-1 flex flex-col min-w-0 bg-white border-r border-nd_gray-150">
    <Toolbar searchText setSearchText filterKeys updateExistingKeys />
    <PageLoaderWrapper screenState> {listBody} </PageLoaderWrapper>
  </section>
}
