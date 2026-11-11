@module("papaparse")
external unparseWithConfig: (
  {"fields": array<string>, "data": array<array<string>>},
  {"escapeFormulae": RegExp.t},
) => string = "unparse"

let unparse = input =>
  unparseWithConfig(input, {"escapeFormulae": %re("/^(?![-+]?\d+(\.\d+)?$)[=+\-@\t\r]/")})

type parseResult = {data: array<array<string>>}

@module("papaparse")
external parse: (string, {"skipEmptyLines": bool}) => parseResult = "parse"
