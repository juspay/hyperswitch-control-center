open Typography
open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsTypes
open ReconEngineTransformedEntryExceptionsStatusUtils

module StatusHero = {
  @react.component
  let make = (~entry: processingEntryType) => {
    let isDebit = entry.entry_type->String.toLowerCase === "debit"
    let typeColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"
    let typeStripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"
    let typeLabel = isDebit ? "DEBIT" : "CREDIT"

    <div className="flex flex-col gap-3">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={entry.status->getEntryLabel}
          color={entry.status->getEntryTagColor}
          variant=Subtle
          size=Sm
        />
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          {`Effective ${entry.effective_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1">
        <div className="flex flex-row items-baseline gap-2 flex-wrap">
          <span
            className={`${body.xs.semibold} ${typeColor} pl-2 border-l-[3px] ${typeStripe} tracking-wider flex-shrink-0`}>
            {typeLabel->React.string}
          </span>
          <span className={`${heading.lg.semibold} text-nd_gray-800 tabular-nums tracking-tight`}>
            {`${entry.currency} ${entry.amount->Float.toString}`->React.string}
          </span>
        </div>
        <RenderIf condition={entry.status === NeedsManualReview}>
          <div
            className="mt-2 rounded-lg border border-nd_orange-200 bg-nd_orange-50/50 p-3 flex flex-col gap-1">
            <span className={`${body.xs.semibold} text-nd_orange-800 uppercase tracking-wider`}>
              {"Manual review reason"->React.string}
            </span>
            <span className={`${body.sm.medium} text-nd_gray-700`}>
              {entry.data.needs_manual_review_type->getNeedsReviewExplanation->React.string}
            </span>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

module MetaBlock = {
  @react.component
  let make = (~entry: processingEntryType) =>
    <div className="grid grid-cols-2 gap-x-4 gap-y-3.5">
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Staging ID"->React.string}
        </span>
        <HelperComponents.CopyTextCustomComp
          customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
          displayValue=Some(entry.staging_entry_id)
        />
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Account"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
          {entry.account.account_name->React.string}
        </span>
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
          {"Version"->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
          {`v${entry.version->Int.toString}`->React.string}
        </span>
      </div>
    </div>
}

module AuditMini = {
  @react.component
  let make = (~versions: array<processingEntryType>, ~onOpenFull: unit => unit) => {
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
                {version.status->getEntryLabel->React.string}
              </span>
              <span className={`${body.xs.medium} text-nd_gray-500`}>
                {`v${version.version->Int.toString} · ${version.effective_at->formatRelativeTime} ago`->React.string}
              </span>
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module EntryCard = {
  @react.component
  let make = (~entry: processingEntryType, ~initial: processingEntryType, ~hasChanges: bool) => {
    let isDebit = entry.entry_type->String.toLowerCase === "debit"
    let typeColor = isDebit ? "text-nd_red-600" : "text-nd_green-600"
    let typeStripe = isDebit ? "border-nd_red-500" : "border-nd_green-400"
    let typeLabel = isDebit ? "DEBIT" : "CREDIT"
    let amountChanged = initial.amount !== entry.amount
    let orderChanged = initial.order_id !== entry.order_id

    <div className="rounded-2xl border border-nd_gray-150 bg-white px-5 py-4 flex flex-col gap-4">
      <div className="flex flex-row items-center justify-between">
        <div className="flex flex-row items-center gap-2.5">
          <span
            className={`${body.xs.semibold} ${typeColor} pl-2 border-l-[3px] ${typeStripe} tracking-wider`}>
            {typeLabel->React.string}
          </span>
          <span className={`${body.sm.semibold} text-nd_gray-700`}>
            {entry.account.account_name->React.string}
          </span>
        </div>
        <RenderIf condition={hasChanges}>
          <span
            className={`${body.xs.semibold} text-nd_orange-700 bg-nd_orange-50 border border-nd_orange-200 px-1.5 py-0.5 rounded uppercase tracking-wider`}>
            {"Edited"->React.string}
          </span>
        </RenderIf>
      </div>
      <div className="grid grid-cols-2 gap-x-4 gap-y-3.5">
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Amount"->React.string}
          </span>
          <div className="flex flex-col gap-0.5">
            {amountChanged
              ? <span
                  className={`${body.xs.medium} text-nd_gray-400 line-through tabular-nums truncate`}>
                  {`${initial.currency} ${initial.amount->Float.toString}`->React.string}
                </span>
              : React.null}
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
            {orderChanged
              ? <span
                  className={`${body.xs.medium} text-nd_gray-400 line-through font-mono truncate`}>
                  {initial.order_id->React.string}
                </span>
              : React.null}
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
            {"Currency"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
            {entry.currency->React.string}
          </span>
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
      </div>
    </div>
  }
}

module ResolutionCard = {
  @react.component
  let make = (
    ~action: resolvingException,
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

module ConfirmDiff = {
  @react.component
  let make = (~initial: processingEntryType, ~updated: processingEntryType) => {
    open ReconEngineTransformedEntryExceptionsUtils
    let summaries = generateResolutionSummary(~currentEntry=initial, ~updatedEntry=updated)
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
  open ReconEngineUtils
  open ReconEngineTransformedEntryExceptionsHelper
  open ReconEngineTransformedEntryExceptionsUtils
  open ReconEngineExceptionsUtils
  open ReconEngineHooks
  open APIUtils

  let getProcessingEntries = useGetProcessingEntries()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentEntry, setCurrentEntry) = React.useState(_ => Dict.make()->processingItemToObjMapper)
  let (updatedEntry, setUpdatedEntry) = React.useState(_ => Dict.make()->processingItemToObjMapper)
  let (allVersions, setAllVersions) = React.useState(_ => [])
  let (availableResolutions, setAvailableResolutions) = React.useState(_ => [])
  let (
    exceptionStage,
    setExceptionStage,
  ) = React.useState(_ => ShowTransformedEntryResolutionOptions(
    NoTransformedEntryResolutionOptionNeeded,
  ))
  let (activeModal, setActiveModal) = React.useState(_ => None)
  let (showConfirmationModal, setShowConfirmationModal) = React.useState(_ => false)
  let (showFullAudit, setShowFullAudit) = React.useState(_ => false)

  let loadDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let list = await getProcessingEntries(~queryParameters=Some(`staging_entry_id=${id}`))
      list->Array.sort(sortByVersion)
      let current = list->getValueFromArray(0, Dict.make()->processingItemToObjMapper)
      setCurrentEntry(_ => current)
      setUpdatedEntry(_ => current)
      setAllVersions(_ => list)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch entry details"))
    }
  }

  let fetchResolutions = async () => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PROCESSING_ENTRY_RESOLUTIONS,
        ~methodType=Get,
        ~id=Some(currentEntry.id),
      )
      let response = await fetchDetails(url)
      let resolutions = parseResolutionActions(response)
      setAvailableResolutions(_ => resolutions)
    } catch {
    | _ => setAvailableResolutions(_ => [])
    }
  }

  React.useEffect(() => {
    loadDetails()->ignore
    None
  }, [])

  React.useEffect(() => {
    if currentEntry.id->isNonEmptyString {
      fetchResolutions()->ignore
    }
    None
  }, [currentEntry.id])

  let isResolutionAvailable = (a: resolvingException) =>
    availableResolutions->Array.some(r => r === a)

  let onDiscard = () => {
    setUpdatedEntry(_ => currentEntry)
    setExceptionStage(_ => ShowTransformedEntryResolutionOptions(
      NoTransformedEntryResolutionOptionNeeded,
    ))
  }

  let pickAction = (a: resolvingException) =>
    switch a {
    | EditTransformedEntry => {
        setExceptionStage(_ => ResolvingTransformedEntry(EditTransformedEntry))
        setActiveModal(_ => Some(EditTransformedEntryModal))
      }
    | VoidTransformedEntry => {
        setExceptionStage(_ => ResolvingTransformedEntry(VoidTransformedEntry))
        setActiveModal(_ => Some(VoidTransformedEntryModal))
      }
    | NoTransformedEntryResolutionNeeded => ()
    }

  let onEditSubmit = (values, _form: ReactFinalForm.formApi) => {
    let formData = values->getDictFromJsonObject
    let updated = getUpdatedEntry(~entryDetails=currentEntry, ~formData)
    setUpdatedEntry(_ => updated)
    setExceptionStage(_ => ConfirmTransformedEntryResolution(EditTransformedEntry))
    setActiveModal(_ => None)
    Promise.resolve(Nullable.null)
  }

  let onVoidSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#VOID_PROCESSING_ENTRY,
        ~methodType=Put,
        ~id=Some(currentEntry.id),
      )
      let body = {"reason": valuesDict->getString("reason", "")}
      let res = await updateDetails(url, body->Identity.genericTypeToJson, Put)
      let processingEntry = res->getDictFromJsonObject->processingItemToObjMapper
      let historyUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~id=Some(currentEntry.transformation_history_id),
      )
      let historyRes = await fetchDetails(historyUrl)
      let historyData = historyRes->getDictFromJsonObject->transformationHistoryItemToObjMapper
      setActiveModal(_ => None)
      setExceptionStage(_ => TransformedEntryExceptionResolved)
      let toastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement
          processingEntry toastKey ingestionHistoryId=historyData.ingestion_history_id
        />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/transformed-entries"),
      )
    } catch {
    | _ => showToast(~message="Failed to ignore entry. Please try again.", ~toastType=ToastError)
    }
    Nullable.null
  }

  let onConfirmSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PROCESSING_ENTRIES_LIST,
        ~methodType=Put,
        ~id=Some(currentEntry.id),
      )
      let body = constructManualReconciliationBody(~updatedEntry, ~values)
      let res = await updateDetails(url, body, Put)
      let processingEntry = res->getDictFromJsonObject->processingItemToObjMapper
      let historyUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~id=Some(currentEntry.transformation_history_id),
      )
      let historyRes = await fetchDetails(historyUrl)
      let historyData = historyRes->getDictFromJsonObject->transformationHistoryItemToObjMapper
      setShowConfirmationModal(_ => false)
      setExceptionStage(_ => TransformedEntryExceptionResolved)
      let toastKey = randomString(~length=32)
      showToast(
        ~toastElement=<CustomToastElement
          processingEntry toastKey ingestionHistoryId=historyData.ingestion_history_id
        />,
        ~message="",
        ~toastType=ToastSuccess,
        ~toastKey,
        ~toastDuration=5000,
      )
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="/v1/recon-engine/exceptions/transformed-entries"),
      )
    } catch {
    | _ => showToast(~message="Failed to update entry. Please try again.", ~toastType=ToastError)
    }
    Nullable.null
  }

  let hasChanges = hasFormValuesChanged(getInitialValuesForEditEntries(updatedEntry), currentEntry)

  let hasPending = exceptionStage == ConfirmTransformedEntryResolution(EditTransformedEntry)

  let recommendedAction = currentEntry.status->getRecommendedResolution
  let recommendedAvailable = switch recommendedAction {
  | NoTransformedEntryResolutionNeeded => false
  | a => isResolutionAvailable(a)
  }

  let allActionsList: array<resolvingException> = [EditTransformedEntry, VoidTransformedEntry]
  let otherActions =
    allActionsList->Array.filter(a => a !== recommendedAction && isResolutionAvailable(a))

  let leftRail =
    <aside className="w-[300px] flex-shrink-0 bg-white border-r border-nd_gray-150 overflow-y-auto">
      <div className="px-6 py-5 flex flex-col gap-5">
        <StatusHero entry=currentEntry />
        <div className="h-px bg-nd_gray-150" />
        <MetaBlock entry=currentEntry />
        <div className="h-px bg-nd_gray-150" />
        <AuditMini versions=allVersions onOpenFull={() => setShowFullAudit(_ => true)} />
      </div>
    </aside>

  let entriesCenter =
    <section className="flex-1 min-w-0 overflow-y-auto bg-nd_gray-25 px-6 py-5 flex flex-col gap-5">
      <div className="flex flex-col gap-0.5">
        <h2 className={`${heading.md.semibold} text-nd_gray-800`}> {"Entry"->React.string} </h2>
        <p className={`${body.sm.medium} text-nd_gray-500`}>
          {"The transformed entry awaiting your decision."->React.string}
        </p>
      </div>
      <EntryCard entry=updatedEntry initial=currentEntry hasChanges />
    </section>

  let resolutionRail =
    <aside
      className="hidden lg:flex flex-shrink-0 w-[380px] flex-col bg-white border-l border-nd_gray-150 overflow-y-auto">
      <div className="px-5 py-5 flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <h3 className={`${heading.sm.semibold} text-nd_gray-800`}>
            {"Resolve this entry"->React.string}
          </h3>
          <p className={`${body.sm.medium} text-nd_gray-500`}>
            {"Edit fixes the data; Ignore drops the entry."->React.string}
          </p>
        </div>
        <RenderIf condition={availableResolutions->Array.length === 0}>
          <div className="rounded-xl border border-nd_gray-150 bg-nd_gray-25 p-4 text-center">
            <p className={`${body.sm.medium} text-nd_gray-500`}>
              {"No resolutions available for this entry."->React.string}
            </p>
          </div>
        </RenderIf>
        <RenderIf condition={recommendedAvailable && !hasPending}>
          <ACLDiv
            authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
            onClick={_ => pickAction(recommendedAction)}
            noAccessDescription="You don't have permission to perform this action.">
            <ResolutionCard
              action=recommendedAction
              recommended=true
              onClick={() => pickAction(recommendedAction)}
            />
          </ACLDiv>
        </RenderIf>
        <RenderIf condition={otherActions->Array.length > 0 && !hasPending}>
          <div className="flex flex-col gap-2.5">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
              {"Other options"->React.string}
            </span>
            {otherActions
            ->Array.map(action =>
              <ACLDiv
                key={action->resolutionLabel}
                authorization={userHasAccess(~groupAccess=ReconExceptionsManage)}
                onClick={_ => pickAction(action)}
                noAccessDescription="You don't have permission to perform this action.">
                <ResolutionCard action onClick={() => pickAction(action)} />
              </ACLDiv>
            )
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf condition={hasPending}>
          <div
            className="rounded-xl border border-nd_orange-200 bg-nd_orange-50/40 px-4 py-3.5 flex flex-col gap-3">
            <div className="flex flex-row items-center gap-2.5">
              <Icon name="nd-alert-circle" size=18 customIconColor="#E67333" />
              <span className={`${body.sm.semibold} text-nd_orange-800`}>
                {"Pending changes"->React.string}
              </span>
            </div>
            <p className={`${body.sm.medium} text-nd_gray-600`}>
              {"Review your edits in the entry panel. When ready, confirm to apply them."->React.string}
            </p>
            <div className="flex flex-row gap-2">
              <Button
                text="Discard"
                buttonType=Secondary
                buttonSize=Small
                customButtonStyle="flex-1 !justify-center"
                onClick={_ => onDiscard()}
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
      </div>
    </aside>

  <PageLoaderWrapper
    screenState customUI={<NoDataFound message="Entry not found." renderType=NotFound />}>
    <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
      <div
        className="flex flex-row items-center justify-between gap-2 px-6 pt-5 pb-3 bg-white flex-shrink-0">
        <div className="flex flex-col gap-1.5 min-w-0">
          <BreadCrumbNavigation
            path=[
              {
                title: "Transformed Entry Exceptions",
                link: "/v1/recon-engine/exceptions/transformed-entries",
              },
            ]
            currentPageTitle=id
          />
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight truncate`}>
            {"Resolve entry"->React.string}
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
      activeModal
      setActiveModal
      exceptionStage
      setExceptionStage
      config={getResolutionModalConfig(exceptionStage)}>
      {switch exceptionStage {
      | ResolvingTransformedEntry(VoidTransformedEntry) =>
        <ReconEngineTransformedEntryExceptionResolution.IgnoreTransactionModalContent
          onSubmit=onVoidSubmit setExceptionStage setShowModal=setActiveModal
        />
      | ResolvingTransformedEntry(EditTransformedEntry) =>
        <ReconEngineTransformedEntryExceptionResolution.EditEntryModalContent
          entryDetails=updatedEntry onSubmit=onEditSubmit
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
          onSubmit=onConfirmSubmit
          validate={validateReasonField}
          initialValues={Dict.make()->JSON.Encode.object}>
          {reasonMultiLineTextInputField(~label="Add Remark")}
          <ConfirmDiff initial=currentEntry updated=updatedEntry />
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
      <AuditTrail allTransactionDetails=allVersions />
    </Modal>
  </PageLoaderWrapper>
}
