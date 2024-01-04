let defaultDict: Js.Dict.t<Dom.element> = Dict.make()

let portalNodes = Recoil.atom(. "portalNodes", defaultDict)
