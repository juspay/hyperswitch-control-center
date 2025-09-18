@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()

  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {transactionEntity}} = React.useContext(UserInfoProvider.defaultContext)
  let {payOut} = featureFlagAtom->Recoil.useRecoilValueFromAtom
  <div key={(transactionEntity :> string)}>
    {switch url.path->urlPath {
    | list{"payments", ...remainingPath} =>
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
    | list{"payouts", ...remainingPath} =>
      <AccessControl isEnabled={payOut} authorization={userHasAccess(~groupAccess=OperationsView)}>
        <FilterContext key="payouts" index="payouts">
          <EntityScaffold
            entityName="Payouts"
            remainingPath
            access=Access
            renderList={() => <PayoutsList />}
            renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
              <ShowPayout id profileId merchantId orgId />}
          />
        </FilterContext>
      </AccessControl>
    | list{"refunds", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=OperationsView)}>
        <FilterContext key="refunds" index="refunds">
          <EntityScaffold
            entityName="Refunds"
            remainingPath
            access=Access
            renderList={() => <Refund />}
            renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
              <ShowRefund id profileId merchantId orgId />}
          />
        </FilterContext>
      </AccessControl>
    | list{"disputes", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=OperationsView)}>
        <FilterContext key="disputes" index="disputes">
          <EntityScaffold
            entityName="Disputes"
            remainingPath
            access=Access
            renderList={() => <Disputes />}
            renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
              <ShowDisputes id profileId merchantId orgId />}
          />
        </FilterContext>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
