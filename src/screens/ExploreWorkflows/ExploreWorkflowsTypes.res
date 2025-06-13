type workflowTypes = [
  | #ExploreSmartRetries
  | #ExploreRouting
]

type cardDetails = {
  title: string,
  description: string,
  buttonText: string,
  imageLink: string,
  workflowType: workflowTypes,
}

type stepDetails = {
  title: string,
  description: string,
  videoPath: option<string>,
  ctaText: option<string>,
  ctaLink: option<string>,
}

type workflowSideDrawerProps = {
  isOpen: bool,
  onClose: unit => unit,
  workflowTitle: string,
  steps: array<stepDetails>,
}
