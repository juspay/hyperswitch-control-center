external ffInputToBoolInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  bool,
> = "%identity"

module BaseComponent = {
  @react.component
  let make = (
    ~isSelected,
    ~setIsSelected,
    ~trueLabel="True",
    ~falseLabel="False",
    ~isDisabled=false,
    ~customWidthCss="",
  ) => {
    let cursorClass = "cursor-pointer"

    let oldPaddingClass = "p-2 pl-6 pr-6"
    let oldSelectionClass = condition => condition ? "text-blue-800" : "text-jp-gray-700"

    //New Theme Condition Class
    let parentClass = `flex flex-row font-bold border rounded w-max ${cursorClass}`

    let selectionClass = oldSelectionClass
    let trueBlockClass = `border-r ${oldPaddingClass} ${customWidthCss} ${selectionClass(
        isSelected,
      )}`

    let falseBlockClass = `${oldPaddingClass} ${customWidthCss} ${selectionClass(!isSelected)}`

    <div className=parentClass>
      <div
        className={trueBlockClass}
        onClick={_ =>
          if !isDisabled {
            setIsSelected(true)
          }}>
        {trueLabel->React.string}
      </div>
      <div
        className=falseBlockClass
        onClick={_ =>
          if !isDisabled {
            setIsSelected(false)
          }}>
        {falseLabel->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~input as baseInput: ReactFinalForm.fieldRenderPropsInput,
  ~trueLabel="True",
  ~falseLabel="False",
  ~isDisabled=false,
  ~customWidthCss="",
  ~enableNewTheme=false,
) => {
  let boolInput = baseInput->ffInputToBoolInput
  let boolValue: Js.Json.t = boolInput.value

  let isSelected = switch boolValue->Js.Json.classify {
  | JSONTrue => true
  | JSONString(str) => str === "true"
  | _ => false
  }
  let setIsSelected = boolInput.onChange

  <BaseComponent isSelected setIsSelected trueLabel falseLabel isDisabled customWidthCss />
}
