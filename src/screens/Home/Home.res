module LowRecoveryCodeBanner = {
  @react.component
  let make = (~recovery_codes_left) => {
    <div className="w-full bg-orange-200 bg-opacity-40 px-6 py-3 flex items-center justify-between">
      <div className="flex items-center gap-3">
        <Icon name="warning-outlined" size=25 />
        <div className="flex gap-2">
          {`You are low on recovery-codes. Only`->React.string}
          <span className="font-bold">
            {`${recovery_codes_left->Int.toString} left`->React.string}
          </span>
        </div>
      </div>
      <Button
        text="Regenerate recovery-codes"
        buttonType={Secondary}
        customButtonStyle="!p-2"
        onClick={_ =>
          RescriptReactRouter.push(
            HSwitchGlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
          )}
      />
    </div>
  }
}

@react.component
let make = () => {
  open HomeUtils
  open PageUtils
  let greeting = getGreeting()

  let {authStatus} = React.useContext(AuthInfoProvider.authStatusContext)

  let recovery_codes_left = switch authStatus {
  | LoggedIn(info) =>
    switch info {
    | TotpAuth(totpAuthInfo) => totpAuthInfo.recovery_codes_left
    | _ => None
    }
  | _ => None
  }

  <div className="w-full gap-8 flex flex-col">
    <div className="flex flex-col gap-4">
      <UIUtils.RenderIf
        condition={recovery_codes_left->Option.isSome && recovery_codes_left->Option.getOr(8) < 3}>
        <LowRecoveryCodeBanner recovery_codes_left={recovery_codes_left->Option.getOr(8)} />
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
