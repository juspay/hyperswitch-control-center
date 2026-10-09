@module("papaparse")
external unparse: {"fields": array<string>, "data": array<array<string>>} => string = "unparse"

type parseResult = {data: array<array<string>>}

@module("papaparse")
external parse: (string, {"skipEmptyLines": bool}) => parseResult = "parse"
