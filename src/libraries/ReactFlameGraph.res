type rec flameGraphNode = {
  name: string,
  id?: int,
  label?: string,
  value: int,
  tooltip?: string,
  color?: string,
  backgroundColor?: string,
  src_loc?: string,
  children?: array<flameGraphNode>,
}

type flameGraphRef = {focusNode: (. int) => unit}

type flameGraphComponentInstance = {__flameGraphRef: flameGraphRef}

@module("react-flame-graph") @react.component
external make: (
  ~ref: React.ref<Js.Nullable.t<flameGraphComponentInstance>>=?,
  ~data: flameGraphNode,
  ~height: int,
  ~width: int,
  ~onChange: flameGraphNode => unit,
) => React.element = "FlameGraph"
