let makeItems = (
  options: array<SelectBox.dropdownOption>,
  ~deselectDisable: bool=false,
  ~selectedValue: string,
): array<MultiSelectBindings.selectMenuGroupType> => {
  // Group options by optGroup
  let groups: Dict.t<array<SelectBox.dropdownOption>> = Dict.make()

  options->Array.forEach(opt => {
    let group = opt.optGroup->Option.getOr("-")
    let existing = groups->Dict.get(group)->Option.getOr([])
    groups->Dict.set(group, Array.concat(existing, [opt]))
  })

  let groupKeys = groups->Dict.keysToArray

  groupKeys->Array.map(groupKey => {
    let groupOptions = groups->Dict.get(groupKey)->Option.getOr([])
    let items: array<MultiSelectBindings.selectMenuItemType> = groupOptions->Array.map(opt => {
      let slot1 = MultiSelectWrapper.getSlotElementFromIcon(opt.icon)
      let slot2 = MultiSelectWrapper.getSlot2FromIcon(opt.icon)
      let isSelected = opt.value === selectedValue
      let alwaysSelected = deselectDisable && isSelected
      {
        MultiSelectBindings.label: opt.label,
        value: opt.value,
        subLabel: ?opt.labelDescription,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        alwaysSelected: ?(alwaysSelected ? Some(true) : None),
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
  ~items: array<MultiSelectBindings.selectMenuGroupType>,
  ~placeholder: string,
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~enableSearch: bool=false,
  ~label: string=?,
  ~disabled: bool=false,
  ~size: option<SingleSelectBinding.selectMenuSize>=?,
  ~searchPlaceholder: string=?,
  ~onBlur: option<unit => unit>=?,
  ~onFocus: option<unit => unit>=?,
  ~required: bool=false,
  ~fullWidth: bool=?,
  ~allowCustomValue: bool=false,
  ~alignment: option<MultiSelectBindings.selectMenuItemAlignment>=?,
  ~side: option<MultiSelectBindings.selectMenuItemSide>=?,
  ~slot: option<React.element>=?,
  ~customTrigger: option<React.element>=?,
  ~minMenuWidth: int=?,
  ~maxMenuWidth: int=?,
  ~allowDeselect: bool=?,
  ~maxTriggerWidth: float=?,
  ~minTriggerWidth: float=?,
  ~variant: option<MultiSelectBindings.selectMenuItemVariant>=?,
) => {
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  let selectedValue = input.value->LogicUtils.getStringFromJson("")

  let handleChange = (value: string) => {
    input.onChange(value->JSON.Encode.string->Identity.jsonToFormReactEvent)
  }

  // Auto-enable search if more than 5 total items
  let totalItems = items->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
  let computedEnableSearch = enableSearch || totalItems > 5

  <SingleSelectBinding
    selected=selectedValue
    onSelect=handleChange
    items
    ?label
    disabled=isDisabled
    required
    placeholder
    ?size
    enableSearch=computedEnableSearch
    ?searchPlaceholder
    ?onBlur
    ?onFocus
    ?fullWidth
    allowCustomValue
    ?alignment
    ?side
    ?slot
    ?customTrigger
    ?minMenuWidth
    ?maxMenuWidth
    ?allowDeselect
    ?maxTriggerWidth
    ?minTriggerWidth
    ?variant
  />
}
