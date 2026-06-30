open ReconEngineOverviewSummaryTypes
open ReconEngineOverviewSummaryUtils
open Typography

module TabSwitch = {
  @react.component
  let make = (~viewType: viewType, ~setViewType) => {
    // Icons and styling change based on current viewType
    let (icon1Bg, icon1Shadow, icon1Color, icon1Name) = switch viewType {
    | Graph => ("bg-white", "shadow-sm", "text-gray-700", "graph-outline")
    | Table => ("bg-transparent", "", "text-gray-500", "graph-outline")
    }

    let (icon2Bg, icon2Shadow, icon2Color, icon2Name) = switch viewType {
    | Graph => ("bg-transparent", "", "text-gray-500", "grid-table")
    | Table => ("bg-white", "shadow-sm", "text-gray-700", "grid-table")
    }

    <div className="bg-gray-100 p-1 rounded-xl flex flex-row gap-2 w-fit mt-2">
      <div
        className={`rounded-lg px-3 py-2.5 transition-all duration-200 cursor-pointer ${icon1Bg} ${icon1Shadow}`}
        onClick={_ => setViewType(_ => Graph)}>
        <Icon className={icon1Color} name={icon1Name} size=12 />
      </div>
      <div
        className={`rounded-lg px-3 py-2.5 transition-all duration-200 cursor-pointer ${icon2Bg} ${icon2Shadow}`}
        onClick={_ => setViewType(_ => Table)}>
        <Icon className={icon2Color} name=icon2Name size=12 />
      </div>
    </div>
  }
}

module FloatCell = {
  @react.component
  let make = (~value: float) => {
    open CurrencyFormatUtils

    let displayValue = valueFormatter(value, Volume)
    let actualValue = formatFloatNumber(value)
    let floatText =
      <span
        className="inline-block max-w-full truncate underline decoration-dotted decoration-nd_gray-400 underline-offset-4">
        {displayValue->React.string}
      </span>
    let actualValueContent =
      <span className="block max-w-64 break-all text-center"> {actualValue->React.string} </span>

    <ToolTip descriptionComponent=actualValueContent toolTipFor=floatText toolTipPosition=Top />
  }
}

module NumberCell = {
  @react.component
  let make = (~value: int) => {
    open CurrencyFormatUtils

    let displayValue = valueFormatter(value->Int.toFloat, Volume)
    let actualValue = formatNumber(value)
    let numberText =
      <span className="underline decoration-dotted decoration-nd_gray-400 underline-offset-4">
        {displayValue->React.string}
      </span>

    <ToolTip description=actualValue toolTipFor={numberText} toolTipPosition=Top />
  }
}

module AmountCell = {
  @react.component
  let make = (~value: float, ~currency: string) => {
    open CurrencyFormatUtils

    let displayValue = `${currency} ${valueFormatter(value, Amount)}`
    let actualValue = `${currency} ${formatFloatNumber(value)}`
    let amountText =
      <span
        className="inline-block max-w-full truncate underline decoration-dotted decoration-nd_gray-400 underline-offset-4">
        {displayValue->React.string}
      </span>
    let actualValueContent =
      <span className="block max-w-64 break-all text-center"> {actualValue->React.string} </span>

    <ToolTip descriptionComponent=actualValueContent toolTipFor=amountText toolTipPosition=Top />
  }
}

module PercentageCell = {
  @react.component
  let make = (~value: float) => {
    open CurrencyFormatUtils

    value->valueFormatter(Rate)->React.string
  }
}

module OutOfCell = {
  @react.component
  let make = (~value1: int, ~value2: int) => {
    open CurrencyFormatUtils

    let displayValue1 = valueFormatter(value1->Int.toFloat, Volume)
    let displayValue2 = valueFormatter(value2->Int.toFloat, Volume)
    let actualValue = `${formatNumber(value1)} of ${formatNumber(value2)}`
    let outOfText =
      <span className="underline decoration-dotted decoration-nd_gray-400 underline-offset-4">
        <span> {displayValue1->React.string} </span>
        <span className={`${body.md.medium} text-nd_gray-500`}>
          {` of ${displayValue2}`->React.string}
        </span>
      </span>

    <ToolTip description=actualValue toolTipFor=outOfText toolTipPosition=Top />
  }
}

module SlashOutOfCell = {
  @react.component
  let make = (~value1: int, ~value2: int) => {
    open CurrencyFormatUtils

    let displayValue1 = valueFormatter(value1->Int.toFloat, Volume)
    let displayValue2 = valueFormatter(value2->Int.toFloat, Volume)
    let actualValue = `${formatNumber(value1)}/${formatNumber(value2)}`
    let slashOutOfText =
      <span className="underline decoration-dotted decoration-nd_gray-400 underline-offset-4">
        <span> {`${displayValue1} / ${displayValue2}`->React.string} </span>
      </span>

    <ToolTip description=actualValue toolTipFor=slashOutOfText toolTipPosition=Top />
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
    ~onStatCardClick=() => (),
  ) => {
    let textColorClass = switch cardType {
    | Info => "text-nd_gray-700"
    | Attention => "text-nd_red-500"
    }

    let hoverBorderClass = switch cardType {
    | Info => "hover:border-nd_primary_blue-300/60"
    | Attention => "hover:border-nd_red-500/60"
    }

    <div
      onClick={_ => onStatCardClick()}
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

module ConnectedStatCard = {
  @react.component
  let make = (
    ~title: connectedStatCardsTitle,
    ~value: valueType,
    ~onConnectedStatCardClick=() => (),
  ) => {
    <div
      onClick={_ => onConnectedStatCardClick()}
      className="group px-4 py-3.5 transition-colors duration-200 cursor-pointer bg-white hover:bg-nd_gray-50 border-r border-b border-nd_gray-200 last:border-r-0">
      <div className="flex items-center justify-between">
        <p
          className={`${body.sm.medium} text-nd_gray-600 transition-colors duration-200 group-hover:text-nd_gray-700`}>
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
