module Language = {
  type completionItemEnum
  type completionItemKind

  type model
  type languages
  type position = {
    lineNumber: int,
    column: int,
  }
  type word = {
    startColumn: int,
    endColumn: int,
  }
  type range = {
    startLineNumber: int,
    endLineNumber: int,
    startColumn: int,
    endColumn: int,
  }
  type labels = {
    label: string,
    insertText: string,
    range: range,
  }
  type suggestions = {suggestions: array<labels>}
  type completionItemProvider = {provideCompletionItems: (model, position) => suggestions}

  type internalModel = {
    startLineNumber: int,
    startColumn: int,
    endLineNumber: int,
    endColumn: int,
  }
  type regProvider
  @send
  external dispose: regProvider => unit = "dispose"
  @send
  external getWordUntilPosition: (model, position) => word = "getWordUntilPosition"
  @get external completionItemKind: languages => completionItemKind = "CompletionItemKind"
  @get external value: completionItemKind => completionItemEnum = "Value"
  @send
  external registerCompletionItemProvider: (
    languages,
    string,
    completionItemProvider,
  ) => regProvider = "registerCompletionItemProvider"
}

// Monaco basic types
type keyCode = {\"KEY_S": int}
type monaco = {languages: Language.languages, \"KeyCode": keyCode}

type lang = [#yaml | #sql]

module Range = {
  type t

  @module("monaco-editor") @new external new: (int, int, int, int) => t = "Range"
}
type wordWrapOverride2 = [#off | #on | #inherit]
type wordWrap = [#off | #on | #wordWrapColumn | #bounded]
type linenumberSwitch = [#off | #on]

type minimap = {enabled: bool}
type options = {
  emptySelectionClipboard?: bool,
  formatOnType?: bool,
  wordWrapOverride2?: wordWrapOverride2,
  wordWrap?: wordWrap,
  lineNumbers?: linenumberSwitch,
  minimap?: minimap,
  roundedSelection?: bool,
}

type setPosition = {
  lineNumber: int,
  column: int,
}
type editor = {
  setPosition: setPosition => unit,
  focus: unit => unit,
}

module Editor = {
  module IStandaloneCodeEditor = {
    type t

    @send external deltaDecorations: (t, 'arr1, 'arr2) => 'decorators = "deltaDecorations"
  }

  @react.component @module("@monaco-editor/react")
  external make: (
    ~height: string,
    ~theme: string,
    ~language: lang,
    ~onChange: string => unit,
    ~value: string,
    ~beforeMount: monaco => unit,
    ~options: options=?,
  ) => React.element = "default"
}
