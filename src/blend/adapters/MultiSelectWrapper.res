let getSlotElementFromIcon = (icon: option<Button.iconType>) =>
  switch icon {
  | Some(CustomIcon(el)) => Some(el)
  | Some(FontAwesome(name)) => Some(<Icon name size=20 />)
  | Some(Euler(name)) => Some(<Icon name size=20 />)
  | _ => None
  }

let getSlot2FromIcon = (icon: option<Button.iconType>) =>
  switch icon {
  | Some(CustomRightIcon(el)) => Some(el)
  | _ => None
  }

let makeItems = (
  options: array<SelectBox.dropdownOption>,
  ~deselectDisable: bool=false,
  ~selectedValues: array<string>,
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
      let slot1 = getSlotElementFromIcon(opt.icon)
      let slot2 = getSlot2FromIcon(opt.icon)
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
  ~showSelectAll: bool=?,
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
  ~showClearButton: bool=?,
  ~onClearAllClick: option<unit => unit>=?,
  ~size: option<MultiSelectBindings.selectMenuItemSize>=?,
  ~error: bool=false,
  ~errorMessage: string=?,
  ~height: int=?,
) => {
  let authContext = React.useContext(FormAuthContext.formAuthContext)
  let isDisabled = disabled || authContext === CommonAuthTypes.NoAccess

  // Batched onChange to handle rapid fire events from select-all / deselect-all
  let batchedRef: React.ref<array<string>> = React.useRef([])
  let timerRef: React.ref<option<Js.Global.timeoutId>> = React.useRef(None)

  let selectedValues = input.value->LogicUtils.getStrArrayFromJson

  let commitChange = () => {
    let values = batchedRef.current
    let jsonValues = values->Array.map(s => JSON.Encode.string(s))->JSON.Encode.array
    input.onChange(jsonValues->Identity.jsonToFormReactEvent)
  }

  let handleChange = (value: string) => {
    // Toggle the value in the current selection
    let current = batchedRef.current
    let next = if current->Array.includes(value) {
      current->Array.filter(v => v !== value)
    } else {
      Array.concat(current, [value])
    }
    batchedRef.current = next

    // Clear any pending timer and set a new one
    switch timerRef.current {
    | Some(id) => Js.Global.clearTimeout(id)
    | None => ()
    }
    timerRef.current = Some(Js.Global.setTimeout(() => {
        commitChange()
        timerRef.current = None
      }, 10))
  }

  // Sync batchedRef with latest input value on each render
  React.useEffect1(() => {
    batchedRef.current = selectedValues
    None
  }, [selectedValues])

  React.useEffect0(() => {
    Some(
      () => {
        switch timerRef.current {
          | Some(id) => Js.Global.clearTimeout(id)
          | None => ()
          }
      },
    )
  })

  <MultiSelectBindings
    selectedValues
    onChange=handleChange
    items
    label
    disabled=isDisabled
    helpIconHintText=?{helpIconHintText->LogicUtils.isEmptyString ? None : Some(helpIconHintText)}
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
    ?onClearAllClick
    ?height
    error
    ?errorMessage
    enableSelectAll=?showSelectAll
    ?primaryAction
    ?secondaryAction
  />
}
