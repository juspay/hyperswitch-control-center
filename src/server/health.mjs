import * as Fs from "fs";
import fetch from "node-fetch";
const errorHandler = (res, result) => {
  res.writeHead(500, { "Content-Type": "application/json" });
  res.write(JSON.stringify(result));
  res.end();
};

let checkHealth = async (res) => {
  let output = {
    env_config: false,
    app_file: false,
    wasm_file: false,
    api_check: false,
  };
  try {
    let indexFile = "dist/hyperswitch/index.html";
    let envFile = "dist/hyperswitch/env-config.js";

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

    let envString = Fs.readFileSync(envFile, { encoding: "utf8" });
    const match = envString.match(/apiBaseUrl:\s*"([^"]*)"/);

    // Check if match is found and extract the value
    const apiBaseUrl = match ? match[1] : null;

    let api = await fetch(`${apiBaseUrl}/health`);
    if (api && api.ok) {
      output.api_check = true;
    }
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

const healthHandler = (_req, res) => {
  try {
    checkHealth(res);
  } catch (error) {
    console.log(error);
    errorHandler(res);
  }
};

export { healthHandler };
