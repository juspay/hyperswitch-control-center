type csvjson = {csv2json: (. string) => JSON.t}
type jsoncsv = {json2csv: (. JSON.t) => string}

@module @val external csvtojson: csvjson = "csvjson-csv2json"

@module @val external jsontocsv: jsoncsv = "csvjson-json2csv"

@module("csvjson-csv2json")
external csvToJsonWithSeparator: (string, {..}) => JSON.t = "csv2json"
