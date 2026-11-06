open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileHelper

@react.component
let make = (~authorization, ~onBack, ~onContinue) => {
  open Typography

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (selectedModel, setSelectedModel) = React.useState(_ => InternalTriggers)

  <div className="flex flex-1 flex-col gap-8 items-center w-full">
    <div className="flex flex-col gap-2 items-center">
      <p className={`${heading.md.bold} text-center text-nd_gray-700`}>
        {"How do you want to process recovery payments?"->React.string}
      </p>
      <p className={`${body.md.regular} text-center text-nd_gray-500 max-w-3xl`}>
        {"This decides what you need to set up."->React.string}
      </p>
    </div>
    <div className="flex flex-col md:flex-row gap-6 w-full max-w-3xl">
      <SelectionCard
        title={InternalTriggers->RevenueRecoveryProfileUtils.getTriggerModelLabel}
        description="We schedule and make the retries through your connected processor and billing platform."
        isSelected={selectedModel == InternalTriggers}
        onClick={() => setSelectedModel(_ => InternalTriggers)}
      />
      <SelectionCard
        title={ExternalTriggers->RevenueRecoveryProfileUtils.getTriggerModelLabel}
        description="We send you a scheduled retry time and you make the retries. No processor or billing platform is needed."
        isSelected={selectedModel == ExternalTriggers}
        onClick={() => setSelectedModel(_ => ExternalTriggers)}
      />
    </div>
    <div className="flex gap-4">
      <Button text="Back" buttonType=Secondary buttonSize=Large onClick={_ => onBack()} />
      <ACLButton
        authorization
        text="Continue"
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
        onClick={_ => {
          mixpanelEvent(
            ~eventName=`recovery_model_selected_${selectedModel->RevenueRecoveryProfileUtils.getTriggerModelValue}`,
          )
          onContinue(selectedModel)
        }}
      />
    </div>
  </div>
}
