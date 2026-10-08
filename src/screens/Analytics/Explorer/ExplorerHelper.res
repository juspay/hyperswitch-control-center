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

module TabList = {
  @react.component
  let make = (
    ~value,
    ~items: array<(string, string)>,
    ~onChange,
    ~variant: TabsBinding.tabsVariant,
    ~size: TabsBinding.tabsSize,
    ~fitContent=true,
  ) =>
    <TabsBinding value onValueChange=onChange variant size>
      <TabsBinding.List variant size fitContent>
        {items
        ->Array.map(((id, label)) =>
          <TabsBinding.Trigger key=id value=id variant size>
            {label->React.string}
          </TabsBinding.Trigger>
        )
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>
}

module SourceTabs = {
  @react.component
  let make = (~question: question, ~onSource) => {
    let siblings = sourceConfig(question.source).domain->getDomainSources
    <div className="flex items-center gap-3">
      <RenderIf condition={siblings->Array.length > 1}>
        <TabList
          value={question.source->sourceToString}
          items={siblings->Array.map(source => (source->sourceToString, sourceLabel(source)))}
          onChange={id => onSource(id->sourceFromString)}
          variant=Boxed
          size=Md
        />
      </RenderIf>
      <span className={`${body.md.regular} text-nd_gray-500`}>
        {sourceDescription(question.source)->React.string}
      </span>
    </div>
  }
}

module DomainTabs = {
  @react.component
  let make = (~question: question, ~onSource) =>
    <TabList
      value={(sourceConfig(question.source).domain :> string)}
      items={domains->Array.map(domain => ((domain :> string), domainLabel(domain)))}
      onChange={id =>
        domains
        ->Array.find(domain => (domain :> string) == id)
        ->Option.forEach(domain => onSource(domain->getDefaultSource))}
      variant=Underline
      size=Lg
      fitContent=false
    />
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

module ViewTabs = {
  @react.component
  let make = (~view: view, ~onViewChange) =>
    <TabList
      value={(view :> string)}
      items={views->Array.map(view => ((view :> string), viewLabel(view)))}
      onChange=onViewChange
      variant=Floating
      size=Md
    />
}

module UnmeasuredNote = {
  @react.component
  let make = (~viewContext: viewContext) => {
    let {question, dataset} = viewContext
    let names =
      dataset.unmeasured
      ->Array.map(((values, counts)) =>
        `${values->getValuesLabel(
            ~split=question.split,
            ~labelFor=viewContext.labelFor,
          )} (${counts.total->formatNumberWithCommas} ${sourceNoun(
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

module FilterChips = {
  @react.component
  let make = (~viewContext: viewContext, ~editing, ~onEdit, ~onRemove) =>
    viewContext.question.filters
    ->Array.map(((key, values)) =>
      <button
        key={(key :> string)}
        className="inline-flex"
        onClick={_ => onEdit(Some(key))}
        title="Edit this filter">
        <TagBinding
          text={`${dimensionLabel(key)}: ${values
            ->Array.map(value => viewContext.labelFor(key, value))
            ->Array.joinWith(", ")}`}
          variant=Subtle
          color={editing == Some(key) ? Primary : Neutral}
          size=Sm
          shape=Rounded
          rightSlot={<span
            className="inline-flex"
            onClick={ev => {
              ev->ReactEvent.Mouse.stopPropagation
              onRemove(key)
            }}>
            <Icon name="nd-cross" size=10 />
          </span>}
        />
      </button>
    )
    ->React.array
}

module OutcomeBar = {
  @react.component
  let make = (~viewContext: viewContext) => {
    let {question, dataset} = viewContext
    <div className="flex flex-col gap-1 pt-2">
      <div className={`${body.sm.medium} uppercase text-nd_gray-400`}>
        {`${dataset.overall.total->formatNumberWithCommas} ${sourceNoun(
            question.source,
          )} by outcome`->React.string}
      </div>
      <StackedBarGraph
        key={`summary|${viewContext.chartKey}`}
        options={StackedBarGraphUtils.getStackedBarGraphOptions(
          {
            categories: [sourceNoun(question.source)],
            data: viewContext
            ->ExplorerSummaryUtils.getOutcomeParts
            ->Array.toReversed
            ->Array.map(((name, value, color)): StackedBarGraphTypes.dataObj => {
              name,
              data: [value],
              color,
            }),
            labelFormatter: ExplorerCharts.outcomeLegend,
          },
          ~yMax=dataset.overall.total->Float.toInt,
          ~labelItemDistance=32,
          ~pointWidth=16,
        )}
      />
      <RenderIf condition={viewContext->ExplorerSummaryUtils.isAwaitingExcluded}>
        <div className={`${body.sm.regular} text-nd_gray-500`}>
          {`Payments awaiting customer or merchant action are excluded from the ${measureLabel(
              question.source,
              question.measure,
            )->String.toLowerCase}.`->React.string}
        </div>
      </RenderIf>
    </div>
  }
}

module SplitSuggestions = {
  @react.component
  let make = (~suggestions: array<dimension>, ~onSelect) =>
    <div
      className={`flex flex-wrap items-center gap-2 border-t border-nd_br_gray-150 px-5 py-3 ${body.md.regular}`}>
      <span className="text-nd_gray-500"> {"Break down by"->React.string} </span>
      {suggestions
      ->Array.map(key =>
        <Button
          key={(key :> string)}
          text={dimensionLabel(key)}
          buttonType=Secondary
          buttonSize=XSmall
          onClick={_ => onSelect(key)}
        />
      )
      ->React.array}
    </div>
}
