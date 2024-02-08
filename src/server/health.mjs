import * as Fs from "fs";

// import fetch from "node-fetch";
const request = require("request");

const https = require("https");
const http = require("http");

const errorHandler = (res, result) => {
  res.writeHead(500, { "Content-Type": "application/json" });
  res.write(JSON.stringify(result));
  res.end();
};

let doProxy = () => {
  return new Promise((resolve, reject) => {
    let configFile = "dist/hyperswitch/env-config.js";
    let envString = Fs.readFileSync(configFile, { encoding: "utf8" });
    console.log(envString, "envString");
    const match = envString.match(/apiBaseUrl:\s*"([^"]*)"/);
    // Check if match is found and extract the value
    const apiBaseUrl = match ? match[1] : null;

    const matchrouterProxyUrl = envString.match(/routerProxyUrl:\s*"([^"]*)"/);
    // Check if match is found and extract the value
    const routerProxyUrl = matchrouterProxyUrl ? matchrouterProxyUrl[1] : null;

    const matchrouterProxyPort = envString.match(
      /routerProxyPort:\s*"([^"]*)"/,
    );
    // Check if match is found and extract the value
    const routerProxyPort = matchrouterProxyPort
      ? matchrouterProxyPort[1]
      : null;

    const proxyHost = routerProxyUrl;
    const proxyPort = routerProxyPort;
    http
      .request({
        host: proxyHost, // IP address of proxy server
        port: proxyPort, // port of proxy server
        method: "CONNECT",
        path: `${proxyHost}:${proxyPort}`,
      })
      .on("connect", (res, socket) => {
        if (res.statusCode === 200) {
          // connected to proxy server
          https.get(
            {
              host: apiBaseUrl,
              socket: socket, // using a tunnel
              agent: false, // cannot use a default agent
              path: "/health", // specify path to get from server
            },
            (res) => {
              let chunks = [];
              res.on("data", (chunk) => chunks.push(chunk));
              res.on("end", () => {
                console.log("DONE", Buffer.concat(chunks).toString("utf8"));
                resolve(Buffer.concat(chunks).toString("utf8"));
              });
            },
          );
        }
      })
      .on("error", (err) => {
        console.log(err);
        reject(err);
      })
      .end();
  });
};

let checkHealth = async (res) => {
  let output = {
    env_config: false,
    app_file: false,
    wasm_file: false,
    api_health: false,
  };
  try {
    let indexFile = "dist/hyperswitch/index.html";

    let data = Fs.readFileSync(indexFile, { encoding: "utf8" });
    if (data.includes(`<script src="/env-config.js"></script>`)) {
      output.env_config = true;
    }
    if (data.includes(`<div id="app"></div>`)) {
      output.app_file = true;
    }
    if (
      data.includes(`<script type="module" src="/wasm/euclid.js"></script>`)
    ) {
      output.wasm_file = true;
    }
    let res = await doProxy();

    let values = Object.values(output);
    if (values.includes(false)) {
      throw "Server Error";
    } else {
      res.writeHead(200, {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });
      res.write(JSON.stringify(output));
      res.end();
    }
  } catch (err) {
    console.log(err);
    errorHandler(res, output);
  }
};

const health = (_req, res) => {
  try {
    res.write("health is good");
    res.end();
  } catch (error) {
    console.log(error);
    errorHandler(res);
  }
};

const healthReadiness = async (_req, res) => {
  try {
    checkHealth(res);
  } catch (error) {
    errorHandler(res);
  }
};

export { healthReadiness, health };
