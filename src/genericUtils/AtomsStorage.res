module Euler = {
  let parentContextRecoil: Recoil.recoilAtom<string> = Recoil.atom(. "parentContext", "")

  let merchantAccessRecoil: Recoil.recoilAtom<array<Js.Json.t>> = Recoil.atom(.
    "merchantAccess",
    [],
  )
}
