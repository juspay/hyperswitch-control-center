let customFilterAtom: Jotai.jotaiAtom<string> = Jotai.atom("customFilterAtom", "")
let completionProvider: Jotai.jotaiAtom<option<Monaco.Language.regProvider>> = Jotai.atom(
  "completionProvider",
  None,
)
