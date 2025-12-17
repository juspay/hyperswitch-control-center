import * as Fs from "fs";
import toml from "@iarna/toml";

// Helper function for error handling
const errorHandler = (res, errorMessage = "something went wrong") => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  console.error(errorMessage);
  res.end("Internal Server Error");
};

// Update config with environment variables
function updateConfigWithEnv(config, domain = "", prefix = "") {
  for (const key in config) {
    if (typeof config[key] === "object" && config[key] !== null) {
      updateConfigWithEnv(config[key], domain, key); // Recursively update nested objects
    } else {
      const envVar = process.env[`${domain}__${prefix}__${key}`];
      if (envVar !== undefined) {
        config[key] = inferType(config[key], envVar); // Convert string to appropriate type
      }
    }
  }

  return config;
}

// Infer type based on the original value's type
const inferType = (originalValue, envValue) => {
  if (typeof originalValue === "boolean")
    return envValue.toLowerCase() === "true";
  if (typeof originalValue === "number") return parseFloat(envValue);
  return envValue;
};

// Check if env values exist or fall back to TOML config
function checkEnvValues(env, tomlConfig) {
  if (typeof env === "string") {
    return env.split(",");
  }
  if (typeof tomlConfig === "object" && tomlConfig !== null) {
    return tomlConfig;
  }
  return [];
}

function processConfigList(configList, body, domain, listType) {
  const result = {};
  for (const key in configList) {
    const envOrgIds =
      process.env[`${domain}__merchant_config__${listType}__${key}__org_ids`];
    const envMerchantIds =
      process.env[
      `${domain}__merchant_config__${listType}__${key}__merchant_ids`
      ];
    const envProfileIds =
      process.env[
      `${domain}__merchant_config__${listType}__${key}__profile_ids`
      ];

    const orgId = checkEnvValues(envOrgIds, configList[key].org_ids).find(
      (id) => body.org_id === id,
    );
    const merchantId = checkEnvValues(
      envMerchantIds,
      configList[key].merchant_ids,
    ).find((id) => body.merchant_id === id);
    const profileId = checkEnvValues(
      envProfileIds,
      configList[key].profile_ids,
    ).find((id) => body.profile_id === id);

    result[key] = {
      org_id: orgId,
      merchant_id: merchantId,
      profile_id: profileId,
    };
  }
  return result;
}

// Update merchant config using environment variables
function updateMerchantConfigWithEnv(tomlConfig, body, domain = "default") {
  let modifiedConfig = {};

  // Handle denylist configurations
  if (tomlConfig.denylist) {
    modifiedConfig.denylist = processConfigList(
      tomlConfig.denylist,
      body,
      domain,
      "denylist",
    );
  }

  // Handle allowlist configurations
  if (tomlConfig.allowlist) {
    modifiedConfig.allowlist = processConfigList(
      tomlConfig.allowlist,
      body,
      domain,
      "allowlist",
    );
  }

  return modifiedConfig;
}

// Read and parse TOML config file
const readTomlConfig = (configPath, res) => {
  return new Promise((resolve, reject) => {
    Fs.readFile(configPath, { encoding: "utf8" }, (err, data) => {
      if (err) {
        errorHandler(res, "Error on Reading File");
        return reject(err);
      }
      try {
        resolve(toml.parse(data));
      } catch (err) {
        errorHandler(res, "Error on Parsing TOML");
        reject(err);
      }
    });
  });
};

// Main config handler
const configHandler = async (
  req,
  res,
  isDeployed = false,
  domain = "default",
  configPath = "dist/server/config/config.toml",
) => {
  const filePath = isDeployed ? configPath : "config/config.toml";
  try {
    const config = await readTomlConfig(filePath, res);
    let merchantConfig = config.default;
    let isDomainExitsInEnv = process.env[`${domain}`];
    console.log("Domain received:", domain);
    console.log("Domain received isDomainExitsInEnv:", isDomainExitsInEnv);

    if (config[domain] && Object.keys(config[domain]).length > 0) {
      merchantConfig = updateConfigWithEnv(config[domain], domain, "theme");
    } else if (domain.length > 0 && isDomainExitsInEnv) {
      merchantConfig = updateConfigWithEnv(config.default, domain, "theme");
    } else {
      merchantConfig = updateConfigWithEnv(merchantConfig, "default", "");
    }
    if (merchantConfig && merchantConfig["merchant_config"]) {
      delete merchantConfig["merchant_config"];
    }

    res.writeHead(200, {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    });
    res.end(JSON.stringify(merchantConfig));
  } catch (error) {
    errorHandler(res, "Server Error");
  }
};

/* 
@module getRequestBody

To Parse the request body
 
*/

// Get request body
const getRequestBody = (req) => {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk.toString()));
    req.on("end", () => resolve(JSON.parse(body)));
    req.on("error", reject);
  });
};

// Merchant config handler
const merchantConfigHandler = async (
  req,
  res,
  isDeployed = false,
  domain = "default",
  configPath = "dist/server/config/config.toml",
) => {
  const filePath = isDeployed ? configPath : "config/config.toml";
  try {
    const body = await getRequestBody(req);
    const config = await readTomlConfig(filePath, res);
    const merchantConfig =
      config[domain]?.merchant_config || config.default.merchant_config;
    const data = updateMerchantConfigWithEnv(merchantConfig, body, domain);

    res.writeHead(200, {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    });
    res.end(JSON.stringify(data));
  } catch (error) {
    if (process.env.NODE_ENV === "development") {
      console.log(error);
    }
    errorHandler(res, "Server Error");
  }
};
export { configHandler, merchantConfigHandler };
