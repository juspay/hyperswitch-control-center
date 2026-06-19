open Typography
open LogicUtils
open ReconEngineRevampedPipelinesTypes

let statusLabelColor = (
  status: ReconEngineTypes.ingestionTransformationStatusType,
): TableUtils.labelColor => {
  switch status {
  | ReconEngineTypes.Processed => LabelGreen
  | ReconEngineTypes.Failed => LabelRed
  | ReconEngineTypes.Processing => LabelOrange
  | ReconEngineTypes.Pending => LabelYellow
  | _ => LabelGray
  }
}

let statusStr = (status: ReconEngineTypes.ingestionTransformationStatusType) =>
  (status :> string)->capitalizeString

let getRelativeTime = (isoString: string) => {
  let now = Js.Date.now()
  let then_ = Js.Date.fromString(isoString)->Js.Date.getTime
  let diffMs = now -. then_
  let diffMins = (diffMs /. 60000.0)->Float.toInt
  let diffHours = diffMins / 60
  let diffDays = diffHours / 24
  if diffDays > 0 {
    `${diffDays->Int.toString} day${diffDays == 1 ? "" : "s"} ago`
  } else if diffHours > 0 {
    `${diffHours->Int.toString} hour${diffHours == 1 ? "" : "s"} ago`
  } else if diffMins > 0 {
    `${diffMins->Int.toString} min${diffMins == 1 ? "" : "s"} ago`
  } else {
    "just now"
  }
}

let getTimestamp = (item: ReconEngineTypes.ingestionHistoryType) =>
  item.discarded_at->isNonEmptyString ? item.discarded_at : item.created_at

type stepConfig = {
  iconName: string,
  iconColor: string,
  borderColor: string,
  bgColor: string,
}

let getStepConfig = (state: ReconEngineDataSourcesTypes.fileTimelineState): stepConfig => {
  switch state {
  | FileReceived => {
      iconName: "nd-upload-file",
      iconColor: "text-nd_gray-500",
      borderColor: "border-nd_gray-200",
      bgColor: "bg-nd_gray-50",
    }
  | FileProcessing => {
      iconName: "nd-upload",
      iconColor: "text-nd_gray-500",
      borderColor: "border-nd_gray-200",
      bgColor: "bg-nd_gray-50",
    }
  | FileUploaded | FileAccepted | FileProcessed => {
      iconName: "nd-check-circle",
      iconColor: "text-nd_green-600",
      borderColor: "border-nd_green-200",
      bgColor: "bg-nd_green-50",
    }
  | FileRejected => {
      iconName: "nd-multiple-cross",
      iconColor: "text-nd_red-500",
      borderColor: "border-nd_red-100",
      bgColor: "bg-nd_red-50",
    }
  | UnknownFileTimelineState => {
      iconName: "nd-hour-glass-outline",
      iconColor: "text-nd_gray-400",
      borderColor: "border-nd_gray-200",
      bgColor: "bg-nd_gray-50",
    }
  }
}

let getStepTitle = (
  state: ReconEngineDataSourcesTypes.fileTimelineState,
  item: ReconEngineTypes.ingestionHistoryType,
) => {
  switch state {
  | FileReceived => (
      "File received",
      `${ReconEngineRevampedPipelinesUtils.getUploadTypeLabel(
          item.upload_type,
        )} · ${item.file_name}`,
    )
  | FileProcessing => ("Processing", "Validating and uploading to the object store")
  | FileUploaded => ("Stored to S3 — transformation triggered", "")
  | FileRejected => ("Failed", item.discarded_status->isNonEmptyString ? item.discarded_status : "")
  | FileAccepted => ("File accepted", "")
  | FileProcessed => ("File processed", "")
  | UnknownFileTimelineState => ("Unknown", "")
  }
}

module StepIcon = {
  @react.component
  let make = (~config: stepConfig) => {
    <div
      className={`w-10 h-10 rounded-full flex items-center justify-center border flex-shrink-0 ${config.borderColor} ${config.bgColor}`}>
      <Icon name={config.iconName} className={config.iconColor} size=16 />
    </div>
  }
}

module IngestionStep = {
  @react.component
  let make = (~item: ReconEngineTypes.ingestionHistoryType, ~isLast: bool) => {
    let state = ReconEngineDataSourcesUtils.getFileTimelineState(
      item.status,
      Some(item.discarded_status),
    )
    let config = getStepConfig(state)
    let (title, desc) = getStepTitle(state, item)
    let ts = getTimestamp(item)

    <div className="flex gap-4 px-6">
      <div className="flex flex-col items-center">
        <StepIcon config />
        <RenderIf condition={!isLast}>
          <div className="w-px flex-1 bg-nd_gray-200 mt-1 min-h-[20px]" />
        </RenderIf>
      </div>
      <div className={`flex-1 min-w-0 ${isLast ? "pb-2" : "pb-6"}`}>
        <div className="flex items-start justify-between gap-3 mb-0.5">
          <p className={`${body.md.semibold} text-nd_gray-800`}> {title->React.string} </p>
          <span className={`${body.xs.medium} text-nd_gray-400 flex-shrink-0 whitespace-nowrap`}>
            <TableUtils.DateCell timestamp=ts textAlign={Left} />
          </span>
        </div>
        <RenderIf condition={desc->isNonEmptyString}>
          <p className={`${body.sm.regular} text-nd_gray-500`}> {desc->React.string} </p>
        </RenderIf>
      </div>
    </div>
  }
}

module TransformationDetail = {
  @react.component
  let make = (~t: ReconEngineTypes.transformationHistoryType) => {
    let cleaned = t.data.transformed_count
    let total = t.data.total_count
    let ignored = t.data.ignored_count
    let failed = t.data.errors->Array.length

    <div className="rounded-xl border border-nd_gray-150 bg-white overflow-hidden mb-3">
      <div className="px-4 py-3 border-b border-nd_gray-100">
        <div className="flex items-center gap-2 flex-wrap mb-1">
          <p className={`${body.sm.semibold} text-nd_gray-800`}>
            {t.transformation_name->React.string}
          </p>
          <TableUtils.NewLabelCell
            labelColor={statusLabelColor(t.status)} text={statusStr(t.status)}
          />
        </div>
        <p className={`${body.xs.regular} text-nd_gray-400`}>
          {`→ ${t.account_id}`->React.string}
        </p>
      </div>
      <div className="px-4 py-3 bg-nd_gray-50">
        <div className="flex items-center justify-center gap-2 mb-2">
          <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400`}>
            {"ROWS IN"->React.string}
          </p>
          <p className={`${heading.sm.semibold} text-nd_gray-800`}>
            {total->Int.toString->React.string}
          </p>
        </div>
        <div className="h-px bg-nd_gray-200 mb-2" />
        <div className="flex items-center justify-around">
          <div className="text-center">
            <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400`}>
              {"FAILED"->React.string}
            </p>
            <p
              className={`${body.md.semibold} ${failed > 0
                  ? "text-nd_red-500"
                  : "text-nd_gray-800"}`}>
              {failed->Int.toString->React.string}
            </p>
          </div>
          <div className="w-px h-8 bg-nd_gray-200" />
          <div className="text-center">
            <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400`}>
              {"CLEANED"->React.string}
            </p>
            <p className={`${body.md.semibold} text-nd_gray-800`}>
              {cleaned->Int.toString->React.string}
            </p>
          </div>
          <div className="w-px h-8 bg-nd_gray-200" />
          <div className="text-center">
            <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400`}>
              {"IGNORED"->React.string}
            </p>
            <p className={`${body.md.semibold} text-nd_gray-800`}>
              {ignored->Int.toString->React.string}
            </p>
          </div>
        </div>
      </div>
    </div>
  }
}

module TransformationStep = {
  @react.component
  let make = (~transformations: array<ReconEngineTypes.transformationHistoryType>) => {
    let count = transformations->Array.length
    let totalCleaned = transformations->Array.reduce(0, (acc, t) => acc + t.data.transformed_count)
    let totalRows = transformations->Array.reduce(0, (acc, t) => acc + t.data.total_count)

    let txConfig: stepConfig = {
      iconName: "nd-pencil-edit-line",
      iconColor: "text-nd_green-600",
      borderColor: "border-nd_green-200",
      bgColor: "bg-nd_green-50",
    }

    <div className="flex gap-4 px-6">
      <div className="flex flex-col items-center">
        <StepIcon config=txConfig />
      </div>
      <div className="flex-1 min-w-0 pb-2">
        <div className="flex items-start justify-between gap-3 mb-1">
          <p className={`${body.md.semibold} text-nd_gray-800`}>
            {"Transformation"->React.string}
          </p>
        </div>
        <p className={`${body.sm.regular} text-nd_gray-500 mb-3`}>
          {`${count->Int.toString} transformation${count == 1
              ? ""
              : "s"} · ${totalCleaned->Int.toString} of ${totalRows->Int.toString} rows cleaned`->React.string}
        </p>
        {transformations
        ->Array.map(t => <TransformationDetail key={t.transformation_history_id} t />)
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~item: option<pipelineIngestionItem>, ~onClose: unit => unit) => {
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let getIngestionHistory = ReconEngineHooks.useGetIngestionHistory()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (historySteps, setHistorySteps) = React.useState((_): array<
    ReconEngineTypes.ingestionHistoryType,
  > => [])
  let (transformations, setTransformations) = React.useState((_): array<
    ReconEngineTypes.transformationHistoryType,
  > => [])

  let fetchData = async (historyId: string) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let qp = `ingestion_history_id=${historyId}`

      let steps = await getIngestionHistory(~queryParameters=Some(qp))
      steps->Array.sort((a, b) => compareLogic(b.version, a.version))
      setHistorySteps(_ => steps)

      let txUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParameters=Some(qp),
      )
      let txRes = await fetchDetails(txUrl)
      let txItems =
        txRes->getArrayDataFromJson(ReconEngineUtils.transformationHistoryItemToObjMapper)
      txItems->Array.sort((a, b) => compareLogic(b.created_at, a.created_at))
      setTransformations(_ => txItems)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    switch item {
    | Some(i) => fetchData(i.ingestion_history_id)->ignore
    | None => ()
    }
    None
  }, [item])

  let showDrawer = item->Option.isSome
  let transitionClass = showDrawer ? "translate-x-0" : "translate-x-full"

  <>
    <RenderIf condition=showDrawer>
      <div className="fixed inset-0 bg-black/20 z-40 transition-opacity" onClick={_ => onClose()} />
    </RenderIf>
    <div
      className={`fixed right-0 top-0 h-full w-[520px] bg-white shadow-2xl rounded-l-2xl overflow-hidden transform transition-all duration-300 ease-in-out flex flex-col z-50 ${transitionClass}`}>
      {switch item {
      | None => React.null
      | Some(i) =>
        <>
          <div className="px-6 py-5 border-b border-nd_gray-150">
            <div className="flex items-start justify-between gap-3 mb-1.5">
              <p className={`${body.md.semibold} text-nd_gray-800 truncate min-w-0`}>
                {i.file_name->React.string}
              </p>
              <div
                className="w-7 h-7 flex items-center justify-center rounded-lg hover:bg-nd_gray-100 cursor-pointer transition-colors flex-shrink-0"
                onClick={_ => onClose()}>
                <Icon name="nd-cross" size=13 className="text-nd_gray-500" />
              </div>
            </div>
            <div className="flex items-center gap-2 flex-wrap mb-1.5">
              <TableUtils.NewLabelCell
                labelColor={statusLabelColor(i.status)} text={statusStr(i.status)}
              />
              <RenderIf condition={i.version > 0}>
                <span
                  className={`${body.xs.medium} px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-500 border border-nd_gray-200`}>
                  {`v${i.version->Int.toString}`->React.string}
                </span>
              </RenderIf>
            </div>
            <p className={`${body.sm.regular} text-nd_gray-400`}>
              {`${ReconEngineRevampedPipelinesUtils.getUploadTypeLabel(
                  i.upload_type,
                )} · ${i.account_name} · received ${getRelativeTime(i.created_at)}`->React.string}
            </p>
          </div>
          <div className="flex-1 overflow-y-auto overflow-x-hidden">
            <PageLoaderWrapper
              screenState
              customLoader={<div className="flex items-center justify-center h-40">
                <div className="animate-spin">
                  <Icon name="spinner" size=20 />
                </div>
              </div>}
              customUI={<NewAnalyticsHelper.NoData
                height="h-40" message="Could not load audit trail."
              />}>
              <div className="pt-5 pb-8 flex flex-col">
                {historySteps
                ->Array.mapWithIndex((step, idx) => {
                  let isLast =
                    idx === historySteps->Array.length - 1 && transformations->Array.length == 0
                  <IngestionStep key={step.id} item=step isLast />
                })
                ->React.array}
                <RenderIf condition={transformations->Array.length > 0}>
                  <TransformationStep transformations />
                </RenderIf>
                <RenderIf
                  condition={historySteps->Array.length == 0 && transformations->Array.length == 0}>
                  <div className="px-6">
                    <p className={`${body.sm.regular} text-nd_gray-400`}>
                      {"No audit trail available."->React.string}
                    </p>
                  </div>
                </RenderIf>
              </div>
            </PageLoaderWrapper>
          </div>
        </>
      }}
    </div>
  </>
}
