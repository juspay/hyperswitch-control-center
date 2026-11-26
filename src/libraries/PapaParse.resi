let unparse: {"fields": array<string>, "data": array<array<string>>} => string

type parseResult = {data: array<array<string>>}

let parse: (string, {"skipEmptyLines": bool}) => parseResult
