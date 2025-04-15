@react.component
let make = (~showOnBoarding, ~setShowOnBoarding, ~currentStep, ~setCurrentStep) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | false => <ReconOverviewContent />
    | true => <ReconConfiguration setShowOnBoarding currentStep setCurrentStep />
    }
  }
}
