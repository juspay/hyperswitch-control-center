const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const tailwindcss = require("tailwindcss");
const webpack = require("webpack");
const path = require("path");
const serverConfig = require("./webpack.server");
const config = import("./src/server/config.mjs");
const appName = process.env.APP_NAME || "hyperswitch";

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

let assetRewriteMiddleware = (req, res, next) => {
  // Rewrite URLs for static assets - add /embedded/ prefix
  // This allows shared code to reference assets without /embedded/ prefix
  if (
    req.path.match(/\.\w+$/) &&
    !req.path.startsWith("/embedded") &&
    !req.path.startsWith("/api")
  ) {
    req.url = "/embedded" + req.path;
  }
  next();
};

let libBuild = () => {
  const isDevelopment = process.env.NODE_ENV !== "production";
  const checkCoverage = process.env.CHECK_COVERAGE === "true";

  let entryObj = {
    app: `./src/embeddable/EmbeddableEntry.res.js`,
  };
  return {
    mode: isDevelopment ? "development" : "production",
    entry: entryObj,
    output: {
      path: path.resolve(__dirname, "dist", "embedded"),
      clean: true,
      publicPath: "/embedded/",
      filename: "[name].js",
      // Library output configuration for npm publication
      library: {
        name: "HyperswitchCC",
        type: "umd",
        umdNamedDefine: true,
        export: "named",
      },
      // This ensures assets are properly resolved when the library is used in other projects
      assetModuleFilename: "assets/[name][ext][query]",
    },
    devServer: {
      static: { directory: path.resolve(__dirname, "dist", "embedded") },
      port: 9000,
      hot: true,
      historyApiFallback: {
        rewrites: [{ from: /^\/embedded/, to: "/embedded/index.html" }],
      },
      proxy: proxy,
      setupMiddlewares: (middlewares, devServer) => {
        devServer.app.use(configMiddleware);
        devServer.app.use(assetRewriteMiddleware);
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
        ...(checkCoverage
          ? [
              {
                test: /\.js$/,
                use: {
                  loader: "@jsdevtools/coverage-istanbul-loader",
                  options: { esModules: true },
                },
                enforce: "post",
                exclude: /node_modules|\.spec\.js$/,
              },
            ]
          : []),
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
          // Copy hyperswitch files to root (not embedded subfolder)
          {
            from: "public/hyperswitch",
            to: ".",
            globOptions: {
              ignore: ["**/index.html"],
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
