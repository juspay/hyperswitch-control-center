open ExplorerCatalog
open ExplorerDescriptions

let measureOptions = source =>
  sourceConfig(source).measures->Array.map((measure): MultiSelectBindings.selectMenuItemType => {
    label: measureLabel(source, measure),
    value: (measure :> string),
    subLabel: measureDefinition(source, measure),
  })
