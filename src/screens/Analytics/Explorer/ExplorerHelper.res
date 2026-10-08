open Typography
open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerDescriptions

module ExplorerCard = {
  @react.component
  let make = (~children, ~className="") =>
    <div className={`rounded-xl border border-nd_br_gray-200 bg-nd_gray-0 ${className}`}>
      children
    </div>
}

module SourceTabs = {
  @react.component
  let make = (~question: question, ~onSource) =>
    <div className="flex items-center gap-3">
      <TabsBinding
        value={question.source->sourceToString}
        onValueChange={id => onSource(id->sourceFromString)}
        variant=Boxed
        size=Md>
        <TabsBinding.List variant=Boxed size=Md fitContent=true>
          {sources
          ->Array.map(source =>
            <TabsBinding.Trigger
              key={source->sourceToString} value={source->sourceToString} variant=Boxed size=Md>
              {sourceLabel(source)->React.string}
            </TabsBinding.Trigger>
          )
          ->React.array}
        </TabsBinding.List>
      </TabsBinding>
      <span className={`${body.md.regular} text-nd_gray-500`}>
        {sourceDescription(question.source)->React.string}
      </span>
    </div>
}

module QueryText = {
  @react.component
  let make = (~text, ~strong=false) =>
    <span
      className={`whitespace-nowrap ${strong
          ? `${body.lg.semibold} text-nd_gray-800`
          : `${body.lg.regular} text-nd_gray-500`}`}>
      {text->React.string}
    </span>
}

module QuerySelect = {
  @react.component
  let make = (
    ~value,
    ~onChange,
    ~options: array<MultiSelectBindings.selectMenuItemType>,
    ~placeholder,
    ~allowDeselect=false,
    ~enableSearch=false,
  ) =>
    <SingleSelectBinding
      selected=value
      onSelect=onChange
      items=[{items: options->Array.map(option => {...option, disableTruncation: true})}]
      placeholder
      size=Sm
      allowDeselect
      enableSearch
      minMenuWidth=300
      maxMenuWidth=380
    />
}

module MetricCard = {
  @react.component
  let make = (~label, ~definition, ~value, ~change, ~impact: changeImpact, ~primary=false) => {
    let impactClass = switch impact {
    | Favorable => "text-nd_green-600 bg-nd_green-50"
    | Unfavorable => "text-nd_red-600 bg-nd_red-50"
    | Neutral => "text-nd_gray-500 bg-nd_gray-50"
    }
    <div
      className={`flex flex-col gap-2 rounded-xl border px-5 py-4 ${primary
          ? "border-nd_primary_blue-200 bg-nd_primary_blue-25"
          : "border-nd_br_gray-200 bg-nd_gray-0"}`}>
      <div className={`flex items-center gap-1.5 ${body.md.medium} text-nd_gray-500`}>
        {label->React.string}
        <ToolTipBinding content={definition->React.string} side=Top maxWidth="280px">
          <span className="inline-flex cursor-help text-nd_gray-400">
            <Icon name="nd-info-circle" size=14 />
          </span>
        </ToolTipBinding>
      </div>
      <div className={`${heading.lg.semibold} text-nd_gray-800`}> {value->React.string} </div>
      <RenderIf condition={change->isNonEmptyString}>
        <div className={`flex items-center gap-2 ${body.sm.regular}`}>
          <span className={`rounded-md px-1.5 py-0.5 ${body.sm.medium} ${impactClass}`}>
            {change->React.string}
          </span>
          <span className="text-nd_gray-400"> {"vs previous period"->React.string} </span>
        </div>
      </RenderIf>
    </div>
  }
}

module UnmeasuredNote = {
  @react.component
  let make = (~viewContext: viewContext) => {
    let {question, dataset} = viewContext
    let names =
      dataset.unmeasured
      ->Array.map(((values, counts)) =>
        `${values
          ->Array.mapWithIndex((value, index) =>
            question.split
            ->Array.get(index)
            ->Option.mapOr(value, key => viewContext.labelFor(key, value))
          )
          ->Array.joinWith(" · ")} (${counts.total->formatNumberWithCommas} ${sourceNoun(
            question.source,
          )}, ${unmeasurableReason(question.source, question.measure)})`
      )
      ->Array.joinWith("; ")
    <div className={`px-5 pb-4 ${body.sm.regular} text-nd_gray-500`}>
      {`Excluded from the ${measureLabel(
          question.source,
          question.measure,
        )->String.toLowerCase}: ${names}.`->React.string}
    </div>
  }
}
