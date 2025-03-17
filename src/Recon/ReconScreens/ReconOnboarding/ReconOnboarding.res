@react.component
let make = (~showOnBoarding) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | true => <ReconOnboardingLanding />
    | false => <ReconOverviewContent />
    }
  }
}
