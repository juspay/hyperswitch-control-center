@react.component
let make = (~setAppScreenState) => {
  open HomeUtils
  open PageUtils
  open Typography
  let greeting = getGreeting()
  let {recoveryCodesLeft} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let recoveryCode = recoveryCodesLeft->Option.getOr(0)
  let (isCurrentMerchantPlatform, _) = OMPSwitchHooks.useOMPType()

  <>
    <div className="flex flex-col gap-4">
      <RenderIf condition={recoveryCodesLeft->Option.isSome && recoveryCode < 3}>
        <HomeUtils.LowRecoveryCodeBanner recoveryCode />
      </RenderIf>
      <PendingInvitationsHome setAppScreenState />
    </div>
    <div className="w-full gap-8 flex flex-col">
      <PageHeading
        title={`${greeting}, it's great to see you!`}
        subTitle="Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments."
        customTitleStyle={`!${heading.lg.semibold}`}
        customSubTitleStyle={`text-nd_gray-400 !opacity-100 !mt-1" ${body.lg.medium}`}
      />
      <RenderIf condition={isCurrentMerchantPlatform}>
        <PlatformOverview />
      </RenderIf>
      <RenderIf condition={!isCurrentMerchantPlatform}>
        <ControlCenter />
        <RenderIf condition={featureFlagDetails.exploreRecipes}>
          <ExploreWorkflowsSection />
        </RenderIf>
      </RenderIf>
      <DevResources />
    </div>
  </>
}
