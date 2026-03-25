// Re-export legacy types so call sites need no type annotation changes
type dropdownOption = FilterSelectBox.dropdownOption
type dropdownOptionWithoutOptional = FilterSelectBox.dropdownOptionWithoutOptional
type allSelectType = FilterSelectBox.allSelectType
type direction = FilterSelectBox.direction

let makeOptions = FilterSelectBox.makeOptions
let makeNonOptional = FilterSelectBox.makeNonOptional

// Direction helpers: FilterSelectBox's 6-value direction → Blend's alignment + side
let getAlignmentFromDirection = (direction: FilterSelectBox.direction) =>
  switch direction {
  | BottomLeft | TopLeft => MultiSelectBindings.End
  | BottomMiddle | TopMiddle => MultiSelectBindings.Center
  | BottomRight | TopRight => MultiSelectBindings.Start
  }

let getSideFromDirection = (direction: FilterSelectBox.direction) =>
  switch direction {
  | TopLeft | TopMiddle | TopRight => MultiSelectBindings.Top
  | BottomLeft | BottomMiddle | BottomRight => MultiSelectBindings.Bottom
  }

// Convert FilterSelectBox.dropdownOption to Blend multi-select items
let makeFilterItems = (
  options: array<FilterSelectBox.dropdownOption>,
  ~selectedValues: array<string>,
): array<MultiSelectBindings.selectMenuGroupType> => {
  let groups: Dict.t<array<FilterSelectBox.dropdownOption>> = Dict.make()
  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->Dict.get(group)->Option.getOr([])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })
  groups
  ->Dict.keysToArray
  ->Array.map(groupKey => {
    let groupOptions = groups->Dict.get(groupKey)->Option.getOr([])
    let items: array<MultiSelectBindings.selectMenuItemType> = groupOptions->Array.map(opt => {
      let slot1 = MultiSelectWrapper.getSlotElementFromIcon(opt.icon)
      let slot2 = MultiSelectWrapper.getSlot2FromIcon(opt.icon)
      let isChecked = selectedValues->Array.includes(opt.value)
      {
        MultiSelectBindings.label: opt.label,
        value: opt.value,
        checked: isChecked,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        tooltip: ?opt.description,
      }
    })
    {
      MultiSelectBindings.groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
      items,
    }
  })
}

// Convert FilterSelectBox.dropdownOption to Blend single-select items
let makeFilterItemsSingle = (
  options: array<FilterSelectBox.dropdownOption>,
  ~selectedValue: string,
): array<MultiSelectBindings.selectMenuGroupType> => {
  let groups: Dict.t<array<FilterSelectBox.dropdownOption>> = Dict.make()
  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->Dict.get(group)->Option.getOr([])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })
  groups
  ->Dict.keysToArray
  ->Array.map(groupKey => {
    let groupOptions = groups->Dict.get(groupKey)->Option.getOr([])
    let items: array<MultiSelectBindings.selectMenuItemType> = groupOptions->Array.map(opt => {
      let slot1 = MultiSelectWrapper.getSlotElementFromIcon(opt.icon)
      let slot2 = MultiSelectWrapper.getSlot2FromIcon(opt.icon)
      {
        MultiSelectBindings.label: opt.label,
        value: opt.value,
        checked: opt.value === selectedValue,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        tooltip: ?opt.description,
      }
    })
    {
      MultiSelectBindings.groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
      items,
    }
  })
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~buttonText="Normal Selection",
  ~buttonSize: Button.buttonSize=?,
  ~allowMultiSelect=false,
  ~isDropDown=true,
  ~hideMultiSelectButtons=false,
  ~options: array<dropdownOption>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isSelectedStateMinus=false,
  ~isHorizontal=false,
  ~deselectDisable=false,
  ~showClearAll=true,
  ~showSelectAll=true,
  ~buttonType: Button.buttonType=Button.SecondaryFilled,
  ~disableSelect=false,
  ~fullLength=false,
  ~customButtonStyle="",
  ~textStyle="",
  ~marginTop="mt-12",
  ~customStyle="",
  ~showSelectionAsChips=true,
  ~showToggle=false,
  ~maxHeight: string=?,
  ~searchable: bool=?,
  ~fill="#0EB025",
  ~optionRigthElement: React.element=?,
  ~hideBorder=false,
  ~allSelectType: FilterSelectBox.allSelectType=FilterSelectBox.Icon,
  ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
  ~searchInputPlaceHolder: string=?,
  ~showSearchIcon=true,
  ~customLabelStyle: string=?,
  ~customMargin="",
  ~showToolTip=false,
  ~showNameAsToolTip=false,
  ~showBorder: bool=?,
  ~showCustomBtnAtEnd=false,
  ~dropDownCustomBtnClick=false,
  ~addDynamicValue=false,
  ~showMatchingRecordsText=true,
  ~customButton=React.null,
  ~descriptionOnHover=false,
  ~fixedDropDownDirection: FilterSelectBox.direction=?,
  ~dropdownCustomWidth: string=?,
  ~baseComponent: React.element=?,
  ~baseComponentMethod: bool => React.element=?,
  ~customMarginStyle: string=?,
  ~buttonTextWeight: string=?,
  ~customButtonLeftIcon: Button.iconType=?,
  ~customTextPaddingClass: string=?,
  ~customButtonPaddingClass: string=?,
  ~customButtonIconMargin: string=?,
  ~setExtSearchString: ('a => string) => unit=?,
  ~buttonStyleOnDropDownOpened="",
  ~listFlexDirection="",
  ~baseComponentCustomStyle="",
  ~ellipsisOnly=false,
  ~customSelectStyle="",
  ~isPhoneDropdown=false,
  ~hasApplyButton: bool=?,
  ~onApply: JsxEventU.Mouse.t => unit=?,
  ~showAllSelectedOptions: bool=?,
  ~buttonClickFn: string => unit=?,
  ~showDescriptionAsTool=true,
  ~optionClass="",
  ~selectClass="",
  ~toggleProps="",
  ~showSelectCountButton=false,
  ~leftIcon: Button.iconType=?,
  ~customBackColor: string=?,
  ~customSelectAllStyle: string=?,
  ~checkboxDimension="",
  ~showToolTipOptions=false,
  ~textEllipsisForDropDownOptions=false,
  ~showBtnTextToolTip=false,
  ~dropdownClassName="",
  ~onItemSelect=(_, _) => (),
  ~wrapBasis="",
  (),
) => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  // baseComponentMethod (render prop) is incompatible with Blend; always use legacy when present
  let useBlend = isBlendEnabled && isDropDown && baseComponentMethod->Option.isNone

  if useBlend {
    let alignment = fixedDropDownDirection->Option.map(getAlignmentFromDirection)
    let side = fixedDropDownDirection->Option.map(getSideFromDirection)

    // Wrap baseComponent in a plain <div> so Radix asChild can inject onClick
    let wrapTrigger = el => <div> el </div>
    let customTrigger = baseComponent->Option.map(wrapTrigger)

    // Map hasApplyButton → Blend primaryAction
    let primaryAction: option<MultiSelectBindings.actionButtonType> = if (
      hasApplyButton->Option.getOr(false)
    ) {
      Some({
        text: "Apply",
        onClick: values => {
          let json = values->Array.map(JSON.Encode.string)->JSON.Encode.array
          input.onChange(json->Identity.jsonToFormReactEvent)
        },
      })
    } else {
      None
    }

    if allowMultiSelect {
      let selectedValues = input.value->LogicUtils.getStrArrayFromJson
      let blendItems = makeFilterItems(options, ~selectedValues)
      <MultiSelectWrapper
        items=blendItems
        placeholder=buttonText
        input
        disabled=disableSelect
        fullWidth=fullLength
        showSelectAll
        ?customTrigger
        ?primaryAction
        ?alignment
        ?side
        minMenuWidth=300
        maxMenuWidth=300
      />
    } else {
      let selectedValue = input.value->LogicUtils.getStringFromJson("")
      let blendItems = makeFilterItemsSingle(options, ~selectedValue)
      let totalItems = blendItems->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
      let computedEnableSearch = searchable->Option.getOr(false) || totalItems > 5
      <SingleSelectWrapper
        items=blendItems
        placeholder=buttonText
        input
        enableSearch=computedEnableSearch
        disabled=disableSelect
        fullWidth=fullLength
        allowDeselect={!deselectDisable}
        ?customTrigger
        ?alignment
        ?side
      />
    }
  } else {
    <FilterSelectBox
      input
      buttonText
      ?buttonSize
      allowMultiSelect
      isDropDown
      hideMultiSelectButtons
      options
      optionSize
      isSelectedStateMinus
      isHorizontal
      deselectDisable
      showClearAll
      showSelectAll
      buttonType
      disableSelect
      fullLength
      customButtonStyle
      textStyle
      marginTop
      customStyle
      showSelectionAsChips
      showToggle
      ?maxHeight
      ?searchable
      fill
      ?optionRigthElement
      hideBorder
      allSelectType
      customSearchStyle
      ?searchInputPlaceHolder
      showSearchIcon
      ?customLabelStyle
      customMargin
      showToolTip
      showNameAsToolTip
      ?showBorder
      showCustomBtnAtEnd
      dropDownCustomBtnClick
      addDynamicValue
      showMatchingRecordsText
      customButton
      descriptionOnHover
      ?fixedDropDownDirection
      ?dropdownCustomWidth
      ?baseComponent
      ?baseComponentMethod
      ?customMarginStyle
      ?buttonTextWeight
      ?customButtonLeftIcon
      ?customTextPaddingClass
      ?customButtonPaddingClass
      ?customButtonIconMargin
      ?setExtSearchString
      buttonStyleOnDropDownOpened
      listFlexDirection
      baseComponentCustomStyle
      ellipsisOnly
      customSelectStyle
      isPhoneDropdown
      ?hasApplyButton
      ?onApply
      ?showAllSelectedOptions
      ?buttonClickFn
      showDescriptionAsTool
      optionClass
      selectClass
      toggleProps
      showSelectCountButton
      ?leftIcon
      ?customBackColor
      ?customSelectAllStyle
      checkboxDimension
      showToolTipOptions
      textEllipsisForDropDownOptions
      showBtnTextToolTip
      dropdownClassName
      onItemSelect
      wrapBasis
    />
  }
}
