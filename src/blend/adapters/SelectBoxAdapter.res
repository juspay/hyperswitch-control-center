// Re-export legacy types so call sites need no type annotation changes
type dropdownOption = SelectBox.dropdownOption
type dropdownOptionWithoutOptional = SelectBox.dropdownOptionWithoutOptional
type allSelectType = SelectBox.allSelectType
type direction = SelectBox.direction

let makeOptions = SelectBox.makeOptions
let makeNonOptional = SelectBox.makeNonOptional

// Direction conversion helpers: CC's 6-value direction → Blend's alignment + side
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
    // Blend-specific props
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
    let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
    let useBlend = isBlendEnabled && baseComponentMethod->Option.isNone

    if useBlend {
      let alignment = switch alignment {
      | Some(_) => alignment
      | None => fixedDropDownDirection->Option.map(getAlignmentFromDirection)
      }
      let side = switch side {
      | Some(_) => side
      | None => fixedDropDownDirection->Option.map(getSideFromDirection)
      }
      let slot = MultiSelectWrapper.getSlotElementFromIcon(defaultLeftIcon)
      // Wrap in a plain <div> so Radix asChild can inject onClick onto a DOM element.
      // Custom React components (e.g. OMPViewBaseComp) don't forward injected props,
      // causing the dropdown to never open.
      let wrapTrigger = el => <div> el </div>
      let customTrigger = switch baseComponent {
      | Some(el) => Some(wrapTrigger(el))
      | None => customButton->Option.map(wrapTrigger)
      }
      let selectedValues = input.value->LogicUtils.getStrArrayFromJson
      let selectedValue = input.value->LogicUtils.getStringFromJson("")

      if allowMultiSelect {
        let blendItems = MultiSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValues)
        <MultiSelectWrapper
          items=blendItems
          placeholder=buttonText
          input
          disabled=disableSelect
          fullWidth=fullLength
          ?showSelectAll
          allowCustomValue=addDynamicValue
          ?slot
          ?customTrigger
          ?primaryAction
          ?secondaryAction
          ?variant
          ?onFocus
          ?onBlur
          ?showClearButton
          ?onClearAllClick
          ?alignment
          ?side
          minMenuWidth={minMenuWidth->Option.getOr(300)}
          maxMenuWidth={maxMenuWidth->Option.getOr(300)}
        />
      } else {
        let blendItems = SingleSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValue)
        let totalItems = blendItems->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
        let computedEnableSearch = searchable->Option.getOr(false) || totalItems > 5
        let searchPlaceholder = searchInputPlaceHolder->Option.map(v => v)
        <SingleSelectWrapper
          items=blendItems
          placeholder=buttonText
          input
          enableSearch=computedEnableSearch
          ?searchPlaceholder
          disabled=disableSelect
          fullWidth=fullLength
          allowCustomValue=addDynamicValue
          allowDeselect={!deselectDisable}
          ?slot
          ?customTrigger
          ?variant
          ?onFocus
          ?onBlur
          ?alignment
          ?side
          ?minMenuWidth
          ?maxMenuWidth
        />
      }
    } else {
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
    }
  }
}

@react.component
let make = (
  // Core props
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~options: array<SelectBox.dropdownOption>,
  ~buttonText: string="",
  ~buttonSize: Button.buttonSize=Medium,
  ~allowMultiSelect: bool=false,
  ~isDropDown: bool=true,
  // Legacy props — passed through to SelectBox unchanged in legacy branch
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
  ~optionRigthElement: React.element=?,
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
  // Blend-specific props (only used when blend is enabled)
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
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)

  // Routing logic:
  // 1. !isDropDown → always legacy
  // 2. baseComponentMethod provided → always legacy (render prop incompatible with Blend)
  // 3. isBlendEnabled → Blend path
  // 4. otherwise → legacy

  let useBlend = isBlendEnabled && isDropDown && baseComponentMethod->Option.isNone

  if useBlend {
    // Compute alignment + side from fixedDropDownDirection if provided
    // Compute alignment + side from fixedDropDownDirection if not explicitly provided
    let alignment = switch alignment {
    | Some(_) => alignment
    | None => fixedDropDownDirection->Option.map(getAlignmentFromDirection)
    }
    let side = switch side {
    | Some(_) => side
    | None => fixedDropDownDirection->Option.map(getSideFromDirection)
    }

    // slot element from leftIcon
    let slot = MultiSelectWrapper.getSlotElementFromIcon(leftIcon)

    // Wrap in a plain <div> so Radix asChild can inject onClick onto a DOM element.
    // Custom React components don't forward injected props, causing dropdown to never open.
    let wrapTrigger = el => <div> el </div>
    let customTrigger = switch baseComponent {
    | Some(el) => Some(wrapTrigger(el))
    | None => customButton->Option.map(wrapTrigger)
    }

    let selectedValues = input.value->LogicUtils.getStrArrayFromJson
    let selectedValue = input.value->LogicUtils.getStringFromJson("")

    if allowMultiSelect {
      let blendItems = MultiSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValues)
      <MultiSelectWrapper
        items=blendItems
        placeholder=buttonText
        input
        disabled=disableSelect
        fullWidth=fullLength
        ?showSelectAll
        allowCustomValue=addDynamicValue
        ?slot
        ?customTrigger
        ?primaryAction
        ?secondaryAction
        ?variant
        ?onFocus
        ?onBlur
        ?showClearButton
        ?onClearAllClick
        ?alignment
        ?side
        minMenuWidth={minMenuWidth->Option.getOr(300)}
        maxMenuWidth={maxMenuWidth->Option.getOr(300)}
      />
    } else {
      let blendItems = SingleSelectWrapper.makeItems(options, ~deselectDisable, ~selectedValue)
      // Auto-search: enable if searchable=true OR total items > 5
      let totalItems = blendItems->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
      let computedEnableSearch = searchable->Option.getOr(false) || totalItems > 5
      let searchPlaceholder = searchInputPlaceHolder

      <SingleSelectWrapper
        items=blendItems
        placeholder=buttonText
        input
        enableSearch=computedEnableSearch
        ?searchPlaceholder
        disabled=disableSelect
        fullWidth=fullLength
        allowCustomValue=addDynamicValue
        allowDeselect={!deselectDisable}
        ?slot
        ?customTrigger
        ?variant
        ?onFocus
        ?onBlur
        ?maxTriggerWidth
        ?minTriggerWidth
        ?alignment
        ?side
        ?minMenuWidth
        ?maxMenuWidth
      />
    }
  } else {
    // Legacy branch — all original props forwarded unchanged
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
      ?optionRigthElement
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
  }
}
