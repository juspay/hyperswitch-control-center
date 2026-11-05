// Ignores repeat clicks for a moment so double-clicks don't fire overlapping list requests
let refreshCooldownMs = 800

@react.component
let make = (~onRefresh) => {
  open Typography
  let (isCoolingDown, setIsCoolingDown) = React.useState(_ => false)

  React.useEffect(() => {
    if isCoolingDown {
      let timeoutId = setTimeout(() => setIsCoolingDown(_ => false), refreshCooldownMs)
      Some(() => clearTimeout(timeoutId))
    } else {
      None
    }
  }, [isCoolingDown])

  let handleClick = _ => {
    if !isCoolingDown {
      setIsCoolingDown(_ => true)
      onRefresh()
    }
  }

  <button
    type_="button"
    ariaLabel="Refresh list"
    disabled=isCoolingDown
    onClick=handleClick
    className={`flex items-center gap-2 ${body.md.medium} text-nd_gray-700 border border-nd_gray-200 rounded-10-px px-3.5 h-9 bg-white disabled:opacity-60 disabled:cursor-not-allowed`}>
    <Icon name="sync-alt" size=14 className={isCoolingDown ? "animate-spin" : ""} />
    {"Refresh"->React.string}
  </button>
}
