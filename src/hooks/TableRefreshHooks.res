// Bumped on every list refresh so widgets outside the table (e.g. status counts) refetch too
let refreshSignalAtom: Recoil.recoilAtom<int> = Recoil.atom("tableRefreshSignal", 0)

// Returns `(refresh, refreshKey)`. Add `refreshKey` to the page's fetch effect dependencies.
// A rolling date preset is moved forward through the filter context, which already refetches
// page 1; otherwise the offset is reset and `refreshKey` bumped, keeping filters and search.
let useListRefresh = (~setOffset, ~startTimeKey="", ~endTimeKey="") => {
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let setRefreshSignal = Recoil.useSetRecoilState(refreshSignalAtom)
  let (refreshKey, setRefreshKey) = React.useState(_ => 0)

  let refresh = () => {
    setRefreshSignal(prev => prev + 1)
    let rolledRange =
      startTimeKey->LogicUtils.isNonEmptyString
        ? DateRangePresetUtils.getRolledRange(
            ~filterValueJson,
            ~startKey=startTimeKey,
            ~endKey=endTimeKey,
          )
        : None

    switch rolledRange {
    | Some((startTime, endTime)) =>
      updateExistingKeys(Dict.fromArray([(startTimeKey, startTime), (endTimeKey, endTime)]))
    | None =>
      setOffset(_ => 0)
      setRefreshKey(prev => prev + 1)
    }
  }

  (refresh, refreshKey)
}
