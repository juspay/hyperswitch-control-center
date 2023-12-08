const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const tailwindcss = require("tailwindcss");
const MonacoWebpackPlugin = require("monaco-editor-webpack-plugin");

module.exports = (appName = "hyperswitch", publicPath = "auto") => {
  const isDevelopment = process.env.NODE_ENV !== "production";
  let entryObj = {
    app: `./src/entryPoints/hyperswitch/HyperSwitchEntry.bs.js`,
  };
  return {
    entry: entryObj,
    output: {
      path: path.resolve(__dirname, "dist", appName),
      clean: true,
      publicPath: "/",
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
                  plugins: [
                    [
                      tailwindcss(
                        appName == "hyperswitch"
                          ? "./tailwindHyperSwitch.config.js"
                          : "./tailwindMain.config.js",
                      ),
                    ],
                  ],
                },
              },
            },
          ],
        },
        {
          test: /\.ttf$/,
          use: ["file-loader"],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin(),
      new CopyPlugin({
        patterns: [
          { from: "public/common" },
          { from: `public/${appName}` },
        ].filter(Boolean),
      }),
      new MonacoWebpackPlugin(),
      new webpack.DefinePlugin({
        dashboardAppName: JSON.stringify(appName),
        dashboardAppEnv: JSON.stringify(process.env.APP_ENV || "sandbox"),
        GIT_COMMIT_HASH: JSON.stringify(process.env.GIT_COMMIT_HASH || ""),
        appVersion: JSON.stringify(process.env.APP_VERSION || ""),
      }),
      isDevelopment && new ReactRefreshWebpackPlugin(),
    ].filter(Boolean),
  };
};
