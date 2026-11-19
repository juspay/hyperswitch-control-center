@react.component
let make = (~remainingPath) => {
  <FilterContext key="payments" index="payments">
    <EntityScaffold
      entityName="Payments"
      remainingPath
      renderList={() => <Orders />}
      renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
        <ShowOrder id profileId merchantId orgId />}
    />
  </FilterContext>
}
