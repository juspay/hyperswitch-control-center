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
    let items = groupOptions->Array.map(opt => {
      let slot1 = getLeftSlot(opt.icon)
      let slot2 = getRightSlot(opt.icon)
      let isChecked = selectedValues->Array.includes(opt.value)
      let alwaysSelected = deselectDisable && isChecked
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
  ~onFocus: option<unit => unit>=?,
  ~onBlur: option<unit => unit>=?,
  ~showClearButton: option<bool>=?,
  ~onClearAllClick: option<unit => unit>=?,
  ~size: option<MultiSelectBindings.selectMenuItemSize>=?,
  ~error: bool=false,
  ~errorMessage: option<string>=?,
  ~height: option<int>=?,
) => {
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  // Batched onChange to handle rapid fire events from select-all / deselect-all
  let batchedRef = React.useRef([])
  let timerRef = React.useRef(None)

  let selectedValues = input.value->getStrArrayFromJson

  let cancelPendingTimer = () =>
    switch timerRef.current {
    | Some(id) => clearTimeout(id)
    | None => ()
    }

  let commitChange = () => {
    let values = batchedRef.current
    input.onChange(values->getJsonFromArrayOfString->Identity.jsonToFormReactEvent)
  }

  let handleChange = value => {
    let current = batchedRef.current
    let next = if current->Array.includes(value) {
      current->Array.filter(v => v !== value)
    } else {
      Array.concat(current, [value])
    }
    batchedRef.current = next
    cancelPendingTimer()
    timerRef.current = Some(setTimeout(() => {
        commitChange()
        timerRef.current = None
      }, 10))
  }

  let defaultClearAll = () => {
    cancelPendingTimer()
    batchedRef.current = []
    input.onChange([]->getJsonFromArrayOfString->Identity.jsonToFormReactEvent)
  }

  let resolvedClearAllClick = onClearAllClick->Option.getOr(defaultClearAll)

  // Only sync when not batching — preserves accumulated state during rapid-fire events
  if timerRef.current->Option.isNone {
    batchedRef.current = selectedValues
  }

  React.useEffect0(() => Some(cancelPendingTimer))

  <MultiSelectBindings
    selectedValues
    onChange=handleChange
    items
    label
    disabled=isDisabled
    helpIconHintText=?{helpIconHintText->isEmptyString ? None : Some(helpIconHintText)}
    required
    fullWidth
    placeholder
    ?size
    ?alignment
    ?side
    allowCustomValue
    ?slot
    ?customTrigger
    minMenuWidth
    maxMenuWidth
    ?variant
    ?onFocus
    ?onBlur
    ?showClearButton
    onClearAllClick=resolvedClearAllClick
    ?height
    error
    ?errorMessage
    enableSelectAll=?showSelectAll
    ?primaryAction
    ?secondaryAction
  />
}
