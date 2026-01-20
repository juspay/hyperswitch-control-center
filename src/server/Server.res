@val @scope("process")
external env: Dict.t<string> = "env"

let appName = Some("hyperswitch")

let port = 9000

open NodeJs

@module("./config.mjs")
external configHandler: (Http.request, Http.response, bool, string, string) => unit =
  "configHandler"

@module("./config.mjs")
external merchantConfigHandler: (Http.request, Http.response, bool, string, string) => unit =
  "merchantConfigHandler"

@module("./theme.mjs")
external themeConfigHandler: (Http.request, Http.response, bool, string) => unit =
  "themeConfigHandler"

@module("./health.mjs")
external healthHandler: (Http.request, Http.response) => unit = "healthHandler"

@module("./health.mjs")
external healthReadinessHandler: (Http.request, Http.response) => unit = "healthReadinessHandler"

@module("./brotli.mjs")
external serveBrotli: (
  ~request: Http.request,
  ~response: Http.response,
  ~filePath: string,
  ~servePath: string,
  ~xDeploymentId: string,
  ~eTag: string,
) => bool = "serveBrotli"

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
  ) => options = ""

  @module
  external handler: (Http.request, Http.response, options) => Promise.t<unit> = "serve-handler"
}

type encodeType = {encoding: string}

@module("child_process")
external execSync: (string, encodeType) => string = "execSync"

@val external nullableGitCommitStr: option<string> = "GIT_COMMIT_HASH"

let currentCommitHash = nullableGitCommitStr->Option.getOr("no-commit-hash")

let serverHandler: Http.serverHandler = (request, response) => {
  let arr = request.url.toString()->String.split("?")

  let domainFromQueryParam =
    arr
    ->Array.get(1)
    ->Option.getOr("domain=")
    ->Js.String2.split("=")
    ->Array.get(1)
    ->Option.getOr("")

  let xTenantId = request.headers->Dict.get("x-tenant-id")
  let domainFromXTenantId = switch xTenantId->Option.getOr("public") {
  | "public" => "default"
  | value => value
  }

  let domain = domainFromQueryParam == "" ? domainFromXTenantId : domainFromQueryParam

  let path =
    arr
    ->Array.get(0)
    ->Option.getOr("")
    ->String.replaceRegExp(%re("/^\/\//"), "/")
    ->String.replaceRegExp(%re("/^\/v4\//"), "/")

  let (serverPath, baseHtmlRoute) = if path->String.startsWith("/embedded") {
    ("dist", "embedded/index.html")
  } else {
    ("dist/hyperswitch", "index.html")
  }

  if path->String.includes("/config/merchant") && request.method === "POST" {
    let path = env->Dict.get("configPath")->Option.getOr("dist/server/config/config.toml")
    Promise.make((resolve, _reject) => {
      merchantConfigHandler(request, response, true, domain, path)
      ()->(resolve(_))
    })
  } else if path->String.includes("/config/feature") && request.method === "GET" {
    let path = env->Dict.get("configPath")->Option.getOr("dist/server/config/config.toml")
    Promise.make((resolve, _reject) => {
      configHandler(request, response, true, domain, path)
      ()->(resolve(_))
    })
  } else if path->String.includes("/config/theme") && request.method === "GET" {
    let path = env->Dict.get("themeConfigPath")->Option.getOr("dist/server/config/theme.json")
    Promise.make((resolve, _reject) => {
      themeConfigHandler(request, response, true, path)
      ()->(resolve(_))
    })
  } else if path === "/health" && request.method === "GET" {
    Promise.make((resolve, _reject) => {
      healthHandler(request, response)
      ()->(resolve(_))
    })
  } else if path === "/health/ready" && request.method === "GET" {
    Promise.make((resolve, _reject) => {
      healthReadinessHandler(request, response)
      ()->(resolve(_))
    })
  } else {
    // Try to serve Brotli-compressed version first
    let brotliServed = serveBrotli(
      ~request,
      ~response,
      ~filePath=path,
      ~servePath=serverPath,
      ~xDeploymentId=currentCommitHash,
      ~eTag=`"${currentCommitHash}"`,
    )

    if !brotliServed {
      // Fall back to regular serve-handler if Brotli not available or not supported
      open ServerHandler

      let cache = if request.url.toString()->String.endsWith(".svg") {
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
          ~rewrites=[makeRewrite(~source="**", ~destination=baseHtmlRoute)],
        ),
      )
    } else {
      Promise.resolve()
    }
  }
}
let serverHandlerWrapper = (req, res) => {
  try {serverHandler(req, res)} catch {
  | err => {
      let err =
        err->Exn.asJsExn->Option.flatMap(msg => msg->Exn.message)->Option.getOr("Error Found")
      res.writeHead(200, Http.makeHeader({"Content-Type": "text/plain"}))
      `Error : ${err}`->(res.write(_))
      res.end()
      Promise.resolve()
    }
  }
}
let server = Http.createServer(serverHandlerWrapper)

server->Http.listen(port, () => {
  let portStr = Int.toString(port)
  Js.log(`Running at http://localhost:${portStr}/`)
})
