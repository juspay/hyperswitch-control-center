let customFilterAtom: Recoil.recoilAtom<string> = Recoil.atom(. "customFilterAtom", "")
let completionProvider: Recoil.recoilAtom<option<Monaco.Language.regProvider>> = Recoil.atom(.
  "completionProvider",
  None,
)
