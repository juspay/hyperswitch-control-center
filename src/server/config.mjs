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

/* 
@module checkEnvValues

Verify the presence of critical merchant specific config.
 
*/

function checkEnvValues(env, tomlConfig) {
  if (env && env !== null && typeof env === "string") {
    let data = env.split(",");
    if (Array.isArray(data)) {
      return data;
    }
  } else if (
    tomlConfig &&
    tomlConfig !== null &&
    typeof tomlConfig === "object"
  ) {
    return tomlConfig;
  } else {
    return [];
  }
}

/* 
@module checkEnvValues

Returns a configuration object populated with their values.
 
*/

function updateMerchantConfigWithEnv(tomlConfig, body, domain = "default") {
  try {
    let modifiedObj = {};
    for (const key in tomlConfig) {
      const envOrgIds =
        process.env[`${domain}__merchant_config__${key}__org_ids`];
      const envMetchantIds =
        process.env[`${domain}__merchant_config__${key}__merchant_ids`];
      const envProfileIds =
        process.env[`${domain}__merchant_config__${key}__profile_ids`];
      let orgIds = checkEnvValues(envOrgIds, tomlConfig[key]["org_ids"]).filter(
        (id) => body.org_id == id,
      );
      let merchantIds = checkEnvValues(
        envMetchantIds,
        tomlConfig[key]["merchant_ids"],
      ).filter((id) => body.org_id == id);
      let profileIds = checkEnvValues(
        envProfileIds,
        tomlConfig[key]["profile_ids"],
      ).filter((id) => body.org_id == id);
      modifiedObj[key] = {
        org_ids: orgIds,
        merchant_ids: merchantIds,
        profile_ids: profileIds,
      };
    }
    return modifiedObj;
  } catch (err) {
    console.error(err, "Error in checking merchant specific config");
    return err;
  }
}
const errorHandler = (res, errorMessage = "something went wrong") => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  console.log(errorMessage);
  res.end("Internal Server Error");
};

// Main function to read TOML file, override config, and output the result
const configHandler = (
  req,
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
          merchantConfig = updateConfigWithEnv(merchantConfig, "default", "");
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

/* 
@module getRequestBody

To Parse the request body
 
*/

const getRequestBody = (req) => {
  return new Promise((resolve, reject) => {
    let body = "";

    req.on("data", (chunk) => {
      body += chunk.toString(); // Convert Buffer to string
    });

    req.on("end", () => {
      resolve(JSON.parse(body)); // When all data has been received, resolve the promise
    });

    req.on("error", (err) => {
      reject(err); // Handle errors
    });
  });
};

/* 
@module merchantConfigHandler

Handler function to handle the request
 
*/

const merchantConfigHandler = (
  req,
  res,
  is_deployed = false,
  domain = "default",
  configPath = "dist/server/config/config.toml",
) => {
  let configFile = is_deployed ? configPath : "config/config.toml";
  try {
    getRequestBody(req).then((body) => {
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
        let merchantConfig = config["default"]["merchant_config"];
        try {
          let data = {};
          // If the domain is present in the toml file
          if (
            domain.length > 0 &&
            config[domain] != undefined &&
            config[domain]["merchant_config"] != undefined &&
            Object.keys(config[domain]["merchant_config"]).length > 0
          ) {
            data = updateMerchantConfigWithEnv(
              config[domain]["merchant_config"],
              body,
              domain,
            );
          } else {
            data = updateMerchantConfigWithEnv(merchantConfig, body, "default");
          }
          res.writeHead(200, {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          });
          res.write(JSON.stringify(data));
          res.end();
        } catch (err) {
          console.log(err, "Error on overriding merchant specific config");
          errorHandler(res, "Error");
          return;
        }
      });
    });
  } catch (error) {
    console.log(error);
    errorHandler(res, "Server Error");
  }
};

export { configHandler, merchantConfigHandler };
