module StepCard = {
  @react.component
  let make = (
    ~stepName,
    ~description="",
    ~isSelected,
    ~onClick,
    ~iconName,
    ~isLoading=false,
    ~customSelectionComponent,
    ~customOuterClass="",
    ~customSelectionBorderClass=?,
    ~isDisabled=false,
  ) => {
    let borderClass = switch (customSelectionBorderClass, isSelected) {
    | (Some(val), true) => val
    | (_, true) => "border-blue-500"
    | _ => ""
    }

    let disabledClass = isDisabled
      ? "opacity-50 filter blur-xs pointer-events-none cursor-not-allowed"
      : "cursor-pointer"

    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border rounded-xl p-4 transition-shadow justify-between w-full ${borderClass}  ${disabledClass} ${customOuterClass}`}
      onClick={onClick}>
      <div className="flex flex-row items-center gap-x-4 mr-5">
        <Icon name=iconName className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-sm font-semibold text-nd_gray-600 leading-5">
            {stepName->React.string}
          </h3>
          <RenderIf condition={description->String.length > 0}>
            <p className="text-xs font-medium text-nd_gray-400"> {description->React.string} </p>
          </RenderIf>
        </div>
      </div>
      <RenderIf condition={isSelected}>
        {<div className="flex flex-row items-center gap-2"> customSelectionComponent </div>}
      </RenderIf>
      <RenderIf condition={isDisabled}>
        <div className="h-4 w-4 border border-nd_gray-300 rounded-full" />
      </RenderIf>
    </div>
  }
}

@react.component
let make = () => {
  open RevenueRecoveryOnboardingUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let defaultPath = RecoveryConnectorContainerUtils.useGetDefaultPath()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let customSelectionComponent =
    <>
      <Icon name="nd-tick-circle" customHeight="16" />
      <p className="font-semibold text-sm leading-5 text-nd_green-600">
        {"Completed"->React.string}
      </p>
    </>

  let handleClick = () => {
    mixpanelEvent(~eventName="recovery_start_exploring")
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=defaultPath))
  }

  <PageWrapper
    title="Connection Successful" subTitle="Recovery for failed invoices will begin shortly.">
    <div className="flex flex-col h-full gap-y-10">
      <div className="flex flex-col gap-6">
        <StepCard
          key="processor_connection_successful"
          stepName="Processor connection successful"
          description=""
          isSelected=true
          customSelectionComponent
          iconName="nd-inbox-with-outline"
          onClick={_ => ()}
          customSelectionBorderClass="border-nd_br_gray-500"
        />
        <StepCard
          key="billing_platform_connection_successful"
          stepName="Billing Platform connection successful"
          description=""
          isSelected=true
          customSelectionComponent
          iconName="nd-plugin-with-outline"
          onClick={_ => ()}
          customSelectionBorderClass="border-nd_br_gray-500"
        />
      </div>
    </div>
    <div className="flex justify-end items-center mt-7">
      <Button
        text="Start exploring"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        buttonState={Normal}
        onClick={_ => handleClick()}
      />
    </div>
  </PageWrapper>
}
