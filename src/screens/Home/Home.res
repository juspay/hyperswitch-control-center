@react.component
let make = (~setAppScreenState) => {
  open HomeUtils
  open PageUtils
  let greeting = getGreeting()
  let {userInfo: {recoveryCodesLeft}} = React.useContext(UserInfoProvider.defaultContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let recoveryCode = recoveryCodesLeft->Option.getOr(0)

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
        customTitleStyle="!text-fs-24 !font-semibold"
        customSubTitleStyle="text-fs-16 text-nd_gray-400 !opacity-100 font-medium !mt-1"
      />
      <ControlCenter />
      <RenderIf condition={featureFlagDetails.exploreRecipes}>
        <ExploreWorkflowsSection />
      </RenderIf>
      <DevResources />
    </div>

    <div className="p-8 space-y-4">
      <TableUtils.LabelCell labelColor=LabelGreen text="PROCESSING" />
      <TableUtils.LabelCell labelColor=LabelRed text="PROCESSING" />
      <TableUtils.LabelCell labelColor=LabelOrange text="PROCESSING" />
      <TableUtils.LabelCell labelColor=LabelBlue text="PROCESSING" />
      <TableUtils.LabelCell labelColor=LabelPurple text="PROCESSING" />
    </div>
  </>
}
