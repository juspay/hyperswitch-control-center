@react.component
let make = (
  ~cursors: ReconEngineTypes.cursors,
  ~isLoading: bool,
  ~hasData: bool,
  ~onPrev: unit => unit,
  ~onNext: unit => unit,
) => {
  <PrevNextPaginationButtons
    isLoading
    hasData
    prevDisabled={cursors.prev->Option.isNone}
    nextDisabled={cursors.next->Option.isNone}
    onPrev
    onNext
  />
}
