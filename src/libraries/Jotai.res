module Provider = {
  @module("jotai") @react.component
  external make: (~children: React.element) => React.element = "Provider"
}

type jotaiAtom<'v>

@module("./jotai_wrapper")
external atom: (string, 'v) => jotaiAtom<'v> = "atom"

@module("jotai")
external useAtom: jotaiAtom<'valueT> => ('valueT, ('valueT => 'valueT) => unit) = "useAtom"

@module("jotai")
external useSetAtom: jotaiAtom<'valueT> => ('valueT => 'valueT) => unit = "useSetAtom"

@module("jotai")
external useAtomValue: jotaiAtom<'valueT> => 'valueT = "useAtomValue"
