import * as Fs from "fs";

const errorHandler = (res, errorMessage = "something went wrong") => {
  res.writeHead(500, { "Content-Type": "text/plain" });
  console.error(errorMessage);
  res.end("Internal Server Error");
};

// Read and parse JSON config file
const readJSONConfig = (configPath, res) => {
  return new Promise((resolve, reject) => {
    Fs.readFile(configPath, { encoding: "utf8" }, (err, data) => {
      if (err) {
        errorHandler(res, "Error on Reading File");
        return reject(err);
      }
      try {
        resolve(data);
      } catch (err) {
        errorHandler(res, "Error on Parsing JSON");
        reject(err);
      }
    });
  });
};
// theme config handler
const themeConfigHandler = async (
  req,
  res,
  isDeployed = false,
  configPath = "dist/server/config/theme.json",
) => {
  const filePath = isDeployed ? configPath : "config/theme.json";
  try {
    const config = await readJSONConfig(filePath, res);
    res.writeHead(200, {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
    });
    res.end(config);
  } catch (error) {
    if (process.env.NODE_ENV === "development") {
      console.log(error);
    }
    errorHandler(res, "Server Error");
  }
};
export { themeConfigHandler };
