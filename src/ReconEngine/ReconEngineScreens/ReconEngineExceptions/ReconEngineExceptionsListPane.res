open Typography
open ReconEngineTypes
open ReconEngineExceptionsStatusUtils

/* Build the filter list shown next to the search input.
   We keep the legacy status + source/target account filters and add a Rule
   filter so the merchant can scope to one rule without the old tab UI. */
let buildInitialFilters = (
  ~ruleOptions: array<FilterSelectBox.dropdownOption>,
  ~creditAccountOptions: array<FilterSelectBox.dropdownOption>,
  ~debitAccountOptions: array<FilterSelectBox.dropdownOption>,
) => {
  open ReconEngineFilterUtils
  let statusOptions = getGroupedTransactionStatusOptions(allExceptionStatuses)
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Status",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="rule_id",
          ~name="rule_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=ruleOptions,
            ~buttonText="Rule",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="source_account",
          ~name="source_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=creditAccountOptions,
            ~buttonText="Source",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="target_account",
          ~name="target_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=debitAccountOptions,
            ~buttonText="Target",
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
    ~txn: transactionType,
    ~active: bool,
    ~isSelected: bool,
    ~ruleName: string,
    ~onSelect: transactionType => unit,
    ~onToggleSelection: transactionType => unit,
  ) => {
    let status = txn.transaction_status
    let label = status->getStatusLabel
    let credit = txn.credit_amount
    let debit = txn.debit_amount
    let varianceRaw = credit.value -. debit.value
    let variance = varianceRaw < 0.0 ? -.varianceRaw : varianceRaw
    let headlineAmount = credit.value > 0.0 ? credit.value : debit.value
    let currency = credit.currency

    let rowBg = active ? "bg-nd_primary_blue-50/60" : "hover:bg-nd_gray-50"
    let kind = status->getStatusKind
    let tagVariant: TagBinding.tagVariant = switch kind {
    | ReconEngineTransactionsStatusUtils.MismatchKind
    | ReconEngineTransactionsStatusUtils.PartialKind =>
      Attentive
    | _ => Subtle
    }

    let age = txn.created_at->ageInDays
    let urgencyClass = if age > 7.0 {
      "text-nd_red-600"
    } else if age > 2.0 {
      "text-nd_orange-600"
    } else {
      "text-nd_gray-500"
    }

    <tr
      className={`group ${rowBg} border-b border-nd_gray-100 cursor-pointer transition-colors`}
      onClick={_ => onSelect(txn)}>
      <td className="py-3 pl-5 pr-0 w-10 align-middle">
        <div onClick={e => e->ReactEvent.Mouse.stopPropagation}>
          <CheckBoxIconAdapter
            isSelected
            setIsSelected={_ => onToggleSelection(txn)}
            size=Small
            isSelectedStateMinus=false
          />
        </div>
      </td>
      <td className="py-3 px-4 w-20 align-middle">
        <span className={`${body.sm.medium} ${urgencyClass} tabular-nums`}>
          {txn.created_at->formatRelativeTime->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-44 align-middle tabular-nums">
        <div className="flex flex-row items-baseline gap-1.5 min-w-0">
          <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {`${currency} ${headlineAmount->Float.toString}`->React.string}
          </span>
          {switch kind {
          | ReconEngineTransactionsStatusUtils.MismatchKind =>
            <span
              className={`${body.xs.semibold} text-nd_red-600 bg-nd_red-50 px-1.5 py-0.5 rounded-md flex-shrink-0`}>
              {`±${variance->Float.toString}`->React.string}
            </span>
          | _ => React.null
          }}
        </div>
      </td>
      <td className="py-3 px-4 w-32 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 truncate block`}>
          {ruleName->React.string}
        </span>
      </td>
      <td className="py-3 px-4 align-middle min-w-0">
        <span className={`${body.sm.medium} text-nd_gray-500 font-mono truncate block`}>
          {txn.transaction_id->React.string}
        </span>
      </td>
      <td className="py-3 pr-5 pl-4 align-middle">
        <TagBinding text={label} color={status->getTagColor} variant=tagVariant size=Xs />
      </td>
    </tr>
  }
}

module Toolbar = {
  @react.component
  let make = (
    ~searchText: string,
    ~setSearchText: (string => string) => unit,
    ~rules: array<ReconEngineRulesTypes.rulePayload>,
    ~accounts: array<accountType>,
    ~filterKeys: array<string>,
    ~updateExistingKeys: Dict.t<string> => unit,
  ) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let ruleOptions = rules->Array.map((r): FilterSelectBox.dropdownOption => {
      FilterSelectBox.label: r.rule_name,
      value: r.rule_id,
    })
    let creditAccountOptions = accounts->Array.map((a): FilterSelectBox.dropdownOption => {
      FilterSelectBox.label: a.account_name,
      value: a.account_id,
    })
    let debitAccountOptions = creditAccountOptions

    let dateDropDownTriggerMixpanelCallback = () =>
      mixpanelEvent(~eventName="recon_engine_exception_transaction_date_filter_opened")

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
          placeholder="Search transaction or order ID"
          className={`flex-1 bg-transparent outline-none border-none placeholder:text-nd_gray-400 ${body.sm.medium} text-nd_gray-800`}
        />
      </div>
      <div className="-ml-1 flex flex-row items-center grow">
        <DynamicFilter
          title="ReconEngineExceptionTransactionFilters"
          initialFilters={buildInitialFilters(
            ~ruleOptions,
            ~creditAccountOptions,
            ~debitAccountOptions,
          )}
          options=[]
          popupFilterFields=[]
          initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[HSAnalyticsUtils.startTimeFilterKey, HSAnalyticsUtils.endTimeFilterKey]
          tabNames=filterKeys
          key="ReconEngineExceptionTransactionFilters"
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
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-44`}>
          {"Amount"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider w-32`}>
          {"Rule"->React.string}
        </th>
        <th className={`py-2.5 px-4 text-left ${body.xs.semibold} uppercase tracking-wider`}>
          {"Transaction"->React.string}
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
  ~exceptions: array<transactionType>,
  ~rules: array<ReconEngineRulesTypes.rulePayload>,
  ~accounts: array<accountType>,
  ~activeTransactionId: option<string>,
  ~onSelect: transactionType => unit,
  ~selectedRows: array<transactionType>,
  ~setSelectedRows: (array<transactionType> => array<transactionType>) => unit,
  ~searchText: string,
  ~setSearchText: (string => string) => unit,
  ~filterKeys: array<string>,
  ~updateExistingKeys: Dict.t<string> => unit,
) => {
  let isSelected = (txn: transactionType) =>
    selectedRows->Array.some(r => r.transaction_id === txn.transaction_id)

  let toggleSelection = (txn: transactionType) =>
    setSelectedRows(prev => {
      if prev->Array.some(r => r.transaction_id === txn.transaction_id) {
        prev->Array.filter(r => r.transaction_id !== txn.transaction_id)
      } else {
        Array.concat(prev, [txn])
      }
    })

  let allChecked =
    exceptions->Array.length > 0 &&
      exceptions->Array.every(t =>
        selectedRows->Array.some(r => r.transaction_id === t.transaction_id)
      )

  let toggleAll = (next: bool) => setSelectedRows(_ => next ? exceptions->Array.copy : [])

  let listBody =
    exceptions->Array.length === 0
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
              {exceptions
              ->Array.map(txn => {
                let ruleName = txn.rule.rule_name
                <Row
                  key={txn.transaction_id}
                  txn
                  active={activeTransactionId === Some(txn.transaction_id)}
                  isSelected={isSelected(txn)}
                  ruleName
                  onSelect
                  onToggleSelection={toggleSelection}
                />
              })
              ->React.array}
            </tbody>
          </table>
        </div>

  <section className="flex-1 flex flex-col min-w-0 bg-white border-r border-nd_gray-150">
    <Toolbar searchText setSearchText rules accounts filterKeys updateExistingKeys />
    <PageLoaderWrapper screenState> {listBody} </PageLoaderWrapper>
  </section>
}
