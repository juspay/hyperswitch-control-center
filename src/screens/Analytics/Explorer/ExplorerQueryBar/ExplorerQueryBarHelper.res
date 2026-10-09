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
  ) =>
    <SingleSelectBinding
      selected=value
      onSelect=onChange
      items=[{items: options->Array.map(option => {...option, disableTruncation: true})}]
      placeholder
      size=Sm
      minMenuWidth=300
      maxMenuWidth=380
    />
}
