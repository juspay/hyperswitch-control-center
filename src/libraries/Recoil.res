module RecoilRoot = {
  @module("recoil") @react.component
  external make: (~children: React.element) => React.element = "RecoilRoot"
}

type recoilAtom<'v> = RecoilAtom('v)
type recoilSelector<'v> = RecoilSelector('v)

@module("./recoil")
external atom: (. string, 'v) => recoilAtom<'v> = "atom"

@module("recoil")
external useRecoilState: recoilAtom<'valueT> => ('valueT, (. 'valueT => 'valueT) => unit) =
  "useRecoilState"

@module("recoil")
external useSetRecoilState: recoilAtom<'valueT> => (. 'valueT => 'valueT) => unit =
  "useSetRecoilState"

@module("recoil")
external useRecoilValueFromAtom: recoilAtom<'valueT> => 'valueT = "useRecoilValue"

module DebugObserver = {
  type snapshot

  @module("recoil")
  external useRecoilSnapshot: unit => snapshot = "useRecoilSnapshot"

  let doSomething: snapshot => unit = %raw(`
  function useSomeHook(snapshot) {
    console.log('DebugObserver :: The following atoms were modified:');
    for (const node of snapshot.getNodes_UNSTABLE({isModified: true})) {
      console.debug("DebugObserver :: ", node.key, snapshot.getLoadable(node));
    }
  }
  `)

  let useMake: unit => React.element = () => {
    let snapshot = useRecoilSnapshot()

    React.useEffect1(() => {
      doSomething(snapshot)

      None
    }, [snapshot])

    React.null
  }
}
