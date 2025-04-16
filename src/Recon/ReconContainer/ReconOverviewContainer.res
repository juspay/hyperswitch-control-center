@react.component
let make = (~showOnBoarding) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | false => <ReconOverviewContent />
    | true => <ReconOnboardingLanding />
    }
  }
}
