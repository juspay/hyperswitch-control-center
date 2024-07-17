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
  ~options: array<SelectBox.dropdownOption>,
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
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
  ~options: array<SelectBox.dropdownOption>,
  ~deselectDisable=false,
  ~borderRadius="rounded-full",
  ~selectedClass="border-jp-gray-900 dark:border-jp-gray-300 text-jp-gray-900 dark:text-jp-gray-300 font-semibold",
  ~nonSelectedClass="border-jp-gray-600 dark:border-jp-gray-800 text-jp-gray-850 dark:text-jp-gray-400",
  ~showTickMark=true,
  ~allowMultiSelect=true,
  (),
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
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

let filterMultiSelectInput = (
  ~options: array<FilterSelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
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
  ~allSelectType=FilterSelectBox.Icon,
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
  ~showSelectCountButton=false,
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
  <FilterSelectBox
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

let multiSelectInput = (
  ~options: array<SelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
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
  ~showSelectCountButton=false,
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
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
  ~options: array<SelectBox.dropdownOption>,
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
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
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
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

let filterDateRangeField = (
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
  ~isTooltipVisible=true,
  (),
): comboCustomInputRecord => {
  let fn = (_fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    <DateRangeField
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
      isTooltipVisible
    />
  }

  {fn, names: [startKey, endKey]}
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
  ~isDisabled,
  ~rows,
  ~cols,
  ~customClass="text-lg",
  ~leftIcon=?,
  ~maxLength=?,
  (),
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder) => {
  <MultiLineTextInput ?maxLength input placeholder isDisabled ?rows ?cols customClass ?leftIcon />
}

let iconFieldWithMessageDes = (mainInputField, ~description="", ()) => (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
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

let passwordMatchField = (~leftIcon=?, ()) => (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
) => {
  <PasswordStrengthInput input placeholder displayStatus=false ?leftIcon />
}

let checkboxInput = (
  ~isHorizontal=false,
  ~options: array<SelectBox.dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isSelectedStateMinus=false,
  ~disableSelect=false,
  ~buttonText="",
  ~maxHeight=?,
  ~searchable=?,
  ~searchInputPlaceHolder=?,
  ~dropdownCustomWidth=?,
  ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
  ~customLabelStyle=?,
  ~customMarginStyle="mx-3 py-2 gap-2",
  ~customStyle="",
  ~checkboxDimension="",
  ~wrapBasis="",
  (),
) => (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
  <SelectBox
    input
    options
    optionSize
    isSelectedStateMinus
    disableSelect
    allowMultiSelect=true
    isDropDown=false
    showSelectAll=false
    buttonText
    isHorizontal
    ?maxHeight
    ?searchable
    ?searchInputPlaceHolder
    ?dropdownCustomWidth
    customSearchStyle
    ?customLabelStyle
    customMarginStyle
    customStyle
    checkboxDimension
    wrapBasis
  />
}

let boolInput = (~isDisabled, ~isCheckBox=false, ~boolCustomClass="", ()) => (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
) => {
  <BoolInput input isDisabled isCheckBox boolCustomClass />
}
