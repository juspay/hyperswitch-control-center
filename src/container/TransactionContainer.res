@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  let url = RescriptReactRouter.useUrl()

  let {userHasAccess} = PermissionHooks.useUserPermissionHook()
  let {userInfo: {transactionEntity}} = React.useContext(UserInfoProvider.defaultContext)
  let {payOut} = featureFlagAtom->Recoil.useRecoilValueFromAtom
  <div key={(transactionEntity :> string)}>
    {switch url.path->urlPath {
    | list{"payments", ...remainingPath} =>
      <AccessControl permission={userHasAccess(~permission=OperationsView)}>
        <FilterContext key="payments" index="payments">
          <EntityScaffold
            entityName="Payments"
            remainingPath
            access=Access
            renderList={() => <Orders />}
            renderShow={(id, key) => <ShowOrder id profileId={key} />}
          />
        </FilterContext>
      </AccessControl>
    | list{"payouts", ...remainingPath} =>
      <AccessControl isEnabled={payOut} permission={userHasAccess(~permission=OperationsView)}>
        <FilterContext key="payouts" index="payouts">
          <EntityScaffold
            entityName="Payouts"
            remainingPath
            access=Access
            renderList={() => <PayoutsList />}
            renderShow={(id, key) => <ShowPayout id profileId={key} />}
          />
        </FilterContext>
      </AccessControl>
    | list{"refunds", ...remainingPath} =>
      <AccessControl permission={userHasAccess(~permission=OperationsView)}>
        <FilterContext key="refunds" index="refunds">
          <EntityScaffold
            entityName="Refunds"
            remainingPath
            access=Access
            renderList={() => <Refund />}
            renderShow={(id, key) => <ShowRefund id profileId={key} />}
          />
        </FilterContext>
      </AccessControl>
    | list{"disputes", ...remainingPath} =>
      <AccessControl permission={userHasAccess(~permission=OperationsView)}>
        <FilterContext key="disputes" index="disputes">
          <EntityScaffold
            entityName="Disputes"
            remainingPath
            access=Access
            renderList={() => <Disputes />}
            renderShow={(id, key) => <ShowDisputes id profileId={key} />}
          />
        </FilterContext>
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <NotFoundPage />
    }}
  </div>
}
