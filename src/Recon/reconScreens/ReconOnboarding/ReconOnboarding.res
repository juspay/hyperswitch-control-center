@react.component
let make = (~showOnBoarding, ~setShowOnBoarding) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | true => <ReconOnboardingLanding setShowOnBoarding />
    | false => <ReconOverview />
    }
  }
}
