type parserInstance

@module("ua-parser-js") @new
external newUAParser: unit => parserInstance = "default"

@send
external setUAString: (parserInstance, string) => parserInstance = "setUA"

@send
external getBrowser: (parserInstance, unit) => Js.Json.t = "getBrowser"

@send
external getOS: (parserInstance, unit) => Js.Json.t = "getOS"
