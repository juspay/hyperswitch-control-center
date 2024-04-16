import * as Fs from "fs";
import toml from "@iarna/toml";

// Function to override config values from environment variables
const overrideConfigWithEnv = (config, prefix) => {
    for (let key in config) {
        if (
            prefix !== undefined &&
            prefix.length > 0 &&
            process.env[`${prefix}__${key}`]
        ) {
            config[key] = process.env[`${prefix}__${key}`];
        } else if (process.env[key]) {
            config[key] = process.env[key];
        }
    }
    return config;
};


function updateConfigWithEnv(updatedConfig, domain = "", prefix = "") {

    for (const key in updatedConfig) {
        if (typeof updatedConfig[key] === 'object' && updatedConfig[key] !== null) {
            updateConfigWithEnv(updatedConfig[key], domain, key); // Recursively update nested objects
        } else {
            // Check if environment variable exists for the key
            console.log(`${domain}__${prefix}__${key}`)
            const envVar = process.env[`${domain}__${prefix}__${key}`];
            if (envVar !== undefined) {
                // Convert string to appropriate type if necessary (e.g., "true" to true)
                if (typeof updatedConfig[key] === 'boolean') {
                    updatedConfig[key] = envVar.toLowerCase() === 'true';
                } else if (typeof updatedConfig[key] === 'number') {
                    updatedConfig[key] = parseFloat(envVar);
                } else {
                    updatedConfig[key] = envVar;
                }
            }
        }
    }
    return updatedConfig;
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
            let merchantConfig = config["default"];
            try {
                if (
                    domain.length > 0 &&
                    config[domain] != undefined &&
                    Object.keys(config[domain]).length > 0
                ) {
                    merchantConfig = updateConfigWithEnv(config[domain], domain, "theme")
                } else {
                    merchantConfig = updateConfigWithEnv("default", "", merchantConfig);
                }
            } catch {
                errorHandler(res);
                return;
            }

            if (typeof merchantConfig === "object") {
                res.writeHead(200, {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                });
                res.write(JSON.stringify(merchantConfig))
                res.end();
            } else {
                errorHandler(res);
                return;
            }


        });
    } catch (error) {
        console.log(error);
        errorHandler(res);
    }
};

export { configHandler, overrideConfigWithEnv };
