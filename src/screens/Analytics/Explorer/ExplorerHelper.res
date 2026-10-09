open Typography
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerDescriptions

module SourceTabs = {
  @react.component
  let make = (~question: question, ~onSource) =>
    <div className="flex items-center gap-3">
      <TabsBinding
        value={(question.source :> string)}
        onValueChange={id => onSource(id->sourceFromString)}
        variant=Boxed
        size=Md>
        <TabsBinding.List variant=Boxed size=Md fitContent=true>
          {sources
          ->Array.map(source =>
            <TabsBinding.Trigger
              key={(source :> string)} value={(source :> string)} variant=Boxed size=Md>
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
