import { Console } from "console";
import fs from "fs";
import path from "path";

/**
 * Middleware to serve compressed files
 * Priority: Brotli (.br) > Gzip (.gz) > Default (uncompressed)
 * Checks if compressed versions exist and if client accepts the encoding
 */
export function serveCompressed(
  req,
  res,
  filePath,
  serverPath,
  XDeploymentId,
  Etag,
) {
  // Check if client accepts any compression encoding
  const acceptEncoding = req.headers["accept-encoding"] || "";
  const supportsBrotli = acceptEncoding.includes("br");
  const supportsGzip = acceptEncoding.includes("gzip");

  const fullPath = path.join(serverPath, filePath);

  //   Priority 1: Try Brotli compression if supported
  if (supportsBrotli) {
    const brotliPath = fullPath + ".br";
    if (fs.existsSync(brotliPath)) {
      const served = serveCompressedFile(
        res,
        brotliPath,
        filePath,
        "br",
        XDeploymentId,
        Etag,
      );
      if (served) return true;
    }
  }

  // Priority 2: Try Gzip compression if supported
  if (supportsGzip) {
    const gzipPath = fullPath + ".gz";
    if (fs.existsSync(gzipPath)) {
      const served = serveCompressedFile(
        res,
        gzipPath,
        filePath,
        "gzip",
        XDeploymentId,
        Etag,
      );
      if (served) return true;
    }
  }

  // Priority 3: No compression available or supported
  return false;
}

/**
 * Helper function to serve a compressed file with appropriate headers
 */
function serveCompressedFile(
  res,
  compressedPath,
  originalFilePath,
  encoding,
  XDeploymentId,
  Etag,
) {
  try {
    const stats = fs.statSync(compressedPath);
    const content = fs.readFileSync(compressedPath);
    // Determine content type based on original file extension
    const ext = path.extname(originalFilePath).toLowerCase();
    let contentType = "application/octet-stream";

    if (ext === ".js" || ext === ".mjs") {
      contentType = "application/javascript";
    } else if (ext === ".css") {
      contentType = "text/css";
    } else if (ext === ".wasm") {
      contentType = "application/wasm";
    } else {
      return false;
    }
    // Set headers for compressed content
    res.writeHead(200, {
      "Content-Type": contentType,
      "Content-Encoding": encoding,
      "X-Deployment-Id": XDeploymentId,
      ETag: Etag,
      "Content-Length": stats.size,
      Vary: "Accept-Encoding",
      "Cache-Control":
        ext === ".svg" ? "max-age=3600, must-revalidate" : "no-cache",
    });
    res.end(content);
    return true;
  } catch (error) {
    console.error(`Error serving ${encoding}-compressed file:`, error);
    return false;
  }
}
