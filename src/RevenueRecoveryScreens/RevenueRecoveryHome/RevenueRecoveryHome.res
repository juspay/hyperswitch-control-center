@react.component
let make = () => {
  open RevenueRecoveryHomeUtils
  open VerticalStepIndicatorTypes

  let (currentStep, _) = React.useState(() => {
    sectionId: (#connectProcessor: revenueRecoverySections :> string),
    subSectionId: Some((#selectProcessor: revenueRecoverySubsections :> string)),
  })

  <div className="flex flex-row">
    <VerticalStepIndicator title="Setup Recovery" sections currentStep />
  </div>
}
