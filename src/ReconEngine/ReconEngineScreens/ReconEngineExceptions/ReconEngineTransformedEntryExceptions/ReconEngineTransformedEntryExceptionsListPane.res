open Typography
open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsStatusUtils

let buildInitialFilters = (~accountOptions: array<FilterSelectBox.dropdownOption>) => {
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="entry_type",
          ~name="entry_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=[{label: "Credit", value: "credit"}, {label: "Debit", value: "debit"}],
            ~buttonText="Type",
            ~showSelectionAsChips=false,
            ~searchable=false,
            ~showToolTip=false,
            ~showNameAsToolTip=false,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="account_id",
          ~name="account_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=accountOptions,
            ~buttonText="Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}

module Row = {
  @react.component
  let make = (
    ~entry: processingEntryType,
    ~active: bool,
    ~isSelected: bool,
    ~onSelect: processingEntryType => unit,
    ~onToggleSelection: processingEntryType => unit,
  ) => {
    let status = entry.status
    let entryTypeLower = entry.entry_type->String.toLowerCase
    let isDebit = entryTypeLower === "debit"
    let typeLabel = isDebit ? "DEBIT" : "CREDIT"
    let typeColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"
    let typeStripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"

    let rowBg = active ? "bg-nd_primary_blue-50/60" : "hover:bg-nd_gray-50"

    let reviewBadge = switch status {
    | NeedsManualReview =>
      <span
        className={`${body.xs.semibold} text-nd_orange-700 bg-nd_orange-50 px-1.5 py-0.5 rounded-md flex-shrink-0`}>
        {entry.data.needs_manual_review_type->getNeedsReviewShort->React.string}
      </span>
    | _ => React.null
    }

    <tr
      className={`group ${rowBg} border-b border-nd_gray-100 cursor-pointer transition-colors`}
      onClick={_ => onSelect(entry)}>
      <td className="py-3 pl-5 pr-0 w-10 align-middle">
        <div onClick={e => e->ReactEvent.Mouse.stopPropagation}>
          <CheckBoxIconAdapter
            isSelected
            setIsSelected={_ => onToggleSelection(entry)}
            size=Small
            isSelectedStateMinus=false
          />
        </div>
      </td>
      <td className="py-3 px-4 w-20 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
          {entry.effective_at->formatRelativeTime->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-32 align-middle tabular-nums">
        <div className="flex flex-row items-center gap-2 min-w-0">
          <span
            className={`${body.xs.semibold} ${typeColor} pl-1.5 border-l-[3px] ${typeStripe} tracking-wider flex-shrink-0`}>
            {typeLabel->React.string}
          </span>
          <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
          </span>
        </div>
      </td>
      <td className="py-3 px-4 w-40 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 truncate block`}>
          {entry.account.account_name->React.string}
        </span>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <span className={`${body.sm.medium} text-nd_gray-500 font-mono truncate block`}>
          {entry.order_id->React.string}
        </span>
      </td>
      <td className="py-3 pr-5 pl-4 align-middle">
        <div className="flex flex-row items-center gap-2 flex-wrap">
          <TagBinding
            text={status->getEntryLabel} color={status->getEntryTagColor} variant=Subtle size=Xs
          />
          {reviewBadge}
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
    ~accountOptions: array<FilterSelectBox.dropdownOption>,
    ~filterKeys: array<string>,
    ~updateExistingKeys: Dict.t<string> => unit,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let dateDropDownTriggerMixpanelCallback = () =>
      mixpanelEvent(~eventName="recon_engine_transformed_entries_exceptions_date_filter_opened")

    <div
      className="flex flex-row items-center gap-2 px-6 py-3 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <div
        className="flex flex-row items-center gap-2 px-3 h-9 max-w-64 min-w-64 rounded-lg border border-nd_gray-150 bg-white flex-1">
        <Icon name="search" size=14 customIconColor="#A1A8B8" />
        <input
          type_="text"
          value={searchText}
          onChange={ev => {
            let value = (ev->ReactEvent.Form.target)["value"]
            setSearchText(_ => value)
          }}
          placeholder="Search staging entry or order ID"
          className={`flex-1 bg-transparent outline-none border-none placeholder:text-nd_gray-400 ${body.sm.medium} text-nd_gray-800`}
        />
      </div>
      <div className="-ml-1 flex flex-row items-center grow">
        <DynamicFilter
          title="ReconEngineTransformedEntriesExceptionsFilters"
          initialFilters={buildInitialFilters(~accountOptions)}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineTransformedEntriesExceptionsFilters"
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
  let make = (~allChecked: bool, ~onToggleAll: bool => unit) =>
    <thead>
      <tr className="bg-nd_gray-50 border-b border-nd_gray-150 text-nd_gray-400">
        <th className="py-2.5 pl-5 pr-0 w-10 text-left">
          <div onClick={e => e->ReactEvent.Mouse.stopPropagation}>
            <CheckBoxIconAdapter
              isSelected={allChecked}
              setIsSelected={_ => onToggleAll(!allChecked)}
              size=Small
              isSelectedStateMinus=false
            />
          </div>
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-20`}>
          {"Age"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-32`}>
          {"Amount"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-40`}>
          {"Account"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Order ID"->React.string}
        </th>
        <th className={`py-2.5 pr-5 pl-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Status"->React.string}
        </th>
      </tr>
    </thead>
}

@react.component
let make = (
  ~screenState,
  ~entries: array<processingEntryType>,
  ~accountOptions: array<FilterSelectBox.dropdownOption>,
  ~activeEntryId: option<string>,
  ~onSelect: processingEntryType => unit,
  ~selectedRows: array<processingEntryType>,
  ~setSelectedRows: (array<processingEntryType> => array<processingEntryType>) => unit,
  ~searchText: string,
  ~setSearchText: (string => string) => unit,
  ~filterKeys: array<string>,
  ~updateExistingKeys: Dict.t<string> => unit,
) => {
  let isSelected = (entry: processingEntryType) => selectedRows->Array.some(r => r.id === entry.id)

  let toggleSelection = (entry: processingEntryType) =>
    setSelectedRows(prev => {
      if prev->Array.some(r => r.id === entry.id) {
        prev->Array.filter(r => r.id !== entry.id)
      } else {
        Array.concat(prev, [entry])
      }
    })

  let allChecked =
    entries->Array.length > 0 &&
      entries->Array.every(e => selectedRows->Array.some(r => r.id === e.id))

  let toggleAll = (next: bool) => setSelectedRows(_ => next ? entries->Array.copy : [])

  let listBody =
    entries->Array.length === 0
      ? <div className="text-nd_gray-400 p-10">
          <NoDataFound
            message="All clear in this view."
            renderType={Painting}
            customMessageCss={`w-full text-nd_gray-500`}
          />
        </div>
      : <div className="flex-1 overflow-y-auto">
          <table className="w-full border-separate border-spacing-0">
            <ColumnHeader allChecked onToggleAll=toggleAll />
            <tbody>
              {entries
              ->Array.map(entry =>
                <Row
                  key={entry.staging_entry_id}
                  entry
                  active={activeEntryId === Some(entry.staging_entry_id)}
                  isSelected={isSelected(entry)}
                  onSelect
                  onToggleSelection={toggleSelection}
                />
              )
              ->React.array}
            </tbody>
          </table>
        </div>

  <section className="flex-1 flex flex-col min-w-0 bg-white border-r border-nd_gray-150">
    <Toolbar searchText setSearchText accountOptions filterKeys updateExistingKeys />
    <PageLoaderWrapper screenState> {listBody} </PageLoaderWrapper>
  </section>
}
