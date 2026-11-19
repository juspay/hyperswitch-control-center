// Ignores repeat clicks briefly so a double-click doesn't fire overlapping requests
let refreshCooldownMs = 800

// Refetches the list from page 1 with the current filters. A rolling date preset (e.g.
// "Last 30 mins") is first moved forward to now, and the date change triggers the refetch.
@react.component
let make = (~offset, ~setOffset, ~onRefresh) => {
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
      // Changing the offset already refetches, so call onRefresh only when on page 1
      offset === 0 ? onRefresh() : setOffset(_ => 0)
    }

  let handleClick = _ => {
    if !isCoolingDown {
      setIsCoolingDown(_ => true)
      refresh()
    }
  }

  <Button
    text="Refresh"
    ariaLabel="Refresh list"
    leftIcon={CustomIcon(
      <Icon name="sync-alt" size=14 className={isCoolingDown ? "animate-spin" : ""} />,
    )}
    buttonType=SecondaryFilled
    buttonSize=Small
    buttonState={isCoolingDown ? Disabled : Normal}
    onClick=handleClick
    customButtonStyle="!rounded-10-px !bg-white !h-9 !text-nd_gray-700 border !border-nd_gray-200 disabled:opacity-60"
  />
}
