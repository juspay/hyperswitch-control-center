open Typography
open ReconEngineTypes
open ReconEngineDataStatusUtils

module EmptyState = {
  @react.component
  let make = () =>
    <div className="flex flex-1 flex-col items-center justify-center text-center px-8 gap-3">
      <div className="w-12 h-12 rounded-full bg-nd_gray-50 flex items-center justify-center">
        <Icon name="nd-reports" size=24 customIconColor="#A1A8B8" />
      </div>
      <p className={`${body.lg.semibold} text-nd_gray-600`}> {"Select a file"->React.string} </p>
      <p className={`${body.sm.medium} text-nd_gray-400 max-w-xs`}>
        {"Pick a row to see its full ingestion, transformation and entry lineage here."->React.string}
      </p>
    </div>
}

module Header = {
  @react.component
  let make = (~onClose: unit => unit) =>
    <div
      className="flex flex-row items-center gap-2 px-5 h-12 border-b border-nd_gray-150 bg-white flex-shrink-0">
      <span className={`${body.sm.medium} text-nd_gray-500 flex-1`}>
        {"File lineage"->React.string}
      </span>
      <button
        type_="button"
        onClick={_ => onClose()}
        className="w-8 h-8 rounded-md border border-nd_gray-150 bg-white text-nd_gray-500 hover:bg-nd_gray-50 grid place-items-center">
        <Icon name="modal-close-icon" size=14 customIconColor="#606B85" />
      </button>
    </div>
}

module Hero = {
  @react.component
  let make = (~ingestion: ingestionHistoryType, ~onDownload: ReactEvent.Mouse.t => unit) => {
    let isDownloadable = switch ingestion.status {
    | Processed => true
    | _ => false
    }

    <div className="flex flex-col gap-4">
      <div className="flex flex-row items-center gap-2.5 flex-wrap">
        <TagBinding
          text={ingestion.status->getIngestionLabel}
          color={ingestion.status->getIngestionTagColor}
          variant=Subtle
          size=Sm
        />
        <span className={`${body.sm.medium} text-nd_gray-500`}>
          {`Received ${ingestion.created_at->formatRelativeTime} ago`->React.string}
        </span>
      </div>
      <div className="flex flex-col gap-1 min-w-0">
        <span className={`${heading.lg.semibold} text-nd_gray-800 font-mono break-all`}>
          {ingestion.file_name->React.string}
        </span>
        <p className={`${body.sm.medium} text-nd_gray-500`}>
          {ingestion.status->getIngestionDescription->React.string}
        </p>
      </div>
      <div className="flex flex-row items-center gap-2">
        <Button
          text="Download file"
          buttonType=Primary
          buttonSize=Small
          buttonState={isDownloadable ? Normal : Disabled}
          customButtonStyle="flex-1"
          leftIcon={CustomIcon(<Icon name="nd-download-down" size=14 className="text-white" />)}
          onClick={onDownload}
        />
        <Button
          text="Reprocess"
          buttonType=Secondary
          buttonSize=Small
          buttonState=Disabled
          leftIcon={CustomIcon(<Icon name="nd-refresh" size=14 />)}
          onClick={_ => ()}
        />
      </div>
    </div>
  }
}

module SectionLabel = {
  @react.component
  let make = (~text: string, ~suffix: string="") =>
    <div className="flex flex-row items-baseline justify-between">
      <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
        {text->React.string}
      </span>
      <RenderIf condition={suffix !== ""}>
        <span className={`${body.xs.medium} text-nd_gray-400`}> {suffix->React.string} </span>
      </RenderIf>
    </div>
}

module KeyValue = {
  @react.component
  let make = (~label: string, ~value: string, ~mono: bool=false, ~copyable: bool=false) => {
    let textCss = mono
      ? `${body.sm.medium} text-nd_gray-700 font-mono truncate`
      : `${body.sm.medium} text-nd_gray-700 truncate`
    <div className="flex flex-col gap-1 min-w-0">
      <span className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wider`}>
        {label->React.string}
      </span>
      {copyable
        ? <HelperComponents.CopyTextCustomComp customTextCss={textCss} displayValue=Some(value) />
        : <span className={textCss}> {value->React.string} </span>}
    </div>
  }
}

module SourceSection = {
  @react.component
  let make = (
    ~configOpt: option<ingestionConfigType>,
    ~ingestion: ingestionHistoryType,
    ~accountName: string,
    ~accountCurrency: string,
  ) => {
    let kind = switch configOpt {
    | Some(c) => sourceTypeFromConfig(c)
    | None => sourceTypeFromRawString(ingestion.upload_type)
    }
    let configName = configOpt->Option.map(c => c.name)->Option.getOr(ingestion.ingestion_name)

    <div className="flex flex-col gap-3">
      <SectionLabel text="Source" />
      <div
        className="rounded-xl border border-nd_gray-150 bg-white px-3.5 py-3 flex flex-row items-center gap-3">
        <div className="w-9 h-9 rounded-md bg-nd_gray-50 grid place-items-center flex-shrink-0">
          <Icon name={kind->sourceTypeIcon} size=18 customIconColor="#606B85" />
        </div>
        <div className="flex flex-col gap-0.5 min-w-0 flex-1">
          <span className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {configName->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-500 truncate`}>
            {`${kind->sourceTypeLabel} · ${accountName} (${accountCurrency})`->React.string}
          </span>
        </div>
      </div>
    </div>
  }
}

module Timeline = {
  /* All versions of this ingestion_history_id, ordered chronologically. The latest
   version's status is the current state; the earlier versions show the journey. */
  type step = {
    label: string,
    timestamp: string,
    color: string,
    iconName: string,
    iconColor: string,
  }

  let buildSteps = (versions: array<ingestionHistoryType>): array<step> => {
    versions->Array.map(v => {
      let state = ReconEngineDataSourcesUtils.getFileTimelineState(
        v.status,
        Some(v.discarded_status),
      )
      let cfg = ReconEngineDataSourcesUtils.getTimelineConfig(state)
      let ts = v.discarded_at !== "" ? v.discarded_at : v.created_at
      {
        label: cfg.statusText,
        timestamp: ts,
        color: cfg.container.borderColor,
        iconName: cfg.icon.name,
        iconColor: cfg.icon.color,
      }
    })
  }

  @react.component
  let make = (~versions: array<ingestionHistoryType>) => {
    let steps = buildSteps(versions)

    <div className="flex flex-col gap-3">
      <SectionLabel text="Timeline" />
      <div className="relative pl-4">
        <div className="absolute left-[7px] top-1 bottom-1 w-px bg-nd_gray-150" />
        <div className="flex flex-col gap-3.5">
          {steps
          ->Array.mapWithIndex((step, idx) =>
            <div key={idx->Int.toString} className="flex flex-row items-start gap-3 relative">
              <div
                className={`absolute -left-4 top-1 w-3.5 h-3.5 rounded-full border-2 ${step.color} bg-white grid place-items-center`}>
                <Icon name={step.iconName} size=8 className={step.iconColor} />
              </div>
              <div className="flex flex-col gap-0.5 min-w-0 ml-1">
                <span className={`${body.sm.semibold} text-nd_gray-800`}>
                  {step.label->React.string}
                </span>
                <span className={`${body.xs.medium} text-nd_gray-500 tabular-nums`}>
                  {step.timestamp->React.string}
                </span>
              </div>
            </div>
          )
          ->React.array}
        </div>
      </div>
    </div>
  }
}

module TransformationCard = {
  @react.component
  let make = (~tx: transformationHistoryType) => {
    let (open_, setOpen) = React.useState(_ => false)
    let hasErrors = tx.data.errors->Array.length > 0
    let isOk = switch tx.status {
    | Processed => !hasErrors
    | _ => false
    }
    <div
      className={`rounded-xl border ${isOk
          ? "border-nd_green-100 bg-nd_green-50/40"
          : hasErrors
          ? "border-nd_red-100 bg-nd_red-50/40"
          : "border-nd_gray-150 bg-white"} px-3.5 py-3 flex flex-col gap-2.5`}>
      <div className="flex flex-row items-center gap-2.5">
        <span className={`${body.sm.semibold} text-nd_gray-800 truncate flex-1 min-w-0`}>
          {tx.transformation_name->React.string}
        </span>
        <TagBinding
          text={tx.status->getIngestionLabel}
          color={tx.status->getIngestionTagColor}
          variant=Subtle
          size=Xs
        />
      </div>
      <div className="flex flex-row items-center gap-4 flex-wrap">
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          <span className="font-mono tabular-nums text-nd_gray-700">
            {tx.data.transformed_count->Int.toString->React.string}
          </span>
          {" created"->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          <span className="font-mono tabular-nums text-nd_gray-700">
            {tx.data.ignored_count->Int.toString->React.string}
          </span>
          {" ignored"->React.string}
        </span>
        <span className={`${body.xs.medium} text-nd_gray-500`}>
          <span
            className={`font-mono tabular-nums ${hasErrors
                ? "text-nd_red-600"
                : "text-nd_gray-700"}`}>
            {tx.data.errors->Array.length->Int.toString->React.string}
          </span>
          {" errors"->React.string}
        </span>
      </div>
      <RenderIf condition={hasErrors}>
        <button
          type_="button"
          onClick={_ => setOpen(o => !o)}
          className={`${body.xs.semibold} text-nd_red-600 hover:underline self-start uppercase tracking-wider`}>
          {(open_ ? "Hide errors" : "View errors")->React.string}
        </button>
        <RenderIf condition={open_}>
          <div className="flex flex-col gap-1.5 pt-1">
            {tx.data.errors
            ->Array.mapWithIndex((err, idx) =>
              <div
                key={idx->Int.toString}
                className={`${body.xs.medium} text-nd_red-700 bg-nd_red-50 border border-nd_red-100 rounded-md px-2.5 py-1.5 break-all`}>
                {err->React.string}
              </div>
            )
            ->React.array}
          </div>
        </RenderIf>
      </RenderIf>
    </div>
  }
}

module TransformationsSection = {
  @react.component
  let make = (~transformations: array<transformationHistoryType>) =>
    <div className="flex flex-col gap-2.5">
      <SectionLabel
        text="Transformations"
        suffix={`${transformations
          ->Array.length
          ->Int.toString} run${transformations->Array.length === 1 ? "" : "s"}`}
      />
      {transformations->Array.length === 0
        ? <div
            className={`${body.sm.medium} text-nd_gray-400 px-3.5 py-3 rounded-xl border border-dashed border-nd_gray-200`}>
            {"No transformations have run on this file yet."->React.string}
          </div>
        : <div className="flex flex-col gap-2">
            {transformations
            ->Array.map(tx => <TransformationCard key={tx.transformation_history_id} tx />)
            ->React.array}
          </div>}
    </div>
}

module EntriesSection = {
  @react.component
  let make = (~transformations: array<transformationHistoryType>, ~ingestionHistoryId: string) => {
    let created = transformations->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
    let ignored = transformations->Array.reduce(0, (acc, t) => acc + t.data.ignored_count)
    let total = created + ignored
    let entriesUrl = GlobalVars.appendDashboardPath(
      ~url=`/v1/recon-engine/transformed-entries?ingestion_history_id=${ingestionHistoryId}`,
    )

    <div className="flex flex-col gap-2.5">
      <SectionLabel text="Transformed entries" />
      <div
        className="rounded-xl border border-nd_gray-150 bg-white px-3.5 py-3 flex flex-row items-center gap-3">
        <div className="flex flex-col gap-0.5 min-w-0 flex-1">
          <span className={`${heading.md.semibold} text-nd_gray-800 tabular-nums`}>
            {created->Int.toString->React.string}
          </span>
          <span className={`${body.xs.medium} text-nd_gray-500`}>
            {`entries created · ${ignored->Int.toString} ignored · ${total->Int.toString} total rows`->React.string}
          </span>
        </div>
        <RenderIf condition={total > 0}>
          <button
            type_="button"
            onClick={_ => RescriptReactRouter.push(entriesUrl)}
            className={`${body.sm.semibold} text-nd_primary_blue-600 hover:text-nd_primary_blue-700 flex flex-row items-center gap-1 flex-shrink-0`}>
            {"View entries"->React.string}
            <Icon name="nd-external-link-square" size=12 customIconColor="#2B6FFF" />
          </button>
        </RenderIf>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~accounts: array<accountType>,
  ~activeIngestion: option<ingestionHistoryType>,
  ~onClose: unit => unit,
) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let getTransformationHistory = ReconEngineHooks.useGetTransformationHistory()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let (configOpt, setConfig) = React.useState(_ => None)
  let (versions, setVersions) = React.useState(_ => [])
  let (transformations, setTransformations) = React.useState(_ => [])

  let activeId = activeIngestion->Option.map(i => i.ingestion_history_id)
  let activeIngestionId = activeIngestion->Option.map(i => i.ingestion_id)

  let loadEverything = async (ingestion: ingestionHistoryType) => {
    /* Run requests in parallel; tolerate individual failures. */
    let configP = async () => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#INGESTION_CONFIG,
          ~id=Some(ingestion.ingestion_id),
        )
        let res = await fetchDetails(url)
        let cfg = res->getDictFromJsonObject->ReconEngineUtils.ingestionConfigItemToObjMapper
        setConfig(_ => Some(cfg))
      } catch {
      | _ => setConfig(_ => None)
      }
    }
    let versionsP = async () => {
      try {
        let res = await getIngestionHistory(
          ~queryParameters=Some(`ingestion_history_id=${ingestion.ingestion_history_id}`),
        )
        let sorted = res->Array.toSorted((a, b) => compareLogic(a.version, b.version))
        setVersions(_ => sorted)
      } catch {
      | _ => setVersions(_ => [ingestion])
      }
    }
    let txP = async () => {
      try {
        let res = await getTransformationHistory(
          ~queryParameters=Some(`ingestion_history_id=${ingestion.ingestion_history_id}`),
        )
        setTransformations(_ => res)
      } catch {
      | _ => setTransformations(_ => [])
      }
    }
    let _ = await Promise.all([configP(), versionsP(), txP()])
  }

  React.useEffect(() => {
    switch activeIngestion {
    | Some(ing) => loadEverything(ing)->ignore
    | None => {
        setConfig(_ => None)
        setVersions(_ => [])
        setTransformations(_ => [])
      }
    }
    None
  }, [activeId])

  let onDownload = (ev: ReactEvent.Mouse.t) => {
    switch activeIngestion {
    | None => ()
    | Some(ingestion) => {
        ev->ReactEvent.Mouse.stopPropagation
        let run = async () => {
          try {
            let url = getURL(
              ~entityName=V1(HYPERSWITCH_RECON),
              ~hyperswitchReconType=#DOWNLOAD_INGESTION_HISTORY_FILE,
              ~methodType=Get,
              ~id=Some(ingestion.id),
            )
            let res = await fetchApi(url, ~method_=Get, ~xFeatureRoute, ~forceCookies)
            let csv = await res->Fetch.Response.text
            DownloadUtils.download(
              ~fileName=ingestion.file_name,
              ~content=csv,
              ~fileType="text/csv",
            )
            showToast(~message="File downloaded successfully", ~toastType=ToastSuccess)
          } catch {
          | _ =>
            showToast(~message="Failed to download file. Please try again.", ~toastType=ToastError)
          }
        }
        run()->ignore
      }
    }
    let _ = activeIngestionId
  }

  switch activeIngestion {
  | None =>
    <aside
      className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150">
      <Header onClose />
      <EmptyState />
    </aside>
  | Some(ingestion) => {
      let acct = accounts->Array.find(a => a.account_id === ingestion.account_id)
      let accountName = acct->Option.map(a => a.account_name)->Option.getOr("—")
      let accountCurrency = acct->Option.map(a => a.currency)->Option.getOr("")
      let timelineVersions = versions->Array.length > 0 ? versions : [ingestion]

      <aside
        className="hidden lg:flex flex-shrink-0 w-[440px] flex-col bg-white border-l border-nd_gray-150 overflow-hidden">
        <Header onClose />
        <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-5">
          <Hero ingestion onDownload />
          <div className="h-px bg-nd_gray-150" />
          <SourceSection configOpt ingestion accountName accountCurrency />
          <Timeline versions={timelineVersions} />
          <TransformationsSection transformations />
          <EntriesSection transformations ingestionHistoryId={ingestion.ingestion_history_id} />
        </div>
      </aside>
    }
  }
}
