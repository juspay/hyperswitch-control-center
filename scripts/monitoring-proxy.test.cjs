const assert = require("node:assert/strict");
const { test } = require("node:test");
const { Readable } = require("node:stream");
const { gzipSync } = require("node:zlib");
const fs = require("node:fs");
const vm = require("node:vm");
const source = fs.readFileSync(require.resolve("../webpack.dev.js"), "utf8");
const sandbox = {
  require: (name) => (name === "http-proxy-middleware" ? require(name) : {}),
  URL,
  process: { env: {} },
  module: { exports: {} },
};
vm.runInNewContext(
  'const { responseInterceptor } = require("http-proxy-middleware");\n' +
    source.slice(
      source.indexOf("const GRAFANA_PATH"),
      source.indexOf("let port ="),
    ) +
    "module.exports = { getMonitoringProxy, rewriteEmbedUrl, validateOrigins };",
  sandbox,
);
const { getMonitoringProxy, rewriteEmbedUrl, validateOrigins } =
  sandbox.module.exports;

const target = "https://app.hyperswitch.io";
const local = "https://localhost:9000";

test("proxy is opt-in and leaves default local development unchanged", () => {
  assert.equal(getMonitoringProxy({}).length, 0);
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
  assert.deepEqual(
    { ...validateOrigins(target, local) },
    {
      target,
      localOrigin: local,
    },
  );
  for (const [remote, origin] of [
    ["http://example.test", local],
    [target, "http://localhost:9000"],
    [target, "https://public.example"],
    [`${target}/api`, local],
  ]) {
    assert.throws(() => validateOrigins(remote, origin));
  }
});

test("keeps session and Grafana paths unchanged", () => {
  const proxies = getMonitoringProxy({ SANDBOX_MONITORING_ORIGIN: target });
  assert.equal(proxies[0].pathRewrite, undefined);
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

test("Grafana proxy adjusts only framing headers and streams the original body", () => {
  const headers = {
    "content-security-policy": `default-src 'self'; frame-ancestors ${target}`,
    "content-type": "text/html",
    "set-cookie": [cookie],
  };
  proxies[1].onProxyRes({ headers });
  assert.equal(
    headers["content-security-policy"],
    `default-src 'self'; frame-ancestors ${local}`,
  );
  assert.deepEqual(headers["set-cookie"], [cookie]);
  assert.equal(proxies[1].selfHandleResponse, undefined);
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
