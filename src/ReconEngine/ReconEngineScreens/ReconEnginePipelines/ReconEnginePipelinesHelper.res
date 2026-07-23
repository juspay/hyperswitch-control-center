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
      | Some(c) =>
        <span className="normal-case font-normal"> {c->Int.toString->React.string} </span>
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
      <ToolTipBinding
        side=ToolTipBinding.Top
        content={<span className={`${body.xs.regular} break-words`}> value </span>}>
        <span
          className={`min-w-0 truncate text-right ${body.sm.medium} text-nd_gray-700 cursor-default`}>
          value
        </span>
      </ToolTipBinding>
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
          className={`shrink-0 whitespace-nowrap min-w-[76px] pt-0.5 ${body.xs.semibold} uppercase tracking-wide text-nd_gray-600`}>
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
        <ToolTipBinding
          side=ToolTipBinding.Top
          content={<span className={`${body.xs.regular} break-words`}>
            {`${field.label} (${field.target})`->React.string}
          </span>}>
          <span className="min-w-0 flex-1 truncate cursor-default">
            <span className={`${body.sm.medium} text-nd_gray-800`}>
              {field.label->React.string}
            </span>
            <span className={`ml-1.5 font-mono ${body.xs.regular} text-nd_gray-500`}>
              {field.target->React.string}
            </span>
            <RenderIf condition=field.isRequired>
              <span className={`ml-1 ${body.xs.medium} text-nd_red-500`}>
                {"required"->React.string}
              </span>
            </RenderIf>
          </span>
        </ToolTipBinding>
        <span
          className={`shrink-0 ${body.xs.medium} lowercase text-nd_gray-700 bg-nd_gray-100 border border-nd_gray-200 rounded px-1.5 py-0.5`}>
          {field.typeLabel->React.string}
        </span>
        <ToolTipBinding
          side=ToolTipBinding.Top
          content={<span className={`${body.xs.regular} break-words`}>
            {(
              field.fieldIdentifier->isNonEmptyString ? field.fieldIdentifier : "—"
            )->React.string}
          </span>}>
          <span className="min-w-0 max-w-[40%] inline-flex items-center gap-1 cursor-default">
            <Icon name="nd-arrow-right" size=10 className="text-nd_gray-300 shrink-0" />
            <span className={`min-w-0 truncate font-mono ${body.xs.regular} text-nd_gray-500`}>
              {(
                field.fieldIdentifier->isNonEmptyString ? field.fieldIdentifier : "—"
              )->React.string}
            </span>
          </span>
        </ToolTipBinding>
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
  let make = (
    ~label: string,
    ~value: int,
    ~desc: string,
    ~cardType: statCardType=Info,
    ~onClick=?,
  ) => {
    let isClickable = onClick->Option.isSome

    let valueColor = switch cardType {
    | Info => "text-nd_gray-800"
    | Attention => "text-nd_red-500"
    }

    <div
      className={`flex flex-col p-4 flex-1 min-w-0 ${isClickable
          ? "cursor-pointer hover:bg-nd_gray-50 transition-colors"
          : ""}`}
      onClick={_ => onClick->Option.mapOr((), fn => fn())}>
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
  let make = (~tx: ReconEngineTypes.transformationHistoryType, ~onOpen: unit => unit) => {
    let errorCount = tx.data.errors->Array.length
    let duration = ReconEnginePipelinesUtils.formatDuration(tx.created_at, tx.processed_at)

    <div
      className="group border border-nd_gray-150 rounded-xl flex flex-col gap-2.5 px-5 py-4 bg-white cursor-pointer hover:bg-nd_gray-50 transition-colors"
      onClick={_ => onOpen()}>
      <div className="flex items-center justify-between gap-4">
        <div className="flex items-center gap-2 flex-wrap min-w-0">
          <TableUtils.LabelCell
            labelColor={switch tx.status {
            | Processed => LabelGreen
            | Failed => LabelRed
            | Processing => LabelOrange
            | Pending => LabelYellow
            | Discarded | UnknownIngestionTransformationStatus => LabelGray
            }}
            text={(tx.status :> string)->capitalizeString}
          />
          <p className={`${body.sm.semibold} text-nd_gray-800 truncate`}>
            {tx.transformation_name->React.string}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0">
          <TableUtils.DateCell
            timestamp=tx.created_at isCard=true textStyle={`${body.xs.regular} text-nd_gray-400`}
          />
          <Icon
            name="nd-arrow-right"
            size=14
            className="text-nd_gray-300 group-hover:text-nd_gray-500 group-hover:translate-x-0.5 transition-all"
          />
        </div>
      </div>
      <div className={`flex items-center flex-wrap gap-1.5 ${body.xs.regular} text-nd_gray-500`}>
        <span>
          <span className={`${body.xs.semibold} text-nd_gray-700`}>
            {tx.data.transformed_count->Int.toString->React.string}
          </span>
          {` / ${tx.data.total_count->Int.toString} transformed`->React.string}
        </span>
        <StatDot> {`${duration} run`->React.string} </StatDot>
        <RenderIf condition={tx.data.ignored_count > 0}>
          <StatDot>
            <span className={`${body.xs.medium} text-nd_orange-600`}>
              {`${tx.data.ignored_count->Int.toString} ignored`->React.string}
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
    </div>
  }
}
