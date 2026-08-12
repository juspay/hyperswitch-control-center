let globalDateFiltersAtom: Recoil.recoilAtom<ReconEngineTypes.globalDateFilter> = Recoil.atom(
  "reconEngineGlobalDateFilters",
  ({startTime: "", endTime: ""}: ReconEngineTypes.globalDateFilter),
)
