open Typography
open ReconEngineTypes
open ReconEngineExceptionsStatusUtils
module Ett = ReconEngineExceptionTransactionTypes

/* Compact status + amount + variance card shown in the left rail. */
module StatusHero = {
  @react.component
  let make = (~txn: transactionType) => {
    let status = txn.transaction_status
    let kind = status->getStatusKind
    let varianceRaw = txn.credit_amount.value -. txn.debit_amount.value
    let variance = varianceRaw < 0.0 ? -.varianceRaw : varianceRaw
    let currency = txn.credit_amount.currency
    let amount = txn.credit_amount.value > 0.0 ? txn.credit_amount.value : txn.debit_amount.value

    <div className="flex flex-col gap-3">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={status->getStatusLabel} color={status->getTagColor} variant=Subtle size=Sm
        />
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {`Flagged ${txn.created_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1">
        <div className="flex flex-row items-baseline gap-2 flex-wrap">
          <span className={`${heading.lg.semibold} text-nd_gray-800 tabular-nums tracking-tight`}>
            {`${currency} ${amount->Float.toString}`->React.string}
          </span>
          {switch kind {
          | ReconEngineTransactionsStatusUtils.MismatchKind =>
            <span
              className={`${body.sm.semibold} text-nd_red-600 bg-nd_red-50 px-2 py-0.5 rounded-md tabular-nums`}>
              {`±${currency} ${variance->Float.toString}`->React.string}
            </span>
          | _ => React.null
          }}
        </div>
        <p className={`${body.sm.medium} text-nd_gray-500`}>
          {status->getStatusDescription->React.string}
        </p>
      </div>
    </div>
  }
}

module MetaBlock = {
  @react.component
  let make = (~txn: transactionType) =>
    <div className="grid grid-cols-2 gap-x-4 gap-y-3.5">
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Txn ID"->React.string}
        </span>
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(txn.transaction_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Rule"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
          {txn.rule.rule_name->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Created"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums truncate`}>
          {txn.created_at
          ->DateTimeUtils.getFormattedDate("DD MMM YYYY, hh:mm A")
          ->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Version"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
          {`v${txn.version->Int.toString}`->React.string}
        </span>
      </div>
    </div>
}

/* Compact history strip — surface the 3 most recent versions of this transaction.
 "Open full history" routes to the legacy timeline view via the Tabs tab. */
module AuditMini = {
  @react.component
  let make = (~versions: array<transactionType>, ~onOpenFull: unit => unit) => {
    let recent = versions->Array.slice(~start=0, ~end=3)
    <div className="flex flex-col gap-2.5">
      <div className="flex flex-row items-baseline justify-between">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Audit Trail"->React.string}
        </span>
        <button
          type_="button"
          onClick={_ => onOpenFull()}
          className={`${body.xs.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700`}>
          {"View all →"->React.string}
        </button>
      </div>
      <div className="flex flex-col gap-2">
        {recent
        ->Array.mapWithIndex((version, idx) => {
          let isLatest = idx === 0
          let dotColor = isLatest ? "bg-nd_primary_blue-500" : "bg-nd_gray-300"
          <div key={idx->Int.toString} className="flex flex-row items-start gap-2.5">
            <div className="flex flex-col items-center flex-shrink-0 mt-1">
              <span className={`w-2 h-2 rounded-full ${dotColor}`} />
              {idx < recent->Array.length - 1
                ? <span className="w-px h-6 bg-nd_gray-200 mt-1" />
                : React.null}
            </div>
            <div className="flex flex-col gap-0.5 min-w-0">
              <span className={`${body.sm.medium} text-nd_gray-700`}>
                {version.transaction_status->getStatusLabel->React.string}
              </span>
              <span className={`${body.xs.medium} text-nd_gray-500`}>
                {`v${version.version->Int.toString} · ${version.created_at->formatRelativeTime} ago`->React.string}
              </span>
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

/* A single resolution option, presented as a clickable card. */
module ResolutionCard = {
  @react.component
  let make = (
    ~action: Ett.resolvingException,
    ~recommended: bool=false,
    ~disabled: bool=false,
    ~onClick: unit => unit,
  ) => {
    let accent = recommended
      ? "border-nd_primary_blue-200 bg-nd_primary_blue-50/40"
      : "border-nd_gray-150 bg-white hover:bg-nd_gray-25"
    let iconAccent = recommended
      ? "bg-white border border-nd_primary_blue-200"
      : "bg-nd_gray-50 border border-nd_gray-150"
    let iconColor = recommended ? "#1F6BD9" : "#606B85"

    <button
      type_="button"
      disabled
      onClick={_ => onClick()}
      className={`w-full text-left rounded-xl border ${accent} px-3.5 py-3 flex flex-row items-center gap-3 transition-colors ${disabled
          ? "opacity-50 cursor-not-allowed"
          : "cursor-pointer"}`}>
      <div className={`w-9 h-9 rounded-lg ${iconAccent} grid place-items-center flex-shrink-0`}>
        <Icon name={action->resolutionIcon} size=18 customIconColor={iconColor} />
      </div>
      <div className="flex flex-col gap-0.5 flex-1 min-w-0">
        <div className="flex flex-row items-center gap-2">
          <span className={`${body.sm.semibold} text-nd_gray-800`}>
            {action->resolutionLabel->React.string}
          </span>
          {recommended
            ? <span
                className={`${body.xs.semibold} text-nd_primary_blue-700 bg-white border border-nd_primary_blue-200 px-1.5 py-0.5 rounded`}>
                {"Recommended"->React.string}
              </span>
            : React.null}
        </div>
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {action->resolutionHint->React.string}
        </span>
      </div>
      <Icon name="nd-chevron-right" size=14 customIconColor="#A1A8B8" />
    </button>
  }
}

/* Visual representation of a single entry inside the center column.
 Highlights changed fields when comparing to the original entry. */
module EntryCard = {
  @react.component
  let make = (
    ~entry: Ett.exceptionResolutionEntryType,
    ~initialEntry: option<entryType>,
    ~isNew: bool=false,
  ) => {
    let isDebit = entry.entry_type === Debit
    let stripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"
    let label = isDebit ? "DEBIT" : "CREDIT"
    let textColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"

    let amountChanged = switch initialEntry {
    | Some(init) => init.amount !== entry.amount
    | None => false
    }
    let orderChanged = switch initialEntry {
    | Some(init) => init.order_id !== entry.order_id
    | None => false
    }
    let statusBadge = if isNew {
      <span
        className={`${body.xs.semibold} text-nd_green-700 bg-nd_green-50 border border-nd_green-200 px-1.5 py-0.5 rounded uppercase tracking-wider`}>
        {"New"->React.string}
      </span>
    } else if amountChanged || orderChanged {
      <span
        className={`${body.xs.semibold} text-nd_orange-700 bg-nd_orange-50 border border-nd_orange-200 px-1.5 py-0.5 rounded uppercase tracking-wider`}>
        {"Edited"->React.string}
      </span>
    } else {
      React.null
    }

    <div className="rounded-xl border border-nd_gray-150 bg-white px-4 py-3.5 flex flex-col gap-3">
      <div className="flex flex-row items-center justify-between gap-2">
        <span
          className={`${body.xs.semibold} ${textColor} pl-2 border-l-[3px] ${stripe} tracking-wider flex-shrink-0`}>
          {label->React.string}
        </span>
        {statusBadge}
      </div>
      <div className="grid grid-cols-2 gap-x-4 gap-y-3">
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Amount"->React.string}
          </span>
          <div className="flex flex-col gap-0.5">
            {switch initialEntry {
            | Some(init) if init.amount !== entry.amount =>
              <span
                className={`${body.xs.medium} text-nd_gray-400 line-through tabular-nums truncate`}>
                {`${init.currency} ${init.amount->Float.toString}`->React.string}
              </span>
            | _ => React.null
            }}
            <span
              className={`${body.sm.semibold} ${amountChanged
                  ? "text-nd_green-700"
                  : "text-nd_gray-800"} tabular-nums truncate`}>
              {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
            </span>
          </div>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Order ID"->React.string}
          </span>
          <div className="flex flex-col gap-0.5">
            {switch initialEntry {
            | Some(init) if init.order_id !== entry.order_id =>
              <span
                className={`${body.xs.medium} text-nd_gray-400 line-through font-mono truncate`}>
                {init.order_id->React.string}
              </span>
            | _ => React.null
            }}
            <span
              className={`${body.sm.medium} ${orderChanged
                  ? "text-nd_green-700"
                  : "text-nd_gray-700"} font-mono truncate`}>
              {entry.order_id->React.string}
            </span>
          </div>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Effective"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums truncate`}>
            {entry.effective_at
            ->DateTimeUtils.getFormattedDate("DD MMM YYYY, hh:mm A")
            ->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Status"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 capitalize truncate`}>
            {(entry.status :> string)->React.string}
          </span>
        </div>
      </div>
    </div>
  }
}

/* The full confirmation diff — replaces the legacy numbered-prose summary. */
module ConfirmDiff = {
  @react.component
  let make = (
    ~originalEntries: array<entryType>,
    ~updatedEntries: array<Ett.exceptionResolutionEntryType>,
  ) => {
    open ReconEngineExceptionTransactionUtils
    let summaries = generateAllResolutionSummaries(
      originalEntries,
      updatedEntries->Array.map(getEntryTypeFromExceptionEntryType),
    )
    if summaries->Array.length === 0 {
      React.null
    } else {
      <div className="flex flex-col gap-2.5 mt-1">
        <span className={`${body.sm.semibold} text-nd_gray-700`}>
          {"Resolution Summary"->React.string}
        </span>
        <div
          className="flex flex-col gap-2 rounded-xl border border-nd_gray-150 bg-nd_gray-50 px-4 py-3.5">
          {summaries
          ->Array.mapWithIndex((item, idx) => {
            <div key={idx->Int.toString} className="flex flex-row items-start gap-2.5">
              <span
                className={`w-5 h-5 rounded-full bg-nd_primary_blue-100 text-nd_primary_blue-700 grid place-items-center ${body.xs.semibold} tabular-nums flex-shrink-0 mt-0.5`}>
                {(idx + 1)->Int.toString->React.string}
              </span>
              <span className={`${body.sm.medium} text-nd_gray-700 flex-1`}>
                {item->React.string}
              </span>
            </div>
          })
          ->React.array}
        </div>
      </div>
    }
  }
}

@react.component
let make = (~id) => {
  open LogicUtils
  open ReconEngineTransactionsUtils
  open ReconEngineTransactionsHelper
  open ReconEngineExceptionTransactionHelper
  open ReconEngineExceptionTransactionUtils
  open ReconEngineExceptionsUtils
  open APIUtils
  open ReconEngineUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let getTransactions = ReconEngineHooks.useGetTransactions()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentExceptionsDetails, setCurrentExceptionDetails) = React.useState(_ =>
    Dict.make()->getTransactionsPayloadFromDict
  )
  let (allExceptionDetails, setAllExceptionDetails) = React.useState(_ => [
    Dict.make()->getTransactionsPayloadFromDict,
  ])
  let (entriesList, setEntriesList) = React.useState(_ => [
    Dict.make()->transactionsEntryItemToObjMapperFromDict,
  ])
  let (accountsData, setAccountsData) = React.useState(_ => [])

  let (exceptionStage, setExceptionStage) = React.useState(_ => Ett.ShowResolutionOptions(
    Ett.NoResolutionOptionNeeded,
  ))
  let (selectedRows, setSelectedRows) = React.useState(_ => [])
  let (updatedEntriesList, setUpdatedEntriesList) = React.useState(_ => [])
  let (showConfirmationModal, setShowConfirmationModal) = React.useState(_ => false)
  let (activeModal, setActiveModal) = React.useState(_ => None)
  let (availableResolutions, setAvailableResolutions) = React.useState(_ => [])
  let (showAllOptions, setShowAllOptions) = React.useState(_ => false)
  let (showFullAudit, setShowFullAudit) = React.useState(_ => false)

  let getExceptionDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let exceptions = await getTransactions(~queryParameters=Some(`transaction_id=${id}`))
      exceptions->Array.sort(sortByVersion)
      let currentExceptionDetails =
        exceptions->getValueFromArray(0, Dict.make()->getTransactionsPayloadFromDict)
      let entriesUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_TRANSACTION,
        ~id=Some(currentExceptionDetails.transaction_id),
      )
      let entriesRes = await fetchDetails(entriesUrl)
      let entriesListRaw =
        entriesRes->getArrayDataFromJson(transactionsEntryItemToObjMapperFromDict)
      let entriesDataArray = currentExceptionDetails.entries->Array.map(entry => {
        let foundEntry =
          entriesListRaw
          ->Array.find(e => entry.entry_id == e.entry_id)
          ->Option.getOr(Dict.make()->transactionsEntryItemToObjMapperFromDict)
        {...foundEntry, account_name: entry.account.account_name}
      })
      let accountData = await getAccounts()
      setEntriesList(_ => entriesDataArray)
      setUpdatedEntriesList(_ => entriesDataArray->addUniqueIdsToEntries)
      setCurrentExceptionDetails(_ => currentExceptionDetails)
      setAllExceptionDetails(_ => exceptions)
      setAccountsData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
    }
  }

  let fetchTransactionResolutions = async () => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#TRANSACTION_RESOLUTIONS,
        ~methodType=Get,
        ~id=Some(currentExceptionsDetails.id),
      )
      let response = await fetchDetails(url)
      let resolutions = parseResolutionActions(response)
      setAvailableResolutions(_ => resolutions)
    } catch {
    | _ => setAvailableResolutions(_ => [])
    }
  }

  React.useEffect(() => {
    getExceptionDetails()->ignore
    None
  }, [])

  React.useEffect(() => {
    if currentExceptionsDetails.id->isNonEmptyString {
      fetchTransactionResolutions()->ignore
    }
    None
  }, [currentExceptionsDetails.id])

  let isResolutionAvailable = (resolution: Ett.resolvingException) =>
    availableResolutions->Array.some(r => r === resolution)

  let onDiscardChanges = () => {
    setExceptionStage(_ => Ett.ShowResolutionOptions(Ett.NoResolutionOptionNeeded))
    setSelectedRows(_ => [])
    setUpdatedEntriesList(_ => entriesList->addUniqueIdsToEntries)
    setShowAllOptions(_ => false)
  }

  let handleResolutionPick = (action: Ett.resolvingException) =>
    switch action {
    | Ett.ForceReconcile => {
        setExceptionStage(_ => Ett.ResolvingException(Ett.ForceReconcile))
        setActiveModal(_ => Some(Ett.ForceReconcileModal))
      }
    | Ett.VoidTransaction => {
        setExceptionStage(_ => Ett.ResolvingException(Ett.VoidTransaction))
        setActiveModal(_ => Some(Ett.IgnoreTransactionModal))
      }
    | EditEntry => setExceptionStage(_ => Ett.ResolvingException(EditEntry))
    | Ett.MarkAsReceived => setExceptionStage(_ => Ett.ResolvingException(Ett.MarkAsReceived))
    | Ett.CreateNewEntry => {
        setExceptionStage(_ => Ett.ResolvingException(Ett.CreateNewEntry))
        setActiveModal(_ => Some(Ett.CreateEntryModal))
      }
    | Ett.LinkStagingEntriesToTransaction => {
        setExceptionStage(_ => Ett.ResolvingException(Ett.LinkStagingEntriesToTransaction))
        setActiveModal(_ => Some(Ett.LinkStagingEntriesModal))
      }
    | Ett.NoResolutionActionNeeded => ()
    }

  let openModalForCurrentStage = () =>
    switch exceptionStage {
    | Ett.ResolvingException(EditEntry) => setActiveModal(_ => Some(EditEntryModal))
    | Ett.ResolvingException(Ett.MarkAsReceived) =>
      setActiveModal(_ => Some(Ett.MarkAsReceivedModal))
    | _ => ()
    }

  /* Submit handlers — same wiring as the legacy resolution component. */
  let onIgnoreTransactionSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#VOID_TRANSACTION,
        ~methodType=Put,
        ~id=Some(currentExceptionsDetails.id),
      )
      let body = {"reason": valuesDict->getString("reason", "")}
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)
      let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => Ett.ExceptionResolved)
      let toastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement transaction toastKey />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/recon"),
      )
    } catch {
    | _ =>
      showToast(
        ~message="Failed to ignore the transaction. Please try again.",
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  let onForceReconcileSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#FORCE_RECONCILE_TRANSACTION,
        ~methodType=Put,
        ~id=Some(currentExceptionsDetails.id),
      )
      let body = {"reason": valuesDict->getString("reason", "")}
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)
      let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => Ett.ExceptionResolved)
      let toastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement transaction toastKey />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/recon"),
      )
    } catch {
    | _ =>
      showToast(
        ~message="Failed to force-match the transaction. Please try again.",
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  let onEditEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    let updatedEntry = getUpdatedEntry(~formData, ~entryDetails)
    let newEntriesList =
      updatedEntriesList->Array.map(entry =>
        entry.entry_key == updatedEntry.entry_key ? updatedEntry : entry
      )
    setUpdatedEntriesList(_ => newEntriesList)
    setExceptionStage(_ => Ett.ConfirmResolution(EditEntry))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onMarkAsReceivedSubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let entryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    let updatedEntry = getUpdatedEntry(~formData, ~markAsReceived=true, ~entryDetails)
    let newEntriesList =
      updatedEntriesList->Array.map(entry =>
        entry.entry_key == updatedEntry.entry_key ? updatedEntry : entry
      )
    setUpdatedEntriesList(_ => newEntriesList)
    setExceptionStage(_ => Ett.ConfirmResolution(EditEntry))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onCreateEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let newEntry = getNewEntry(~formData, ~updatedEntriesList)
    setUpdatedEntriesList(_ => updatedEntriesList->Array.concat([newEntry]))
    setExceptionStage(_ => Ett.ConfirmResolution(Ett.CreateNewEntry))
    setActiveModal(_ => None)
    Nullable.null
  }

  let onReplaceEntrySubmit = async (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getArrayDataFromJson(exceptionTransactionEntryItemToItemMapper)
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    let selectedEntryDetails =
      selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
    let newEntriesList =
      updatedEntriesList->Array.filter(entry => entry.entry_key !== selectedEntryDetails.entry_key)
    setUpdatedEntriesList(_ => newEntriesList->Array.concat(formData))
    setExceptionStage(_ => Ett.ConfirmResolution(Ett.LinkStagingEntriesToTransaction))
    setActiveModal(_ => None)
    setSelectedRows(_ => [])
    Nullable.null
  }

  let onConfirmResolveSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#MANUAL_RECONCILIATION,
        ~methodType=Post,
        ~id=Some(currentExceptionsDetails.id),
      )
      let body = constructManualReconciliationBody(~updatedEntriesList, ~values)
      let res = await updateDetails(url, body, Post)
      let transaction = res->getDictFromJsonObject->transactionItemToObjMapper
      setShowConfirmationModal(_ => false)
      setExceptionStage(_ => Ett.ExceptionResolved)
      let toastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement transaction toastKey />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/recon"),
      )
    } catch {
    | _ =>
      showToast(
        ~message="Failed to resolve transaction exception. Please try again.",
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  /* Derived */
  let recommendedAction = currentExceptionsDetails.transaction_status->getRecommendedResolution

  let availableActionsList: array<Ett.resolvingException> = [
    EditEntry,
    Ett.MarkAsReceived,
    Ett.CreateNewEntry,
    Ett.LinkStagingEntriesToTransaction,
    Ett.ForceReconcile,
    Ett.VoidTransaction,
  ]

  let otherActions =
    availableActionsList->Array.filter(a => a !== recommendedAction && isResolutionAvailable(a))

  /* The Mark-as-Received button only shows when an Expected entry exists. */
  let markAsReceivedAvailable =
    isResolutionAvailable(Ett.MarkAsReceived) &&
    (currentExceptionsDetails.transaction_status === Expected ||
      updatedEntriesList->Array.some(entry => entry.status == Expected))

  let recommendedAvailable = switch recommendedAction {
  | Ett.MarkAsReceived => markAsReceivedAvailable
  | Ett.NoResolutionActionNeeded => false
  | a => isResolutionAvailable(a)
  }

  let entryForSelection = React.useMemo(() => {
    let selectedEntry = selectedRows->getValueFromArray(0, JSON.Encode.null)
    selectedEntry->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
  }, [selectedRows])

  let isNewlyCreatedEntry = entryForSelection.entry_id == "-"

  let isRowSelectable = switch exceptionStage {
  | Ett.ResolvingException(Ett.MarkAsReceived) =>
    Some(
      (rowData: JSON.t) => {
        let entry = rowData->getDictFromJsonObject->exceptionTransactionEntryItemToItemMapper
        entry.status == Expected
      },
    )
  | _ => None
  }

  let handleRowSelect = (updateFn: array<JSON.t> => array<JSON.t>) => {
    setSelectedRows(prev => {
      let updated = updateFn(prev)
      switch updated->Array.length {
      | 0 => []
      | _ => [updated->getValueFromArray(updated->Array.length - 1, JSON.Encode.null)]
      }
    })
  }

  let (groupedEntries, accountInfoMap) = React.useMemo(() => {
    getGroupedEntriesAndAccountMaps(~accountsData, ~updatedEntriesList)
  }, (updatedEntriesList, accountsData))

  /* Entries grouped by account for the center column. */
  let entriesByAccount = React.useMemo(() => {
    let dict: Dict.t<array<Ett.exceptionResolutionEntryType>> = Dict.make()
    updatedEntriesList->Array.forEach(entry => {
      let key = entry.account_id
      let bucket = dict->Dict.get(key)->Option.getOr([])
      dict->Dict.set(key, Array.concat(bucket, [entry]))
    })
    dict->Dict.toArray
  }, [updatedEntriesList])

  let hasPendingChanges =
    exceptionStage == Ett.ConfirmResolution(EditEntry) ||
    exceptionStage == Ett.ConfirmResolution(Ett.CreateNewEntry) ||
    exceptionStage == Ett.ConfirmResolution(Ett.MarkAsReceived) ||
    exceptionStage == Ett.ConfirmResolution(Ett.LinkStagingEntriesToTransaction)

  let inSelectMode = switch exceptionStage {
  | Ett.ResolvingException(EditEntry)
  | Ett.ResolvingException(Ett.MarkAsReceived)
  | Ett.ResolvingException(Ett.LinkStagingEntriesToTransaction) => true
  | _ => false
  }

  let selectionPrompt = switch exceptionStage {
  | Ett.ResolvingException(EditEntry) => "Select an entry to edit."
  | Ett.ResolvingException(Ett.MarkAsReceived) => "Select an Expected entry to mark as received."
  | Ett.ResolvingException(Ett.LinkStagingEntriesToTransaction) => "Select an entry to replace."
  | _ => ""
  }

  let leftRail =
    <aside className="w-[300px] flex-shrink-0 bg-white border-r border-nd_gray-150 overflow-y-auto">
      <div className="px-6 py-5 flex flex-col gap-5">
        <StatusHero txn=currentExceptionsDetails />
        <div className="h-px bg-nd_gray-150" />
        <MetaBlock txn=currentExceptionsDetails />
        <div className="h-px bg-nd_gray-150" />
        <AuditMini versions=allExceptionDetails onOpenFull={() => setShowFullAudit(_ => true)} />
      </div>
    </aside>

  /* Center column shows entries grouped by account, side-by-side debit/credit columns
   when there's exactly one of each (the common case for one-to-one rules). */
  let entriesCenter =
    <section className="flex-1 min-w-0 overflow-y-auto bg-nd_gray-25 px-6 py-5 flex flex-col gap-5">
      <div className="flex flex-row items-center justify-between">
        <div className="flex flex-col gap-0.5">
          <h2 className={`${heading.md.semibold} text-nd_gray-800`}> {"Entries"->React.string} </h2>
          <p className={`${body.sm.medium} text-nd_gray-500`}>
            {"The records this transaction is built from."->React.string}
          </p>
        </div>
        <RenderIf condition={inSelectMode}>
          <span
            className={`${body.sm.semibold} text-nd_primary_blue-700 bg-nd_primary_blue-50 border border-nd_primary_blue-200 px-2.5 py-1 rounded-md`}>
            {selectionPrompt->React.string}
          </span>
        </RenderIf>
      </div>
      <ExceptionDataDisplay
        currentExceptionDetails=currentExceptionsDetails
        entryDetails={updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
        accountInfoMap
      />
      <RenderIf condition={inSelectMode}>
        <ReconEngineCustomExpandableSelectionTable
          title=""
          heading={getDetailFieldsForTableSections->Array.map(EntriesTableEntity.getHeading)}
          getSectionRowDetails={(sectionIndex, rowIndex) =>
            getSectionRowDetails(
              ~sectionIndex,
              ~rowIndex,
              ~groupedEntries=groupedEntries->convertGroupedEntriesToEntryType,
            )}
          showScrollBar=true
          showOptions=true
          selectedRows
          onRowSelect=handleRowSelect
          sections={getEntriesSections(
            ~groupedEntries,
            ~accountInfoMap,
            ~detailsFields=getDetailFieldsForTableSections,
          )->Array.mapWithIndex((section, idx) => {
            let accountIds = groupedEntries->Dict.keysToArray
            let accountId = accountIds->getValueFromArray(idx, "")
            let entriesWithUniqueId = groupedEntries->getValueFromDict(accountId, [])
            {
              ...section,
              rowData: entriesWithUniqueId->Array.map(entry => entry->Identity.genericTypeToJson),
            }
          })}
          ?isRowSelectable
        />
      </RenderIf>
      <RenderIf condition={!inSelectMode}>
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
          {entriesByAccount
          ->Array.map(((accountId, entries)) => {
            let accountName =
              accountInfoMap
              ->Dict.get(accountId)
              ->Option.map(a => a.account_info_name)
              ->Option.getOr(accountId)
            <div
              key={accountId}
              className="rounded-2xl border border-nd_gray-150 bg-white px-5 py-4 flex flex-col gap-3.5">
              <div className="flex flex-row items-baseline justify-between">
                <span
                  className={`${body.sm.semibold} text-nd_gray-600 uppercase tracking-wider truncate`}>
                  {accountName->React.string}
                </span>
                <span className={`${body.xs.medium} text-nd_gray-400 tabular-nums flex-shrink-0`}>
                  {`${entries->Array.length->Int.toString} entries`->React.string}
                </span>
              </div>
              <div className="flex flex-col gap-3">
                {entries
                ->Array.map(entry => {
                  let initial = entriesList->Array.find(e => e.entry_id === entry.entry_id)
                  let isNew = entry.entry_id === "-"
                  <EntryCard key={entry.entry_key} entry initialEntry=initial isNew />
                })
                ->React.array}
              </div>
            </div>
          })
          ->React.array}
        </div>
      </RenderIf>
    </section>

  /* Right rail — resolution playbook. */
  let resolutionRail =
    <aside
      className="hidden lg:flex flex-shrink-0 w-[380px] flex-col bg-white border-l border-nd_gray-150 overflow-y-auto">
      <div className="px-5 py-5 flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h3 className={`${heading.sm.semibold} text-nd_gray-800`}>
            {"Resolve this exception"->React.string}
          </h3>
          <p className={`${body.sm.medium} text-nd_gray-500`}>
            {"Pick a path. Reversible actions surface first, irreversible ones at the bottom."->React.string}
          </p>
        </div>
        <RenderIf condition={availableResolutions->Array.length === 0}>
          <div className="rounded-xl border border-nd_gray-150 bg-nd_gray-25 p-4 text-center">
            <p className={`${body.sm.medium} text-nd_gray-500`}>
              {"No resolutions available for this exception."->React.string}
            </p>
          </div>
        </RenderIf>
        <RenderIf condition={recommendedAvailable && !hasPendingChanges}>
          <ACLDiv
            authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
            onClick={_ => handleResolutionPick(recommendedAction)}
            noAccessDescription="You don't have permission to perform this action.">
            <ResolutionCard
              action=recommendedAction
              recommended=true
              onClick={() => handleResolutionPick(recommendedAction)}
            />
          </ACLDiv>
        </RenderIf>
        <RenderIf
          condition={otherActions->Array.length > 0 &&
          !hasPendingChanges &&
          !(recommendedAvailable && !showAllOptions)}>
          <div className="flex flex-col gap-2.5">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
              {"Other options"->React.string}
            </span>
            {otherActions
            ->Array.map(action => {
              let isMarkAsReceived = action === Ett.MarkAsReceived
              let availableForMark = !isMarkAsReceived || markAsReceivedAvailable
              <ACLDiv
                key={action->resolutionLabel}
                authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
                onClick={_ =>
                  if availableForMark {
                    handleResolutionPick(action)
                  }}
                noAccessDescription="You don't have permission to perform this action.">
                <ResolutionCard
                  action
                  disabled={!availableForMark}
                  onClick={() =>
                    if availableForMark {
                      handleResolutionPick(action)
                    }}
                />
              </ACLDiv>
            })
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf
          condition={recommendedAvailable &&
          otherActions->Array.length > 0 &&
          !showAllOptions &&
          !hasPendingChanges}>
          <button
            type_="button"
            onClick={_ => setShowAllOptions(_ => true)}
            className={`${body.sm.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 self-start`}>
            {`See ${otherActions
              ->Array.length
              ->Int.toString} other option${otherActions->Array.length > 1
                ? "s"
                : ""} ↓`->React.string}
          </button>
        </RenderIf>
        <RenderIf condition={hasPendingChanges}>
          <div
            className="rounded-xl border border-nd_orange-200 bg-nd_orange-50/40 px-4 py-3.5 flex flex-col gap-3">
            <div className="flex flex-row items-center gap-2.5">
              <Icon name="nd-alert-circle" size=18 customIconColor="#E67333" />
              <span className={`${body.sm.semibold} text-nd_orange-800`}>
                {"Pending changes"->React.string}
              </span>
            </div>
            <p className={`${body.sm.medium} text-nd_gray-600`}>
              {"Review your edits in the entries panel. When ready, confirm to apply them."->React.string}
            </p>
            <div className="flex flex-row gap-2">
              <Button
                text="Discard"
                buttonType=Secondary
                buttonSize=Small
                customButtonStyle="flex-1 !justify-center"
                onClick={_ => onDiscardChanges()}
              />
              <Button
                text="Confirm resolution"
                buttonType=Primary
                buttonSize=Small
                customButtonStyle="flex-1 !justify-center"
                onClick={_ => setShowConfirmationModal(_ => true)}
              />
            </div>
          </div>
        </RenderIf>
        <RenderIf condition={inSelectMode}>
          <div
            className="rounded-xl border border-nd_primary_blue-200 bg-nd_primary_blue-50/40 px-4 py-3.5 flex flex-col gap-3">
            <span className={`${body.sm.semibold} text-nd_primary_blue-800`}>
              {selectionPrompt->React.string}
            </span>
            <p className={`${body.xs.medium} text-nd_gray-600`}>
              {"Tap a row in the entries panel, then continue."->React.string}
            </p>
            <div className="flex flex-row gap-2">
              <Button
                text="Cancel"
                buttonType=Secondary
                buttonSize=Small
                customButtonStyle="flex-1 !justify-center"
                onClick={_ => onDiscardChanges()}
              />
              <Button
                text="Continue"
                buttonType=Primary
                buttonSize=Small
                customButtonStyle="flex-1 !justify-center"
                buttonState={selectedRows->Array.length > 0 ? Normal : Disabled}
                onClick={_ => openModalForCurrentStage()}
              />
            </div>
          </div>
        </RenderIf>
      </div>
    </aside>

  <PageLoaderWrapper
    screenState
    customUI={<NoDataFound message="Exception not found in our record." renderType=NotFound />}>
    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      <div
        className="flex flex-row items-center justify-between gap-2 px-6 pt-5 pb-3 bg-white flex-shrink-0">
        <div className="flex flex-col gap-1.5 min-w-0">
          <BreadCrumbNavigation
            path=[{title: "Recon Exceptions", link: "/v1/recon-engine/exceptions/recon"}]
            currentPageTitle=id
          />
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight truncate`}>
            {"Resolve exception"->React.string}
          </p>
        </div>
      </div>
      <div className="flex flex-row flex-1 min-h-0 border-t border-nd_gray-150">
        {leftRail}
        {entriesCenter}
        {resolutionRail}
      </div>
    </div>
    <ResolutionModal
      exceptionStage
      setExceptionStage
      setSelectedRows
      activeModal
      setActiveModal
      config={getResolutionModalConfig(exceptionStage)}>
      {switch exceptionStage {
      | Ett.ResolvingException(Ett.VoidTransaction) =>
        <ReconEngineExceptionTransactionResolution.IgnoreTransactionModalContent
          onSubmit=onIgnoreTransactionSubmit setExceptionStage setShowModal=setActiveModal
        />
      | Ett.ResolvingException(Ett.ForceReconcile) =>
        <ReconEngineExceptionTransactionResolution.ForceReconcileModalContent
          onSubmit=onForceReconcileSubmit setExceptionStage setShowModal=setActiveModal
        />
      | Ett.ResolvingException(EditEntry) =>
        <ReconEngineExceptionTransactionResolution.EditEntryModalContent
          entryDetails=entryForSelection
          isNewlyCreatedEntry
          updatedEntriesList={isNewlyCreatedEntry
            ? entriesList->addUniqueIdsToEntries->Array.map(getEntryTypeFromExceptionEntryType)
            : updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
          onSubmit=onEditEntrySubmit
        />
      | Ett.ResolvingException(Ett.MarkAsReceived) =>
        <ReconEngineExceptionTransactionResolution.MarkAsReceivedModalContent
          entryDetails=entryForSelection
          isNewlyCreatedEntry
          updatedEntriesList={isNewlyCreatedEntry
            ? entriesList->addUniqueIdsToEntries->Array.map(getEntryTypeFromExceptionEntryType)
            : updatedEntriesList->Array.map(getEntryTypeFromExceptionEntryType)}
          onSubmit=onMarkAsReceivedSubmit
        />
      | Ett.ResolvingException(Ett.CreateNewEntry) =>
        <ReconEngineExceptionTransactionResolution.CreateEntryModalContent
          entriesList={entriesList
          ->addUniqueIdsToEntries
          ->Array.map(getEntryTypeFromExceptionEntryType)}
          onSubmit=onCreateEntrySubmit
          entryDetails=entryForSelection
        />
      | Ett.ResolvingException(Ett.LinkStagingEntriesToTransaction) =>
        <ReconEngineExceptionTransactionResolution.LinkStagingEntryModalContent
          entryDetails=entryForSelection
          accountsData
          currentExceptionDetails=currentExceptionsDetails
          activeModal
          setActiveModal
          onSubmit=onReplaceEntrySubmit
          updatedEntriesList
        />
      | _ => React.null
      }}
    </ResolutionModal>
    <Modal
      setShowModal=setShowConfirmationModal
      showModal=showConfirmationModal
      closeOnOutsideClick=true
      onCloseClickCustomFun={() => setShowConfirmationModal(_ => false)}
      modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
      childClass="mx-4 mb-4 h-full"
      modalHeadingClass={`${heading.sm.semibold} text-nd_gray-700`}
      modalHeading="Resolve Exception">
      <div className="flex flex-col gap-4">
        <Form
          onSubmit=onConfirmResolveSubmit
          validate={validateReasonField}
          initialValues={Dict.make()->JSON.Encode.object}>
          {reasonMultiLineTextInputField(~label="Add Remark")}
          <ConfirmDiff originalEntries=entriesList updatedEntries=updatedEntriesList />
          <div className="flex justify-end gap-3 mt-4 items-center">
            <Button
              buttonType=Secondary
              buttonSize=Medium
              text="Cancel"
              customButtonStyle="!w-fit mt-4"
              onClick={_ => setShowConfirmationModal(_ => false)}
            />
            <FormRenderer.SubmitButton
              text="Confirm & Resolve" buttonType=Primary customSubmitButtonStyle="!w-fit mt-4"
            />
          </div>
        </Form>
      </div>
    </Modal>
    <Modal
      setShowModal=setShowFullAudit
      showModal=showFullAudit
      closeOnOutsideClick=true
      modalClass="flex flex-col justify-start h-screen w-1/2 float-right overflow-hidden !bg-white"
      childClass="relative h-full flex flex-col overflow-y-auto p-6"
      modalHeadingClass={`${heading.sm.semibold} text-nd_gray-700`}
      modalHeading="Audit Trail">
      <AuditTrail allTransactionDetails=allExceptionDetails />
    </Modal>
  </PageLoaderWrapper>
}
