open LogicUtils

let makeItems = (options: array<SelectBox.dropdownOption>) => {
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
      {
        SingleSelectBinding.label: opt.label,
        value: opt.value,
        subLabel: ?opt.labelDescription,
        ?slot1,
        ?slot2,
        disabled: ?opt.isDisabled,
        tooltip: ?opt.description,
      }
    })
    {
      SingleSelectBinding.groupLabel: ?(groupKey === "-" ? None : Some(groupKey)),
      items,
    }
  })
}

@react.component
let make = (
  ~items: array<SingleSelectBinding.selectMenuGroupType>,
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
  ~menuFooter: option<React.element>=?,
) => {
  let triggerId = React.useId()
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  let selectedValue = input.value->getStringFromJson("")

  let handleChange = value => {
    // V2 delegates reselect-to-clear to the controlled parent.
    let next = allowDeselect->Option.getOr(false) && value === selectedValue ? "" : value
    input.onChange(next->JSON.Encode.string->Identity.jsonToFormReactEvent)
  }

  let totalItems = items->Array.reduce(0, (acc, g) => acc + g.items->Array.length)
  let computedEnableSearch = enableSearch || totalItems > 5

  <SingleSelectBinding
    name=triggerId
    selected=selectedValue
    onSelect=handleChange
    items
    ?label
    disabled=isDisabled
    required
    placeholder
    ?size
    search={show: computedEnableSearch, placeholder: ?searchPlaceholder}
    ?onBlur
    ?onFocus
    triggerDimensions={
      minWidth: ?minTriggerWidth,
      maxWidth: ?maxTriggerWidth,
      width: ?(fullWidth->Option.getOr(false) ? Some("100%") : None),
    }
    allowCustomValue
    menuPosition={?alignment, ?side}
    ?slot
    customTrigger={customTrigger->Option.getOr(
      SingleSelectBinding.Trigger.make(
        ~items,
        ~id=triggerId,
        ~label?,
        ~onFocus?,
        ~onBlur?,
        ~selected=selectedValue,
        ~placeholder,
        ~disabled=isDisabled,
        ~slot?,
        ~fullWidth=fullWidth->Option.getOr(false),
        ~minWidth=?minTriggerWidth,
        ~maxWidth=?maxTriggerWidth,
        ~size?,
        (),
      ),
    )}
    menuDimensions={minWidth: ?minMenuWidth, maxWidth: ?maxMenuWidth, maxHeight: 320}
    ?variant
    ?menuFooter
  />
}
