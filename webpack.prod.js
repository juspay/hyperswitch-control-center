const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CompressionPlugin = require("compression-webpack-plugin");
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
      },
      plugins: [
        // Brotli compression for JS files
        new CompressionPlugin({
          filename: "[path][base].br",
          algorithm: "brotliCompress",
          test: /\.(js|jsx|ts|tsx)$/,
          compressionOptions: {
            level: 11,
          },
          threshold: 10240,
          minRatio: 0.8,
          deleteOriginalAssets: false,
        }),
        new CompressionPlugin({
          filename: "[path][base].br",
          algorithm: "brotliCompress",
          test: /\.(wasm)$/,
          compressionOptions: {
            level: 11,
          },
          threshold: 10240,
          minRatio: 0.8,
          deleteOriginalAssets: false,
        }),
        // Brotli compression for CSS files
        new CompressionPlugin({
          filename: "[path][base].br",
          algorithm: "brotliCompress",
          test: /\.css$/,
          compressionOptions: {
            level: 11,
          },
          threshold: 10240,
          minRatio: 0.8,
          deleteOriginalAssets: false,
        }),
      ],
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
