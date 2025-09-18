@react.component
let make = () => {
  open HSwitchUtils

  let url = RescriptReactRouter.useUrl()

  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {transactionEntity}} = React.useContext(UserInfoProvider.defaultContext)

  <div key={(transactionEntity :> string)}>
    {switch url.path->urlPath {
    | list{"v2", "orchestration", "payments", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=OperationsView)}>
        <FilterContext key="payments" index="payments">
          <EntityScaffold
            entityName="Payments"
            remainingPath
            access=Access
            renderList={() => <Orders />}
            renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
              <ShowOrder id profileId merchantId orgId />}
          />
        </FilterContext>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
