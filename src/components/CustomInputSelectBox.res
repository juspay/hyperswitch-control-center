@react.component
let make = (
  ~onChange,
  ~value,
  ~buttonText,
  ~showBorder=?,
  ~options,
  ~allowMultiSelect=false,
  ~isDropDown=true,
  ~hideMultiSelectButtons=false,
  ~isHorizontal=false,
  ~deselectDisable=false,
  ~buttonType=Button.SecondaryFilled,
  ~customButtonStyle="",
  ~customStyle="",
  ~textStyle="",
  ~disableSelect=false,
  ~searchable=?,
  ~baseComponent=?,
  ~isPhoneDropdown=false,
  ~marginTop=?,
  ~searchInputPlaceHolder=?,
  ~showSearchIcon=true,
) => {
  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "dummy-name",
    onBlur: _ev => (),
    onChange,
    onFocus: _ev => (),
    value,
    checked: true,
  }
  <SelectBox
    isDropDown
    allowMultiSelect
    hideMultiSelectButtons
    buttonText
    customStyle
    textStyle
    ?showBorder
    input
    options
    deselectDisable
    isHorizontal
    buttonType
    disableSelect
    customButtonStyle
    ?searchable
    ?baseComponent
    isPhoneDropdown
    ?marginTop
    ?searchInputPlaceHolder
    showSearchIcon
  />
}
