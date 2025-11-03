type parseConfig

type rec parseResult<'data> = {
  data: 'data,
  errors: array<parseError>,
  meta: parseMeta,
}

and parseError = {
  @as("type")
  type_: string,
  code: string,
  message: string,
  row: option<int>,
}

and parseMeta = {
  delimiter: string,
  linebreak: string,
  aborted: bool,
  truncated: bool,
  cursor: int,
}

@module("papaparse")
external parse: (string, 'config) => parseResult<array<array<string>>> = "parse"

@module("papaparse")
external parseWithHeaders: (string, 'config) => parseResult<array<Dict.t<string>>> = "parse"

@obj
external makeConfig: (
  ~delimiter: string=?,
  ~newline: string=?,
  ~header: bool=?,
  ~skipEmptyLines: bool=?,
  ~dynamicTyping: bool=?,
  ~transformHeader: string => string=?,
  unit,
) => parseConfig = ""

let parseToArrays = (csvText, ~config=makeConfig()) => {
  parse(csvText, config)
}

let parseWithHeadersToDict = (csvText, ~config=makeConfig(~header=true, ())) => {
  parseWithHeaders(csvText, config)
}
