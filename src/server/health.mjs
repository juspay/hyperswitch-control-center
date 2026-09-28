import * as Fs from "fs";
import toml from "@iarna/toml";
import { updateConfigWithEnv } from "./config.mjs";

const errorHandler = (res, result = { error: "something went wrong" }) => {
  res.writeHead(500, { "Content-Type": "application/json" });
  res.write(JSON.stringify(result));
  res.end();
};

const checkHealth = (res, configFilePath, indexFilePath) => {
  const output = {
    env_config: false,
    app_file: false,
    wasm_file: false,
  };

  try {
    const config = toml.parse(
      Fs.readFileSync(configFilePath, { encoding: "utf8" }),
    );
    // Parsing is not enough: without an API endpoint the dashboard has no backend to call.
    // Resolve env overrides the same way configHandler does so this checks
    // the api_url the client will actually receive rather than the raw TOML value.
    const merchantConfig = updateConfigWithEnv(
      config.default ?? {},
      "default",
      "",
    );
    output.env_config = Boolean(merchantConfig?.endpoints?.api_url);
  } catch (err) {
    console.error(`health: unable to read config at ${configFilePath}`, err);
  }

  try {
    const data = Fs.readFileSync(indexFilePath, { encoding: "utf8" });
    output.app_file = data.includes(`<div id="app"></div>`);
    // hyperswitch emits an absolute src ("/wasm/..."), embedded a relative
    // one ("wasm/..."), accept either.
    output.wasm_file = /src="\/?wasm\/euclid\.js"/.test(data);
  } catch (err) {
    console.error(`health: unable to read index at ${indexFilePath}`, err);
  }

  if (Object.values(output).includes(false)) {
    console.error("health: readiness check failed", output);
    errorHandler(res, output);
    return;
  }

  res.writeHead(200, {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
  });
  res.write(JSON.stringify(output));
  res.end();
};

const healthHandler = (_req, res) => {
  try {
    res.write("health is good");
    res.end();
  } catch (error) {
    console.error(error);
    errorHandler(res);
  }
};

const healthReadinessHandler = (_req, res, configFilePath, indexFilePath) => {
  try {
    checkHealth(res, configFilePath, indexFilePath);
  } catch (error) {
    console.error(error);
    errorHandler(res);
  }
};

export { healthHandler, healthReadinessHandler };
