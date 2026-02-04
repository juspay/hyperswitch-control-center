const path = require("path");
const ReactRefreshWebpackPlugin = require("@pmmmwh/react-refresh-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");
const CompressionPlugin = require("compression-webpack-plugin");
const tailwindcss = require("tailwindcss");
const serverConfig = require("./webpack.server");
const config = import("./src/server/config.mjs");

const DEV_SERVER_PORT = 9000;

const createCompressionPlugins = (test) => [
  new CompressionPlugin({
    filename: "[path][base].br",
    algorithm: "brotliCompress",
    test,
    compressionOptions: { level: 11 },
    threshold: 10240,
    minRatio: 0.8,
    deleteOriginalAssets: false,
  }),
  new CompressionPlugin({
    filename: "[path][base].gz",
    algorithm: "gzip",
    test,
    compressionOptions: { level: 9 },
    threshold: 10240,
    minRatio: 0.8,
    deleteOriginalAssets: false,
  }),
];

const proxyConfig = [
  {
    context: ["/api"],
    target: "http://localhost:8080",
    pathRewrite: { "^/api": "" },
    changeOrigin: true,
  },
];

const configMiddleware = (req, res, next) => {
  if (req.path.includes("/config/feature") && req.method === "GET") {
    const { domain = "default" } = req.query;
    config
      .then((result) => {
        result.configHandler(req, res, false, domain);
      })
      .catch((error) => {
        console.error("Config middleware error:", error);
        res.writeHead(500, { "Content-Type": "text/plain" });
        res.end("Internal Server Error");
      });
    return;
  }
  next();
};

const assetRewriteMiddleware = (req, _res, next) => {
  if (
    req.path.match(/\.\w+$/) &&
    !req.path.startsWith("/embedded") &&
    !req.path.startsWith("/api")
  ) {
    req.url = "/embedded" + req.path;
  }
  next();
};

const setupMiddlewares = (middlewares, devServer) => {
  devServer.app.use(configMiddleware);
  devServer.app.use(assetRewriteMiddleware);
  return middlewares;
};

const getModuleRules = () => {
  const checkCoverage = process.env.CHECK_COVERAGE === "true";

  const rules = [
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
      test: /\.(woff|woff2|eot|ttf|otf)$/,
      type: "asset/resource",
      generator: {
        filename: "assets/fonts/[name][ext][query]",
      },
    },
  ];

  if (checkCoverage) {
    rules.push({
      test: /\.js$/,
      use: {
        loader: "@jsdevtools/coverage-istanbul-loader",
        options: { esModules: true },
      },
      enforce: "post",
      exclude: /node_modules|\.spec\.js$/,
    });
  }

  return rules;
};

const getCopyPatterns = (isDevelopment) => [
  { from: "public/common" },
  {
    from: "public/hyperswitch",
    to: ".",
    globOptions: {
      ignore: ["**/index.html", ...(isDevelopment ? [] : ["**/assets/**"])],
    },
  },
  {
    from: "public/embeddable-app/index.html",
    to: "index.html",
  },
];
lae;
const getPlugins = (isDevelopment) => {
  const plugins = [
    new MiniCssExtractPlugin(),
    new CopyPlugin({
      patterns: getCopyPatterns(isDevelopment),
    }),
  ];

  if (isDevelopment) {
    plugins.push(new ReactRefreshWebpackPlugin());
  }

  if (!isDevelopment) {
    plugins.push(...createCompressionPlugins(/\.(js|jsx|ts|tsx)$/));
    plugins.push(...createCompressionPlugins(/\.(wasm)$/));
    plugins.push(...createCompressionPlugins(/\.css$/));
  }

  return plugins;
};

const libBuild = () => {
  const isDevelopment = process.env.NODE_ENV !== "production";

  let entryObj = {
    app: `./src/embeddable/EmbeddableEntry.res.js`,
  };
  return {
    mode: isDevelopment ? "development" : "production",
    entry: {
      app: "./src/embeddable/EmbeddableEntry.res.js",
    },

    output: {
      path: path.resolve(__dirname, "dist", "embedded"),
      clean: true,
      publicPath: "/embedded/",
      filename: "[name].js",
      library: {
        name: "HyperswitchCC",
        type: "umd",
        umdNamedDefine: true,
        export: "named",
      },
      assetModuleFilename: "assets/[name][ext][query]",
    },
    devServer: {
      static: { directory: path.resolve(__dirname, "dist", "embedded") },
      port: DEV_SERVER_PORT,
      hot: true,
      historyApiFallback: {
        rewrites: [{ from: /^\/embedded/, to: "/embedded/index.html" }],
      },
      proxy: proxyConfig,
      setupMiddlewares,
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
      rules: getModuleRules(),
    },

    plugins: getPlugins(isDevelopment),
  };
};

module.exports = (env, _argv) => {
  const webpackConfigs = [serverConfig, libBuild(env)];
  console.log("Embeddable app webpack configs loaded");
  return webpackConfigs;
};
