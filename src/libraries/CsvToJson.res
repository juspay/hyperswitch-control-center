type csvjson = {csv2json: (. string) => Js.Json.t}
type jsoncsv = {json2csv: (. Js.Json.t) => string}

@module @val external csvtojson: csvjson = "csvjson-csv2json"

@module @val external jsontocsv: jsoncsv = "csvjson-json2csv"

@module("csvjson-csv2json")
external csvToJsonWithSeparator: (string, {..}) => Js.Json.t = "csv2json"
