open Typography
open LogicUtils
open ReconEngineRevampedUtils
open ReconEngineRevampedTypes

module PageHeading = {
  @react.component
  let make = (~title, ~subTitle=?) => {
    let isMiniLaptopView = MatchMedia.useScreenSizeChecker(~screenSize="1300")

    let titleClass = isMiniLaptopView ? heading.sm.semibold : heading.md.semibold

    <div className="flex flex-col gap-1.5">
      <div className="flex items-center gap-4">
        <div className={`${titleClass} text-nd_gray-800`}> {title->React.string} </div>
        <OMPPermaLinkButton />
      </div>
      {switch subTitle {
      | Some(text) =>
        <RenderIf condition={text->isNonEmptyString}>
          <div className={`${body.md.regular} text-nd_gray-600`}> {text->React.string} </div>
        </RenderIf>
      | None => React.null
      }}
    </div>
  }
}

module ReconEngineStatus = {
  @react.component
  let make = () => {
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let (engineStatus, setEngineStatus) = React.useState(_ => Stopped)

    let fetchEngineStatus = async () => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#RECON_STATUS,
          ~methodType=Get,
        )
        let res = await fetchDetails(url)
        let reconStatus = res->getDictFromJsonObject->reconStatusResponseMapper
        setEngineStatus(_ => reconStatus.status)
      } catch {
      | _ => setEngineStatus(_ => Stopped)
      }
    }

    React.useEffect(() => {
      fetchEngineStatus()->ignore
      let intervalId = Js.Global.setInterval(() => {
        fetchEngineStatus()->ignore
      }, 10000)

      Some(() => Js.Global.clearInterval(intervalId))
    }, [])

    let (label, borderClass, dotClass, showPulse) = switch engineStatus {
    | Running => ("Engine Running", "border-nd_green-200", "bg-nd_green-500", true)
    | Stopped => ("Engine Stopped", "border-nd_red-100", "bg-nd_red-500", false)
    }

    <div className="fixed top-6 right-5">
      <div
        className={`flex items-center gap-2 rounded-full border ${borderClass} bg-white/95 px-3 py-1.5 shadow-sm backdrop-blur`}>
        <div className="relative flex h-2 w-2">
          <RenderIf condition={showPulse}>
            <span
              className={`absolute inline-flex h-full w-full animate-ping rounded-full ${dotClass} opacity-70`}
            />
          </RenderIf>
          <span className={`relative inline-flex h-2 w-2 rounded-full ${dotClass}`} />
        </div>
        <div className={`${body.sm.medium} text-nd_gray-700`}> {label->React.string} </div>
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

    <ToolTip
      descriptionComponent=actualValueContent toolTipFor=floatText toolTipPosition={ToolTip.Top}
    />
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

    <ToolTip description=actualValue toolTipFor={numberText} toolTipPosition={ToolTip.Top} />
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

    <ToolTip
      descriptionComponent=actualValueContent toolTipFor=amountText toolTipPosition={ToolTip.Top}
    />
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

    <ToolTip description=actualValue toolTipFor=outOfText toolTipPosition={ToolTip.Top} />
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

    <ToolTip description=actualValue toolTipFor=slashOutOfText toolTipPosition={ToolTip.Top} />
  }
}
