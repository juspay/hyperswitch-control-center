const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const serverConfig = require("./webpack.server");
const { execSync } = require("child_process");

process.env["NODE_ENV"] = "production";

var currentBranch = "hyperswitch";

const mergeProd = (dashboardAppName, env) => {
  console.log("Building", dashboardAppName);
  const publicPath = "auto";
  let isProduction = process.env["APP_ENV"] === "production";
  return merge([
    common(dashboardAppName, publicPath),
    {
      mode: "production",
      output: {
        publicPath,
      },
      optimization: {
        minimize: true,
        minimizer: [
          new TerserPlugin({
            terserOptions: {
              compress: {
                drop_console: true,
              },
            },
          }),
          // For webpack@5 you can use the `...` syntax to extend existing minimizers (i.e. `terser-webpack-plugin`), uncomment the next line
          // `...`,
          // new CssMinimizerPlugin(),
        ],
      },
    },
  ]);
};

module.exports = (env, _argv) => {
  var webpackConfigs = [serverConfig];

  console.log("currentBranch", currentBranch);

  if (currentBranch.search(/hyperswitch/) != -1) {
    webpackConfigs.push(mergeProd("hyperswitch", env));
  }

  console.log("webpackConfigs", webpackConfigs);

  return webpackConfigs;
};
