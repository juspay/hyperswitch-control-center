open Button

@react.component
let make = (
  ~text=?,
  ~buttonState: buttonState=Normal,
  ~buttonType: buttonType=SecondaryFilled,
  ~buttonVariant: buttonVariant=Fit,
  ~buttonSize: option<buttonSize>=?,
  ~leftIcon: iconType=NoIcon,
  ~rightIcon: iconType=NoIcon,
  ~showBorder=true,
  ~type_="button",
  ~onClick=?,
  ~textStyle="",
  ~customIconMargin=?,
  ~customTextSize=?,
  ~customIconSize=?,
  ~textWeight=?,
  ~fullLength=false,
  ~disableRipple=false,
  ~customButtonStyle="",
  ~textStyleClass=?,
  ~customTextPaddingClass=?,
  ~allowButtonTextMinWidth=true,
  ~customPaddingClass=?,
  ~customRoundedClass=?,
  ~customHeightClass=?,
  ~customBackColor=?,
  ~showBtnTextToolTip=false,
  ~access=AuthTypes.Access,
  ~tooltipText="You do not have the required permissions to access this module. Please contact your administrator for necessary permissions.",
  ~toolTipPosition=?,
) => {
  let buttonState = switch access {
  | Access => buttonState
  | NoAccess => Button.Disabled
  }

  let showBtnTextToolTip = access === NoAccess

  <Button
    buttonState
    ?text
    buttonType
    buttonVariant
    ?buttonSize
    leftIcon
    rightIcon
    showBorder
    type_
    ?onClick
    textStyle
    ?customIconMargin
    ?customTextSize
    ?customIconSize
    ?textWeight
    fullLength
    disableRipple
    customButtonStyle
    ?textStyleClass
    ?customTextPaddingClass
    allowButtonTextMinWidth
    ?customPaddingClass
    ?customRoundedClass
    ?customHeightClass
    ?customBackColor
    showBtnTextToolTip
    tooltipText
    ?toolTipPosition
  />
}
