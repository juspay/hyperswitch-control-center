open Typography
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerDescriptions

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

module DomainTabs = {
  @react.component
  let make = (~selection: selection, ~onSource) =>
    <TabList
      value={(sourceConfig(selection.source).domain :> string)}
      items={domains->Array.map(domain => ((domain :> string), domainLabel(domain)))}
      onChange={id =>
        id->domainFromString->Option.forEach(domain => onSource(domain->getDefaultSource))}
      variant=Underline
      size=Lg
      fitContent=false
    />
}

module SourceTabs = {
  @react.component
  let make = (~selection: selection, ~onSource) => {
    let domainSources = sourceConfig(selection.source).domain->getDomainSources
    <div className="flex items-center gap-3">
      <RenderIf condition={domainSources->Array.length > 1}>
        <TabList
          value={(selection.source :> string)}
          items={domainSources->Array.map(source => ((source :> string), sourceLabel(source)))}
          onChange={id => onSource(id->sourceFromString)}
          variant=Boxed
          size=Md
        />
      </RenderIf>
      <span className={`${body.md.regular} text-nd_gray-500`}>
        {sourceDescription(selection.source)->React.string}
      </span>
    </div>
  }
}
