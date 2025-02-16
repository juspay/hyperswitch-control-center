open SelectBox
@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<dropdownOption>,
  ~buttonClass="",
  ~isDisabled=false,
  ~isSeparate=false,
  ~buttonSize=?,
) => {
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let onChange = str => input.onChange(str->Identity.stringToFormReactEvent)
  let buttonState = {isDisabled ? Button.Disabled : Button.Normal}

  let buttons =
    options
    ->Array.mapWithIndex((op, i) => {
      let active = input.value->LogicUtils.getStringFromJson("") === op.value
      if isSeparate {
        <Button
          key={i->Int.toString}
          text={op.label}
          onClick={_ => onChange(op.value)}
          buttonType={active ? Primary : SecondaryFilled}
          leftIcon=?op.icon
          buttonState
          ?buttonSize
        />
      } else {
        <Button
          key={i->Int.toString}
          text={op.label}
          onClick={_ => onChange(op.value)}
          textStyle={active ? `${textColor.primaryNormal}` : ""}
          textWeight={active ? "font-semibold" : "font-medium"}
          customButtonStyle={active ? "shadow-inner" : ""}
          buttonType={active ? SecondaryFilled : Secondary}
          leftIcon=?op.icon
          buttonState
          ?buttonSize
        />
      }
    })
    ->React.array

  if isSeparate {
    <div className={`flex flex-row gap-4 items-center my-2 ${buttonClass}`}> {buttons} </div>
  } else {
    <ButtonGroup wrapperClass="flex flex-row mr-2 ml-1"> {buttons} </ButtonGroup>
  }
}
