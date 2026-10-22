open Typography

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
  ) =>
    <SingleSelectBinding
      selected=value
      onSelect={next => onChange(allowDeselect && next === value ? "" : next)}
      items=[
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
      customTrigger={SingleSelectBinding.Trigger.make(
        ~items=[
          {
            items: options->Array.map(item => {
              SingleSelectBinding.label: item.label,
              value: item.value,
            }),
          },
        ],
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
