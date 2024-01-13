@module("react-diff-viewer") @react.component
external make: (
  ~disableWordDiff: bool=?,
  ~oldValue: string,
  ~newValue: string,
  ~splitView: bool=?,
  ~codeFoldMessageRenderer: unit => string=?,
  ~hideLineNumbers: bool=?,
  ~useDarkTheme: bool=?,
  ~styles: Js.Json.t=?,
  ~leftTitle: string=?,
  ~rightTitle: string=?,
  ~compareMethod: string=?,
  ~renderContent: 'a=?,
) => React.element = "default"
