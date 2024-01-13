const path = require("path");
const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const configScripts = import("./src/server/config.mjs");

const appName = process.env.appName;
const integ = process.env.integ;

let port = 9000;
let proxy = {};

let configMiddleware = (req, res, next) => {
  if (req.path == "/config/merchant-access" && req.method == "POST") {
    configScripts
      .then((result) => {
        result.configHandler(req, res, false);
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
    directory: path.resolve(__dirname, "dist", appName),
  },
  compress: true,
  hot: true,
  port: port,
  historyApiFallback: true,
  proxy: proxy,
  onBeforeSetupMiddleware: (devServer) => {
    devServer.app.use(configMiddleware);
  },
};

console.log(devServer);
module.exports = merge([
  common(appName),
  {
    mode: "development",
    devServer: devServer,
  },
]);
