const { merge } = require("webpack-merge");
const common = require("./webpack.common.js");
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CompressionPlugin = require("compression-webpack-plugin");
const serverConfig = require("./webpack.server");
const { execSync } = require("child_process");

process.env["NODE_ENV"] = "production";

var currentBranch = "hyperswitch";

/**
 * Creates compression plugins for both Brotli and Gzip
 * @param {RegExp} test - File pattern to match
 * @param {string} description - Description for logging
 * @returns {Array} Array of compression plugins
 */
const createCompressionPlugins = (test, description = "") => {
  const plugins = [];

  // Brotli compression (higher priority)
  plugins.push(
    new CompressionPlugin({
      filename: "[path][base].br",
      algorithm: "brotliCompress",
      test: test,
      compressionOptions: {
        level: 11,
      },
      threshold: 10240,
      minRatio: 0.8,
      deleteOriginalAssets: false,
    }),
  );

  // Gzip compression (fallback)
  plugins.push(
    new CompressionPlugin({
      filename: "[path][base].gz",
      algorithm: "gzip",
      test: test,
      compressionOptions: {
        level: 9,
      },
      threshold: 10240,
      minRatio: 0.8,
      deleteOriginalAssets: false,
    }),
  );

  return plugins;
};

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
        // Compression for JS/TS files (both Brotli and Gzip)
        ...createCompressionPlugins(/\.(js|jsx|ts|tsx)$/, "JS/TS files"),

        // Compression for WASM files (both Brotli and Gzip)
        ...createCompressionPlugins(/\.(wasm)$/, "WASM files"),

        // Compression for CSS files (both Brotli and Gzip)
        ...createCompressionPlugins(/\.css$/, "CSS files"),
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
