@react.component
let make = () => {
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
    ~entityName=V2(V2_CONNECTOR),
    ~version=V2,
  )
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let {devRecoveryExternalTrigger} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId(
    ~version=UserInfoTypes.V2,
  )

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (recoveryProfile, setRecoveryProfile) =
    HyperswitchAtom.recoveryProfileAtom->Recoil.useRecoilState

  let fetchRecoveryProfile = async () => {
    let profile = await fetchBusinessProfileFromId(~profileId=Some(profileId))
    setRecoveryProfile(_ => Some(profile->RevenueRecoveryProfileUtils.mapJsonToRecoveryProfile))
  }

  let refreshRecoveryProfile = async () => {
    try {
      await fetchRecoveryProfile()
    } catch {
    | _ => ()
    }
  }

  let setUpConnectorContainer = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      setRecoveryProfile(_ => None)
      if (
        userHasAccess(~groupAccess=ConnectorsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsView) === Access ||
        userHasAccess(~groupAccess=WorkflowsManage) === Access
      ) {
        let connectorList = await fetchConnectorListResponse()
        if devRecoveryExternalTrigger {
          let hasBillingConnector =
            connectorList
            ->ConnectorInterfaceUtils.filterConnectorList(BillingProcessor)
            ->LogicUtils.isNonEmptyArray
          try {
            await fetchRecoveryProfile()
          } catch {
          | error =>
            if !hasBillingConnector {
              raise(error)
            }
          }
        }
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  let connectors = ConnectorListInterface.useFilteredConnectorList(~retainInList=BillingProcessor)

  let hasConfiguredBillingConnector = connectors->Array.length > 0
  let isOnboarded = RevenueRecoveryProfileUtils.isRecoveryOnboarded(
    ~recoveryProfile,
    ~hasConfiguredBillingConnector,
  )
  let onProfileSaved = savedProfile => setRecoveryProfile(_ => Some(savedProfile))

  React.useEffect(() => {
    setUpConnectorContainer()->ignore
    None
  }, [merchantId, profileId])

  React.useEffect(() => {
    switch recoveryProfile {
    | Some({RevenueRecoveryProfileTypes.retryAlgorithm: None}) if hasConfiguredBillingConnector =>
      refreshRecoveryProfile()->ignore
    | _ => ()
    }
    None
  }, [hasConfiguredBillingConnector])
  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    | list{"v2", "recovery", "onboarding", "configuration"} if devRecoveryExternalTrigger =>
      <AccessControl authorization={userHasAccess(~groupAccess=AccountManage)}>
        <div className="mt-14">
          <RevenueRecoveryModeConfiguration isOnboarded onProfileSaved />
        </div>
      </AccessControl>
    | list{"v2", "recovery", "onboarding", ...remainingPath} =>
      <AccessControl authorization={userHasAccess(~groupAccess=ConnectorsView)}>
        {<div className="mt-14">
          <EntityScaffold
            entityName="onboarding"
            remainingPath
            renderList={() => <RevenueRecoveryOnboarding />}
            renderNewForm={() => <RevenueRecoveryOnboarding />}
            renderShow={(_, _) => <RevenueRecoveryOnboarding />}
          />
        </div>}
      </AccessControl>
    | list{"v2", "recovery", "invoices", ...remainingPath} =>
      if isOnboarded {
        <EntityScaffold
          entityName="Invoices"
          remainingPath
          access=Access
          renderList={() =>
            <FilterContext key="RecoveryInvoices" index="RecoveryInvoices">
              <RevenueRecoveryInvoices />
            </FilterContext>}
          renderCustomWithOMP={(id, profileId, merchantId, orgId) =>
            <ShowRevenueRecovery id profileId merchantId orgId />}
        />
      } else {
        <RevenueRecoveryOnboardingLanding createMerchant=false />
      }
    | list{"v2", "recovery", "summary", ..._} =>
      if isOnboarded {
        <BillingConnectorsSummary recoveryProfile onProfileSaved />
      } else {
        <RevenueRecoveryOnboardingLanding createMerchant=false />
      }
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <EmptyPage path=RevenueRecoverySidebarValues.defaultPath />
    }}
  </PageLoaderWrapper>
}
