type customInputFn = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder: string,
) => React.element

type comboCustomInputFn = array<ReactFinalForm.fieldRenderProps> => React.element
type comboCustomInputRecord = {
  fn: comboCustomInputFn,
  names: array<string>,
}

let selectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~buttonText,
  ~deselectDisable=false,
  ~isHorizontal=true,
  ~disableSelect=false,
  ~fullLength=false,
  ~customButtonStyle="",
  ~textStyle="",
  ~marginTop="mt-12",
  ~customStyle="",
  ~searchable=?,
  ~showBorder=?,
  ~showToolTipOptions=false,
  ~textEllipsisForDropDownOptions=false,
  ~showCustomBtnAtEnd=false,
  ~dropDownCustomBtnClick=false,
  ~addDynamicValue=false,
  ~showMatchingRecordsText=true,
  ~fixedDropDownDirection=?,
  ~customButton=React.null,
  ~buttonType=Button.SecondaryFilled,
  ~dropdownCustomWidth="w-80",
  ~allowButtonTextMinWidth=?,
  ~setExtSearchString=_ => (),
  ~textStyleClass=?,
  ~ellipsisOnly=false,
  ~showBtnTextToolTip=false,
  ~dropdownClassName="",
  ~descriptionOnHover=false,
  (),
) => {
  <SelectBox
    input
    options
    buttonText
    allowMultiSelect=false
    deselectDisable
    isHorizontal
    disableSelect
    fullLength
    customButtonStyle
    textStyle
    marginTop
    customStyle
    ?showBorder
    showToolTipOptions
    textEllipsisForDropDownOptions
    ?searchable
    showCustomBtnAtEnd
    dropDownCustomBtnClick
    addDynamicValue
    showMatchingRecordsText
    ?fixedDropDownDirection
    customButton
    buttonType
    dropdownCustomWidth
    ?allowButtonTextMinWidth
    setExtSearchString
    ?textStyleClass
    ellipsisOnly
    showBtnTextToolTip
    dropdownClassName
    descriptionOnHover
  />
}

let infraSelectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~deselectDisable=false,
  ~borderRadius="rounded-full",
  ~selectedClass="border-jp-gray-900 dark:border-jp-gray-300 text-jp-gray-900 dark:text-jp-gray-300 font-semibold",
  ~nonSelectedClass="border-jp-gray-600 dark:border-jp-gray-800 text-jp-gray-850 dark:text-jp-gray-400",
  ~showTickMark=true,
  ~allowMultiSelect=true,
  (),
) => {
  <SelectBox.InfraSelectBox
    input
    options
    deselectDisable
    borderRadius
    selectedClass
    nonSelectedClass
    showTickMark
    allowMultiSelect
  />
}

let multiSelectInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~placeholder as _,
  ~buttonText,
  ~buttonSize=?,
  ~hideMultiSelectButtons=false,
  ~showSelectionAsChips=true,
  ~showToggle=false,
  ~isDropDown=true,
  ~searchable=false,
  ~showBorder=?,
  ~optionRigthElement=?,
  ~customStyle="",
  ~customMargin="",
  ~customButtonStyle=?,
  ~hideBorder=false,
  ~allSelectType=SelectBox.Icon,
  ~showToolTip=false,
  ~showNameAsToolTip=false,
  ~buttonType=Button.SecondaryFilled,
  ~showSelectAll=true,
  ~isHorizontal=false,
  ~fullLength=?,
  ~fixedDropDownDirection=?,
  ~dropdownCustomWidth=?,
  ~customMarginStyle=?,
  ~buttonTextWeight=?,
  ~marginTop=?,
  ~customButtonLeftIcon=?,
  ~customButtonPaddingClass=?,
  ~customButtonIconMargin=?,
  ~customTextPaddingClass=?,
  ~listFlexDirection="",
  ~buttonClickFn=?,
  ~showDescriptionAsTool=true,
  ~optionClass="",
  ~selectClass="",
  ~toggleProps="",
  ~showSelectCountButton=true,
  ~showAllSelectedOptions=true,
  ~leftIcon=?,
  ~customBackColor=?,
  ~customSelectAllStyle=?,
  ~onItemSelect=(_, _) => (),
  ~wrapBasis="",
  ~dropdownClassName="",
  ~baseComponentMethod=?,
  ~disableSelect=false,
  (),
) => {
  <SelectBox
    input
    options
    optionSize
    buttonText
    ?buttonSize
    allowMultiSelect=true
    hideMultiSelectButtons
    showSelectionAsChips
    isDropDown
    showToggle
    searchable
    ?showBorder
    customStyle
    customMargin
    ?optionRigthElement
    hideBorder
    allSelectType
    ?customButtonStyle
    ?fixedDropDownDirection
    showToolTip
    showNameAsToolTip
    disableSelect
    buttonType
    showSelectAll
    ?fullLength
    isHorizontal
    ?customMarginStyle
    ?dropdownCustomWidth
    ?buttonTextWeight
    ?marginTop
    ?customButtonLeftIcon
    ?customButtonPaddingClass
    ?customButtonIconMargin
    ?customTextPaddingClass
    listFlexDirection
    ?buttonClickFn
    showDescriptionAsTool
    optionClass
    selectClass
    toggleProps
    showSelectCountButton
    showAllSelectedOptions
    ?leftIcon
    ?customBackColor
    ?customSelectAllStyle
    onItemSelect
    wrapBasis
    dropdownClassName
    ?baseComponentMethod
  />
}

let radioInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~placeholder as _,
  ~buttonText,
  ~disableSelect=true,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isHorizontal=false,
  ~deselectDisable=true,
  ~customStyle="",
  ~baseComponentCustomStyle="",
  ~customSelectStyle="",
  ~fill=?,
  ~maxHeight=?,
  (),
) => {
  <SelectBox
    input
    disableSelect
    optionSize
    options
    buttonText
    allowMultiSelect=false
    isDropDown=false
    isHorizontal
    deselectDisable
    customStyle
    baseComponentCustomStyle
    customSelectStyle
    ?fill
    ?maxHeight
  />
}

let textInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~description="",
  ~isDisabled=false,
  ~autoFocus=false,
  ~type_="text",
  ~inputMode="text",
  ~pattern=?,
  ~autoComplete=?,
  ~maxLength=?,
  ~leftIcon=?,
  ~rightIcon=?,
  ~rightIconOnClick=?,
  ~inputStyle="",
  ~customStyle="",
  ~customWidth="w-full",
  ~customPaddingClass="",
  ~iconOpacity="opacity-30",
  ~rightIconCustomStyle="",
  ~leftIconCustomStyle="",
  ~customDashboardClass=?,
  ~onHoverCss=?,
  ~onDisabledStyle=?,
  ~onActiveStyle=?,
  ~customDarkBackground=?,
  ~phoneInput=false,
  ~widthMatchwithPlaceholderLength=None,
  (),
) => {
  <TextInput
    input
    placeholder
    description
    isDisabled
    type_
    inputMode
    ?pattern
    ?autoComplete
    ?maxLength
    ?leftIcon
    ?rightIcon
    ?rightIconOnClick
    inputStyle
    customStyle
    customWidth
    autoFocus
    iconOpacity
    customPaddingClass
    rightIconCustomStyle
    leftIconCustomStyle
    ?customDashboardClass
    ?onHoverCss
    ?onDisabledStyle
    ?onActiveStyle
    ?customDarkBackground
    phoneInput
    widthMatchwithPlaceholderLength
  />
}

let textTagInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~name="",
  ~customStyle=?,
  ~disabled=false,
  ~seperateByComma=false,
  ~seperateBySpace=false,
  ~customButtonStyle=?,
  (),
) => {
  <MultipleTextInput
    input name disabled seperateByComma seperateBySpace ?customStyle ?customButtonStyle placeholder
  />
}

let numericTextInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~customStyle="",
  ~inputMode=?,
  ~precision=?,
  ~maxLength=?,
  ~removeLeadingZeroes=false,
  ~leftIcon=?,
  ~rightIcon=?,
  ~customPaddingClass=?,
  ~rightIconCustomStyle=?,
  ~leftIconCustomStyle=?,
  (),
) => {
  <NumericTextInput
    customStyle
    input
    placeholder
    isDisabled
    ?inputMode
    ?precision
    ?maxLength
    removeLeadingZeroes
    ?leftIcon
    ?rightIcon
    ?customPaddingClass
    ?rightIconCustomStyle
    ?leftIconCustomStyle
  />
}

let singleDatePickerInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~customDisabledFutureDays=0.0,
  ~format="YYYY-MM-DDTHH:mm:ss",
  ~currentDateHourFormat="00",
  ~currentDateMinuteFormat="00",
  ~currentDateSecondsFormat="00",
  ~customButtonStyle=?,
  ~newThemeCustomButtonStyle=?,
  ~calendarContaierStyle=?,
  ~buttonSize=?,
  ~showTime=?,
  ~fullLength=?,
  (),
) => {
  <DatePicker
    input
    disablePastDates
    disableFutureDates
    format
    customDisabledFutureDays
    currentDateHourFormat
    currentDateMinuteFormat
    currentDateSecondsFormat
    ?customButtonStyle
    ?newThemeCustomButtonStyle
    ?calendarContaierStyle
    ?buttonSize
    ?showTime
    ?fullLength
  />
}

let dateRangeField = (
  ~startKey: string,
  ~endKey: string,
  ~format,
  ~disablePastDates=false,
  ~disableFutureDates=false,
  ~showTime=false,
  ~predefinedDays=[],
  ~disableApply=false,
  ~numMonths=1,
  ~dateRangeLimit=?,
  ~removeFilterOption=?,
  ~optFieldKey=?,
  ~showSeconds=true,
  ~hideDate=false,
  ~selectStandardTime=false,
  ~customButtonStyle=?,
  ~isTooltipVisible=true,
  (),
): comboCustomInputRecord => {
  let fn = (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    <DateRangePicker
      disablePastDates
      disableFutureDates
      format
      predefinedDays
      numMonths
      showTime
      disableApply
      startKey
      endKey
      ?dateRangeLimit
      ?removeFilterOption
      ?optFieldKey
      showSeconds
      hideDate
      selectStandardTime
      ?customButtonStyle
      isTooltipVisible
    />
  }

  {fn, names: [startKey, endKey]}
}

let multiLineTextInput = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled,
  ~rows,
  ~cols,
  ~customClass="text-lg",
  ~leftIcon=?,
  ~maxLength=?,
  (),
) => {
  <MultiLineTextInput ?maxLength input placeholder isDisabled ?rows ?cols customClass ?leftIcon />
}

let iconFieldWithMessageDes = (
  mainInputField,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~description="",
  (),
) => {
  <div>
    <div> {mainInputField(~input, ~placeholder)} </div>
    <div>
      {switch description {
      | "" => React.null
      | _ =>
        <div
          className="pt-2 pb-2 text-sm text-bold text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ">
          {React.string(description)}
        </div>
      }}
    </div>
  </div>
}

let passwordMatchField = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  (),
) => {
  <PasswordStrengthInput input placeholder displayStatus=false ?leftIcon />
}
