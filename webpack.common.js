const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const tailwindcss = require("tailwindcss");
const MonacoWebpackPlugin = require("monaco-editor-webpack-plugin");

module.exports = () => {
  const isDevelopment = process.env.NODE_ENV !== "production";
  let entryObj = {
    app: `./src/entryPoints/HyperSwitchEntry.res.js`,
  };
  return {
    entry: entryObj,
    output: {
      path: path.resolve(__dirname, "dist", "hyperswitch"),
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
        {
          test: /\.(woff|woff2|eot|ttf|otf)$/, // Fonts
          use: [
            {
              loader: "file-loader",
              options: {
                name: "fonts/[name].[ext]",
                outputPath: "assets/fonts/",
              },
            },
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin(),
      new CopyPlugin({
        patterns: [
          { from: "public/common" },
          // All the current assets needs to be moved to public directory
          { from: `public/hyperswitch/public` },
          //Remove ignore once the gifs are moved to public directory
          {
            from: `public/hyperswitch`,
            globOptions: {
              ignore: ["**/public/gifs/**"],
            },
          },
        ].filter(Boolean),
      }),
      new MonacoWebpackPlugin(),
      new webpack.DefinePlugin({
        dashboardAppEnv: JSON.stringify(process.env.APP_ENV || "sandbox"),
        GIT_COMMIT_HASH: JSON.stringify(process.env.GIT_COMMIT_HASH || ""),
        appVersion: JSON.stringify(process.env.APP_VERSION || ""),
      }),
      isDevelopment && new ReactRefreshWebpackPlugin(),
    ].filter(Boolean),
  };
};
