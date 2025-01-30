@react.component
let make = () => {
  open PageUtils

  <div
    className="flex flex-col w-full gap-6 items-center border bg-white rounded-lg py-14 px-10 h-923-px">
    <PageHeading
      customHeadingStyle="gap-3 flex flex-col items-center"
      title="Effortless, Realtime Payment Reconciliation"
      customTitleStyle="md:text-fs-48 text-fs-28 md:leading-60 text-center font-bold"
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
    />
    <img alt="reconLanding" className="w-full" src="/assets/reconLanding.svg" />
  </div>
}
