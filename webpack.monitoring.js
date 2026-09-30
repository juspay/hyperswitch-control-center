const { responseInterceptor } = require("http-proxy-middleware");

const GRAFANA_PATH = "/api/observability-plane/grafana";
const SESSION_PATH = "/api/observability-plane/monitoring/grafana/session/";

function validateOrigins(target, localOrigin) {
  const remote = new URL(target);
  const local = new URL(localOrigin);
  if (
    remote.protocol !== "https:" ||
    remote.href !== remote.origin + "/" ||
    remote.username ||
    remote.password ||
    local.protocol !== "https:" ||
    !["localhost", "127.0.0.1", "[::1]"].includes(local.hostname) ||
    local.href !== local.origin + "/"
  ) {
    throw new Error(
      "Monitoring proxy requires an HTTPS upstream origin and an HTTPS loopback origin.",
    );
  }
  return { target: remote.origin, localOrigin: local.origin };
}

function rewriteEmbedUrl(embedUrl, target, localOrigin) {
  const url = new URL(embedUrl);
  if (
    url.origin !== target ||
    !url.pathname.startsWith(GRAFANA_PATH + "/") ||
    url.username ||
    url.password
  ) {
    throw new Error(
      "Monitoring destination is outside the configured gateway.",
    );
  }
  return localOrigin + url.pathname + url.search + url.hash;
}

function getMonitoringProxy(env = process.env) {
  if (!env.SANDBOX_MONITORING_ORIGIN) return [];
  const { target, localOrigin } = validateOrigins(
    env.SANDBOX_MONITORING_ORIGIN,
    env.MONITORING_LOCAL_ORIGIN || "https://localhost:9000",
  );
  const rewriteOrigin = (proxyReq) => {
    if (proxyReq.getHeader("origin") === localOrigin) {
      proxyReq.setHeader("origin", target);
    }
  };
  const common = {
    target,
    changeOrigin: true,
    secure: true,
    // Credentials are forwarded normally; never print headers or request bodies.
    logLevel: "silent",
    onProxyReq: rewriteOrigin,
    onProxyReqWs: rewriteOrigin,
  };
  return [
    {
      ...common,
      context: [SESSION_PATH],
      selfHandleResponse: true,
      pathRewrite(path) {
        // Temporary opt-in alias until sandbox provisions the agreed api_health ID.
        const alias = env.MONITORING_API_HEALTH_ID;
        if (alias && !/^[a-z][a-z0-9_]*$/.test(alias)) {
          throw new Error("Invalid monitoring test destination ID.");
        }
        return alias && path === SESSION_PATH + "api_health"
          ? SESSION_PATH + alias
          : path;
      },
      onProxyRes: responseInterceptor(async (buffer, proxyRes, req, res) => {
        if (proxyRes.statusCode !== 200) return buffer;
        try {
          const body = JSON.parse(buffer.toString("utf8"));
          body.embed_url = rewriteEmbedUrl(body.embed_url, target, localOrigin);
          return JSON.stringify(body);
        } catch {
          res.statusCode = 502;
          res.removeHeader("set-cookie");
          return JSON.stringify({
            error: "Invalid monitoring gateway response",
          });
        }
      }),
    },
    {
      ...common,
      context: (pathname) =>
        pathname === GRAFANA_PATH || pathname.startsWith(GRAFANA_PATH + "/"),
      ws: true,
      selfHandleResponse: true,
      onProxyRes: responseInterceptor(async (buffer, proxyRes, req, res) => {
        // Dev-only framing/root URL adaptation; cookie security attributes are unchanged.
        const csp = proxyRes.headers["content-security-policy"];
        if (typeof csp === "string") {
          res.setHeader(
            "content-security-policy",
            csp.split(target).join(localOrigin),
          );
        }
        const location = proxyRes.headers.location;
        if (location && location.startsWith(target + GRAFANA_PATH)) {
          res.setHeader("location", location.replace(target, localOrigin));
        }
        return proxyRes.headers["content-type"]?.includes("text/html")
          ? buffer.toString("utf8").split(target).join(localOrigin)
          : buffer;
      }),
    },
  ];
}

module.exports = { getMonitoringProxy, rewriteEmbedUrl, validateOrigins };
