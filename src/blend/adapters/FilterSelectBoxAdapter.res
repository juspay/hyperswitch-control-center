type dropdownOption = FilterSelectBox.dropdownOption
type dropdownOptionWithoutOptional = FilterSelectBox.dropdownOptionWithoutOptional
type allSelectType = FilterSelectBox.allSelectType
type direction = FilterSelectBox.direction

let makeOptions = FilterSelectBox.makeOptions
let makeNonOptional = FilterSelectBox.makeNonOptional

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
  ~buttonSize: option<Button.buttonSize>=?,
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
  ~maxHeight: option<string>=?,
  ~searchable: option<bool>=?,
  ~fill="#0EB025",
  ~optionRigthElement: option<React.element>=?,
  ~hideBorder=false,
  ~allSelectType: FilterSelectBox.allSelectType=FilterSelectBox.Icon,
  ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
  ~searchInputPlaceHolder: option<string>=?,
  ~showSearchIcon=true,
  ~customLabelStyle: option<string>=?,
  ~customMargin="",
  ~showToolTip=false,
  ~showNameAsToolTip=false,
  ~showBorder: option<bool>=?,
  ~showCustomBtnAtEnd=false,
  ~dropDownCustomBtnClick=false,
  ~addDynamicValue=false,
  ~showMatchingRecordsText=true,
  ~customButton=React.null,
  ~descriptionOnHover=false,
  ~fixedDropDownDirection: option<FilterSelectBox.direction>=?,
  ~dropdownCustomWidth: option<string>=?,
  ~baseComponent: option<React.element>=?,
  ~baseComponentMethod: option<bool => React.element>=?,
  ~customMarginStyle: option<string>=?,
  ~buttonTextWeight: option<string>=?,
  ~customButtonLeftIcon: option<Button.iconType>=?,
  ~customTextPaddingClass: option<string>=?,
  ~customButtonPaddingClass: option<string>=?,
  ~customButtonIconMargin: option<string>=?,
  ~setExtSearchString: option<('a => string) => unit>=?,
  ~buttonStyleOnDropDownOpened="",
  ~listFlexDirection="",
  ~baseComponentCustomStyle="",
  ~ellipsisOnly=false,
  ~customSelectStyle="",
  ~isPhoneDropdown=false,
  ~hasApplyButton: option<bool>=?,
  ~onApply: option<JsxEventU.Mouse.t => unit>=?,
  ~showAllSelectedOptions: option<bool>=?,
  ~buttonClickFn: option<string => unit>=?,
  ~showDescriptionAsTool=true,
  ~optionClass="",
  ~selectClass="",
  ~toggleProps="",
  ~showSelectCountButton=false,
  ~leftIcon: option<Button.iconType>=?,
  ~customBackColor: option<string>=?,
  ~customSelectAllStyle: option<string>=?,
  ~checkboxDimension="",
  ~showToolTipOptions=false,
  ~textEllipsisForDropDownOptions=false,
  ~showBtnTextToolTip=false,
  ~dropdownClassName="",
  ~onItemSelect=(_, _) => (),
  ~wrapBasis="",
  (),
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()
  let useBlend = isBlendEnabled && isDropDown && baseComponentMethod->Option.isNone

  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let form = ReactFinalForm.useForm()
  let {removeKeys, filterKeys, setfilterKeys} = React.useContext(FilterContext.filterContext)

  let (pendingValues, setPendingValues) = React.useState(() =>
    input.value->LogicUtils.getStrArrayFromJson
  )

  React.useEffect1(() => {
    setPendingValues(_ => input.value->LogicUtils.getStrArrayFromJson)
    None
  }, [input.value])

  if useBlend {
    let alignment = fixedDropDownDirection->Option.map(getAlignmentFromDirection)
    let side = fixedDropDownDirection->Option.map(getSideFromDirection)

    let wrapTrigger = el => <div> el </div>
    let customTrigger = baseComponent->Option.map(wrapTrigger)

    let isDisabled = disableSelect || authContext === CommonAuthTypes.NoAccess

    let onClearAllClick = () => {
      [input.name]->removeKeys
      setfilterKeys(_ => filterKeys->Array.filter(item => item !== input.name))
    }

    if allowMultiSelect {
      let handleChange = (value: string) => {
        setPendingValues(prev =>
          if prev->Array.includes(value) {
            prev->Array.filter(v => v !== value)
          } else {
            Array.concat(prev, [value])
          }
        )
      }

      let primaryAction: MultiSelectBindings.actionButtonType = {
        text: "Apply",
        onClick: _blendValues => {
          let json = pendingValues->Array.map(JSON.Encode.string)->JSON.Encode.array
          input.onChange(json->Identity.jsonToFormReactEvent)
          form.submit()->ignore
        },
      }

      let blendItems = makeFilterItems(options, ~selectedValues=pendingValues)
      <MultiSelectBindings
        selectedValues=pendingValues
        onChange=handleChange
        items=blendItems
        placeholder=buttonText
        disabled=isDisabled
        fullWidth=fullLength
        enableSelectAll=showSelectAll
        ?customTrigger
        primaryAction
        showActionButtons=true
        selectionTagType=MultiSelectBindings.Count
        onClearAllClick
        minMenuWidth=300
        maxMenuWidth=300
        ?alignment
        ?side
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
        disabled=isDisabled
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
