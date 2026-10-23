open ExplorerTypes
open ExplorerCatalog
open ExplorerDescriptions

let measureOptions = source =>
  sourceConfig(source).measures->Array.map((measure): MultiSelectBindings.selectMenuItemType => {
    label: measureLabel(source, measure),
    value: (measure :> string),
    subLabel: measureDefinition(source, measure),
  })

let dimensionOptions = (source, dimensions: array<dimension>) =>
  dimensions->Array.map((key): MultiSelectBindings.selectMenuItemType => {
    label: dimensionLabel(key),
    value: (key :> string),
    subLabel: dimensionDescription(source, key),
  })

let getStaticFilterValues = (source: source, key: dimension) =>
  switch (source, key) {
  | (#intent, #status) => Some(intentStatuses->Array.map(status => (status :> string)))
  | _ => None
  }
