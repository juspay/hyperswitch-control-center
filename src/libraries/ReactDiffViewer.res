let defaultStyles = Dict.make()
let wordDiffStyle = Dict.make()
Dict.set(wordDiffStyle, "padding", "0px"->JSON.Encode.string)
Dict.set(defaultStyles, "wordDiff", wordDiffStyle->JSON.Encode.object)
let styles = defaultStyles->JSON.Encode.object

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
