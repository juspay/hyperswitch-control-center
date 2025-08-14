const path = require("path");
const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const config = import("./src/server/config.mjs");

let port = 9000;
// proxy is setup to make frontend and backend url same for local testing
let proxy = [
  {
    context: ["/api/hyperswitch-recon-engine"],
    pathRewrite: { "^/api/hyperswitch-recon-engine": "" },
    target: "",
    changeOrigin: true,
  },
  {
    context: ["/api"],
    target: "https://integ.hyperswitch.io/api",
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

  next();
};

let devServer = {
  static: { directory: path.resolve(__dirname, "dist", "hyperswitch") },
  compress: true,
  hot: true,
  port: port,
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
