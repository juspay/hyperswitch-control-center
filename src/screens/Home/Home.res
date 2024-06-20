@react.component
let make = () => {
  open HomeUtils
  open PageUtils
  let greeting = getGreeting()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let recovery_codes_left = switch authStatus {
  | LoggedIn(Auth(totpInfo)) => totpInfo.recovery_codes_left
  | _ => HSwitchGlobalVars.maximumRecoveryCodes
  }

  <div className="w-full gap-8 flex flex-col">
    <div className="flex flex-col gap-4">
      <UIUtils.RenderIf condition={featureFlagDetails.totp && recovery_codes_left < 3}>
        <HomeUtils.LowRecoveryCodeBanner recovery_codes_left />
      </UIUtils.RenderIf>
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
