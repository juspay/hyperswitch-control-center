@react.component
let make = (
  ~isSelected,
  ~setIsSelected,
  ~isDisabled=false,
  ~boolCustomClass="",
  ~toggleBorder="border-green-950",
  ~toggleEnableColor="bg-green-950",
  ~customToggleHeight="16px",
  ~customToggleWidth="30px",
  ~customInnerCircleHeight="12px",
  ~transformValue="14px",
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  let blendNode =
    <AddDataAttributes
      attributes=[("data-bool-value", isSelected ? "on" : "off")]>
      <div className="inline-flex items-center">
        <SwitchBinding checked=isSelected onChange=setIsSelected disabled=isDisabled />
      </div>
    </AddDataAttributes>

  <>
    <RenderIf condition={isBlendEnabled}> blendNode </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <BoolInput.BaseComponent
        isSelected
        setIsSelected
        isDisabled
        boolCustomClass
        toggleBorder
        toggleEnableColor
        customToggleHeight
        customToggleWidth
        customInnerCircleHeight
        transformValue
      />
    </RenderIf>
  </>
}
