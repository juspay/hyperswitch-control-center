@val @scope(("navigator", "clipboard"))
external writeText: string => unit = "writeText"

@react.component
let make = (~icon, ~label, ~number, ~color) => {
  let (isCopied, setIsCopied) = React.useState(_ => false)

  let handleIsCopied = () => {
    setIsCopied(_ => true)
    writeText(number)
  }

  let handleMouseLeave = () => {
    setIsCopied(_ => false)
  }

  let cardClass = "flex min-h-[38px] justify-between items-center p-[10px] bg-white rounded-md cursor-pointer font-bold text-xs border border-solid border-[rgba(60,66,87,.12)] w-full mb-2 relative shadow-testCardsShadow"
  let cardAfterClass = `after:opacity-0 after:content-['Copy'] after:absolute after:bg-[rgba(86,86,86,.85)] after:text-white after:font-bold after:text-sm after:h-full after:w-full after:-m-[10px] after:rounded-md after:flex after:justify-center after:items-center after:transition-opacity after:duration-150 after:ease-in-out`
  let cardCopiedAfter = "hover:after:content-['Copied'] after:bg-no-repeat bgUrl"

  let cardDotElement =
    <div
      className={`h-[2px] w-[2px] rounded-full mr-[1px]`}
      style={ReactDOMStyle.make(~backgroundColor=color, ())}
    />

  let css = ".bgPosition:hover::after {
      background-position: 60px;
    }
    .bgUrl::after {
      background-image: url('icons/hyperswitchSDK/tickMarkWhite.svg')
    }
    "

  <>
    <style> {React.string(css)} </style>
    <button
      className={`${cardClass} hover:after:opacity-100 ${cardAfterClass} ${isCopied
          ? cardCopiedAfter
          : ""} bgPosition`}
      style={ReactDOMStyle.make(~color, ())}
      onClick={_ => handleIsCopied()}
      onMouseLeave={_ => handleMouseLeave()}>
      <div className="flex items-center">
        {switch icon {
        | "authentication" =>
          <img className="mr-1" src="/icons/hyperswitchSDK/authentication.svg" />
        | _ => <Icon size=12 name={icon} className="mr-1" />
        }}
        <div className="card__type__label"> {React.string(label)} </div>
      </div>
      <div className="flex items-center">
        <div className="flex items-center mr-1">
          {cardDotElement}
          {cardDotElement}
          {cardDotElement}
          {cardDotElement}
        </div>
        <div className="card__number__value">
          {React.string(Js.String2.substr(number, ~from=-4))}
        </div>
      </div>
    </button>
  </>
}
