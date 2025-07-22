open ExploreWorkflowsTypes
open WorkflowSideDrawerHelper

let workflowCardsData: array<cardDetails> = [
  {
    title: "Explore Smart Retries",
    description: "Automatically re-attempt failed payments to boost your success rates. Set up your rules now.",
    buttonText: "Try Smart Retires",
    imageLink: "smart_retries_graphic.png",
    workflowType: #ExploreSmartRetries,
  },
]

let getStepsForWorkflow = (workflowTitle): array<stepDetails> => {
  open Typography
  switch workflowTitle {
  | #ExploreSmartRetries => [
      {
        title: "Get Started",
        description: <span className={`${body.md.medium} text-nd_gray-600`}>
          {React.string(
            "This guide uses pre-configured dummy processors and test cards to simulate Smart Retry. For real connectors, refer to docs.",
          )}
        </span>,
        videoPath: None,
        cta: Some((
          "Refer Docs →",
          ExternalLink({
            url: "https://docs.hyperswitch.io/",
            trackingEvent: "Explore Smart Retries - Refer Docs",
          }),
        )),
      },
      {
        title: "Step 1: Enable Auto Retries",
        description: exploreAutoRetries,
        videoPath: Some("smartRetry/step1.mp4"),
        cta: Some(("Go to Payment Settings →", InternalRoute("/payment-settings"))),
      },
      {
        title: "Step 2: Add Two Dummy Connectors",
        description: addAtleastTwoConnectors,
        videoPath: Some("smartRetry/step2.mp4"),
        cta: Some(("Go to Payment Processors →", InternalRoute("/connectors"))),
      },
      {
        title: "Step 3: Set Connector Priority Order",
        description: setProcessorPriorityOrder,
        videoPath: Some("smartRetry/step3.mp4"),
        cta: Some(("Set Fallback Order →", InternalRoute("/routing/default"))),
      },
      {
        title: "Step 4: Simulate a Failed Payment and Verify the Retry",
        description: simulateAndVerifyRetry,
        videoPath: Some("smartRetry/step4.mp4"),
        cta: Some(("Try It Out →", InternalRoute("/sdk"))),
      },
    ]
  | _ => []
  }
}

let getCurrentWorkflowDetails = (workflowType: workflowTypes): (
  string,
  string,
  array<stepDetails>,
) => {
  switch workflowType {
  | #ExploreSmartRetries => (
      "Smart Retry Setup Guide",
      "Automatically re-attempt failed payments using fallback processors to improve your success rate.",
      getStepsForWorkflow(workflowType),
    )
  | #ExploreRouting => ("Explore Routing", "", getStepsForWorkflow(workflowType))
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
