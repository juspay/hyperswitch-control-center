@react.component
let make = (~showOnBoarding, ~setShowOnBoarding, ~showSkeleton, ~setShowSkeleton) => {
  open ReconOnboardingHelper

  {
    switch showOnBoarding {
    | true => <ReconOnboardingLanding setShowOnBoarding />
    | false => <ReconOverview showSkeleton setShowSkeleton />
    }
  }
}
