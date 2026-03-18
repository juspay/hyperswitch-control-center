let defaultDict: Dict.t<Dom.element> = Dict.make()

let portalNodes = Jotai.atom("portalNodes", defaultDict)
