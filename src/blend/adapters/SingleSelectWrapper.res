open LogicUtils

let makeItems = (
  options: array<SelectBox.dropdownOption>,
  ~deselectDisable: bool=false,
  ~selectedValue: string,
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
    let items = groupOptions->Array.map(opt => {
      let slot1 = MultiSelectWrapper.getLeftSlot(opt.icon)
      let slot2 = MultiSelectWrapper.getRightSlot(opt.icon)
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
  ~label: option<string>=?,
  ~disabled: bool=false,
  ~size: option<SingleSelectBinding.selectMenuSize>=?,
  ~searchPlaceholder: option<string>=?,
  ~onBlur: option<unit => unit>=?,
  ~onFocus: option<unit => unit>=?,
  ~required: bool=false,
  ~fullWidth: option<bool>=?,
  ~allowCustomValue: bool=false,
  ~alignment: option<MultiSelectBindings.selectMenuItemAlignment>=?,
  ~side: option<MultiSelectBindings.selectMenuItemSide>=?,
  ~slot: option<React.element>=?,
  ~customTrigger: option<React.element>=?,
  ~minMenuWidth: option<int>=?,
  ~maxMenuWidth: option<int>=?,
  ~allowDeselect: option<bool>=?,
  ~maxTriggerWidth: option<float>=?,
  ~minTriggerWidth: option<float>=?,
  ~variant: option<MultiSelectBindings.selectMenuItemVariant>=?,
) => {
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  let selectedValue = input.value->getStringFromJson("")

  let handleChange = value => {
    input.onChange(value->JSON.Encode.string->Identity.jsonToFormReactEvent)
  }

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
