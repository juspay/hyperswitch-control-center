open MultiSelectBindings
open MultiSelectWrapper
open LogicUtils

type dropdownOption = FilterSelectBox.dropdownOption
type dropdownOptionWithoutOptional = FilterSelectBox.dropdownOptionWithoutOptional
type allSelectType = FilterSelectBox.allSelectType
type direction = FilterSelectBox.direction

let makeOptions = FilterSelectBox.makeOptions
let makeNonOptional = FilterSelectBox.makeNonOptional

let getAlignmentFromDirection = direction => {
  open FilterSelectBox
  switch direction {
  | BottomLeft | TopLeft => End
  | BottomMiddle | TopMiddle => Center
  | BottomRight | TopRight => Start
  }
}

let getSideFromDirection = direction => {
  open FilterSelectBox
  switch direction {
  | TopLeft | TopMiddle | TopRight => Top
  | BottomLeft | BottomMiddle | BottomRight => Bottom
  }
}

let makeFilterItems = (options: array<dropdownOption>, ~selectedValues) => {
  let groups = Dict.make()
  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->Dict.get(group)->Option.getOr([])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })
  groups
  ->Dict.keysToArray
  ->Array.map(groupKey => {
    let groupOptions = groups->Dict.get(groupKey)->Option.getOr([])
    let items = groupOptions->Array.map(opt => {
      let slot1 = getSlotElementFromIcon(opt.icon)
      let slot2 = getSlot2FromIcon(opt.icon)
      let isChecked = selectedValues->Array.includes(opt.value)
      {
        label: opt.label,
        value: opt.value,
        checked: isChecked,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        tooltip: ?opt.description,
      }
    })
    {
      groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
      items,
    }
  })
}

let makeFilterItemsSingle = (options: array<dropdownOption>, ~selectedValue) => {
  let groups = Dict.make()
  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->Dict.get(group)->Option.getOr([])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })
  groups
  ->Dict.keysToArray
  ->Array.map(groupKey => {
    let groupOptions = groups->Dict.get(groupKey)->Option.getOr([])
    let items = groupOptions->Array.map(opt => {
      let slot1 = getSlotElementFromIcon(opt.icon)
      let slot2 = getSlot2FromIcon(opt.icon)
      {
        label: opt.label,
        value: opt.value,
        checked: opt.value === selectedValue,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        tooltip: ?opt.description,
      }
    })
    {
      groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
      items,
    }
  })
}

module BlendMultiSelect = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~buttonText: string,
    ~options: array<dropdownOption>,
    ~showSelectAll: bool,
    ~fullLength: bool,
    ~showSelectionAsChips: bool,
    ~dropdownCustomWidth: option<string>=?,
    ~isDisabled: bool,
    ~customTrigger: option<React.element>=?,
    ~alignment: option<selectMenuItemAlignment>=?,
    ~side: option<selectMenuItemSide>=?,
  ) => {
    let form = ReactFinalForm.useForm()
    let {removeKeys, filterKeys, setfilterKeys} = React.useContext(FilterContext.filterContext)

    let (pendingValues, setPendingValues) = React.useState(() => input.value->getStrArrayFromJson)
    let hasPendingChanges = React.useRef(false)

    React.useEffect1(() => {
      if !hasPendingChanges.current {
        setPendingValues(_ => input.value->getStrArrayFromJson)
      }
      None
    }, [input.value])

    let handleChange = (value: string) => {
      hasPendingChanges.current = true
      setPendingValues(prev =>
        if prev->Array.includes(value) {
          prev->Array.filter(v => v !== value)
        } else {
          Array.concat(prev, [value])
        }
      )
    }

    let onClearAllClick = () => {
      hasPendingChanges.current = false
      [input.name]->removeKeys
      setfilterKeys(_ => filterKeys->Array.filter(item => item !== input.name))
    }

    let primaryAction: actionButtonType = {
      text: "Apply",
      onClick: _blendValues => {
        hasPendingChanges.current = false
        let json = pendingValues->Array.map(JSON.Encode.string)->JSON.Encode.array
        input.onChange(json->Identity.jsonToFormReactEvent)
        form.submit()->ignore
      },
    }

    let menuWidth =
      dropdownCustomWidth
      ->Option.flatMap(w => w->String.replace("px", "")->Int.fromString)
      ->Option.getOr(300)
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
      selectionTagType={showSelectionAsChips ? Text : Count}
      onClearAllClick
      minMenuWidth=menuWidth
      maxMenuWidth=menuWidth
      ?alignment
      ?side
    />
  }
}

module BlendSingleSelect = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~buttonText: string,
    ~options: array<dropdownOption>,
    ~searchable: option<bool>=?,
    ~fullLength: bool,
    ~deselectDisable: bool,
    ~isDisabled: bool,
    ~customTrigger: option<React.element>=?,
    ~alignment: option<selectMenuItemAlignment>=?,
    ~side: option<selectMenuItemSide>=?,
  ) => {
    let selectedValue = input.value->getStringFromJson("")
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
  ~allSelectType: allSelectType=FilterSelectBox.Icon,
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
  ~fixedDropDownDirection: option<direction>=?,
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
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let useBlend = isBlendEnabled && isDropDown && baseComponentMethod->Option.isNone

  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disableSelect || authContext === CommonAuthTypes.NoAccess

  let alignment = fixedDropDownDirection->Option.map(getAlignmentFromDirection)
  let side = fixedDropDownDirection->Option.map(getSideFromDirection)
  let customTrigger = baseComponent->Option.map(el => <div> el </div>)

  <>
    <RenderIf condition={useBlend && allowMultiSelect}>
      <BlendMultiSelect
        input
        buttonText
        options
        showSelectAll
        fullLength
        showSelectionAsChips
        ?dropdownCustomWidth
        isDisabled
        ?customTrigger
        ?alignment
        ?side
      />
    </RenderIf>
    <RenderIf condition={useBlend && !allowMultiSelect}>
      <BlendSingleSelect
        input
        buttonText
        options
        ?searchable
        fullLength
        deselectDisable
        isDisabled
        ?customTrigger
        ?alignment
        ?side
      />
    </RenderIf>
    <RenderIf condition={!useBlend}>
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
    </RenderIf>
  </>
}
