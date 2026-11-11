@react.component
let make = (~remainingPath) => {
  <FilterContext key="refunds" index="refunds">
    <EntityScaffold
      entityName="Refunds"
      remainingPath
      renderList={() => <Refund />}
      renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
        <ShowRefund id profileId merchantId orgId />}
    />
  </FilterContext>
}
