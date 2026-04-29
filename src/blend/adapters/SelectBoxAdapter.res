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
    ~buttonSize: option<Button.buttonSize>=?,
    ~allowMultiSelect: bool,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~showClearAll: option<bool>=?,
    ~showSelectAll: option<bool>=?,
    ~options: array<SelectBox.dropdownOption>,
    ~optionSize: option<CheckBoxIcon.size>=?,
    ~isSelectedStateMinus: option<bool>=?,
    ~hideMultiSelectButtons: bool,
    ~deselectDisable: bool=false,
    ~buttonType: option<Button.buttonType>=?,
    ~baseComponent: option<React.element>=?,
    ~baseComponentMethod: option<bool => React.element>=?,
    ~disableSelect: bool=false,
    ~textStyle: option<string>=?,
    ~buttonTextWeight: option<string>=?,
    ~defaultLeftIcon: option<Button.iconType>=?,
    ~autoApply: option<bool>=?,
    ~fullLength: bool=false,
    ~customButtonStyle: option<string>=?,
    ~onAssignClick: option<string => unit>=?,
    ~fixedDropDownDirection: option<SelectBox.direction>=?,
    ~addButton: option<bool>=?,
    ~marginTop: option<string>=?,
    ~customStyle: option<string>=?,
    ~customSearchStyle: option<string>=?,
    ~showSelectionAsChips: option<bool>=?,
    ~showToolTip: option<bool>=?,
    ~showNameAsToolTip: option<bool>=?,
    ~searchable: option<bool>=?,
    ~showBorder: option<bool>=?,
    ~dropDownCustomBtnClick: option<bool>=?,
    ~showCustomBtnAtEnd: option<bool>=?,
    ~customButton: option<React.element>=?,
    ~descriptionOnHover: option<bool>=?,
    ~addDynamicValue: bool=false,
    ~showMatchingRecordsText: option<bool>=?,
    ~hasApplyButton: option<bool>=?,
    ~dropdownCustomWidth: option<string>=?,
    ~allowButtonTextMinWidth: option<bool>=?,
    ~customMarginStyle: option<string>=?,
    ~customButtonLeftIcon: option<Button.iconType>=?,
    ~customTextPaddingClass: option<string>=?,
    ~customButtonPaddingClass: option<string>=?,
    ~customButtonIconMargin: option<string>=?,
    ~textStyleClass: option<string>=?,
    ~buttonStyleOnDropDownOpened: option<string>=?,
    ~selectedString: option<string>=?,
    ~setSelectedString: option<('a => string) => unit>=?,
    ~setExtSearchString: option<('b => string) => unit>=?,
    ~listFlexDirection: option<string>=?,
    ~ellipsisOnly: option<bool>=?,
    ~isPhoneDropdown: option<bool>=?,
    ~onApply: option<JsxEventU.Mouse.t => unit>=?,
    ~showAllSelectedOptions: option<bool>=?,
    ~buttonClickFn: option<string => unit>=?,
    ~toggleChevronState: option<unit => unit>=?,
    ~showSelectCountButton: option<bool>=?,
    ~maxHeight: option<string>=?,
    ~customBackColor: option<string>=?,
    ~showToolTipOptions: option<bool>=?,
    ~textEllipsisForDropDownOptions: option<bool>=?,
    ~showBtnTextToolTip: option<bool>=?,
    ~dropdownClassName: option<string>=?,
    ~searchInputPlaceHolder: option<string>=?,
    ~showSearchIcon: option<bool>=?,
    ~sortingBasedOnDisabled: option<bool>=?,
    ~customSelectStyle: option<string>=?,
    ~baseComponentCustomStyle: option<string>=?,
    ~bottomComponent: option<React.element>=?,
    ~optionClass: option<string>=?,
    ~selectClass: option<string>=?,
    ~customDropdownOuterClass: option<string>=?,
    ~customScrollStyle: option<string>=?,
    ~dropdownContainerStyle: option<string>=?,
    ~shouldDisplaySelectedOnTop: option<bool>=?,
    ~labelDescriptionClass: option<string>=?,
    ~customSelectionIcon: option<Button.iconType>=?,
    ~placeholderCss: option<string>=?,
    ~reverseSortGroupKeys: option<bool>=?,
    ~maxButtonWidth: option<string>=?,
    ~customSortOrder: option<array<string>>=?,
    ~side: option<MultiSelectBindings.selectMenuItemSide>=?,
    ~alignment: option<MultiSelectBindings.selectMenuItemAlignment>=?,
    ~minMenuWidth: option<int>=?,
    ~maxMenuWidth: option<int>=?,
    ~primaryAction: option<MultiSelectBindings.actionButtonType>=?,
    ~secondaryAction: option<MultiSelectBindings.secondaryActionButtonType>=?,
    ~onFocus: option<unit => unit>=?,
    ~onBlur: option<unit => unit>=?,
    ~showClearButton: option<bool>=?,
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
  ~hideMultiSelectButtons: option<bool>=?,
  ~optionSize: option<CheckBoxIcon.size>=?,
  ~isSelectedStateMinus: option<bool>=?,
  ~isHorizontal: option<bool>=?,
  ~deselectDisable: bool=false,
  ~showClearAll: option<bool>=?,
  ~showSelectAll: option<bool>=?,
  ~buttonType: option<Button.buttonType>=?,
  ~disableSelect: bool=false,
  ~fullLength: bool=false,
  ~customButtonStyle: option<string>=?,
  ~textStyle: option<string>=?,
  ~marginTop: option<string>=?,
  ~customStyle: option<string>=?,
  ~showSelectionAsChips: option<bool>=?,
  ~showToggle: option<bool>=?,
  ~maxHeight: option<string>=?,
  ~searchable: option<bool>=?,
  ~fill: option<string>=?,
  ~optionRigthElement: option<React.element>=?,
  ~hideBorder: option<bool>=?,
  ~allSelectType: option<SelectBox.allSelectType>=?,
  ~customSearchStyle: option<string>=?,
  ~searchInputPlaceHolder: option<string>=?,
  ~showSearchIcon: option<bool>=?,
  ~customLabelStyle: option<string>=?,
  ~customMargin: option<string>=?,
  ~showToolTip: option<bool>=?,
  ~showNameAsToolTip: option<bool>=?,
  ~showBorder: option<bool>=?,
  ~showCustomBtnAtEnd: option<bool>=?,
  ~dropDownCustomBtnClick: option<bool>=?,
  ~addDynamicValue: bool=false,
  ~showMatchingRecordsText: option<bool>=?,
  ~customButton: option<React.element>=?,
  ~descriptionOnHover: option<bool>=?,
  ~fixedDropDownDirection: option<SelectBox.direction>=?,
  ~dropdownCustomWidth: option<string>=?,
  ~allowButtonTextMinWidth: option<bool>=?,
  ~baseComponent: option<React.element>=?,
  ~baseComponentMethod: option<bool => React.element>=?,
  ~customMarginStyle: option<string>=?,
  ~buttonTextWeight: option<string>=?,
  ~customButtonLeftIcon: option<Button.iconType>=?,
  ~customTextPaddingClass: option<string>=?,
  ~customButtonPaddingClass: option<string>=?,
  ~customButtonIconMargin: option<string>=?,
  ~textStyleClass: option<string>=?,
  ~setExtSearchString: option<('a => string) => unit>=?,
  ~buttonStyleOnDropDownOpened: option<string>=?,
  ~listFlexDirection: option<string>=?,
  ~baseComponentCustomStyle: option<string>=?,
  ~ellipsisOnly: option<bool>=?,
  ~customSelectStyle: option<string>=?,
  ~isPhoneDropdown: option<bool>=?,
  ~hasApplyButton: option<bool>=?,
  ~onApply: option<JsxEventU.Mouse.t => unit>=?,
  ~showAllSelectedOptions: option<bool>=?,
  ~buttonClickFn: option<string => unit>=?,
  ~showDescriptionAsTool: option<bool>=?,
  ~optionClass: option<string>=?,
  ~selectClass: option<string>=?,
  ~toggleProps: option<string>=?,
  ~showSelectCountButton: option<bool>=?,
  ~leftIcon: option<Button.iconType>=?,
  ~customBackColor: option<string>=?,
  ~customSelectAllStyle: option<string>=?,
  ~checkboxDimension: option<string>=?,
  ~showToolTipOptions: option<bool>=?,
  ~textEllipsisForDropDownOptions: option<bool>=?,
  ~showBtnTextToolTip: option<bool>=?,
  ~dropdownClassName: option<string>=?,
  ~onItemSelect: option<(JsxEventU.Mouse.t, string) => unit>=?,
  ~wrapBasis: option<string>=?,
  ~customScrollStyle: option<string>=?,
  ~shouldDisplaySelectedOnTop: option<bool>=?,
  ~placeholderCss: option<string>=?,
  ~maxButtonWidth: option<string>=?,
  ~side: option<MultiSelectBindings.selectMenuItemSide>=?,
  ~alignment: option<MultiSelectBindings.selectMenuItemAlignment>=?,
  ~minMenuWidth: option<int>=?,
  ~maxMenuWidth: option<int>=?,
  ~primaryAction: option<MultiSelectBindings.actionButtonType>=?,
  ~secondaryAction: option<MultiSelectBindings.secondaryActionButtonType>=?,
  ~maxTriggerWidth: option<float>=?,
  ~minTriggerWidth: option<float>=?,
  ~onFocus: option<unit => unit>=?,
  ~onBlur: option<unit => unit>=?,
  ~showClearButton: option<bool>=?,
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
