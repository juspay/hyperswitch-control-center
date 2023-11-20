external ffInputToBoolInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  bool,
> = "%identity"

module BaseComponent = {
  @react.component
  let make = (
    ~isSelected,
    ~setIsSelected,
    ~size: CheckBoxIcon.size=Small,
    ~isDisabled=false,
    ~boolCustomClass="",
    ~addAttributeId="",
  ) => {
    let toggleSelect = React.useCallback3(_ev => {
      if !isDisabled {
        setIsSelected(!isSelected)
      }
    }, (isDisabled, isSelected, setIsSelected))
    let isMobileView = MatchMedia.useMobileChecker()

    let toggleEnableColor = "bg-green-950  border dark:bg-green-950"

    let toggleBorder = "border border-green-950"
    let toggleColor = "bg-gradient-to-t from-jp-gray-200 to-jp-gray-250 dark:from-jp-gray-darkgray_background dark:to-jp-gray-darkgray_background"

    let boolCustomClass = if boolCustomClass == "" {
      if isMobileView {
        ""
      } else {
        "mx-4"
      }
    } else {
      boolCustomClass
    }
    let selectedClass = `${boolCustomClass} ${toggleEnableColor}`
    let borderSelectedClass = `${toggleBorder}`
    let defaultInputClass = `${boolCustomClass} ${toggleColor}`
    let defaultBorder = "border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960"
    let backgroundClass = if isSelected {
      selectedClass
    } else {
      defaultInputClass
    }

    let borderClass = if isSelected && !isDisabled {
      borderSelectedClass
    } else {
      defaultBorder
    }

    let shadowClass = ""

    let transformValue = if isSelected {
      "translateX(14px)"
    } else {
      "translateX(0px)"
    }

    let cursorClass = if isDisabled {
      "cursor-not-allowed"
    } else {
      "cursor-pointer"
    }

    let circleColor = if isSelected {
      "bg-white"
    } else if isDisabled {
      "bg-jp-gray-900 bg-opacity-50 dark:bg-jp-gray-900 dark:bg-opacity-40"
    } else {
      "bg-jp-gray-900 bg-opacity-50 dark:bg-white dark:bg-opacity-100"
    }

    let innerShadow = ""
    let roundedClass = "rounded-2.5"
    let toggleHeight = "16px"
    let toggleWidth = "30px"
    let innerCircleHeight = "12px"
    let innerCircleWidth = innerCircleHeight

    <AddDataAttributes
      attributes=[
        ("data-bool-value", isSelected ? "on" : "off"),
        ("data-bool-for", addAttributeId),
      ]>
      <div
        style={ReactDOMStyle.make(
          ~width=toggleWidth,
          ~height=toggleHeight,
          ~minWidth=toggleWidth,
          (),
        )}
        onClick=toggleSelect
        className={`flex items-center transition ${roundedClass} ${backgroundClass} ${borderClass} ${cursorClass} ${shadowClass}`}>
        <div
          style={ReactDOMStyle.make(
            ~width=innerCircleWidth,
            ~height=innerCircleHeight,
            ~transform=transformValue,
            (),
          )}
          className={`m-0.25 transition rounded-full ${circleColor} ${innerShadow}`}
        />
      </div>
    </AddDataAttributes>
  }
}

@react.component
let make = (
  ~input as baseInput: ReactFinalForm.fieldRenderPropsInput,
  ~isDisabled=false,
  ~isCheckBox=false,
  ~boolCustomClass="",
  ~addAttributeId="",
) => {
  let accessLevel = React.useContext(FormAuthContext.formAuthContext)
  let boolInput = baseInput->ffInputToBoolInput
  let boolValue: Js.Json.t = boolInput.value

  let isSelected = switch boolValue->Js.Json.classify {
  | JSONTrue => true
  | JSONString(str) => str === "true"
  | _ => false
  }
  let setIsSelected = boolInput.onChange

  isCheckBox
    ? <CheckBoxIcon
        isSelected setIsSelected isDisabled={isDisabled || accessLevel == AuthTypes.Read}
      />
    : <BaseComponent
        isSelected
        setIsSelected
        isDisabled={isDisabled || accessLevel == AuthTypes.Read}
        boolCustomClass
        addAttributeId
      />
}
