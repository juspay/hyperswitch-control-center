open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module ConfigRow = {
  @react.component
  let make = (
    ~config: transformationConfigType,
    ~accountName: string,
    ~active: bool,
    ~onSelect: string => unit,
  ) => {
    let border = active
      ? "border-nd_primary_blue-500 ring-1 ring-nd_primary_blue-200"
      : "border-nd_gray-150 hover:border-nd_gray-300"
    <button
      type_="button"
      onClick={_ => onSelect(config.transformation_id)}
      className={`text-left w-full rounded-xl border ${border} bg-white px-3.5 py-3 flex flex-col gap-1 transition-colors`}>
      <div className="flex flex-row items-center gap-2">
        <span className={`${body.sm.semibold} text-nd_gray-800 truncate flex-1 min-w-0`}>
          {config.name->React.string}
        </span>
        <span
          className={`w-2 h-2 rounded-full flex-shrink-0 ${config.is_active
              ? "bg-nd_green-500"
              : "bg-nd_gray-300"}`}
        />
      </div>
      <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
        {accountName->React.string}
      </span>
    </button>
  }
}

module MappingTable = {
  /* Renders the file-column → system-field mapping inline. No modal. */
  @react.component
  let make = (~schemaOpt: option<metadataSchemaType>) =>
    switch schemaOpt {
    | None =>
      <div
        className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-6 rounded-xl border border-dashed border-nd_gray-200 text-center`}>
        {"No schema attached to this transformation."->React.string}
      </div>
    | Some(schema) => {
        let mainRows =
          schema.schema_data.fields.main_fields->Array.map(m => (
            m.identifier,
            m.field_name,
            "core",
          ))
        let metaRows = schema.schema_data.fields.metadata_fields->Array.map(m => {
          let label = switch m.field_name {
          | String => m.identifier
          | Metadata(k) => `metadata.${k}`
          }
          (m.identifier, label, m.required ? "required" : "optional")
        })
        let rows = Array.concat(mainRows, metaRows)

        <div className="rounded-xl border border-nd_gray-150 bg-white overflow-hidden">
          <table className="w-full border-separate border-spacing-0">
            <thead>
              <tr className="bg-nd_gray-50 border-b border-nd_gray-150">
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                  {"File column"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                  {"System field"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-24`}>
                  {""->React.string}
                </th>
              </tr>
            </thead>
            <tbody>
              {rows
              ->Array.mapWithIndex(((fileCol, sysField, tag), idx) =>
                <tr key={idx->Int.toString} className="border-b border-nd_gray-100">
                  <td className="py-3 px-4 align-middle">
                    <span className={`${body.sm.medium} text-nd_gray-700 font-mono truncate block`}>
                      {fileCol->React.string}
                    </span>
                  </td>
                  <td className="py-3 px-4 align-middle">
                    <span className={`${body.sm.medium} text-nd_gray-700 truncate block`}>
                      {sysField->React.string}
                    </span>
                  </td>
                  <td className="py-3 px-4 align-middle w-24">
                    <span
                      className={`${body.xs.semibold} px-2 py-0.5 rounded uppercase tracking-wider ${tag === "core"
                          ? "bg-nd_primary_blue-50 text-nd_primary_blue-600"
                          : tag === "required"
                          ? "bg-nd_orange-50 text-nd_orange-600"
                          : "bg-nd_gray-100 text-nd_gray-500"}`}>
                      {tag->React.string}
                    </span>
                  </td>
                </tr>
              )
              ->React.array}
            </tbody>
          </table>
        </div>
      }
    }
}

module RunsTable = {
  @react.component
  let make = (~runs: array<transformationHistoryType>) =>
    runs->Array.length === 0
      ? <div
          className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-6 rounded-xl border border-dashed border-nd_gray-200 text-center`}>
          {"No transformation runs yet."->React.string}
        </div>
      : <div className="rounded-xl border border-nd_gray-150 bg-white overflow-hidden">
          <table className="w-full border-separate border-spacing-0">
            <thead>
              <tr className="bg-nd_gray-50 border-b border-nd_gray-150">
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
                  {"Run"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-32`}>
                  {"Created"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-40`}>
                  {"Result"->React.string}
                </th>
                <th
                  className={`py-2.5 px-4 text-left ${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider w-32`}>
                  {"Status"->React.string}
                </th>
              </tr>
            </thead>
            <tbody>
              {runs
              ->Array.map(r =>
                <tr key={r.transformation_history_id} className="border-b border-nd_gray-100">
                  <td className="py-3 px-4 align-middle">
                    <span
                      className={`${body.sm.medium} text-nd_gray-700 font-mono truncate block max-w-[260px]`}>
                      {r.transformation_history_id->React.string}
                    </span>
                  </td>
                  <td className="py-3 px-4 w-32 align-middle">
                    <span className={`${body.sm.medium} text-nd_gray-500 tabular-nums`}>
                      {r.created_at->formatRelativeTime->React.string}
                    </span>
                  </td>
                  <td className="py-3 px-4 w-40 align-middle">
                    <span className={`${body.xs.medium} text-nd_gray-500`}>
                      <span className="font-mono tabular-nums text-nd_gray-700">
                        {r.data.transformed_count->Int.toString->React.string}
                      </span>
                      {" created · "->React.string}
                      <span
                        className={`font-mono tabular-nums ${r.data.errors->Array.length > 0
                            ? "text-nd_red-600"
                            : "text-nd_gray-700"}`}>
                        {r.data.errors->Array.length->Int.toString->React.string}
                      </span>
                      {" errors"->React.string}
                    </span>
                  </td>
                  <td className="py-3 px-4 w-32 align-middle">
                    <TagBinding
                      text={r.status->getIngestionLabel}
                      color={r.status->getIngestionTagColor}
                      variant=Subtle
                      size=Xs
                    />
                  </td>
                </tr>
              )
              ->React.array}
            </tbody>
          </table>
        </div>
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let getAccounts = ReconEngineHooks.useGetAccounts()
  let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
  let fetchMetadataSchema = ReconEngineHooks.useFetchMetadataSchema()

  let (accounts, setAccounts) = React.useState(_ => [])
  let (configs, setConfigs) = React.useState(_ => [])
  let (selectedId, setSelectedId) = React.useState(_ => None)
  let (schemaOpt, setSchema) = React.useState(_ => None)
  let (runs, setRuns) = React.useState(_ => [])
  let (showJson, setShowJson) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let loadConfigsForAccount = async (accountId: string) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
        ~queryParameters=Some(`account_id=${accountId}`),
      )
      let res = await fetchDetails(url)
      res->getArrayDataFromJson(ReconEngineUtils.transformationConfigItemToObjMapper)
    } catch {
    | _ => []
    }
  }

  let loadAll = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let accts = await getAccounts()
      setAccounts(_ => accts)
      let cfgsArrays = await Promise.all(accts->Array.map(a => loadConfigsForAccount(a.account_id)))
      let flat = cfgsArrays->Array.reduce([], (acc, arr) => Array.concat(acc, arr))
      let sorted = flat->Array.toSorted((a, b) => compareLogic(b.created_at, a.created_at))
      setConfigs(_ => sorted)
      switch sorted->Array.get(0) {
      | Some(c) => setSelectedId(_ => Some(c.transformation_id))
      | None => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load transformations"))
    }
  }

  React.useEffect0(() => {
    loadAll()->ignore
    None
  })

  React.useEffect(() => {
    switch selectedId {
    | Some(id) => {
        let load = async () => {
          /* Schema */
          try {
            let res = await fetchMetadataSchema(~transformationId=id)
            let dict = res->getDictFromJsonObject
            if dict->Dict.toArray->Array.length > 0 {
              setSchema(_ => Some(dict->ReconEngineUtils.metadataSchemaItemToObjMapper))
            } else {
              setSchema(_ => None)
            }
          } catch {
          | _ => setSchema(_ => None)
          }
          /* Runs */
          try {
            let res = await getTransformationHistory(
              ~queryParameters=Some(`transformation_id=${id}`),
            )
            setRuns(_ => res)
          } catch {
          | _ => setRuns(_ => [])
          }
        }
        load()->ignore
      }
    | None => {
        setSchema(_ => None)
        setRuns(_ => [])
      }
    }
    None
  }, [selectedId])

  let selectedConfig =
    selectedId->Option.flatMap(id => configs->Array.find(c => c.transformation_id === id))

  let accountNameFor = (accountId: string) =>
    accounts
    ->Array.find(a => a.account_id === accountId)
    ->Option.map(a => a.account_name)
    ->Option.getOr("—")

  let header =
    <div
      className="flex flex-row justify-between items-center px-6 pt-5 pb-4 bg-white flex-shrink-0">
      <div className="flex flex-row items-baseline gap-2.5">
        <p className={`${heading.lg.semibold} text-nd_gray-800 tracking-tight`}>
          {"Transformations"->React.string}
        </p>
        <span className={`${body.md.medium} text-nd_gray-500 tabular-nums`}>
          {`· ${configs->Array.length->Int.toString} configured`->React.string}
        </span>
      </div>
      <Button
        text="Add new transformation"
        buttonType=Primary
        buttonSize=Small
        buttonState=Disabled
        leftIcon={CustomIcon(<Icon name="nd-plus" size=14 className="text-white" />)}
        onClick={_ => ()}
      />
    </div>

  let detail = switch selectedConfig {
  | None =>
    <div className={`${body.sm.medium} text-nd_gray-500 p-10`}>
      {"Select a transformation from the left."->React.string}
    </div>
  | Some(cfg) =>
    <div className="flex flex-col gap-6 p-6">
      <div className="flex flex-row items-center gap-3">
        <div className="flex flex-col gap-0.5 min-w-0 flex-1">
          <span className={`${heading.md.semibold} text-nd_gray-800`}>
            {cfg.name->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-500`}>
            {accountNameFor(cfg.account_id)->React.string}
          </span>
        </div>
        <TagBinding
          text={cfg.is_active ? "Active" : "Inactive"}
          color={cfg.is_active ? Success : Neutral}
          variant=Subtle
          size=Sm
        />
      </div>
      <div className="h-px bg-nd_gray-150" />
      <div className="grid grid-cols-2 gap-x-6 gap-y-5">
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Transformation ID"->React.string}
          </span>
          <HelperComponents.CopyTextCustomComp
            customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
            displayValue=Some(cfg.transformation_id)
          />
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Linked ingestion"->React.string}
          </span>
          <HelperComponents.CopyTextCustomComp
            customTextCss={`${body.sm.medium} text-nd_gray-700 font-mono truncate`}
            displayValue=Some(cfg.ingestion_id)
          />
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Last transformed"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
            {(
              cfg.last_transformed_at->isNonEmptyString ? cfg.last_transformed_at : "—"
            )->React.string}
          </span>
        </div>
        <div className="flex flex-col gap-1 min-w-0">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Schema version"->React.string}
          </span>
          <span className={`${body.sm.medium} text-nd_gray-700 tabular-nums`}>
            {schemaOpt
            ->Option.map(s => `v${s.version->Int.toString}`)
            ->Option.getOr("—")
            ->React.string}
          </span>
        </div>
      </div>
      <div className="flex flex-col gap-3">
        <div className="flex flex-row items-center justify-between">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
            {"Column mapping"->React.string}
          </span>
          <RenderIf condition={schemaOpt->Option.isSome}>
            <button
              type_="button"
              onClick={_ => setShowJson(s => !s)}
              className={`${body.xs.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 uppercase tracking-wider`}>
              {(showJson ? "Hide raw schema" : "View raw schema")->React.string}
            </button>
          </RenderIf>
        </div>
        <MappingTable schemaOpt />
        <RenderIf condition={showJson && schemaOpt->Option.isSome}>
          {switch schemaOpt {
          | Some(s) => {
              let raw =
                s.schema_data
                ->Obj.magic
                ->JSON.stringifyWithIndent(2)
              <pre
                className={`${body.xs.medium} text-nd_gray-700 font-mono bg-nd_gray-50 border border-nd_gray-150 rounded-xl px-3 py-3 overflow-x-auto whitespace-pre-wrap break-all max-h-72 overflow-y-auto`}>
                {raw->React.string}
              </pre>
            }
          | None => React.null
          }}
        </RenderIf>
      </div>
      <div className="flex flex-col gap-3">
        <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
          {"Recent runs"->React.string}
        </span>
        <RunsTable runs />
      </div>
    </div>
  }

  <div className="absolute left-0 min-w-full flex flex-col h-[calc(100vh-4rem)] bg-white">
    {header}
    <PageLoaderWrapper screenState>
      <div className="flex flex-row flex-1 min-h-0">
        <aside
          className="w-[320px] flex-shrink-0 bg-white border-r border-nd_gray-150 p-4 flex flex-col gap-2 overflow-y-auto">
          <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider pb-1`}>
            {`Transformations · ${configs->Array.length->Int.toString}`->React.string}
          </span>
          {configs->Array.length === 0
            ? <span className={`${body.sm.medium} text-nd_gray-400`}>
                {"No transformations configured."->React.string}
              </span>
            : configs
              ->Array.map(c =>
                <ConfigRow
                  key={c.transformation_id}
                  config=c
                  accountName={accountNameFor(c.account_id)}
                  active={selectedId === Some(c.transformation_id)}
                  onSelect={id => setSelectedId(_ => Some(id))}
                />
              )
              ->React.array}
        </aside>
        <section className="flex-1 flex flex-col min-w-0 bg-white overflow-y-auto">
          {detail}
        </section>
      </div>
    </PageLoaderWrapper>
  </div>
}
