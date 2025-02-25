@react.component
let make = (~showOnBoarding, ~setShowOnBoarding, ~showSkeleton) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | true => <ReconOnboardingLanding setShowOnBoarding />
    | false => <ReconOverview showSkeleton />
    }
  }
}
