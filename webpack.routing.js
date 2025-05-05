const path = require("path");
const webpack = require("webpack");
const common = require("./webpack.routingcommon.js");
const { merge } = require("webpack-merge");
const config = import("./src/server/config.mjs");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const tailwindcss = require("tailwindcss");
const MonacoWebpackPlugin = require("monaco-editor-webpack-plugin");

let port = 9000;
// proxy is setup to make frontend and backend url same for local testing
let proxy = {
  "/api": {
    target: "http://localhost:8080",
    pathRewrite: { "^/api": "" },
    changeOrigin: true,
  },
  "/themes": {
    target: "",
    changeOrigin: true,
  },
  "/test-data/recon": {
    target: "",
    changeOrigin: true,
  },
};

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
  static: {
    directory: path.resolve(__dirname, "dist", "hyperswitch"),
  },
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
  common(),
  {
    mode: "development",
    devServer: devServer,
  },
]);
