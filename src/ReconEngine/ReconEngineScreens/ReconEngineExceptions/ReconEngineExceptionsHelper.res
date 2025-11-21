open Typography

module ResolutionButton = {
  @react.component
  let make = (~config: ReconEngineExceptionsTypes.buttonConfig) => {
    <RenderIf condition={config.condition}>
      <Button
        buttonState=Normal
        buttonSize=Medium
        buttonType={config.buttonType}
        text={config.text}
        textWeight={`${body.md.semibold}`}
        leftIcon={CustomIcon(<Icon name={config.icon} className={config.iconClass} size=16 />)}
        onClick={_ => config.onClick()}
        customButtonStyle="!w-fit"
      />
    </RenderIf>
  }
}
