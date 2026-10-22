open LogicUtils

let getLeftSlot = (icon: option<Button.iconType>) =>
  switch icon {
  | Some(CustomIcon(el)) => Some(el)
  | Some(FontAwesome(name)) => Some(<Icon name size=20 />)
  | _ => None
  }

let getRightSlot = (icon: option<Button.iconType>) =>
  switch icon {
  | Some(CustomRightIcon(el)) => Some(el)
  | _ => None
  }

let makeItems = (
  options: array<SelectBox.dropdownOption>,
  ~deselectDisable: bool=false,
  ~selectedValues: array<string>,
) => {
  let groups = Dict.make()

  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->getValueFromDict(group, [])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })

  let groupKeys = groups->Dict.keysToArray

  groupKeys->Array.map(groupKey => {
    let groupOptions = groups->getValueFromDict(groupKey, [])
    let items: array<MultiSelectBindings.multiSelectV2ItemType> = groupOptions->Array.map(opt => {
      let slot1 = getLeftSlot(opt.icon)
      let slot2 = getRightSlot(opt.icon)
      let isChecked = selectedValues->Array.includes(opt.value)
      let alwaysSelected = deselectDisable && isChecked

      (
        {
          MultiSelectBindings.label: opt.label,
          value: opt.value,
          checked: isChecked,
          subLabel: ?opt.labelDescription,
          ?slot1,
          ?slot2,
          disabled: ?opt.isDisabled,
          alwaysSelected: ?(alwaysSelected ? Some(true) : None),
          tooltip: ?opt.description,
        }: MultiSelectBindings.multiSelectV2ItemType
      )
    })

    (
      {
        MultiSelectBindings.groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
        items,
      }: MultiSelectBindings.multiSelectV2GroupType
    )
  })
}

@react.component
let make = (
  ~items: array<MultiSelectBindings.multiSelectV2GroupType>,
  ~placeholder: string,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~label: string="",
  ~disabled: bool=false,
  ~helpIconHintText: string="",
  ~required: bool=false,
  ~fullWidth: bool=false,
  ~showSelectAll: option<bool>=?,
  ~alignment: option<MultiSelectBindings.selectMenuItemAlignment>=?,
  ~side: option<MultiSelectBindings.selectMenuItemSide>=?,
  ~allowCustomValue: bool=false,
  ~slot: option<React.element>=?,
  ~customTrigger: option<React.element>=?,
  ~minMenuWidth: int=300,
  ~maxMenuWidth: int=300,
  ~primaryAction: option<MultiSelectBindings.actionButtonType>=?,
  ~secondaryAction: option<MultiSelectBindings.secondaryActionButtonType>=?,
  ~variant: option<MultiSelectBindings.selectMenuItemVariant>=?,
  ~selectionTagType: option<MultiSelectBindings.selectionTagType>=?,
  ~onFocus: option<unit => unit>=?,
  ~onBlur: option<unit => unit>=?,
  ~showClearButton: option<bool>=?,
  ~onClearAllClick: option<unit => unit>=?,
  ~size: option<MultiSelectBindings.selectMenuItemSize>=?,
  ~error: bool=false,
  ~errorMessage: option<string>=?,
  ~height: option<int>=?,
  ~menuFooter: option<React.element>=?,
  ~enableSearch: option<bool>=?,
  ~searchPlaceholder: option<string>=?,
  ~enableVirtualization: option<bool>=?,
) => {
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  let selectedValues = input.value->getStrArrayFromJson
  let handleChange = values =>
    input.onChange(values->getJsonFromArrayOfString->Identity.jsonToFormReactEvent)
  let resolvedClearAllClick = onClearAllClick->Option.getOr(() => handleChange([]))

  <MultiSelectBindings
    selectedValues
    onSelectionChange=handleChange
    items
    label
    disabled=isDisabled
    helpIconText=?{helpIconHintText->isEmptyString ? None : Some(helpIconHintText)}
    required
    triggerDimensions={width: fullWidth ? "100%" : "auto"}
    placeholder
    ?size
    menuPosition={?alignment, ?side}
    allowCustomValue
    ?slot
    customTrigger={customTrigger->Option.getOr(
      MultiSelectBindings.Trigger.make(
        ~items,
        ~selectedValues,
        ~placeholder,
        ~disabled=isDisabled,
        ~slot?,
        ~fullWidth,
        ~size?,
        ~selectionTagType?,
        ~height?,
        (),
      ),
    )}
    menuDimensions={minWidth: minMenuWidth, maxWidth: maxMenuWidth, maxHeight: 320}
    ?variant
    ?onFocus
    ?onBlur
    ?showClearButton
    onClearAllClick=resolvedClearAllClick
    error={show: error, message: ?errorMessage}
    enableSelectAll=?showSelectAll
    ?primaryAction
    ?secondaryAction
    ?selectionTagType
    ?menuFooter
    search={show: ?enableSearch, placeholder: ?searchPlaceholder}
    ?enableVirtualization
  />
}
