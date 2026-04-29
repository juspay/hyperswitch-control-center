type dropdownOption = SelectBox.dropdownOption
type dropdownOptionWithoutOptional = SelectBox.dropdownOptionWithoutOptional
type allSelectType = SelectBox.allSelectType
type direction = SelectBox.direction

let makeOptions = SelectBox.makeOptions
let makeNonOptional = SelectBox.makeNonOptional

let getAlignmentFromDirection = (direction: SelectBox.direction) =>
  switch direction {
  | BottomLeft | TopLeft => MultiSelectBindings.End
  | BottomMiddle | TopMiddle => MultiSelectBindings.Center
  | BottomRight | TopRight => MultiSelectBindings.Start
  }

let getSideFromDirection = (direction: SelectBox.direction) =>
  switch direction {
  | TopLeft | TopMiddle | TopRight => MultiSelectBindings.Top
  | BottomLeft | BottomMiddle | BottomRight => MultiSelectBindings.Bottom
  }

module BaseDropdown = {
  @react.component
  let make = (
    ~buttonText: string,
    ~buttonSize: Button.buttonSize=?,
    ~allowMultiSelect: bool,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~showClearAll: bool=?,
    ~showSelectAll: bool=?,
    ~options: array<SelectBox.dropdownOption>,
    ~optionSize: CheckBoxIcon.size=?,
    ~isSelectedStateMinus: bool=?,
    ~hideMultiSelectButtons: bool,
    ~deselectDisable: bool=false,
    ~buttonType: Button.buttonType=?,
    ~baseComponent: React.element=?,
    ~baseComponentMethod: bool => React.element=?,
    ~disableSelect: bool=false,
    ~textStyle: string=?,
    ~buttonTextWeight: string=?,
    ~defaultLeftIcon: Button.iconType=?,
    ~autoApply: bool=?,
    ~fullLength: bool=false,
    ~customButtonStyle: string=?,
    ~onAssignClick: string => unit=?,
    ~fixedDropDownDirection: SelectBox.direction=?,
    ~addButton: bool=?,
    ~marginTop: string=?,
    ~customStyle: string=?,
    ~customSearchStyle: string=?,
    ~showSelectionAsChips: bool=?,
    ~showToolTip: bool=?,
    ~showNameAsToolTip: bool=?,
    ~searchable: bool=?,
    ~showBorder: bool=?,
    ~dropDownCustomBtnClick: bool=?,
    ~showCustomBtnAtEnd: bool=?,
    ~customButton: React.element=?,
    ~descriptionOnHover: bool=?,
    ~addDynamicValue: bool=false,
    ~showMatchingRecordsText: bool=?,
    ~hasApplyButton: bool=?,
    ~dropdownCustomWidth: string=?,
    ~allowButtonTextMinWidth: bool=?,
    ~customMarginStyle: string=?,
    ~customButtonLeftIcon: Button.iconType=?,
    ~customTextPaddingClass: string=?,
    ~customButtonPaddingClass: string=?,
    ~customButtonIconMargin: string=?,
    ~textStyleClass: string=?,
    ~buttonStyleOnDropDownOpened: string=?,
    ~selectedString: string=?,
    ~setSelectedString: ('a => string) => unit=?,
    ~setExtSearchString: ('b => string) => unit=?,
    ~listFlexDirection: string=?,
    ~ellipsisOnly: bool=?,
    ~isPhoneDropdown: bool=?,
    ~onApply: JsxEventU.Mouse.t => unit=?,
    ~showAllSelectedOptions: bool=?,
    ~buttonClickFn: string => unit=?,
    ~toggleChevronState: option<unit => unit>=?,
    ~showSelectCountButton: bool=?,
    ~maxHeight: string=?,
    ~customBackColor: string=?,
    ~showToolTipOptions: bool=?,
    ~textEllipsisForDropDownOptions: bool=?,
    ~showBtnTextToolTip: bool=?,
    ~dropdownClassName: string=?,
    ~searchInputPlaceHolder: string=?,
    ~showSearchIcon: bool=?,
    ~sortingBasedOnDisabled: bool=?,
    ~customSelectStyle: string=?,
    ~baseComponentCustomStyle: string=?,
    ~bottomComponent: React.element=?,
    ~optionClass: string=?,
    ~selectClass: string=?,
    ~customDropdownOuterClass: string=?,
    ~customScrollStyle: string=?,
    ~dropdownContainerStyle: string=?,
    ~shouldDisplaySelectedOnTop: bool=?,
    ~labelDescriptionClass: string=?,
    ~customSelectionIcon: Button.iconType=?,
    ~placeholderCss: string=?,
    ~reverseSortGroupKeys: bool=?,
    ~maxButtonWidth: string=?,
    ~customSortOrder: array<string>=?,
    ~side: MultiSelectBindings.selectMenuItemSide=?,
    ~alignment: MultiSelectBindings.selectMenuItemAlignment=?,
    ~minMenuWidth: int=?,
    ~maxMenuWidth: int=?,
    ~primaryAction: MultiSelectBindings.actionButtonType=?,
    ~secondaryAction: MultiSelectBindings.secondaryActionButtonType=?,
    ~onFocus: option<unit => unit>=?,
    ~onBlur: option<unit => unit>=?,
    ~showClearButton: bool=?,
    ~onClearAllClick: option<unit => unit>=?,
    ~variant: option<MultiSelectBindings.selectMenuItemVariant>=?,
  ) => {
    let isBlendEnabled = BlendContext.useBlendEnabled()
    let useBlend = isBlendEnabled && baseComponentMethod->Option.isNone

    let blendAlignment = switch alignment {
    | Some(_) => alignment
    | None => fixedDropDownDirection->Option.map(getAlignmentFromDirection)
    }
    let blendSide = switch side {
    | Some(_) => side
    | None => fixedDropDownDirection->Option.map(getSideFromDirection)
    }
    let blendSlot = MultiSelectWrapper.getLeftSlot(defaultLeftIcon)
    // Wrap in a plain <div> so Radix asChild can inject onClick onto a DOM element.
    // Custom React components (e.g. OMPViewBaseComp) don't forward injected props,
    // causing the dropdown to never open.
    let wrapTrigger = el => <div> el </div>
    let blendCustomTrigger = switch baseComponent {
    | Some(el) => Some(wrapTrigger(el))
    | None => customButton->Option.map(wrapTrigger)
    }
    let selectedValues = input.value->LogicUtils.getStrArrayFromJson
    let selectedValue = input.value->LogicUtils.getStringFromJson("")

    <>
      <RenderIf condition=useBlend>
        {if allowMultiSelect {
          let blendItems = MultiSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValues)
          <MultiSelectWrapper
            items=blendItems
            placeholder=buttonText
            input
            disabled=disableSelect
            fullWidth=fullLength
            ?showSelectAll
            allowCustomValue=addDynamicValue
            slot=?blendSlot
            customTrigger=?blendCustomTrigger
            ?primaryAction
            ?secondaryAction
            ?variant
            ?onFocus
            ?onBlur
            ?showClearButton
            ?onClearAllClick
            alignment=?blendAlignment
            side=?blendSide
            minMenuWidth={minMenuWidth->Option.getOr(300)}
            maxMenuWidth={maxMenuWidth->Option.getOr(300)}
          />
        } else {
          let blendItems = SingleSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValue)
          let totalItems = blendItems->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
          let computedEnableSearch = searchable->Option.getOr(false) || totalItems > 5
          <SingleSelectWrapper
            items=blendItems
            placeholder=buttonText
            input
            enableSearch=computedEnableSearch
            searchPlaceholder=?searchInputPlaceHolder
            disabled=disableSelect
            fullWidth=fullLength
            allowCustomValue=addDynamicValue
            allowDeselect={!deselectDisable}
            slot=?blendSlot
            customTrigger=?blendCustomTrigger
            ?variant
            ?onFocus
            ?onBlur
            alignment=?blendAlignment
            side=?blendSide
            ?minMenuWidth
            ?maxMenuWidth
          />
        }}
      </RenderIf>
      <RenderIf condition={!useBlend}>
        <SelectBox.BaseDropdown
          buttonText
          ?buttonSize
          allowMultiSelect
          input
          ?showClearAll
          ?showSelectAll
          options
          ?optionSize
          ?isSelectedStateMinus
          hideMultiSelectButtons
          deselectDisable
          ?buttonType
          ?baseComponent
          ?baseComponentMethod
          disableSelect
          ?textStyle
          ?buttonTextWeight
          ?defaultLeftIcon
          ?autoApply
          fullLength
          ?customButtonStyle
          ?onAssignClick
          ?fixedDropDownDirection
          ?addButton
          ?marginTop
          ?customStyle
          ?customSearchStyle
          ?showSelectionAsChips
          ?showToolTip
          ?showNameAsToolTip
          ?searchable
          ?showBorder
          ?dropDownCustomBtnClick
          ?showCustomBtnAtEnd
          ?customButton
          ?descriptionOnHover
          addDynamicValue
          ?showMatchingRecordsText
          ?hasApplyButton
          ?dropdownCustomWidth
          ?allowButtonTextMinWidth
          ?customMarginStyle
          ?customButtonLeftIcon
          ?customTextPaddingClass
          ?customButtonPaddingClass
          ?customButtonIconMargin
          ?textStyleClass
          ?buttonStyleOnDropDownOpened
          ?selectedString
          ?setSelectedString
          ?setExtSearchString
          ?listFlexDirection
          ?ellipsisOnly
          ?isPhoneDropdown
          ?onApply
          ?showAllSelectedOptions
          ?buttonClickFn
          ?toggleChevronState
          ?showSelectCountButton
          ?maxHeight
          ?customBackColor
          ?showToolTipOptions
          ?textEllipsisForDropDownOptions
          ?showBtnTextToolTip
          ?dropdownClassName
          ?searchInputPlaceHolder
          ?showSearchIcon
          ?sortingBasedOnDisabled
          ?customSelectStyle
          ?baseComponentCustomStyle
          ?bottomComponent
          ?optionClass
          ?selectClass
          ?customDropdownOuterClass
          ?customScrollStyle
          ?dropdownContainerStyle
          ?shouldDisplaySelectedOnTop
          ?labelDescriptionClass
          ?customSelectionIcon
          ?placeholderCss
          ?reverseSortGroupKeys
          ?maxButtonWidth
          ?customSortOrder
        />
      </RenderIf>
    </>
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~buttonText: string="",
  ~buttonSize: Button.buttonSize=Medium,
  ~allowMultiSelect: bool=false,
  ~isDropDown: bool=true,
  ~hideMultiSelectButtons: bool=?,
  ~optionSize: CheckBoxIcon.size=?,
  ~isSelectedStateMinus: bool=?,
  ~isHorizontal: bool=?,
  ~deselectDisable: bool=false,
  ~showClearAll: bool=?,
  ~showSelectAll: bool=?,
  ~buttonType: Button.buttonType=?,
  ~disableSelect: bool=false,
  ~fullLength: bool=false,
  ~customButtonStyle: string=?,
  ~textStyle: string=?,
  ~marginTop: string=?,
  ~customStyle: string=?,
  ~showSelectionAsChips: bool=?,
  ~showToggle: bool=?,
  ~maxHeight: string=?,
  ~searchable: bool=?,
  ~fill: string=?,
  ~optionRightElement: React.element=?,
  ~hideBorder: bool=?,
  ~allSelectType: SelectBox.allSelectType=?,
  ~customSearchStyle: string=?,
  ~searchInputPlaceHolder: string=?,
  ~showSearchIcon: bool=?,
  ~customLabelStyle: string=?,
  ~customMargin: string=?,
  ~showToolTip: bool=?,
  ~showNameAsToolTip: bool=?,
  ~showBorder: bool=?,
  ~showCustomBtnAtEnd: bool=?,
  ~dropDownCustomBtnClick: bool=?,
  ~addDynamicValue: bool=false,
  ~showMatchingRecordsText: bool=?,
  ~customButton: React.element=?,
  ~descriptionOnHover: bool=?,
  ~fixedDropDownDirection: SelectBox.direction=?,
  ~dropdownCustomWidth: string=?,
  ~allowButtonTextMinWidth: bool=?,
  ~baseComponent: React.element=?,
  ~baseComponentMethod: bool => React.element=?,
  ~customMarginStyle: string=?,
  ~buttonTextWeight: string=?,
  ~customButtonLeftIcon: Button.iconType=?,
  ~customTextPaddingClass: string=?,
  ~customButtonPaddingClass: string=?,
  ~customButtonIconMargin: string=?,
  ~textStyleClass: string=?,
  ~setExtSearchString: ('a => string) => unit=?,
  ~buttonStyleOnDropDownOpened: string=?,
  ~listFlexDirection: string=?,
  ~baseComponentCustomStyle: string=?,
  ~ellipsisOnly: bool=?,
  ~customSelectStyle: string=?,
  ~isPhoneDropdown: bool=?,
  ~hasApplyButton: bool=?,
  ~onApply: JsxEventU.Mouse.t => unit=?,
  ~showAllSelectedOptions: bool=?,
  ~buttonClickFn: string => unit=?,
  ~showDescriptionAsTool: bool=?,
  ~optionClass: string=?,
  ~selectClass: string=?,
  ~toggleProps: string=?,
  ~showSelectCountButton: bool=?,
  ~leftIcon: Button.iconType=?,
  ~customBackColor: string=?,
  ~customSelectAllStyle: string=?,
  ~checkboxDimension: string=?,
  ~showToolTipOptions: bool=?,
  ~textEllipsisForDropDownOptions: bool=?,
  ~showBtnTextToolTip: bool=?,
  ~dropdownClassName: string=?,
  ~onItemSelect: (JsxEventU.Mouse.t, string) => unit=?,
  ~wrapBasis: string=?,
  ~customScrollStyle: string=?,
  ~shouldDisplaySelectedOnTop: bool=?,
  ~placeholderCss: string=?,
  ~maxButtonWidth: string=?,
  ~side: MultiSelectBindings.selectMenuItemSide=?,
  ~alignment: MultiSelectBindings.selectMenuItemAlignment=?,
  ~minMenuWidth: int=?,
  ~maxMenuWidth: int=?,
  ~primaryAction: MultiSelectBindings.actionButtonType=?,
  ~secondaryAction: MultiSelectBindings.secondaryActionButtonType=?,
  ~maxTriggerWidth: float=?,
  ~minTriggerWidth: float=?,
  ~onFocus: option<unit => unit>=?,
  ~onBlur: option<unit => unit>=?,
  ~showClearButton: bool=?,
  ~onClearAllClick: option<unit => unit>=?,
  ~variant: option<MultiSelectBindings.selectMenuItemVariant>=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  let useBlend = isBlendEnabled && isDropDown && baseComponentMethod->Option.isNone

  let blendAlignment = switch alignment {
  | Some(_) => alignment
  | None => fixedDropDownDirection->Option.map(getAlignmentFromDirection)
  }
  let blendSide = switch side {
  | Some(_) => side
  | None => fixedDropDownDirection->Option.map(getSideFromDirection)
  }
  let blendSlot = MultiSelectWrapper.getLeftSlot(leftIcon)
  // Wrap in a plain <div> so Radix asChild can inject onClick onto a DOM element.
  // Custom React components don't forward injected props, causing dropdown to never open.
  let wrapTrigger = el => <div> el </div>
  let blendCustomTrigger = switch baseComponent {
  | Some(el) => Some(wrapTrigger(el))
  | None => customButton->Option.map(wrapTrigger)
  }
  let selectedValues = input.value->LogicUtils.getStrArrayFromJson
  let selectedValue = input.value->LogicUtils.getStringFromJson("")

  <>
    <RenderIf condition=useBlend>
      {if allowMultiSelect {
        let blendItems = MultiSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValues)
        <MultiSelectWrapper
          items=blendItems
          placeholder=buttonText
          input
          disabled=disableSelect
          fullWidth=fullLength
          ?showSelectAll
          allowCustomValue=addDynamicValue
          slot=?blendSlot
          customTrigger=?blendCustomTrigger
          ?primaryAction
          ?secondaryAction
          ?variant
          ?onFocus
          ?onBlur
          ?showClearButton
          ?onClearAllClick
          alignment=?blendAlignment
          side=?blendSide
          minMenuWidth={minMenuWidth->Option.getOr(300)}
          maxMenuWidth={maxMenuWidth->Option.getOr(300)}
        />
      } else {
        let blendItems = SingleSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValue)
        let totalItems = blendItems->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
        let computedEnableSearch = searchable->Option.getOr(false) || totalItems > 5
        <SingleSelectWrapper
          items=blendItems
          placeholder=buttonText
          input
          enableSearch=computedEnableSearch
          searchPlaceholder=?searchInputPlaceHolder
          disabled=disableSelect
          fullWidth=fullLength
          allowCustomValue=addDynamicValue
          allowDeselect={!deselectDisable}
          slot=?blendSlot
          customTrigger=?blendCustomTrigger
          ?variant
          ?onFocus
          ?onBlur
          ?maxTriggerWidth
          ?minTriggerWidth
          alignment=?blendAlignment
          side=?blendSide
          ?minMenuWidth
          ?maxMenuWidth
        />
      }}
    </RenderIf>
    <RenderIf condition={!useBlend}>
      <SelectBox
        input
        buttonText
        buttonSize
        allowMultiSelect
        isDropDown
        options
        deselectDisable
        disableSelect
        fullLength
        addDynamicValue
        ?hideMultiSelectButtons
        ?optionSize
        ?isSelectedStateMinus
        ?isHorizontal
        ?showClearAll
        ?showSelectAll
        ?buttonType
        ?customButtonStyle
        ?textStyle
        ?marginTop
        ?customStyle
        ?showSelectionAsChips
        ?showToggle
        ?maxHeight
        ?searchable
        ?fill
        ?optionRightElement
        ?hideBorder
        ?allSelectType
        ?customSearchStyle
        ?searchInputPlaceHolder
        ?showSearchIcon
        ?customLabelStyle
        ?customMargin
        ?showToolTip
        ?showNameAsToolTip
        ?showBorder
        ?showCustomBtnAtEnd
        ?dropDownCustomBtnClick
        ?showMatchingRecordsText
        ?customButton
        ?descriptionOnHover
        ?fixedDropDownDirection
        ?dropdownCustomWidth
        ?allowButtonTextMinWidth
        ?baseComponent
        ?baseComponentMethod
        ?customMarginStyle
        ?buttonTextWeight
        ?customButtonLeftIcon
        ?customTextPaddingClass
        ?customButtonPaddingClass
        ?customButtonIconMargin
        ?textStyleClass
        ?setExtSearchString
        ?buttonStyleOnDropDownOpened
        ?listFlexDirection
        ?baseComponentCustomStyle
        ?ellipsisOnly
        ?customSelectStyle
        ?isPhoneDropdown
        ?hasApplyButton
        ?onApply
        ?showAllSelectedOptions
        ?buttonClickFn
        ?showDescriptionAsTool
        ?optionClass
        ?selectClass
        ?toggleProps
        ?showSelectCountButton
        ?leftIcon
        ?customBackColor
        ?customSelectAllStyle
        ?checkboxDimension
        ?showToolTipOptions
        ?textEllipsisForDropDownOptions
        ?showBtnTextToolTip
        ?dropdownClassName
        ?onItemSelect
        ?wrapBasis
        ?customScrollStyle
        ?shouldDisplaySelectedOnTop
        ?placeholderCss
        ?maxButtonWidth
      />
    </RenderIf>
  </>
}
