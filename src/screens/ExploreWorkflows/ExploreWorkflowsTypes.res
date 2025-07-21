type workflowTypes = [
  | #ExploreSmartRetries
  | #ExploreRouting
]

type actionType =
  | InternalRoute(string)
  | ExternalLink({url: string, trackingEvent: string})

type cardDetails = {
  title: string,
  description: string,
  buttonText: string,
  imageLink: string,
  workflowType: workflowTypes,
}

type stepDetails = {
  title: string,
  description: React.element,
  videoPath: option<string>,
  cta: option<(string, actionType)>,
}

type workflowSideDrawerProps = {
  isOpen: bool,
  onClose: unit => unit,
  workflowTitle: string,
  steps: array<stepDetails>,
}
