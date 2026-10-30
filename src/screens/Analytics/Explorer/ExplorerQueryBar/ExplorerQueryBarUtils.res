open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerDescriptions

let measureOptions = source =>
  sourceConfig(source).measures->Array.map((measure): MultiSelectBindings.selectMenuItemType => {
    label: measureLabel(source, measure),
    value: (measure :> string),
    subLabel: measureDefinition(source, measure),
  })

let flowOptions = (dataset: dataset) =>
  flows->Array.map((flow): MultiSelectBindings.selectMenuItemType => {
    label: flowLabel(flow),
    value: (flow :> string),
    subLabel: flow == #all
      ? flowDescription(flow)
      : `${flowDescription(flow)} · ${dataset.flowCounts
          ->getValueFromDict((flow :> string), 0.0)
          ->formatNumberWithCommas}`,
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
  | (#refund, #refund_status) => Some(refundStatuses->Array.map(status => (status :> string)))
  | _ => None
  }
