import * as Fs from "fs";
import toml from "@iarna/toml";

function updateConfigWithEnv(updatedConfig, domain = "", prefix = "") {
  for (const key in updatedConfig) {
    if (typeof updatedConfig[key] === "object" && updatedConfig[key] !== null) {
      updateConfigWithEnv(updatedConfig[key], domain, key); // Recursively update nested objects
    } else {
      // Check if environment variable exists for the key
      const envVar = process.env[`${domain}__${prefix}__${key}`];
      if (envVar !== undefined) {
        // Convert string to appropriate type if necessary (e.g., "true" to true)
        if (typeof updatedConfig[key] === "boolean") {
          updatedConfig[key] = envVar.toLowerCase() === "true";
        } else if (typeof updatedConfig[key] === "number") {
          updatedConfig[key] = parseFloat(envVar);
        } else {
          updatedConfig[key] = envVar;
        }
      }
    }
  }
  return updatedConfig;
}

const errorHandler = (res, errorMessage = "something went wrong") => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  console.log(errorMessage);
  res.end("Internal Server Error");
};

// Main function to read TOML file, override config, and output the result
const configHandler = (
  _req,
  res,
  is_deployed = false,
  domain = "default",
  configPath = "dist/server/config/config.toml",
) => {
  let configFile = is_deployed ? configPath : "config/config.toml";
  try {
    Fs.readFile(configFile, { encoding: "utf8" }, (err, data) => {
      if (err) {
        errorHandler(res, "Error on Reading File");
        return;
      }
      let config;
      try {
        config = toml.parse(data);
      } catch {
        errorHandler(res, "Error on Parsing toml");
        return;
      }
      let merchantConfig = config["default"];
      try {
        // If the domain is present in the toml file
        if (
          domain.length > 0 &&
          config[domain] != undefined &&
          Object.keys(config[domain]).length > 0
        ) {
          merchantConfig = updateConfigWithEnv(config[domain], domain, "theme");
        }
        // If the domain not is present in the toml file but need to overide the default value with the theme set in the env
        else if (domain && domain.length > 0 && domain !== undefined) {
          merchantConfig = updateConfigWithEnv(
            config["default"],
            domain,
            "theme",
          );
        } else {
          merchantConfig = updateConfigWithEnv("default", "", merchantConfig);
        }
      } catch {
        errorHandler(res, "Error on Overding ENV");
        return;
      }
      if (typeof merchantConfig === "object") {
        res.writeHead(200, {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        });
        res.write(JSON.stringify(merchantConfig));
        res.end();
      } else {
        errorHandler(res, "Error on sending response");
        return;
      }
    });
  } catch (error) {
    errorHandler(res, "Server Error");
  }
};

export { configHandler };
