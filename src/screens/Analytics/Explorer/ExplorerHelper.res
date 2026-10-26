open Typography
open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerDescriptions
open ExplorerSelection

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

module PresetPicker = {
  @react.component
  let make = (~selection: selection, ~onPreset) =>
    <div className="flex items-center gap-2 pb-1">
      <span className={`${body.md.regular} text-nd_gray-500`}>
        {"Start with a question"->React.string}
      </span>
      <SingleSelectBinding
        selected={selection->getActivePreset->mapOptionOrDefault("", preset => preset.title)}
        onSelect={title =>
          presets->Array.find(preset => preset.title == title)->Option.forEach(onPreset)}
        items=[
          {
            items: presets->Array.map((preset): MultiSelectBindings.selectMenuItemType => {
              label: preset.title,
              value: preset.title,
              subLabel: `${domainLabel(sourceConfig(preset.source).domain)} · ${measureLabel(
                  preset.source,
                  preset.measure,
                )}`,
              disableTruncation: true,
            }),
          },
        ]
        placeholder="Choose a question"
        size=Sm
        minMenuWidth=320
        maxMenuWidth=380
        alignment=End
      />
    </div>
}
