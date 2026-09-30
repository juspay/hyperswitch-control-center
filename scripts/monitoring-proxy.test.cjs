const assert = require("node:assert/strict");
const { test } = require("node:test");
const { Readable } = require("node:stream");
const { gzipSync } = require("node:zlib");
const {
  getMonitoringProxy,
  rewriteEmbedUrl,
  validateOrigins,
} = require("../webpack.monitoring");

const target = "https://app.hyperswitch.io";
const local = "https://localhost:9000";

test("proxy is opt-in and leaves default local development unchanged", () => {
  assert.deepEqual(getMonitoringProxy({}), []);
});

test("rewrites only approved gateway URLs and preserves Explore state", () => {
  assert.equal(
    rewriteEmbedUrl(
      `${target}/api/observability-plane/grafana/explore?panes=loki&kiosk`,
      target,
      local,
    ),
    `${local}/api/observability-plane/grafana/explore?panes=loki&kiosk`,
  );
  for (const url of [
    `${target}/other`,
    "https://evil.example/api/observability-plane/grafana/explore",
    `${target}/api/observability-plane/grafana-other/explore`,
    "javascript:alert(1)",
  ]) {
    assert.throws(() => rewriteEmbedUrl(url, target, local));
  }
});

test("requires HTTPS origins and a loopback local server", () => {
  assert.deepEqual(validateOrigins(target, local), {
    target,
    localOrigin: local,
  });
  for (const [remote, origin] of [
    ["http://example.test", local],
    [target, "http://localhost:9000"],
    [target, "https://public.example"],
    [`${target}/api`, local],
  ]) {
    assert.throws(() => validateOrigins(remote, origin));
  }
});

test("keeps session and Grafana paths, and makes aliases explicit and dev-only", () => {
  const proxies = getMonitoringProxy({
    SANDBOX_MONITORING_ORIGIN: target,
    MONITORING_API_HEALTH_ID: "api_inbound",
  });
  assert.equal(
    proxies[0].pathRewrite(
      "/api/observability-plane/monitoring/grafana/session/api_health",
    ),
    "/api/observability-plane/monitoring/grafana/session/api_inbound",
  );
  assert.equal(
    proxies[0].pathRewrite(
      "/api/observability-plane/monitoring/grafana/session/explore",
    ),
    "/api/observability-plane/monitoring/grafana/session/explore",
  );
  assert.equal(proxies[1].ws, true);
  assert.equal(proxies[1].secure, true);
  assert.equal(proxies[1].cookieDomainRewrite, undefined);
  assert.equal(proxies[1].cookiePathRewrite, undefined);
  assert.equal(proxies[1].context("/api/observability-plane/grafana"), true);
  assert.equal(
    proxies[1].context("/api/observability-plane/grafana/d/test"),
    true,
  );
  assert.equal(
    proxies[1].context("/api/observability-plane/grafana-other/test"),
    false,
  );
});

function intercept(handler, body, headers, status = 200) {
  return new Promise((resolve, reject) => {
    const upstream = Readable.from([Buffer.from(body)]);
    upstream.headers = headers;
    upstream.statusCode = status;
    upstream.statusMessage = "Test";
    const result = { headers: {}, body: Buffer.alloc(0), statusCode: 0 };
    const response = {
      setHeader(key, value) {
        result.headers[key] = value;
      },
      removeHeader(key) {
        delete result.headers[key];
      },
      set statusCode(value) {
        result.statusCode = value;
      },
      write(value) {
        result.body = Buffer.concat([result.body, value]);
      },
      end(value) {
        if (value) reject(new Error(value));
        else resolve(result);
      },
    };
    handler(upstream, {}, response).catch(reject);
  });
}

const proxies = getMonitoringProxy({ SANDBOX_MONITORING_ORIGIN: target });
const cookie =
  "grafana_token=test-only; Path=/api/observability-plane/grafana; Secure; HttpOnly; SameSite=Strict";

test("bootstrap interceptor preserves the secure host-only cookie and decompresses responses", async () => {
  const response = await intercept(
    proxies[0].onProxyRes,
    gzipSync(
      JSON.stringify({
        embed_url: `${target}/api/observability-plane/grafana/explore?panes=loki`,
      }),
    ),
    {
      "content-type": "application/json",
      "content-encoding": "gzip",
      "set-cookie": [cookie],
    },
  );
  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.headers["set-cookie"], [cookie]);
  assert.equal(response.headers["content-encoding"], undefined);
  assert.equal(
    JSON.parse(response.body).embed_url,
    `${local}/api/observability-plane/grafana/explore?panes=loki`,
  );
  assert.equal(response.headers["content-length"], response.body.length);
});

for (const body of [
  "not-json",
  JSON.stringify({
    embed_url: "https://evil.example/api/observability-plane/grafana/explore",
  }),
  JSON.stringify({}),
]) {
  test(`bootstrap interceptor fails closed for invalid responses: ${body}`, async () => {
    const response = await intercept(proxies[0].onProxyRes, body, {
      "content-type": "application/json",
      "set-cookie": [cookie],
    });
    assert.equal(response.statusCode, 502);
    assert.equal(response.headers["set-cookie"], undefined);
    assert.deepEqual(JSON.parse(response.body), {
      error: "Invalid monitoring gateway response",
    });
  });
}

test("Grafana interceptor rewrites framing/redirect/HTML origins but preserves binary responses", async () => {
  const response = await intercept(
    proxies[1].onProxyRes,
    `<html>${target}/api/observability-plane/grafana/</html>`,
    {
      "content-type": "text/html",
      "content-security-policy": `default-src 'self'; frame-ancestors ${target}`,
      location: `${target}/api/observability-plane/grafana/login`,
      "set-cookie": [cookie],
    },
  );
  assert.equal(
    response.headers["content-security-policy"],
    `default-src 'self'; frame-ancestors ${local}`,
  );
  assert.equal(
    response.headers.location,
    `${local}/api/observability-plane/grafana/login`,
  );
  assert.equal(
    response.body.toString(),
    `<html>${local}/api/observability-plane/grafana/</html>`,
  );
  assert.deepEqual(response.headers["set-cookie"], [cookie]);
  const binary = Buffer.from([0, 255, 1, 128]);
  const asset = await intercept(proxies[1].onProxyRes, binary, {
    "content-type": "image/png",
  });
  assert.deepEqual(asset.body, binary);
});

test("HTTP and WebSocket origin rewriting leaves cookies and authorization unchanged", () => {
  for (const handler of [proxies[1].onProxyReq, proxies[1].onProxyReqWs]) {
    const headers = {
      origin: local,
      cookie: "grafana_token=test-only",
      authorization: "Bearer test-only",
    };
    handler({
      getHeader: (key) => headers[key],
      setHeader: (key, value) => {
        headers[key] = value;
      },
    });
    assert.equal(headers.origin, target);
    assert.equal(headers.cookie, "grafana_token=test-only");
    assert.equal(headers.authorization, "Bearer test-only");
  }
});
