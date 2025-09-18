const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const tailwindcss = require("tailwindcss");
const webpack = require("webpack");
const path = require("path");
const serverConfig = require("./webpack.server");
let customBuild = () => {
  const isDevelopment = process.env.NODE_ENV !== "production";
  let entryObj = {
    app: `./src/entry-points/HyperSwitchEntry.res.js`,
  };
  return {
    mode: "production",
    entry: entryObj,
    output: {
      path: path.resolve(__dirname, "dist", "hyperswitch"),
      clean: true,
      publicPath: "/",
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
      ],
    },
    module: {
      rules: [
        {
          test: /\.css$/i,
          use: [
            MiniCssExtractPlugin.loader,
            "css-loader",
            {
              loader: "postcss-loader",
              options: {
                postcssOptions: {
                  plugins: [[tailwindcss("./tailwind.config.js")]],
                },
              },
            },
          ],
        },
        {
          test: /\.ttf$/,
          use: ["file-loader"],
        },
        {
          test: /\.js$/,
          use: {
            loader: "@jsdevtools/coverage-istanbul-loader",
            options: { esModules: true },
          },
          enforce: "post",
          exclude: /node_modules|\.spec\.js$/,
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin(),
      new CopyPlugin({
        patterns: [
          { from: `public/hyperswitch/index.html` },
          { from: `public/hyperswitch/module.js` },
        ].filter(Boolean),
      }),
      new webpack.DefinePlugin({
        dashboardAppEnv: JSON.stringify(process.env.APP_ENV || "sandbox"),
        GIT_COMMIT_HASH: JSON.stringify(process.env.GIT_COMMIT_HASH || ""),
        appVersion: JSON.stringify(process.env.APP_VERSION || ""),
      }),
      isDevelopment && new ReactRefreshWebpackPlugin(),
    ].filter(Boolean),
  };
};

module.exports = (env, _argv) => {
  var webpackConfigs = [serverConfig];
  webpackConfigs.push(customBuild("hyperswitch", env));
  console.log("webpackConfigs", webpackConfigs);
  return webpackConfigs;
};
