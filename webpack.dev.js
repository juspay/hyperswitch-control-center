const path = require("path");
const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const config = import("./src/server/config.mjs");
const themeConfig = import("./src/server/theme.mjs");
const { responseInterceptor } = require("http-proxy-middleware");

const GRAFANA_PATH = "/api/observability-plane/grafana";
const SESSION_PATH = "/api/observability-plane/monitoring/grafana/session/";

function validateOrigins(target, localOrigin) {
  const remote = new URL(target);
  const local = new URL(localOrigin);
  if (
    remote.protocol !== "https:" ||
    remote.href !== remote.origin + "/" ||
    remote.username ||
    remote.password ||
    local.protocol !== "https:" ||
    !["localhost", "127.0.0.1", "[::1]"].includes(local.hostname) ||
    local.href !== local.origin + "/"
  ) {
    throw new Error(
      "Monitoring proxy requires an HTTPS upstream origin and an HTTPS loopback origin.",
    );
  }
  return { target: remote.origin, localOrigin: local.origin };
}

function rewriteEmbedUrl(embedUrl, target, localOrigin) {
  const url = new URL(embedUrl);
  if (
    url.origin !== target ||
    !url.pathname.startsWith(GRAFANA_PATH + "/") ||
    url.username ||
    url.password
  ) {
    throw new Error(
      "Monitoring destination is outside the configured gateway.",
    );
  }
  return localOrigin + url.pathname + url.search + url.hash;
}

function getMonitoringProxy(env = process.env) {
  if (!env.SANDBOX_MONITORING_ORIGIN) return [];
  const { target, localOrigin } = validateOrigins(
    env.SANDBOX_MONITORING_ORIGIN,
    env.MONITORING_LOCAL_ORIGIN || "https://localhost:9000",
  );
  const rewriteOrigin = (proxyReq) => {
    if (proxyReq.getHeader("origin") === localOrigin) {
      proxyReq.setHeader("origin", target);
    }
  };
  const common = {
    target,
    changeOrigin: true,
    secure: true,
    // Credentials are forwarded normally; never print headers or request bodies.
    logLevel: "silent",
    onProxyReq: rewriteOrigin,
    onProxyReqWs: rewriteOrigin,
  };
  return [
    {
      ...common,
      context: [SESSION_PATH],
      selfHandleResponse: true,
      onProxyRes: responseInterceptor(async (buffer, proxyRes, req, res) => {
        if (proxyRes.statusCode !== 200) return buffer;
        try {
          const body = JSON.parse(buffer.toString("utf8"));
          body.embed_url = rewriteEmbedUrl(body.embed_url, target, localOrigin);
          return JSON.stringify(body);
        } catch {
          res.statusCode = 502;
          res.removeHeader("set-cookie");
          return JSON.stringify({
            error: "Invalid monitoring gateway response",
          });
        }
      }),
    },
    {
      ...common,
      context: (pathname) =>
        pathname === GRAFANA_PATH || pathname.startsWith(GRAFANA_PATH + "/"),
      ws: true,
      onProxyRes(proxyRes) {
        // Local sandbox embedding needs the local parent permitted by Grafana's CSP.
        const csp = proxyRes.headers["content-security-policy"];
        if (typeof csp === "string") {
          proxyRes.headers["content-security-policy"] = csp
            .split(target)
            .join(localOrigin);
        }
      },
    },
  ];
}

let port = 9000;
// proxy is setup to make frontend and backend url same for local testing
let proxy = [
  ...getMonitoringProxy(),
  {
    context: ["/api/hyperswitch-recon-engine"],
    pathRewrite: { "^/api/hyperswitch-recon-engine": "" },
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/api/observability-plane/alerts-manager/ui"],
    pathRewrite: { "^/api": "" },
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/api"],
    target: "http://localhost:8080",
    pathRewrite: { "^/api": "" },
    changeOrigin: true,
  },
  {
    context: ["/themes"],
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/test-data/recon"],
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/test-data/analytics"],
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/dynamo-simulation-template"],
    target: "",
    changeOrigin: true,
  },
];

let configMiddleware = (req, res, next) => {
  if (req.path.includes("/config/feature") && req.method == "GET") {
    let { domain = "default" } = req.query;
    config
      .then((result) => {
        result.configHandler(req, res, false, domain);
      })
      .catch((error) => {
        console.log(error, "error");
        res.writeHead(500, { "Content-Type": "text/plain" });
        res.end("Internal Server Error");
      });
    return;
  }
  if (req.path.includes("/config/merchant") && req.method == "POST") {
    let { domain = "default" } = req.query;
    if (!domain || domain === "") {
      domain = "default"; // Fallback to default if no domain is provided
    }
    config
      .then((result) => {
        result.merchantConfigHandler(req, res, false, domain);
      })
      .catch((error) => {
        console.log(error, "error");
        res.writeHead(500, { "Content-Type": "text/plain" });
        res.end("Internal Server Error");
      });
    return;
  }

  if (req.path.includes("/config/theme") && req.method == "GET") {
    themeConfig
      .then((result) => {
        result.themeConfigHandler(req, res, false);
      })
      .catch((error) => {
        console.log(error, "error");
        res.writeHead(500, { "Content-Type": "text/plain" });
        res.end("Internal Server Error");
      });
    return;
  }

  next();
};

let devServer = {
  static: { directory: path.resolve(__dirname, "dist", "hyperswitch") },
  compress: true,
  hot: true,
  port: port,
  ...(process.env.SANDBOX_MONITORING_ORIGIN
    ? { host: "localhost", server: "https" }
    : {}),
  historyApiFallback: {
    rewrites: [{ from: /^\/dashboard/, to: "/index.html" }],
  },
  proxy: proxy,
  setupMiddlewares: (middlewares, devServer) => {
    devServer.app.use(configMiddleware);
    return middlewares;
  },
};

console.log(devServer);
module.exports = merge([
  common("hyperswitch"),
  { mode: "development", devServer: devServer },
]);
