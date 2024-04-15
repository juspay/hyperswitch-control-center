import * as Fs from "fs";
import toml from "@iarna/toml";

// Function to read TOML file
function readConfigFromFile(filePath) {
  try {
    const data = fs.readFileSync(filePath, "utf8");
    return toml.parse(data);
  } catch (err) {
    console.error("Error reading TOML file:", err);
    return {};
  }
}

// Function to override config values from environment variables
function overrideConfigWithEnv(config) {
  for (let key in config) {
    if (process.env[key]) {
      config[key] = process.env[key];
    }
  }
  return config;
}
const errorHandler = (res) => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  res.end("Internal Server Error");
};

// Main function to read TOML file, override config, and output the result
const configHandler = (
  req,
  res,
  is_deployed = false,
  configPath = "dist/server/config/config.toml",
) => {
  let configFile = is_deployed ? configPath : "config/config.toml";

  try {
    let { domain = "default" } = req.query;
    Fs.readFile(configFile, { encoding: "utf8" }, (err, data) => {
      if (err) {
        console.error(err, "error error error");
        errorHandler(res);
        return;
      }
      let config;
      try {
        config = toml.parse(data);
      } catch {
        errorHandler(res);
        return;
      }

      let endPoints = config["endpoints"];
      let merchantConfig = config["default"];
      if (
        domain.length > 0 &&
        config[domain] != undefined &&
        Object.keys(config[domain]).length > 0
      ) {
        merchantConfig = config[domain];
      } else {
        merchantConfig;
      }
      res.writeHead(200, {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });
      res.write(JSON.stringify(Object.assign(merchantConfig, endPoints)));
      res.end();
    });
  } catch (error) {
    console.log(error);
    errorHandler(res);
  }
};

export { configHandler };
