@val @scope("process")
external env: Js.Dict.t<string> = "env"

let appName = env->Dict.get("appName")

let serverPath = "dist/hyperswitch"
let port = 9000

open NodeJs

@module("./config.mjs")
external configHandler: (Http.request, Http.response, bool, string) => unit = "configHandler"

module ServerHandler = {
  type rewrite = {source: string, destination: string}
  type header = {key: string, value: string}
  type headerType = {source: string, headers: array<header>}

  @obj external makeRewrite: (~source: string, ~destination: string) => rewrite = ""
  type options

  @obj
  external makeOptions: (
    ~public: string,
    ~rewrites: array<rewrite>,
    ~headers: array<headerType>,
    unit,
  ) => options = ""

  @module
  external handler: (Http.request, Http.response, options) => Promise.t<unit> = "serve-handler"
}

if appName === Some("hyperswitch") {
  let htmlInFs = Fs.readFileSync("dist/hyperswitch/index.html", {"encoding": "utf8"})

  Fs.writeFileSync("dist/hyperswitch/hyperswitch.html", htmlInFs)
}

type encodeType = {encoding: string}

@module("child_process")
external execSync: (string, encodeType) => string = "execSync"

@val external nullableGitCommitStr: option<string> = "GIT_COMMIT_HASH"

let currentCommitHash = nullableGitCommitStr->Belt.Option.getWithDefault("no-commit-hash")

let serverHandler: Http.serverHandler = (request, response) => {
  open Belt.Option
  let arr = request.url.toString(.)->String.split("?")
  let path =
    arr
    ->Belt.Array.get(0)
    ->getWithDefault("")
    ->String.replaceRegExp(%re("/^\/\//"), "/")
    ->String.replaceRegExp(%re("/^\/v4\//"), "/")

  if path === "/config/merchant-access" && request.method === "POST" {
    let path =
      env->Dict.get("configPath")->Belt.Option.getWithDefault("dist/server/config/FeatureFlag.json")
    Promise.make((resolve, _reject) => {
      configHandler(request, response, true, path)
      ()->resolve(. _)
    })
  } else {
    open ServerHandler

    let cache = if request.url.toString(.)->String.endsWith(".svg") {
      "max-age=3600, must-revalidate"
    } else {
      "no-cache"
    }

    let newRequest = {
      ...request,
      url: path->NodeJs.Http.asUrl,
    }
    let headers = [
      {
        key: "X-Deployment-Id",
        value: currentCommitHash,
      },
      {
        key: "Cache-Control",
        value: cache,
      },
      {
        key: "Access-Control-Allow-Origin",
        value: "*",
      },
      {
        key: "Access-Control-Allow-Headers",
        value: "*",
      },
      {
        key: "ETag",
        value: `"${currentCommitHash}"`,
      },
    ]

    handler(
      newRequest,
      response,
      makeOptions(
        ~public=serverPath,
        ~headers=[
          {
            source: "**",
            headers,
          },
        ],
        ~rewrites=[makeRewrite(~source="**", ~destination="/index.html")],
        (),
      ),
    )
  }
}
let serverHandlerWrapper = (req, res) => {
  try {serverHandler(req, res)} catch {
  | err => {
      let err =
        err
        ->Js.Exn.asJsExn
        ->Belt.Option.flatMap(Js.Exn.message)
        ->Belt.Option.getWithDefault("Error Found")
      res.writeHead(. 200, Http.makeHeader({"Content-Type": "text/plain"}))
      `Error : ${err}`->res.write(. _)
      res.end(.)
      Promise.resolve()
    }
  }
}
let server = Http.createServer(serverHandlerWrapper)

server->Http.listen(port, () => {
  let portStr = Belt.Int.toString(port)
  Js.log(`Running at http://localhost:${portStr}/`)
})
