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
  let onChange = str => input.onChange(str->Identity.stringToFormReactEvent)
  let buttonState = {isDisabled ? Button.Disabled : Button.Normal}

  let buttons =
    options
    ->Array.mapWithIndex((op, i) => {
      let active = input.value->LogicUtils.getStringFromJson("") === op.value
      if isSeparate {
        <Button
          key={i->string_of_int}
          text={op.label}
          onClick={_ => onChange(op.value)}
          buttonType={active ? Primary : SecondaryFilled}
          leftIcon=?op.icon
          buttonState
          ?buttonSize
        />
      } else {
        <Button
          key={i->string_of_int}
          text={op.label}
          onClick={_ => onChange(op.value)}
          textStyle={active ? "text-blue-800" : ""}
          textWeight={active ? "font-semibold" : "font-medium"}
          customButtonStyle={active ? "shadow-inner px-0" : "px-0"}
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
