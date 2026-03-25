const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const serverConfig = require("./webpack.server");
const { execSync } = require("child_process");

process.env["NODE_ENV"] = "production";

var currentBranch = "hyperswitch";

const mergeProd = () => {
  console.log("Building hyperswitch");
  const publicPath = "auto";
  let isProduction = process.env["APP_ENV"] === "production";
  return merge([
    common(),
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
        splitChunks: {
          chunks: "all",
          cacheGroups: {
            monaco: {
              test: /[\\/]node_modules[\\/](@monaco-editor|monaco-editor)[\\/]/,
              name: "monaco",
              chunks: "all",
              priority: 30,
              reuseExistingChunk: true,
            },
            charts: {
              test: /[\\/]node_modules[\\/]highcharts[\\/]/,
              name: "charts",
              chunks: "all",
              priority: 20,
              reuseExistingChunk: true,
            },
            vendors: {
              test: /[\\/]node_modules[\\/]/,
              name: "vendors",
              chunks: "all",
              priority: 10,
              reuseExistingChunk: true,
            },
          },
        },
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
