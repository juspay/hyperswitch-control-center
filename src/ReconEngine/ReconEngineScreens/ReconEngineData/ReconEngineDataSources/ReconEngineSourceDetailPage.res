open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module SourceCard = {
  @react.component
  let make = (
    ~config: ingestionConfigType,
    ~accountLabel: string="",
    ~active: bool,
    ~onSelect: ingestionConfigType => unit,
  ) => {
    let kind = sourceTypeFromConfig(config)
    let border = active
      ? "border-nd_primary_blue-500 ring-1 ring-nd_primary_blue-200"
      : "border-nd_gray-150 hover:border-nd_gray-300"
    let subtitle =
      accountLabel === "" ? kind->sourceTypeLabel : `${kind->sourceTypeLabel} · ${accountLabel}`

    <button
      type_="button"
      onClick={_ => onSelect(config)}
      className={`text-left w-full rounded-xl border ${border} bg-white px-3.5 py-3 flex flex-row items-center gap-3 transition-colors`}>
      <div className="w-9 h-9 rounded-md bg-nd_gray-50 grid place-items-center flex-shrink-0">
        <Icon name={kind->sourceTypeIcon} size=18 customIconColor="#606B85" />
      </div>
      <div className="flex flex-col gap-0.5 min-w-0 flex-1">
        <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
          {config.name->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
          {subtitle->React.string}
        </span>
      </div>
      <span
        className={`w-2 h-2 rounded-full flex-shrink-0 ${config.is_active
            ? "bg-nd_green-500"
            : "bg-nd_gray-300"}`}
      />
    </button>
  }
}

module UploadWidget = {
  @react.component
  let make = (~config: ingestionConfigType, ~onUploaded: unit => unit) => {
    open APIUtils
    open FormDataUtils
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let hasManageAccess =
      userHasAccess(~groupAccess=UserManagementTypes.ReconSourcesManage) === Access
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()

    let (selectedFile, setSelectedFile) = React.useState(_ => None)
    let (isUploading, setIsUploading) = React.useState(_ => false)
    let fileInputRef = React.useRef(Js.Nullable.null)

    let clearInput = () =>
      fileInputRef.current
      ->Nullable.toOption
      ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))

    let onPick = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(value) =>
        let fileSize = value["size"]
        if fileSize > 10 * 1024 * 1024 {
          showToast(~message="File size should be less than 10MB", ~toastType=ToastError)
          setSelectedFile(_ => None)
        } else {
          setSelectedFile(_ => Some(value))
        }
      | None => setSelectedFile(_ => None)
      }
    }

    let upload = async () =>
      switch selectedFile {
      | None => showToast(~message="Please select a file to upload.", ~toastType=ToastError)
      | Some(file) =>
        try {
          setIsUploading(_ => true)
          let url = getURL(
            ~entityName=V1(HYPERSWITCH_RECON),
            ~methodType=Post,
            ~hyperswitchReconType=#FILE_UPLOAD,
            ~id=Some(config.ingestion_id),
          )
          let formData = formData()
          append(formData, "file", file)
          let _ = await updateDetails(
            ~bodyFormData=formData,
            url,
            Dict.make()->JSON.Encode.object,
            Post,
            ~contentType=AuthHooks.Unknown,
          )
          showToast(~message="File uploaded successfully.", ~toastType=ToastSuccess)
          setSelectedFile(_ => None)
          clearInput()
          setIsUploading(_ => false)
          onUploaded()
        } catch {
        | _ =>
          showToast(~message="An error occurred while uploading the file.", ~toastType=ToastError)
          clearInput()
          setIsUploading(_ => false)
        }
      }

    let cursor = hasManageAccess ? "cursor-pointer" : "cursor-not-allowed"

    <div className="flex flex-col gap-3">
      <input
        ref={fileInputRef->ReactDOM.Ref.domRef}
        type_="file"
        accept=".csv,.ext,.xlsx"
        disabled={!hasManageAccess}
        onChange={ev => ev->onPick}
        hidden=true
        id="reconEngineSourceUpload"
      />
      <label
        htmlFor="reconEngineSourceUpload"
        className={`flex flex-col items-center justify-center w-full rounded-xl border border-dashed border-nd_gray-300 bg-nd_gray-50/40 ${cursor} hover:border-nd_gray-400 transition-colors px-6 py-10 gap-4`}>
        <div
          className="w-12 h-12 rounded-full bg-white border border-nd_gray-150 grid place-items-center">
          <Icon name="nd-upload-up" size=20 customIconColor="#606B85" />
        </div>
        <div className="flex flex-col gap-1 items-center text-center">
          <span className={`${body.md.semibold} text-nd_gray-800`}>
            {"Choose a file or drag it here"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-500`}>
            {".csv, .ext, .xlsx · up to 10 MB"->React.string}
          </span>
        </div>
        <span
          className={`${body.sm.semibold} text-nd_gray-700 border border-nd_gray-200 bg-white px-3 py-1.5 rounded-md`}>
          {"Browse files"->React.string}
        </span>
      </label>
      {switch selectedFile {
      | Some(file) =>
        <div
          className="rounded-xl border border-nd_gray-150 bg-white px-3.5 py-3 flex flex-row items-center gap-3">
          <Icon name="nd-file" size=18 customIconColor="#606B85" />
          <div className="flex flex-col gap-0.5 min-w-0 flex-1">
            <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
              {file["name"]->React.string}
            </span>
            <span className={`${body.xs.medium} text-nd_gray-500`}>
              {`${(file["size"] / 1024)->Int.toString} KB`->React.string}
            </span>
          </div>
          <ACLButton
            authorization={userHasAccess(~groupAccess=UserManagementTypes.ReconSourcesManage)}
            text={isUploading ? "Uploading…" : "Upload"}
            buttonType=Primary
            buttonSize=Small
            buttonState={isUploading ? Loading : Normal}
            onClick={_ => upload()->ignore}
          />
        </div>
      | None => React.null
      }}
    </div>
  }
}

module ReadOnlyConfig = {
  @react.component
  let make = (~config: ingestionConfigType) => {
    open LogicUtils
    let dataDict = config.data->getDictFromJsonObject
    let pairs =
      getKeyValuePairsFromDict(dataDict)->Array.filter(((k, _)) =>
        !(k->titleToSnake === "ingestion_type")
      )
    let kind = sourceTypeFromConfig(config)

    <div className="flex flex-col gap-4">
      <div className="grid grid-cols-2 gap-x-6 gap-y-5">
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Source type"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700`}>
            {kind->sourceTypeLabel->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Status"->React.string}
          </span>
          <div className="flex flex-row items-center gap-2">
            <span
              className={`w-2 h-2 rounded-full ${config.is_active
                  ? "bg-nd_green-500"
                  : "bg-nd_gray-300"}`}
            />
            <span className={`${body.sm.medium} text-nd_gray-700`}>
              {(config.is_active ? "Active" : "Inactive")->React.string}
            </span>
          </div>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Last sync"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
            {(
              config.last_synced_at->isNonEmptyString ? config.last_synced_at : "—"
            )->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Ingestion ID"->React.string}
          </span>
          <HelperComponents.CopyTextCustomComp
            customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
            displayValue=Some(config.ingestion_id)
          />
        </div>
        {pairs
        ->Array.map(((k, v)) =>
          <div key={k} className="flex flex-col gap-1 min-w-0">
            <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
              {k->React.string}
            </span>
            <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
              {v->React.string}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

module HistoryRow = {
  @react.component
  let make = (~ingestion: ingestionHistoryType) =>
    <tr className="border-b border-nd_gray-100">
      <td className="py-3 px-4 align-middle">
        <span className={`${body.sm.semibold} text-nd_gray-800 font-mono truncate block`}>
          {ingestion.file_name->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-28 align-middle">
        <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
          {ingestion.created_at->formatRelativeTime->React.string}
        </span>
      </td>
      <td className="py-3 px-4 w-32 align-middle">
        <TagBinding
          text={ingestion.status->getIngestionLabel}
          color={ingestion.status->getIngestionTagColor}
          variant=Subtle
          size=Xs
        />
      </td>
      <td className="py-3 px-4 w-24 align-middle text-right">
        <button
          type_="button"
          onClick={_ =>
            RescriptReactRouter.push(
              GlobalVars.appendDashboardPath(
                ~url=`/v1/recon-engine/sources?file=${ingestion.ingestion_history_id}`,
              ),
            )}
          className={`${body.xs.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 uppercase tracking-wider`}>
          {"View"->React.string}
        </button>
      </td>
    </tr>
}

module HistoryTable = {
  @react.component
  let make = (~items: array<ingestionHistoryType>) =>
    items->Array.length === 0
      ? <div
          className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-6 rounded-xl border border-dashed border-nd_gray-200 text-center`}>
          {"No files have been ingested for this source yet."->React.string}
        </div>
      : <div className="rounded-xl border border-nd_gray-150 bg-white overflow-hidden">
          <table className="w-full border-separate border-spacing-0">
            <thead>
              <tr className="bg-nd_gray-50 border-b border-nd_gray-150">
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                  {"File"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-28`}>
                  {"Received"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-32`}>
                  {"Status"->React.string}
                </th>
                <th className="py-2.5 px-4 w-24" />
              </tr>
            </thead>
            <tbody>
              {items
              ->Array.map(it => <HistoryRow key={it.ingestion_history_id} ingestion=it />)
              ->React.array}
            </tbody>
          </table>
        </div>
}

@react.component
let make = (~accountId: string) => {
  open APIUtils
  open LogicUtils

  /* accountId === "" → "manage" mode: rail shows every source from every account.
     Otherwise the rail still shows every source but the page-level context (header,
     account chip) is scoped to the supplied account. Selection lives in the URL so
     deep links and back/forward work. */
  let isManageMode = accountId === ""

  let url = RescriptReactRouter.useUrl()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let (accountsList, setAccountsList) = React.useState(_ => [])
  let (allConfigs, setAllConfigs) = React.useState(_ => [])
  let (history, setHistory) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (refreshTick, setRefreshTick) = React.useState(_ => 0)

  let selectedFromUrl = url.search->getDictFromUrlSearchParams->getOptionValFromDict("source")
  let (selectedIngestionId, setSelectedIngestionId) = React.useState(_ => selectedFromUrl)

  let setSelected = (cfg: ingestionConfigType) => {
    setSelectedIngestionId(_ => Some(cfg.ingestion_id))
    /* Always anchor the URL to the source's own account so refresh + share work. */
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(
        ~url=`/v1/recon-engine/sources/${cfg.account_id}?source=${cfg.ingestion_id}`,
      ),
    )
  }

  let fetchConfigsForAccount = async (id: string) => {
    try {
      let cfgUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~queryParameters=Some(`account_id=${id}`),
      )
      let res = await fetchDetails(cfgUrl)
      res->getArrayDataFromJson(ReconEngineUtils.ingestionConfigItemToObjMapper)
    } catch {
    | _ => []
    }
  }

  let loadAll = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      /* Always load every account so the rail can show all sources globally. */
      let accts = await getAccounts()
      setAccountsList(_ => accts)

      let cfgArrays = await Promise.all(accts->Array.map(a => fetchConfigsForAccount(a.account_id)))
      let flat = cfgArrays->Array.reduce([], (acc, arr) => Array.concat(acc, arr))
      let sorted = flat->Array.toSorted((a, b) => compareLogic(b.created_at, a.created_at))
      setAllConfigs(_ => sorted)

      /* Default-select: if URL didn't already pick one, choose the first source
       belonging to the current account (or the first overall in manage mode). */
      switch selectedIngestionId {
      | Some(_) => ()
      | None => {
          let pool = isManageMode ? sorted : sorted->Array.filter(c => c.account_id === accountId)
          switch pool->Array.get(0) {
          | Some(first) => {
              setSelectedIngestionId(_ => Some(first.ingestion_id))
              RescriptReactRouter.replace(
                GlobalVars.appendDashboardPath(
                  ~url=`/v1/recon-engine/sources/${first.account_id}?source=${first.ingestion_id}`,
                ),
              )
            }
          | None => ()
          }
        }
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load sources"))
    }
  }

  React.useEffect0(() => {
    loadAll()->ignore
    None
  })

  React.useEffect(() => {
    switch selectedIngestionId {
    | Some(id) => {
        let load = async () => {
          try {
            let res = await getIngestionHistory(~queryParameters=Some(`ingestion_id=${id}`))
            let latest =
              res
              ->ReconEngineDataStatusUtils.dedupeToLatest
              ->Array.toSorted((a, b) => LogicUtils.compareLogic(b.created_at, a.created_at))
            setHistory(_ => latest)
          } catch {
          | _ => setHistory(_ => [])
          }
        }
        load()->ignore
      }
    | None => setHistory(_ => [])
    }
    None
  }, (selectedIngestionId, refreshTick))

  let selectedConfig =
    selectedIngestionId->Option.flatMap(id => allConfigs->Array.find(c => c.ingestion_id === id))

  let accountFor = (id: string) => accountsList->Array.find(a => a.account_id === id)

  let selectedAccount = selectedConfig->Option.flatMap(c => accountFor(c.account_id))

  let breadcrumbs: array<BreadCrumbNavigation.breadcrumb> = [
    {title: "Sources", link: "/v1/recon-engine/sources"},
  ]
  let pageTitle = isManageMode
    ? "Manage sources"
    : selectedAccount->Option.map(a => a.account_name)->Option.getOr("Account")
  let pageSubtitle = selectedAccount->Option.map(a => a.currency)->Option.getOr("")

  let header =
    <div
      className="flex flex-col gap-2 px-6 pt-5 pb-4 bg-white flex-shrink-0 border-b border-nd_gray-150">
      <BreadCrumbNavigation path=breadcrumbs currentPageTitle={pageTitle} />
      <div className="flex flex-row justify-between items-center">
        <div className="flex flex-row items-baseline gap-2.5">
          <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
            {pageTitle->React.string}
          </p>
          <RenderIf condition={pageSubtitle !== ""}>
            <span className={`${body.md.medium} text-nd_gray-500`}>
              {`· ${pageSubtitle}`->React.string}
            </span>
          </RenderIf>
        </div>
        <Button
          text="Add new source"
          buttonType=Primary
          buttonSize=Small
          buttonState=Disabled
          leftIcon={CustomIcon(<Icon name="nd-plus" size=14 className="text-white" />)}
          onClick={_ => ()}
        />
      </div>
    </div>

  let pageBody = switch selectedConfig {
  | None =>
    <div className="flex flex-col items-center justify-center text-center px-8 py-20 gap-3">
      <div className="w-12 h-12 rounded-full bg-nd_gray-50 grid place-items-center">
        <Icon name="nd-upload-up" size=22 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.lg.semibold} text-nd_gray-600`}>
        {(isManageMode ? "Pick a source" : "No sources configured yet")->React.string}
      </p>
      <p className={`${body.sm.medium} text-nd_gray-400 max-w-xs`}>
        {(
          isManageMode
            ? "Choose a source from the list on the left to upload a file or review its configuration."
            : "Create a source for this account to start ingesting files."
        )->React.string}
      </p>
    </div>
  | Some(cfg) => {
      let kind = sourceTypeFromConfig(cfg)
      let isManual = switch kind {
      | ManualUpload => true
      | _ => false
      }
      <div className="flex flex-col gap-6 p-6">
        <div className="flex flex-row items-center gap-3">
          <div
            className="w-10 h-10 rounded-lg bg-nd_gray-50 border border-nd_gray-150 grid place-items-center">
            <Icon name={kind->sourceTypeIcon} size=18 customIconColor="#606B85" />
          </div>
          <div className="flex flex-col gap-0.5">
            <span className={`${heading.md.semibold} text-nd_gray-800`}>
              {cfg.name->React.string}
            </span>
            <span className={`${body.xs.medium} text-nd_gray-500`}>
              {kind->sourceTypeLabel->React.string}
            </span>
          </div>
          <div className="flex-1" />
          <TagBinding
            text={cfg.is_active ? "Active" : "Inactive"}
            color={cfg.is_active ? Success : Neutral}
            variant=Subtle
            size=Sm
          />
        </div>
        <div className="h-px bg-nd_gray-150" />
        {isManual
          ? <UploadWidget config=cfg onUploaded={() => setRefreshTick(t => t + 1)} />
          : <ReadOnlyConfig config=cfg />}
        <div className="flex flex-col gap-3">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Recent files"->React.string}
          </span>
          <HistoryTable items=history />
        </div>
      </div>
    }
  }

  <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
    {header}
    <PageLoaderWrapper screenState>
      <div className="flex flex-row flex-1 min-h-0">
        <aside
          className="w-[320px] flex-shrink-0 bg-white border-r border-nd_gray-150 p-4 flex flex-col gap-2 overflow-y-auto">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider pb-1`}>
            {`Sources · ${allConfigs->Array.length->Int.toString}`->React.string}
          </span>
          {allConfigs->Array.length === 0
            ? <span className={`${body.sm.medium} text-nd_gray-400`}>
                {"No sources yet."->React.string}
              </span>
            : allConfigs
              ->Array.map(c => {
                let acctLabel =
                  accountFor(c.account_id)
                  ->Option.map(a => a.account_name)
                  ->Option.getOr("")
                <SourceCard
                  key={c.ingestion_id}
                  config=c
                  accountLabel={acctLabel}
                  active={selectedIngestionId === Some(c.ingestion_id)}
                  onSelect=setSelected
                />
              })
              ->React.array}
        </aside>
        <section className="flex-1 flex flex-col min-w-0 bg-white overflow-y-auto">
          {pageBody}
        </section>
      </div>
    </PageLoaderWrapper>
  </div>
}
