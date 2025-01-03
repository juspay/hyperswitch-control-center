@react.component
let make = () => {
  open PageUtils

  <div className="flex flex-col w-full gap-6 items-center justify-center">
    <PageHeading
      customHeadingStyle="gap-3 max-w-860 flex flex-col items-center"
      title="Effortless Realtime Payment Reconciliation"
      customTitleStyle="text-fs-48 leading-60 text-center max-w-600 font-bold"
      customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
      subTitle="Effortlessly Track, Match, and Reconcile Transactions with Ease. Gain Real-Time Accuracy and Unmatched Confidence in Financial Operations"
    />
    <Button
      text="Get Started"
      onClick={_ => {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon/configuration"))
      }}
      buttonType=Primary
      buttonSize=Large
      buttonState=Normal
      customButtonStyle="rounded-md"
    />
    <img alt="reconLanding" className="sm:w-10/12 w-full" src="/assets/reconLanding.svg" />
  </div>
}
