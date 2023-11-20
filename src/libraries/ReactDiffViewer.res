let defaultStyles = Js.Dict.empty()
let wordDiffStyle = Js.Dict.empty()
Js.Dict.set(wordDiffStyle, "padding", "0px"->Js.Json.string)
Js.Dict.set(defaultStyles, "wordDiff", wordDiffStyle->Js.Json.object_)
let styles = defaultStyles->Js.Json.object_

@react.component
let make = (
  ~disableWordDiff=?,
  ~oldValue,
  ~newValue,
  ~splitView=?,
  ~codeFoldMessageRenderer=?,
  ~hideLineNumbers=?,
  ~useDarkTheme=?,
  ~leftTitle=?,
  ~rightTitle=?,
  ~compareMethod=?,
  ~renderContent=?,
) => {
  <ReactDiffViewerBase
    ?disableWordDiff
    oldValue
    newValue
    ?splitView
    ?codeFoldMessageRenderer
    ?hideLineNumbers
    ?useDarkTheme
    styles
    ?leftTitle
    ?rightTitle
    ?compareMethod
    ?renderContent
  />
}
