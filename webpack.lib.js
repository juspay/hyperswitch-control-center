const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const tailwindcss = require("tailwindcss");
const webpack = require("webpack");
const path = require("path");
const serverConfig = require("./webpack.server");
const config = import("./src/server/config.mjs");

let proxy = [
  {
    context: ["/api"],
    target: "http://localhost:8080",
    pathRewrite: { "^/api": "" },
    changeOrigin: true,
  },
];

let configMiddleware = (req, res, next) => {
  if (req.path.includes("/config/feature") && req.method == "GET") {
    let { domain = "default" } = req.query;
    config
      .then((result) => {
        result.configHandler(req, res, false, domain);
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

let libBuild = () => {
  const isDevelopment = process.env.NODE_ENV !== "production";
  let entryObj = {
    app: `./src/embeddable/EmbeddableEntry.res.js`,
  };
  return {
    mode: isDevelopment ? "development" : "production",
    entry: entryObj,
    output: {
      path: path.resolve(__dirname, "dist", "libapp"),
      clean: true,
      publicPath: "/",
      filename: "[name].js",
      // This ensures assets are properly resolved when the library is used in other projects
      assetModuleFilename: "assets/[name][ext][query]",
    },
    devServer: {
      port: 5000,
      hot: true,
      historyApiFallback: true,
      proxy: proxy,
      setupMiddlewares: (middlewares, devServer) => {
        devServer.app.use(configMiddleware);
        return middlewares;
      },
    },
    optimization: {
      minimize: !isDevelopment,
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            compress: {
              drop_console: !isDevelopment,
            },
          },
        }),
      ],
      splitChunks: true,
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
          type: "asset/resource",
          generator: {
            filename: "assets/fonts/[name][ext][query]",
          },
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin(),
      new CopyPlugin({
        patterns: [
          { from: "public/common" },
          // Copy hyperswitch files except index.html
          {
            from: `public/hyperswitch`,
            globOptions: {
              ignore: ["**/index.html"], // Don't copy hyperswitch index.html
            },
          },
          // Copy libapp index.html explicitly
          {
            from: "public/embeddable-app/index.html",
            to: "index.html",
          },
        ].filter(Boolean),
      }),
      isDevelopment && new ReactRefreshWebpackPlugin(),
    ].filter(Boolean),
  };
};

module.exports = (env, _argv) => {
  var webpackConfigs = [serverConfig];
  webpackConfigs.push(libBuild(env));
  console.log("Embeddable app webpack configs loaded");
  return webpackConfigs;
};
