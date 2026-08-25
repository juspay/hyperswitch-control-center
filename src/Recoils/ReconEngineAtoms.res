let globalDateFiltersAtom: Recoil.recoilAtom<ReconEngineFilterTypes.globalDateFilter> = Recoil.atom(
  "reconEngineGlobalDateFilters",
  ({startTime: "", endTime: ""}: ReconEngineFilterTypes.globalDateFilter),
)
