type observer
type dimensions
@new external newResizerObserver: (Js.Array2.t<dimensions> => unit) => observer = "ResizeObserver"
