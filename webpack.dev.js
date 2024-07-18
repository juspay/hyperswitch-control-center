const path = require("path");
const webpack = require("webpack");
const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");

const appName = process.env.appName || "defaultAppName";

let port = 9000;
let proxy = {};

const configMiddleware = async (req, res, next) => {
  if (req.path.includes("/config/merchant-config") && req.method === "GET") {
    try {
      const { configHandler } = await import("./src/server/config.mjs");
      const { domain = "default" } = req.query;
      configHandler(req, res, false, domain);
    } catch (error) {
      console.error("Error loading config.mjs:", error);
      res.writeHead(500, { "Content-Type": "text/plain" });
      res.end("Internal Server Error");
    }
    return;
  }
  next();
};

const devServer = {
  static: {
    directory: path.resolve(__dirname, "dist", appName),
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
  common(appName),
  {
    mode: "development",
    devServer: devServer,
  },
]);
