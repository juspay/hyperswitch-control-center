@react.component
let make = () => {
  open HomeUtils
  open PageUtils
  let greeting = getGreeting()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let {recoveryCodesLeft} = React.useContext(UserInfoProvider.defaultContext)
  let recoveryCode = recoveryCodesLeft->Option.getOr(0)

  <div className="w-full gap-8 flex flex-col">
    <div className="flex flex-col gap-4">
      <RenderIf
        condition={featureFlagDetails.totp && recoveryCodesLeft->Option.isSome && recoveryCode < 3}>
        <HomeUtils.LowRecoveryCodeBanner recoveryCode />
      </RenderIf>
      <AcceptInviteHome />
    </div>
    <PageHeading
      title={`${greeting}, it's great to see you!`}
      subTitle="Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments."
    />
    <ControlCenter />
    <DevResources />
  </div>
}
