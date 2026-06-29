open ReactFinalForm
open LogicUtils

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder: string,
  ~isDisabled: bool,
  ~rows: option<int>=?,
  ~cols: option<int>=?,
  ~customClass: string="",
  ~leftIcon: option<React.element>=?,
  ~readOnly: option<bool>=?,
  ~maxLength: option<int>=?,
  ~autoFocus: option<bool>=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()
  let showPopUp = PopUpState.useShowPopUp()

  React.useEffect(() => {
    let val = input.value->getStringFromJson("")
    if isBlendEnabled && (val->String.includes("<script>") || val->String.includes("</script>")) {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Script Tags are not allowed`,
        description: React.string(`Input cannot contain <script>, </script> tags`),
        handleConfirm: {text: "OK"},
      })
      input.onChange(
        val
        ->stringReplaceAll("<script>", "")
        ->stringReplaceAll("</script>", "")
        ->Identity.stringToFormReactEvent,
      )
    }
    None
  }, [input.value])

  let value = switch input.value->JSON.Classify.classify {
  | String(str) => str
  | Number(num) => num->Float.toString
  | _ => ""
  }

  let blendTextArea =
    <TextAreaBinding
      value
      placeholder
      onChange=input.onChange
      onBlur=input.onBlur
      onFocus=input.onFocus
      name=input.name
      disabled=isDisabled
      ?rows
      ?cols
      ?maxLength
      ?readOnly
      ?autoFocus
    />

  let blendContent = switch leftIcon {
  | Some(icon) =>
    <div className="flex flex-row md:relative">
      <div className="absolute self-start p-3"> icon </div>
      blendTextArea
    </div>
  | None => blendTextArea
  }

  <>
    <RenderIf condition={isBlendEnabled}> blendContent </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <MultiLineTextInput
        input
        placeholder
        isDisabled
        ?rows
        ?cols
        customClass
        ?leftIcon
        ?readOnly
        ?maxLength
        ?autoFocus
      />
    </RenderIf>
  </>
}
