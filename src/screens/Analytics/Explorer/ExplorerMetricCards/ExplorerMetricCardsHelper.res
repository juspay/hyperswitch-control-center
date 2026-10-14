open Typography
open LogicUtils
open ExplorerTypes
open ExplorerUtils

module MetricCard = {
  @react.component
  let make = (~label, ~definition, ~value, ~change, ~impact: changeImpact, ~primary=false) => {
    let (impactTextClass, impactBgClass) = impact->getImpactClasses
    <div
      className={`flex flex-col gap-2 rounded-xl border px-5 py-4 ${primary
          ? "border-nd_primary_blue-200 bg-nd_primary_blue-25"
          : "border-nd_br_gray-200 bg-nd_gray-0"}`}>
      <div className={`flex items-center gap-1.5 ${body.md.medium} text-nd_gray-500`}>
        {label->React.string}
        <ToolTip
          description=definition
          toolTipPosition=Top
          toolTipFor={<span className="inline-flex cursor-help text-nd_gray-400">
            <Icon name="nd-info-circle" size=14 />
          </span>}
        />
      </div>
      <div className={`${heading.lg.semibold} text-nd_gray-800`}> {value->React.string} </div>
      <RenderIf condition={change->isNonEmptyString}>
        <div className={`flex items-center gap-2 ${body.sm.regular}`}>
          <span
            className={`rounded-md px-1.5 py-0.5 ${body.sm.medium} ${impactTextClass} ${impactBgClass}`}>
            {change->React.string}
          </span>
          <span className="text-nd_gray-400"> {"vs previous period"->React.string} </span>
        </div>
      </RenderIf>
    </div>
  }
}
