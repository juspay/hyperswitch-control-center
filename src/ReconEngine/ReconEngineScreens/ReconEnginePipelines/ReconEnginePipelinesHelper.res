open Typography
open LogicUtils
open ReconEnginePipelinesTypes
open ReconEngineOverviewSummaryTypes

module SectionTitle = {
  @react.component
  let make = (~count=?, ~children) => {
    <h4 className={`flex items-center gap-1.5 ${body.md.semibold} text-nd_gray-800`}>
      {children}
      {switch count {
      | Some(count) => <span> {`(${count->Int.toString})`->React.string} </span>
      | None => React.null
      }}
    </h4>
  }
}

module MetaRow = {
  @react.component
  let make = (~label: string, ~value: React.element) => {
    <div className={`flex items-baseline justify-between gap-3 ${body.sm.regular}`}>
      <span className="text-nd_gray-500"> {label->React.string} </span>
      <ToolTip
        toolTipPosition=Top
        descriptionComponent={<span className={`${body.xs.regular} break-words`}> value </span>}
        toolTipFor={<span
          className={`min-w-0 truncate text-right ${body.sm.medium} text-nd_gray-700 cursor-default`}>
          value
        </span>}
      />
    </div>
  }
}

module FunnelStat = {
  @react.component
  let make = (~label: string, ~value: int, ~valueColor="text-nd_gray-800") => {
    <div className="flex flex-col items-center text-center p-3 flex-1 min-w-0">
      <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-500 mb-1`}>
        {label->React.string}
      </p>
      <p className={`${heading.sm.semibold} ${valueColor}`}>
        <ReconEngineOverviewSummaryHelper.NumberCell value />
      </p>
    </div>
  }
}

module RuleChips = {
  @react.component
  let make = (~label: string, ~rules: array<string>) => {
    <RenderIf condition={rules->isNonEmptyArray}>
      <div className="flex flex-wrap items-start gap-1.5">
        <span
          className={`shrink-0 whitespace-nowrap min-w-76-px pt-0.5 ${body.xs.semibold} uppercase tracking-wide text-nd_gray-600`}>
          {label->React.string}
        </span>
        <div className="flex flex-wrap gap-1.5 flex-1 min-w-0">
          {rules
          ->Array.mapWithIndex((rule, index) =>
            <span
              key={index->Int.toString}
              className={`${body.xs.medium} bg-nd_gray-150 text-nd_gray-800 rounded px-1.5 py-0.5 break-words`}>
              {rule->React.string}
            </span>
          )
          ->React.array}
        </div>
      </div>
    </RenderIf>
  }
}

module FieldRow = {
  @react.component
  let make = (~field: displayField) => {
    let (transformRules, validationRules, postParseRules) =
      field.ruleSet->ReconEnginePipelinesUtils.describeFieldRules
    let hasRules =
      transformRules->isNonEmptyArray ||
      validationRules->isNonEmptyArray ||
      postParseRules->isNonEmptyArray

    <div className="px-3 py-2.5 border-b border-nd_gray-150 last:border-0">
      <div className={`flex items-center gap-2 ${body.sm.regular}`}>
        <div className="flex items-center min-w-0 flex-1">
          <ToolTip
            toolTipPosition=Top
            descriptionComponent={<span className={`${body.xs.regular} break-words`}>
              {`${field.label} (${field.target})`->React.string}
            </span>}
            toolTipFor={<span className={`min-w-0 truncate ${body.sm.medium} text-nd_gray-800`}>
              {field.label->React.string}
            </span>}
          />
          <RenderIf condition=field.isRequired>
            <ToolTip
              toolTipPosition=Top
              description="Required"
              toolTipFor={<span className={`ml-1 ${body.xs.medium} text-nd_red-500 cursor-default`}>
                {"*"->React.string}
              </span>}
            />
          </RenderIf>
        </div>
        <span
          className={`shrink-0 ${body.sm.medium} lowercase text-nd_gray-700 bg-nd_gray-100 border border-nd_gray-200 rounded px-1.5 py-0.5`}>
          {field.typeLabel->React.string}
        </span>
        <ToolTip
          toolTipPosition=Top
          descriptionComponent={<span className={`${body.sm.regular} break-words`}>
            {(
              field.fieldIdentifier->isNonEmptyString ? field.fieldIdentifier : "—"
            )->React.string}
          </span>}
          toolTipFor={<span
            className="min-w-0 max-w-40-per inline-flex items-center gap-1 cursor-default">
            <Icon name="nd-arrow-right" size=10 className="text-nd_gray-300 shrink-0" />
            <span className={`min-w-0 truncate ${body.sm.regular} text-nd_gray-500`}>
              {(
                field.fieldIdentifier->isNonEmptyString ? field.fieldIdentifier : "—"
              )->React.string}
            </span>
          </span>}
        />
      </div>
      <RenderIf condition=hasRules>
        <div className="mt-2 flex flex-col gap-1.5">
          <RuleChips label="Transform" rules=transformRules />
          <RuleChips label="Validate" rules=validationRules />
          <RuleChips label="Post" rules=postParseRules />
        </div>
      </RenderIf>
    </div>
  }
}

module StatCard = {
  @react.component
  let make = (~label: string, ~value: int, ~desc: string, ~cardType: statCardType=Info) => {
    let valueColor = switch cardType {
    | Info => "text-nd_gray-800"
    | Attention => "text-nd_red-500"
    }

    <div className="flex flex-col p-4 flex-1 min-w-0">
      <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400 mb-1`}>
        {label->React.string}
      </p>
      <div className={`${heading.lg.semibold} ${valueColor} mb-0.5`}>
        <ReconEngineOverviewSummaryHelper.NumberCell value />
      </div>
      <RenderIf condition={desc->isNonEmptyString}>
        <p className={`${body.xs.regular} text-nd_gray-400`}> {desc->React.string} </p>
      </RenderIf>
    </div>
  }
}

module StatDot = {
  @react.component
  let make = (~children) => {
    <>
      <span className="text-nd_gray-300"> {"·"->React.string} </span>
      {children}
    </>
  }
}

module TransformationCard = {
  @react.component
  let make = (
    ~transformation: ReconEngineTypes.transformationHistoryType,
    ~onOpen: unit => unit,
  ) => {
    open ReconEnginePipelinesUtils

    let getURL = APIUtils.useGetURL()
    let fetchApi = AuthHooks.useApiFetcher()
    let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
      HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let showToast = ToastAdapter.useShowToast()

    let errorCount = transformation.data.failed_count
    let duration = formatDuration(transformation.created_at, transformation.processed_at)

    let onDownloadReport = async (~format: reportFormat) => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#DOWNLOAD_TRANSFORMATION_REPORT,
          ~methodType=Get,
          ~id=Some(transformation.transformation_history_id),
          ~queryParameters=Some((format :> string)),
        )
        let res = await fetchApi(
          url,
          ~method_=Get,
          ~xFeatureRoute,
          ~forceCookies,
          ~sendV1DummyApiKeyHeader,
        )
        if res->Fetch.Response.status >= 300 {
          Exn.raiseError("Failed to download report")
        }
        let content = await res->Fetch.Response.blob
        DownloadUtils.download(
          ~fileName=getTransformationReportFileName(~transformation, ~format),
          ~content,
          ~fileType=reportFormatFileType(format),
        )
        showToast(~message="Report downloaded successfully", ~toastType=ToastSuccess)
      } catch {
      | _ =>
        showToast(~message="Failed to download report. Please try again.", ~toastType=ToastError)
      }
    }

    <div
      className="group border border-nd_gray-150 rounded-xl flex flex-col gap-2.5 px-5 py-4 bg-white cursor-pointer hover:bg-nd_gray-50 transition-colors"
      onClick={_ => onOpen()}>
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-2 flex-wrap min-w-0">
          <TableUtils.LabelCell
            labelColor={switch transformation.status {
            | Processed => LabelGreen
            | Failed => LabelRed
            | Processing => LabelOrange
            | Pending => LabelYellow
            | Discarded | UnknownIngestionTransformationStatus => LabelGray
            }}
            text={(transformation.status :> string)->capitalizeString}
          />
          <p className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {transformation.transformation_name->React.string}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0">
          <TableUtils.DateCell
            timestamp=transformation.created_at
            isCard=true
            hideTime=true
            textStyle={`${body.sm.medium} text-nd_gray-600`}
          />
          <Icon
            name="nd-arrow-right"
            size=14
            className="text-nd_gray-300 group-hover:text-nd_gray-500 group-hover:translate-x-0.5 transition-all"
          />
        </div>
      </div>
      <div className="flex items-end justify-between gap-4">
        <div className={`flex items-center flex-wrap gap-1.5 ${body.sm.medium} text-nd_gray-600`}>
          <span>
            <span className={`${body.sm.semibold} text-nd_gray-800`}>
              {transformation.data.transformed_count->Int.toString->React.string}
            </span>
            {` / ${transformation.data.total_count->Int.toString} transformed`->React.string}
          </span>
          <StatDot> {`${duration} run`->React.string} </StatDot>
          <RenderIf condition={transformation.data.ignored_count > 0}>
            <StatDot>
              <span className={`${body.sm.medium} text-nd_orange-600`}>
                {`${transformation.data.ignored_count->Int.toString} ignored`->React.string}
              </span>
            </StatDot>
          </RenderIf>
          <RenderIf condition={errorCount > 0}>
            <StatDot>
              <span className={`${body.xs.medium} text-nd_red-500`}>
                {`${errorCount->Int.toString} error${errorCount == 1 ? "" : "s"}`->React.string}
              </span>
            </StatDot>
          </RenderIf>
        </div>
        <RenderIf condition={transformation.status->isReportDownloadable}>
          <div className="flex-shrink-0" onClick={ev => ev->ReactEvent.Mouse.stopPropagation}>
            <Button
              text="Transformation summary"
              leftIcon={CustomIcon(<Icon name="nd-download-down" size=12 />)}
              customIconMargin="ml-3"
              buttonType=Button.Secondary
              buttonSize=Small
              onClick={_ => onDownloadReport(~format=Csv)->ignore}
              maxButtonWidth="!w-fit"
            />
          </div>
        </RenderIf>
      </div>
    </div>
  }
}
