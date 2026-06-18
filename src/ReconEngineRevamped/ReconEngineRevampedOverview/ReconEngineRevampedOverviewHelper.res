open Typography
open ReconEngineRevampedOverviewTypes

module ConnectedStatCard = {
  @react.component
  let make = (~title: connectedStatCardsTitle, ~value: valueType) => {
    open ReconEngineRevampedHelper

    <div
      className="px-4 py-3.5 transition-colors bg-white border-r border-b border-nd_gray-200 last:border-r-0">
      <div className="flex items-center justify-between">
        <p className={`${body.sm.medium} text-nd_gray-600`}>
          {(title :> string)->String.toUpperCase->React.string}
        </p>
      </div>
      <div className="flex flex-col gap-y-2.5 items-start mt-1.5">
        <p className={`${heading.sm.semibold} min-w-0 max-w-full text-nd_gray-700`}>
          {switch value {
          | Percentage(v) => <PercentageCell value=v />
          | Float(v) => <FloatCell value=v />
          | Number(v) => <NumberCell value=v />
          | Amount(v, currency) => <AmountCell value=v currency />
          | OutOf(v1, v2) => <OutOfCell value1=v1 value2=v2 />
          | SlashOutOf(v1, v2) => <SlashOutOfCell value1=v1 value2=v2 />
          }}
        </p>
      </div>
    </div>
  }
}

module StatCard = {
  @react.component
  let make = (
    ~title: statCardsTitle,
    ~value: valueType,
    ~icon: Button.iconType,
    ~description,
    ~cardType: statCardType,
  ) => {
    open ReconEngineRevampedHelper

    let textColorClass = switch cardType {
    | Info => "text-nd_gray-700"
    | Attention => "text-nd_red-500"
    }

    let hoverBorderClass = switch cardType {
    | Info => "hover:border-nd_primary_blue-300/60"
    | Attention => "hover:border-nd_red-500/60"
    }

    <div
      className={`px-4 py-3.5 transition-all cursor-pointer ${hoverBorderClass} hover:shadow-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring/40 bg-white rounded-xl border border-nd_gray-200 shadow-sm`}>
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
