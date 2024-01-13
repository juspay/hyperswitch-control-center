type promisifyable
type execResponse
type promiseableExecFile = (. string, array<string>) => Promise.t<execResponse>

module Util = {
  @module("util")
  external promisify: promisifyable => promiseableExecFile = "promisify"
}

module ChildProcess = {
  @module("child_process")
  external execFile: promisifyable = "execFile"
}

module Fs = {
  @module("fs")
  external readFileSync: (string, {..}) => string = "readFileSync"

  @module("fs")
  external writeFileSync: (string, string) => unit = "writeFileSync"
}

module Querystring = {
  type parsedUrlQUery = Js.Json.t

  @module("querystring")
  external parse: string => parsedUrlQUery = "parse"
}

module Http = {
  type url = {toString: (. unit) => string}

  external asUrl: string => url = "%identity"

  type on = (. string, unit => unit) => unit
  type read = (. unit) => Js.Nullable.t<string>
  type headers = Js.Dict.t<string>
  type server
  type request = {url: url, headers: headers, method: string, on: on, read: read}

  external makeHeader: {..} => headers = "%identity"

  type response = {
    writeHead: (. int, headers) => unit,
    write: (. string) => unit,
    end: (. unit) => unit,
  }

  type serverHandler = (request, response) => Promise.t<unit>

  @module("http")
  external createServer: serverHandler => server = "createServer"

  @send external listen: (server, int, unit => unit) => unit = "listen"
}
