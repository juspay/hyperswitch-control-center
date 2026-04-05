@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()

  <div>
    {switch url.path->urlPath {
    | list{"payments", ...remainingPath} =>
      <FilterContext key="payments" index="payments">
        <EntityScaffold
          entityName="Payments"
          remainingPath
          access=Access
          renderList={() => <Orders showAdditionalFeatures=false />}
          renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
            <ShowOrder id profileId merchantId orgId />}
        />
      </FilterContext>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
