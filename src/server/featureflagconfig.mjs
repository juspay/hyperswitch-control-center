import * as Fs from "fs";
import toml from "@iarna/toml";
// const { overrideConfigWithEnv } = import("./src/server/config.mjs");
import { overrideConfigWithEnv } from "./config.mjs";
const errorHandler = (res) => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  res.end("Internal Server Error");
};

const featureFlagConfigHandler = (
  _req,
  res,
  is_deployed = false,
  configPath = "dist/server/config/config.toml",
) => {
  let configFile = is_deployed ? configPath : "config/config.toml";
  try {
    Fs.readFile(configFile, { encoding: "utf8" }, (err, data) => {
      if (err) {
        console.error(err, "error error error");
        errorHandler(res);
        return;
      }
      let config;
      try {
        config = toml.parse(data);
      } catch (error) {
        console.log(error);
        errorHandler(res);
        return;
      }
      let merchantConfig = overrideConfigWithEnv(
        config["features"],
        "features",
      );
      res.writeHead(200, {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });
      res.write(JSON.stringify(merchantConfig));
      res.end();
    });
  } catch (error) {
    console.log(error);
    errorHandler(res);
  }
};

export { featureFlagConfigHandler };
