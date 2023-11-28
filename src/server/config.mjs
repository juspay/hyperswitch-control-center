import { error } from "console";
import * as Fs from "fs";
import fetch from "node-fetch";

const errorHandler = (res) => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  res.end("Internal Server Error");
};

const configHandler = (
  _req,
  res,
  is_deployed = false,
  configPath = "dist/server/config/FeatureFlag.json",
) => {
  let configFile = is_deployed ? configPath : "config/FeatureFlag.json";

  try {
    Fs.readFile(configFile, { encoding: "utf8" }, (err, data) => {
      if (err) {
        console.error(err, "error error error");
        errorHandler(res);
        return;
      }
      let merchantAccess = JSON.parse(data);
      res.writeHead(200, {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });
      res.write(JSON.stringify(merchantAccess));
      res.end();
    });
  } catch (error) {
    console.log(error);
    errorHandler(res);
  }
};

export { configHandler };
