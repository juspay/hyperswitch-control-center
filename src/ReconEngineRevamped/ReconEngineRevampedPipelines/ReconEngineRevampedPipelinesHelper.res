open Typography
open ReconEngineRevampedPipelinesTypes

module ConnectedStatCard = {
  @react.component
  let make = (
    ~title: connectedStatCardsTitle,
    ~value: valueType,
    ~cardType: connectedStatCardType,
    ~icon: Button.iconType,
    ~description: string,
    ~onPress: option<unit => unit>=?,
  ) => {
    open ReconEngineRevampedHelper

    let (hovered, setHovered) = React.useState(_ => false)

    let bgClass = switch (cardType, hovered) {
    | (Info, true) => "bg-blue-50"
    | (Attention, true) => "bg-red-50"
    | (_, false) => "bg-white"
    }

    let textColorClass = switch cardType {
    | Info => "text-nd_gray-700"
    | Attention => "text-nd_red-500"
    }

    <div
      className={`px-4 py-3.5 transition-all cursor-pointer ${bgClass} border-r border-nd_gray-200 last:border-r-0`}
      onMouseEnter={_ => setHovered(_ => true)}
      onMouseLeave={_ => setHovered(_ => false)}
      onClick={_ =>
        switch onPress {
        | Some(f) => f()
        | None => ()
        }}>
      <div className="flex items-center justify-between">
        <p className={`${body.sm.medium} text-nd_gray-600`}>
          {(title :> string)->String.toUpperCase->React.string}
        </p>
        <div className="bg-nd_gray-150/60 rounded-md w-8 h-8 flex items-center justify-center">
          {switch icon {
          | FontAwesome(iconName) =>
            <span className="flex items-center">
              <Icon className="text-nd_gray-500" size=14 name=iconName />
            </span>
          | Euler(iconName) =>
            <span className="flex items-center">
              <Icon className="text-nd_gray-500" size=14 name=iconName />
            </span>
          | CustomIcon(element) => <span className="flex items-center"> {element} </span>
          | _ => React.null
          }}
        </div>
      </div>
      <div className="flex flex-col gap-y-2.5 items-start mt-1.5">
        <p className={`${heading.md.semibold} min-w-0 max-w-full ${textColorClass}`}>
          {switch value {
          | Percentage(v) => <PercentageCell value=v />
          | Float(v) => <FloatCell value=v />
          | Number(v) => <NumberCell value=v />
          | Amount(v, currency) => <AmountCell value=v currency />
          | OutOf(v1, v2) => <OutOfCell value1=v1 value2=v2 />
          | SlashOutOf(v1, v2) => <SlashOutOfCell value1=v1 value2=v2 />
          }}
        </p>
        <p className={`${body.sm.medium} text-nd_gray-500`}> {description->React.string} </p>
      </div>
    </div>
  }
}
