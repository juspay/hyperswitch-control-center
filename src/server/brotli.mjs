import { Console } from "console";
import fs from "fs";
import path from "path";

/**
 * Middleware to serve Brotli-compressed files
 * Checks if a .br version exists and if client accepts brotli encoding
 */
export function serveBrotli(
  req,
  res,
  filePath,
  serverPath,
  XDeploymentId,
  Etag,
) {
  // Check if client accepts Brotli encoding
  const acceptEncoding = req.headers["accept-encoding"] || "";
  const supportsBrotli = acceptEncoding.includes("br");
  console.log(
    "Checking Brotli support: ",
    req.headers["accept-encoding"],
    acceptEncoding,
    supportsBrotli,
  );
  if (!supportsBrotli) {
    return false; // Client doesn't support Brotli
  }

  // Build the path to the potentially Brotli-compressed file
  const fullPath = path.join(serverPath, filePath);
  const brotliPath = fullPath + ".br";

  // Check if Brotli version exists
  if (fs.existsSync(brotliPath)) {
    try {
      const stats = fs.statSync(brotliPath);
      const content = fs.readFileSync(brotliPath);

      // Determine content type based on original file extension
      const ext = path.extname(filePath).toLowerCase();
      let contentType = "application/octet-stream";

      if (ext === ".js" || ext === ".mjs") {
        contentType = "application/javascript";
      } else if (ext === ".css") {
        contentType = "text/css";
      } else if (ext === ".html") {
        contentType = "text/html";
      } else if (ext === ".json") {
        contentType = "application/json";
      } else if (ext === ".svg") {
        contentType = "image/svg+xml";
      } else if (ext === ".wasm") {
        contentType = "application/wasm";
      }

      // Set headers for Brotli-compressed content
      res.writeHead(200, {
        "Content-Type": contentType,
        "Content-Encoding": "br",
        "X-Deployment-Id": XDeploymentId,
        ETag: Etag,
        "Content-Length": stats.size,
        Vary: "Accept-Encoding",
        "Cache-Control":
          ext === ".svg" ? "max-age=3600, must-revalidate" : "no-cache",
      });

      res.end(content);
      return true; // Successfully served Brotli file
    } catch (error) {
      console.error("Error serving Brotli file:", error);
      return false; // Fall back to regular serving
    }
  }

  return false; // No Brotli version available
}
