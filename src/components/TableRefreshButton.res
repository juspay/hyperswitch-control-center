@react.component
let make = (~onRefresh, ~offset=0, ~setOffset=_ => ()) => {
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let setRefreshSignal = Recoil.useSetRecoilState(HyperswitchAtom.tableRefreshSignalAtom)

  let refresh = _ =>
    switch filterValueJson->DateRangePresetUtils.getRolledRange {
    | Some(rolled) =>
      DateRangePresetUtils.savePresetSelection(rolled)
      updateExistingKeys(
        Dict.fromArray([(rolled.startKey, rolled.startTime), (rolled.endKey, rolled.endTime)]),
      )
    | None =>
      setRefreshSignal(prev => prev + 1)
      offset === 0 ? onRefresh() : setOffset(_ => 0)
    }

  <Button
    text="Refresh"
    ariaLabel="Refresh list"
    leftIcon={CustomIcon(<Icon name="sync-alt" size=14 />)}
    buttonType=SecondaryFilled
    buttonSize=Small
    onClick=refresh
    customButtonStyle="!rounded-10-px !bg-white !h-9 !text-nd_gray-700 border !border-nd_gray-200"
  />
}
