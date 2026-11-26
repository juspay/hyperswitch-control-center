open Typography
open ExplorerTypes
open ExplorerDescriptions

module QueryText = {
  @react.component
  let make = (~text, ~strong=false) =>
    <span
      className={`whitespace-nowrap ${strong
          ? `${body.lg.semibold} text-nd_gray-800`
          : `${body.lg.regular} text-nd_gray-500`}`}>
      {text->React.string}
    </span>
}

module QuerySelect = {
  @react.component
  let make = (
    ~value,
    ~onChange,
    ~options: array<MultiSelectBindings.selectMenuItemType>,
    ~placeholder,
    ~allowDeselect=false,
    ~enableSearch=false,
  ) => {
    let items: array<SingleSelectBinding.selectMenuGroupType> = [
      {
        items: options->Array.map(option => {
          SingleSelectBinding.label: option.label,
          value: option.value,
          subLabel: ?option.subLabel,
          slot1: ?option.slot1,
          slot2: ?option.slot2,
          disabled: ?option.disabled,
          tooltip: ?option.tooltip,
          disableTruncation: true,
        }),
      },
    ]
    <SingleSelectBinding
      selected=value
      onSelect={next => onChange(allowDeselect && next === value ? "" : next)}
      items
      customTrigger={SingleSelectBinding.Trigger.make(
        ~items,
        ~selected=value,
        ~placeholder,
        ~size=Sm,
        (),
      )}
      placeholder
      size=Sm
      search={show: enableSearch}
      menuDimensions={minWidth: 300, maxWidth: 380}
    />
  }
}

module FilterChips = {
  @react.component
  let make = (~selection: selection, ~labelFor, ~editing, ~onEdit, ~onRemove) =>
    selection.filters
    ->Array.map(((key, values)) =>
      <TagBinding
        key={(key :> string)}
        text={`${dimensionLabel(key)}: ${values
          ->Array.map(value => labelFor(key, value))
          ->Array.joinWith(", ")}`}
        variant=Subtle
        color={editing == Some(key) ? Primary : Neutral}
        size=Sm
        shape=Rounded
        onClick={_ => onEdit(Some(key))}
        rightSlot={<span
          className="inline-flex"
          onClick={ev => {
            ev->ReactEvent.Mouse.stopPropagation
            onRemove(key)
          }}>
          <Icon name="nd-cross" size=10 />
        </span>}
      />
    )
    ->React.array
}
