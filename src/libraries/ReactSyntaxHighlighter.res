type editorStyle

@module("react-syntax-highlighter/dist/esm/styles/hljs")
external lightfair: editorStyle = "googlecode"

type style = {
  backgroundColor?: string,
  lineHeight?: string,
  fontSize?: string,
  paddingLeft?: string,
  padding?: string,
}

type props = {
  language?: string,
  style?: editorStyle,
  customStyle?: style,
  showLineNumbers?: bool,
  wrapLines?: bool,
  wrapLongLines?: bool,
  lineNumberContainerStyle?: style,
  children: string,
}

module SyntaxHighlighter = {
  @module("react-syntax-highlighter") @react.component
  external make: (
    ~language: string=?,
    ~style: editorStyle=?,
    ~customStyle: style,
    ~showLineNumbers: bool,
    ~wrapLines: bool=?,
    ~wrapLongLines: bool=?,
    ~lineNumberContainerStyle: style,
    ~children: string,
  ) => React.element = "default"
}
