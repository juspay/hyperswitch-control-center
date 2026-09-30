let globalDateFiltersAtom: Recoil.recoilAtom<ReconEngineFilterTypes.globalDateFilter> = Recoil.atom(
  "reconEngineGlobalDateFilters",
  ({startTime: "", endTime: ""}: ReconEngineFilterTypes.globalDateFilter),
)

let businessProfileAtom: Recoil.recoilAtom<
  option<ReconEngineTypes.reconBusinessProfileType>,
> = Recoil.atom("reconEngineBusinessProfile", None)
