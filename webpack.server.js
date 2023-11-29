const path = require("path");
const webpack = require("webpack");
const { execSync } = require("child_process");
const CopyWebpackPlugin = require("copy-webpack-plugin");
var currentCommitHash = execSync("git rev-parse HEAD", {
  encoding: "utf-8",
}).trim();

module.exports = {
  mode: "development",
  entry: {
    server: "./src/server/Server.bs.js",
  },
  output: {
    filename: `server.js`,
    path: path.resolve(__dirname, "dist/server"),
    clean: true,
    publicPath: "/",
  },
  target: "node",
  plugins: [
    new webpack.DefinePlugin({
      GIT_COMMIT_HASH: JSON.stringify(currentCommitHash),
      IS_SCOPING_MODULE_ACTIVE: JSON.stringify(
        process.env.IS_SCOPING_MODULE_ACTIVE || "true",
      ),
    }),
    new CopyWebpackPlugin({
      patterns: [{ from: "config", to: "config" }],
    }),
  ],
};
