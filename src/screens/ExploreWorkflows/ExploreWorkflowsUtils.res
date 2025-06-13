open ExploreWorkflowsTypes

let workflowCardsData: array<cardDetails> = [
  {
    title: "Explore Smart Retries",
    description: "Automatically re-attempt failed payments to boost your success rates. Set up your rules now.",
    buttonText: "Try Smart Retires",
    imageLink: "smart_retries_graphic.png",
    workflowType: #ExploreSmartRetries,
  },
  {
    title: "Explore Routing",
    description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. adipiscing elit.",
    buttonText: "Setup Routing",
    imageLink: "routing_graphic.png",
    workflowType: #ExploreRouting,
  },
]

let getStepsForWorkflow = (workflowTitle): array<stepDetails> => {
  switch workflowTitle {
  | #ExploreSmartRetries => [
      {
        title: "Step 1: Connect Processors",
        description: "Navigate to Connectors > Add Processor, and enter your API credentials. Connect at least two processors so Smart Retries has a backup.",
        videoPath: Some("connect_processor.mp4"),
        ctaText: Some("Add processors →"),
        ctaLink: Some("/connectors"),
      },
      {
        title: "Step 2: Configure Fallback Order",
        description: "Define the sequence of processors to try if the primary one fails.",
        videoPath: None,
        ctaText: Some("Configure Routing →"),
        ctaLink: Some("/routing/default"),
      },
      {
        title: "Step 3: Set Up Retry Rules",
        description: "Define when and how to retry failed payments. Configure retry attempts, intervals, and conditions.",
        videoPath: None,
        ctaText: Some("Configure Retries →"),
        ctaLink: Some("/settings/retry"),
      },
      {
        title: "Step 4: Monitor Performance",
        description: "Track the success rate of your retries in the Analytics dashboard. Adjust your strategy based on performance data.",
        videoPath: None,
        ctaText: Some("View Analytics →"),
        ctaLink: Some("/analytics-payments"),
      },
    ]

  | #ExploreRouting => [
      {
        title: "Step 1: Define Routing Rules",
        description: "Create rules in the Routing section to direct payments based on your criteria.",
        videoPath: Some("connect_processor.mp4"),
        ctaText: Some("Setup Routing →"),
        ctaLink: Some("/routing"),
      },
    ]
  | _ => []
  }
}

let getDrawerTitleFromVariant = (workflowType: workflowTypes): string => {
  switch workflowType {
  | #ExploreSmartRetries => "Explore Smart Retries"
  | #ExploreRouting => "Explore Routing"
  }
}

let getNextStateBasedOnPrevState = (
  prevState: ProviderTypes.workflowDrawerStateTypes,
): ProviderTypes.workflowDrawerStateTypes => {
  switch prevState {
  | Closed => Closed
  | FullWidth(title) => Minimised(title)
  | Minimised(title) => FullWidth(title)
  }
}
