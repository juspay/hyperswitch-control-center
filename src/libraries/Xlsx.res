// Minimal SheetJS (xlsx) binding — used to turn a binary spreadsheet
// (.xlsx / .xls) into CSV text so it can be viewed line-by-line.
type workbook
type worksheet

type readOpts = {@as("type") type_: string}
type csvOpts = {
  blankrows: bool,
  @as("FS") fs: string,
}

@new external uint8FromBuffer: Fetch.arrayBuffer => Js.TypedArray2.Uint8Array.t = "Uint8Array"
@module("xlsx") external read: (Js.TypedArray2.Uint8Array.t, readOpts) => workbook = "read"
@get external sheetNames: workbook => array<string> = "SheetNames"
@get external sheets: workbook => Dict.t<worksheet> = "Sheets"
@module("xlsx") @scope("utils")
external sheetToCsv: (worksheet, csvOpts) => string = "sheet_to_csv"

// Parse the first sheet of a spreadsheet buffer into CSV text.
// `blankrows: true` keeps empty rows so 1-indexed line numbers stay aligned
// with the original sheet rows (matching backend "Line N" references).
let firstSheetToCsv = (buf: Fetch.arrayBuffer): string => {
  let wb = read(buf->uint8FromBuffer, {type_: "array"})
  switch wb->sheetNames->Array.get(0) {
  | Some(name) =>
    switch wb->sheets->Dict.get(name) {
    | Some(ws) => sheetToCsv(ws, {blankrows: true, fs: ","})
    | None => ""
    }
  | None => ""
  }
}
