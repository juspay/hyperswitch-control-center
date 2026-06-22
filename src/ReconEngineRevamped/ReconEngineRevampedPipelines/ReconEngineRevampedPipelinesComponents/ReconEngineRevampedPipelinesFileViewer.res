open Typography
open LogicUtils
open ReconEngineTypes
open ReconEngineRevampedPipelinesFileViewerUtils

type viewerState = Loading | Loaded | Errored

// Custom "recon-data" language: rainbow coloring of CSV / delimited columns so
// the content isn't flat black text.
let reconLanguageId = "recon-data"
let reconLightTheme = "recon-data-light"
let reconDarkTheme = "recon-data-dark"

let rainbowColumns = 7

// Rainbow-CSV tokens provider: each comma-separated column gets its own color,
// cycling through the palette. `tokenize` runs once per line, so column counting
// restarts at 0 every line. Quoted fields containing commas are kept whole.
let rainbowProvider = (n: int): Monaco.Setup.tokensProvider => {
  getInitialState: () => Monaco.Setup.makeState(),
  tokenize: (line, state) => {
    let tokens: array<Monaco.Setup.token> = [{startIndex: 0, scopes: "rainbow0"}]
    let col = ref(0)
    let inQuotes = ref(false)
    for i in 0 to line->String.length - 1 {
      let c = line->String.charAt(i)
      if c == "\"" {
        inQuotes := !inQuotes.contents
      } else if c == "," && !inQuotes.contents {
        tokens->Array.push({startIndex: i, scopes: "delimiter"})
        col := mod(col.contents + 1, n)
        tokens->Array.push({startIndex: i + 1, scopes: `rainbow${col.contents->Int.toString}`})
      }
    }
    {tokens, endState: state}
  },
}

let rainbowRules = (palette: array<string>, delimiter: string) => {
  let rules = palette->Array.mapWithIndex((color, i) => {
    {"token": `rainbow${i->Int.toString}`, "foreground": color}
  })
  rules->Array.push({"token": "delimiter", "foreground": delimiter})
  rules
}

let lightThemeData = {
  "base": "vs",
  "inherit": true,
  "rules": rainbowRules(
    ["2563EB", "16A34A", "9333EA", "EA580C", "0891B2", "DB2777", "CA8A04"],
    "CBD5E1",
  ),
  "colors": (Js.Dict.empty(): Js.Dict.t<string>),
}

let darkThemeData = {
  "base": "vs-dark",
  "inherit": true,
  "rules": rainbowRules(
    ["4FC1FF", "5BD68B", "C586C0", "FFAA5C", "56D4DD", "FF80BF", "E5C07B"],
    "5A5A5A",
  ),
  "colors": (Js.Dict.empty(): Js.Dict.t<string>),
}

let reconRegistered = ref(false)
let setupMonaco = (m: Monaco.Setup.t) =>
  if !reconRegistered.contents {
    reconRegistered := true
    m.languages->Monaco.Setup.register({"id": reconLanguageId})
    m.languages->Monaco.Setup.setTokensProvider(reconLanguageId, rainbowProvider(rainbowColumns))
    m.editor->Monaco.Setup.defineTheme(reconLightTheme, lightThemeData)
    m.editor->Monaco.Setup.defineTheme(reconDarkTheme, darkThemeData)
  }

let themeOptions = [(reconLightTheme, "Light"), (reconDarkTheme, "Dark")]

// Monaco decoration shapes (deltaDecorations is bound generically).
type decoRange = {
  startLineNumber: int,
  startColumn: int,
  endLineNumber: int,
  endColumn: int,
}
type hoverMsg = {value: string}
type overviewRuler = {color: string, position: int}
type decoOptions = {
  isWholeLine: bool,
  className?: string,
  glyphMarginClassName?: string,
  hoverMessage?: hoverMsg,
  overviewRuler?: overviewRuler,
}
type decoration = {
  range: decoRange,
  options: decoOptions,
}

// Gutter glyphs for Monaco's glyph margin. The bulb (error) / warning (skip)
// icons are defined as a Tailwind plugin in tailwind.config.js (reliable,
// always generated — no class-scanning fragility).
let errorGlyphClass = "recon-glyph-error"
let skipGlyphClass = "recon-glyph-skip"

// Transformation selector — same wrapper pattern as the detail page's FilterSelect.
module TxSelect = {
  @react.component
  let make = (~value: string, ~options: array<(string, string)>, ~onChange: string => unit) => {
    let selectOptions = options->Array.map(((v, l)) => {SelectBox.label: l, value: v})
    let input = ReactFinalForm.makeInputRecord(value->JSON.Encode.string, ev => {
      let v = ev->Identity.genericTypeToJson->getStringFromJson(value)
      onChange(v)
    })
    <SelectBoxAdapter
      input options=selectOptions allowMultiSelect=false isDropDown=true deselectDisable=true
    />
  }
}

@react.component
let make = (
  ~historyItem: option<ingestionHistoryType>,
  ~transformations: array<transformationHistoryType>,
  ~txConfigs: Dict.t<JSON.t>,
  ~onClose: unit => unit,
  ~onDownload: unit => unit,
) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()
  let {xFeatureRoute, forceCookies} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (viewerState, setViewerState) = React.useState(_ => Loading)
  let (rawText, setRawText) = React.useState(_ => "")
  let (editorReady, setEditorReady) = React.useState(_ => false)
  let (selectedTheme, setSelectedTheme) = React.useState(_ => reconLightTheme)
  let editorRef = React.useRef(Nullable.null)
  let decoIds = React.useRef([])

  let fileName = switch historyItem {
  | Some(h) => h.file_name
  | None => "file"
  }
  let fileId = switch historyItem {
  | Some(h) => h.id
  | None => ""
  }
  let nameParts = fileName->String.split(".")
  let ext = nameParts->Array.get(nameParts->Array.length - 1)->Option.getOr("")->String.toLowerCase
  let extLabel = ext == "" ? "TEXT" : ext->String.toUpperCase
  let isSpreadsheet = ext == "xlsx" || ext == "xls"
  // JSON/XML get Monaco's built-in coloring; everything else uses our CSV-ish language.
  let monacoLang = switch ext {
  | "json" => "json"
  | "xml" => "xml"
  | _ => reconLanguageId
  }

  let firstTxHistoryId = switch transformations->Array.get(0) {
  | Some(t) => t.transformation_history_id
  | None => ""
  }
  let (selectedTxHistoryId, setSelectedTxHistoryId) = React.useState(_ => firstTxHistoryId)

  let txOptions =
    transformations->Array.map(t => (t.transformation_history_id, t.transformation_name))
  let selectedTx =
    transformations->Array.find(t => t.transformation_history_id == selectedTxHistoryId)

  let fetchFile = async () => {
    try {
      setViewerState(_ => Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#DOWNLOAD_INGESTION_HISTORY_FILE,
        ~methodType=Get,
        ~id=Some(fileId),
      )
      let res = await fetchApi(url, ~method_=Get, ~xFeatureRoute, ~forceCookies)
      let text = if isSpreadsheet {
        let buf = await res->Fetch.Response.arrayBuffer
        Xlsx.firstSheetToCsv(buf)
      } else {
        await res->Fetch.Response.text
      }
      setRawText(_ => text)
      setViewerState(_ => Loaded)
    } catch {
    | _ => setViewerState(_ => Errored)
    }
  }

  React.useEffect0(() => {
    fetchFile()->ignore
    None
  })

  let rawLines = React.useMemo(() => {
    rawText->String.replaceRegExp(%re("/\r/g"), "")->String.split("\n")
  }, [rawText])
  let lineCount = rawLines->Array.length

  let fileStatus = React.useMemo(() => {
    switch selectedTx {
    | Some(tx) =>
      let config = txConfigs->Dict.get(tx.transformation_id)->Option.getOr(JSON.Encode.null)
      buildFileStatus(~rawLines, ~transformation=tx, ~config)
    | None => {
        lineMap: Map.make(),
        unlinkedErrors: [],
        transformedCount: 0,
        errorCount: 0,
        skippedCount: 0,
      }
    }
  }, (rawLines, selectedTxHistoryId))

  // No row background tints — only left-gutter glyphs: a stop sign on error
  // lines and a warning sign on skipped lines (plus a scrollbar mark for each).
  // Every line still exposes its outcome on hover; the range spans the line's
  // text so the hover fires anywhere on the line. Detail is rich markdown from
  // buildFileStatus. Transformed hover decorations are capped on huge files.
  let buildDecorations = () => {
    let decorateTransformed = lineCount <= 5000
    let decos: array<decoration> = []
    fileStatus.lineMap->Map.forEachWithKey((status, lineNo) => {
      let lineLen = rawLines->Array.get(lineNo - 1)->Option.getOr("")->String.length
      let range = {
        startLineNumber: lineNo,
        startColumn: 1,
        endLineNumber: lineNo,
        endColumn: lineLen + 1,
      }
      let hover = status.detail->Option.map(d => {value: d})
      switch status.severity {
      | Transformed =>
        if decorateTransformed {
          decos->Array.push({range, options: {isWholeLine: true, hoverMessage: ?hover}})->ignore
        }
      | Skipped =>
        decos
        ->Array.push({
          range,
          options: {
            isWholeLine: true,
            glyphMarginClassName: skipGlyphClass,
            hoverMessage: ?hover,
            overviewRuler: {color: "#f59e0b", position: 4},
          },
        })
        ->ignore
      | ErrorLine =>
        decos
        ->Array.push({
          range,
          options: {
            isWholeLine: true,
            glyphMarginClassName: errorGlyphClass,
            hoverMessage: ?hover,
            overviewRuler: {color: "#e5484d", position: 4},
          },
        })
        ->ignore
      | Header =>
        decos->Array.push({range, options: {isWholeLine: true, hoverMessage: ?hover}})->ignore
      | _ => ()
      }
    })
    decos
  }

  // Re-apply decorations whenever the editor is ready or the file/transformation changes.
  React.useEffect(() => {
    switch editorRef.current->Nullable.toOption {
    | Some(editor) =>
      let decos = buildDecorations()
      let newIds: array<string> =
        editor->Monaco.Editor.IStandaloneCodeEditor.deltaDecorations(decoIds.current, decos)
      decoIds.current = newIds
    | None => ()
    }
    None
  }, (editorReady, rawText, selectedTxHistoryId))

  let openFind = () =>
    switch editorRef.current->Nullable.toOption {
    | Some(editor) =>
      editor->Monaco.Editor.IStandaloneCodeEditor.focus
      editor->Monaco.Editor.IStandaloneCodeEditor.trigger(
        "keyboard",
        "actions.find",
        JSON.Encode.null,
      )
    | None => ()
    }

  // Sorted line numbers of issues (errors + skipped/warnings) for prev/next nav.
  let (issueIdx, setIssueIdx) = React.useState(_ => 0)
  let issues = React.useMemo(() => {
    let arr = []
    fileStatus.lineMap->Map.forEachWithKey((status, lineNo) =>
      switch status.severity {
      | ErrorLine | Skipped => arr->Array.push(lineNo)->ignore
      | _ => ()
      }
    )
    arr->Array.toSorted(Int.compare)
  }, (rawText, selectedTxHistoryId))

  let gotoIssue = dir => {
    let count = issues->Array.length
    if count > 0 {
      let next = mod(issueIdx + dir + count, count)
      setIssueIdx(_ => next)
      switch (issues->Array.get(next), editorRef.current->Nullable.toOption) {
      | (Some(ln), Some(editor)) =>
        editor->Monaco.Editor.IStandaloneCodeEditor.revealLineInCenter(ln)
        editor->Monaco.Editor.IStandaloneCodeEditor.setPosition({"lineNumber": ln, "column": 1})
        editor->Monaco.Editor.IStandaloneCodeEditor.focus
      | _ => ()
      }
    }
  }

  let iconBtn = (~icon, ~onClick, ~title) =>
    <button
      onClick={_ => onClick()}
      title
      className="p-2 rounded-lg hover:bg-nd_gray-100 text-nd_gray-500 transition-colors">
      <Icon name=icon size=16 />
    </button>

  let legendChip = (color, label, count) =>
    <div className="flex items-center gap-1.5">
      <span className={`w-2 h-2 rounded-full ${color}`} />
      <span className={`${body.sm.regular} text-nd_gray-600`}>
        {`${count->Int.toString} ${label}`->React.string}
      </span>
    </div>

  <div className="fixed inset-0 z-[60] bg-white flex flex-col">
    <div className="h-16 flex-shrink-0 border-b border-nd_gray-150 flex items-center gap-3 px-5">
      <div
        className="w-9 h-9 rounded-lg bg-nd_gray-100 flex items-center justify-center flex-shrink-0">
        <Icon name="nd-file" size=18 className="text-nd_gray-500" />
      </div>
      <div className="flex flex-col min-w-0">
        <span
          className={`${body.md.semibold} text-nd_gray-800 leading-tight truncate max-w-[320px]`}>
          {fileName->React.string}
        </span>
        <span className={`${body.sm.regular} text-nd_gray-400 leading-tight`}>
          {`${lineCount->Int.toString} lines · ${extLabel}`->React.string}
        </span>
      </div>
      <div className="w-px h-8 bg-nd_gray-150 mx-1" />
      <RenderIf condition={transformations->Array.length > 1}>
        <div className="flex items-center gap-2">
          <span className={`${body.sm.medium} text-nd_gray-400`}>
            {"Transformation"->React.string}
          </span>
          <div className="w-52">
            <TxSelect
              value=selectedTxHistoryId
              options=txOptions
              onChange={v => setSelectedTxHistoryId(_ => v)}
            />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={transformations->Array.length == 1}>
        <span
          className={`px-2.5 py-1 rounded-lg bg-nd_gray-100 ${body.sm.medium} text-nd_gray-600`}>
          {switch selectedTx {
          | Some(t) => t.transformation_name
          | None => ""
          }->React.string}
        </span>
      </RenderIf>
      <div className="flex-1" />
      <RenderIf condition={issues->Array.length > 0}>
        <div
          className="flex items-center gap-2 pl-2.5 pr-1 py-1 rounded-lg bg-nd_gray-50 border border-nd_gray-150">
          <span className={`${body.sm.regular} text-nd_gray-600`}>
            {`${fileStatus.errorCount->Int.toString} errors · ${fileStatus.skippedCount->Int.toString} skipped`->React.string}
          </span>
          <div className="flex items-center">
            <button
              onClick={_ => gotoIssue(-1)}
              title="Previous error / skipped line"
              className="p-0.5 rounded hover:bg-nd_gray-100 text-nd_gray-500">
              <Icon name="nd-angle-up" size=12 />
            </button>
            <button
              onClick={_ => gotoIssue(1)}
              title="Next error / skipped line"
              className="p-0.5 rounded hover:bg-nd_gray-100 text-nd_gray-500">
              <Icon name="nd-angle-down" size=12 />
            </button>
          </div>
        </div>
      </RenderIf>
      <div className="w-32">
        <TxSelect
          value=selectedTheme options=themeOptions onChange={v => setSelectedTheme(_ => v)}
        />
      </div>
      {iconBtn(~icon="nd-search", ~onClick=openFind, ~title="Find (Cmd/Ctrl + F)")}
      {iconBtn(~icon="nd-download-down", ~onClick=onDownload, ~title="Download file")}
      {iconBtn(~icon="nd-cross", ~onClick=onClose, ~title="Close")}
    </div>
    {switch viewerState {
    | Loading =>
      <div className="flex-1 flex items-center justify-center">
        <div
          className="w-7 h-7 border-2 border-nd_gray-200 border-t-nd_primary_blue-500 rounded-full animate-spin"
        />
      </div>
    | Errored =>
      <div className="flex-1 flex flex-col items-center justify-center gap-3">
        <Icon name="nd-alert-triangle" size=28 className="text-nd_red-400" />
        <p className={`${body.md.medium} text-nd_gray-700`}>
          {"Couldn't load this file."->React.string}
        </p>
        <Button
          text="Retry" buttonType=Secondary buttonSize=Small onClick={_ => fetchFile()->ignore}
        />
      </div>
    | Loaded =>
      <div className="flex-1 min-h-0">
        <React.Suspense
          fallback={<div className="h-full flex items-center justify-center">
            <div
              className="w-7 h-7 border-2 border-nd_gray-200 border-t-nd_primary_blue-500 rounded-full animate-spin"
            />
          </div>}>
          <MonacoEditor
            defaultLanguage=monacoLang
            value=rawText
            height="100%"
            theme=selectedTheme
            options={
              readOnly: true,
              glyphMargin: true,
              minimap: {enabled: true},
              scrollBeyondLastLine: false,
              automaticLayout: true,
              renderLineHighlight: "all",
              lineNumbersMinChars: 4,
              folding: false,
              contextmenu: false,
            }
            beforeMount=setupMonaco
            onMount={editor => {
              editorRef.current = Nullable.make(editor)
              setEditorReady(_ => true)
            }}
          />
        </React.Suspense>
      </div>
    }}
    <div
      className="h-9 flex-shrink-0 border-t border-nd_gray-150 bg-nd_gray-50 flex items-center gap-4 px-5">
      <span className={`${body.sm.regular} text-nd_gray-400`}> {extLabel->React.string} </span>
      <span className={`${body.sm.regular} text-nd_gray-400`}>
        {`${lineCount->Int.toString} lines`->React.string}
      </span>
      <div className="flex-1" />
      {legendChip("bg-nd_green-500", "transformed", fileStatus.transformedCount)}
      {legendChip("bg-nd_red-500", "error", fileStatus.errorCount)}
      {legendChip("bg-nd_orange-400", "skipped", fileStatus.skippedCount)}
      <RenderIf condition={fileStatus.unlinkedErrors->Array.length > 0}>
        <span className={`${body.sm.regular} text-nd_orange-600`}>
          {`${fileStatus.unlinkedErrors
            ->Array.length
            ->Int.toString} errors not tied to a line`->React.string}
        </span>
      </RenderIf>
    </div>
  </div>
}
