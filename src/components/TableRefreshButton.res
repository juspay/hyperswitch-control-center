// Ignores repeat clicks for a moment so double-clicks don't fire overlapping list requests
let refreshCooldownMs = 800

// Refetches the list from page 1 with the same filters and search. A rolling date preset
// (e.g. "Last 30 mins") is moved forward to now; the new dates refetch the list and counts.
@react.component
let make = (~offset, ~setOffset, ~onRefresh) => {
  open Typography
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let setRefreshSignal = Recoil.useSetRecoilState(HyperswitchAtom.tableRefreshSignalAtom)
  let (isCoolingDown, setIsCoolingDown) = React.useState(_ => false)

  React.useEffect(() => {
    if isCoolingDown {
      let timeoutId = setTimeout(() => setIsCoolingDown(_ => false), refreshCooldownMs)
      Some(() => clearTimeout(timeoutId))
    } else {
      None
    }
  }, [isCoolingDown])

  let refresh = () =>
    switch filterValueJson->DateRangePresetUtils.getRolledRange {
    | Some(rolledRange) => updateExistingKeys(rolledRange)
    | None =>
      setRefreshSignal(prev => prev + 1)
      // Lists already refetch when the offset changes, so fetch directly only on page 1
      offset === 0 ? onRefresh() : setOffset(_ => 0)
    }

  let handleClick = _ => {
    if !isCoolingDown {
      setIsCoolingDown(_ => true)
      refresh()
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
