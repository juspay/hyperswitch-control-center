type prerequisite = ConnectorList | BusinessProfile

type embeddableComponent = {
  name: string,
  prerequisites: array<prerequisite>,
  filterKey: option<string>,
  displayOptions: EmbeddableComponentContext.displayOptions,
  render: list<string> => React.element,
}

let components = [
  {
    name: "connectors",
    prerequisites: [ConnectorList, BusinessProfile],
    filterKey: None,
    displayOptions: EmbeddableComponentContext.embeddableDisplayOptions,
    render: remainingPath =>
      <EntityScaffold
        entityName="Connectors"
        remainingPath
        renderList={() =>
          <ConnectorList
            showDummyProcessorBanner=false
            showRequestConnectorBtn=false
            showDummyConnectorButton=false
          />}
        renderNewForm={() => <ConnectorHome showBreadCrumbWarning=false />}
        renderShow={(_, _) => <ConnectorHome showBreadCrumbWarning=false />}
      />,
  },
  {
    name: "payments",
    prerequisites: [],
    filterKey: Some("payments"),
    displayOptions: EmbeddableComponentContext.embeddableDisplayOptions,
    render: remainingPath =>
      <EntityScaffold
        entityName="Payments"
        remainingPath
        renderList={() => <Orders />}
        renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
          <ShowOrder id profileId merchantId orgId />}
      />,
  },
  {
    name: "refunds",
    prerequisites: [],
    filterKey: Some("refunds"),
    displayOptions: EmbeddableComponentContext.embeddableDisplayOptions,
    render: remainingPath =>
      <EntityScaffold
        entityName="Refunds"
        remainingPath
        renderList={() => <Refund />}
        renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
          <ShowRefund id profileId merchantId orgId />}
      />,
  },
]

let getComponent = name => components->Array.find(component => component.name === name)
