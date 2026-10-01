import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";

const views = [
  ["explore", "explore", "Explore"],
  ["api-health", "api_health", "API Health"],
  ["connector-performance", "connector_performance", "Connector Performance"],
  ["business-metrics", "business_metrics", "Business Metrics"],
  ["system-health", "system_health", "System Health"],
];

async function setup(page: Page, role = "internal_view_only", enabled = true) {
  await page.addInitScript(() => {
    localStorage.setItem(
      "USER_INFO",
      JSON.stringify({ token: "monitoring-test-token" }),
    );
  });
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features.dev_alerts = enabled;
    json.features.mixpanel = false;
    json.endpoints.api_url = new URL("/api", route.request().url()).href;
    await route.fulfill({ response, json });
  });
  await page.route("**/api/**", async (route) => {
    const path = new URL(route.request().url()).pathname;
    const data =
      path === "/api/user"
        ? {
            email: "monitoring@example.test",
            name: "Monitoring Test",
            merchant_id: "monitoring_test",
            org_id: "org_test",
            profile_id: "profile_test",
            role_id: role,
            entity_type: "tenant",
            version: "v1",
          }
        : path === "/api/user/role/v2"
          ? { groups: [], resources: [] }
          : path === "/api/user/merchant_details"
            ? {
                product_type: "orchestration",
                merchant_account_type: "standard",
              }
            : {};
    await route.fulfill({ json: data });
  });
  await page.route("**/api/observability-plane/grafana/**", (route) =>
    route.fulfill({
      contentType: "text/html",
      body: "<!doctype html><title>Test dashboard</title><h1>Monitoring fixture</h1>",
    }),
  );
}

async function session(page: Page, status = 200, embedUrl?: string) {
  await page.route(
    "**/api/observability-plane/monitoring/grafana/session/*",
    async (route) => {
      expect(route.request().method()).toBe("POST");
      expect(route.request().postData()).toBeNull();
      expect(route.request().headers().authorization).toBe(
        "Bearer monitoring-test-token",
      );
      const id = new URL(route.request().url()).pathname.split("/").pop();
      await route.fulfill({
        status,
        json:
          status === 200
            ? {
                embed_url:
                  embedUrl ??
                  new URL(
                    `/api/observability-plane/grafana/d/${id}/view?kiosk&from=now-24h&to=now`,
                    route.request().url(),
                  ).href,
              }
            : { error: { code: "IR_06", message: "Monitoring test failure" } },
        headers:
          status === 200
            ? {
                "set-cookie":
                  "grafana_token=test-cookie; Path=/api/observability-plane/grafana; Secure; HttpOnly; SameSite=Strict",
              }
            : {},
      });
    },
  );
}

test.describe("Monitoring", () => {
  test("defaults to Explore and bootstraps all five sidebar views", async ({
    page,
    context,
  }) => {
    await setup(page);
    await session(page);
    await page.goto("/dashboard/monitoring");
    await expect(page).toHaveURL(/\/dashboard\/monitoring\/explore$/);
    for (const [slug, id, title] of views) {
      if (slug !== "explore")
        await page.getByRole("link", { name: title, exact: true }).click();
      await expect(
        page.locator(`#monitoring-screen iframe[title="${title}"]`),
      ).toBeVisible();
      const src = await page
        .locator("#monitoring-screen iframe")
        .getAttribute("src");
      const url = new URL(src!);
      expect(url.pathname).toContain(`/grafana/d/${id}/`);
      expect(url.searchParams.has("kiosk")).toBe(true);
      expect(src).not.toMatch(/[?&]kiosk=/);
      expect(url.searchParams.get("theme")).toBe("light");
      expect(url.searchParams.get("from")).toBe("now-24h");
    }
    const cookie = (await context.cookies()).find(
      (value) => value.name === "grafana_token",
    );
    expect(cookie).toMatchObject({
      path: "/api/observability-plane/grafana",
      secure: true,
      httpOnly: true,
      sameSite: "Strict",
    });
    await page.reload();
    await expect(page.locator('iframe[title="System Health"]')).toBeVisible();
    await page.goBack();
    await expect(
      page.locator('iframe[title="Business Metrics"]'),
    ).toBeVisible();
  });

  for (const role of ["internal_view_only", "internal_admin"]) {
    test(`${role} can access a direct monitoring URL`, async ({ page }) => {
      await setup(page, role);
      await session(page);
      await page.goto("/dashboard/monitoring/api-health");
      await expect(page.locator('iframe[title="API Health"]')).toBeVisible();
    });
  }

  for (const [name, role, enabled] of [
    ["external role", "merchant_admin", true],
    ["disabled alerts flag", "internal_admin", false],
  ] as const) {
    test(`denies sidebar and direct access for ${name}`, async ({ page }) => {
      await setup(page, role, enabled);
      let calls = 0;
      await page.route("**/monitoring/grafana/session/*", (route) => {
        calls++;
        return route.fulfill({ status: 403, json: {} });
      });
      await page.goto("/dashboard/monitoring/explore");
      await expect(page.getByText("Explore", { exact: true })).toHaveCount(0);
      await expect(page.locator("#monitoring-screen")).toHaveCount(0);
      expect(calls).toBe(0);
    });
  }

  for (const [status, message] of [
    [403, "You do not have access to Monitoring."],
    [404, "This monitoring view has not been configured yet."],
    [503, "Monitoring is temporarily unavailable."],
  ] as const) {
    test(`handles bootstrap ${status}`, async ({ page }) => {
      await setup(page);
      await session(page, status);
      await page.goto("/dashboard/monitoring/api-health");
      await expect(page.getByRole("alert")).toHaveText(new RegExp(message));
      await expect(page.locator("#monitoring-screen iframe")).toHaveCount(0);
      await expect(
        page.getByRole("button", { name: "Retry", exact: true }),
      ).toHaveCount(0);
    });
  }

  test("401 uses the existing CC logout flow", async ({ page }) => {
    await setup(page);
    await session(page, 401);
    await page.goto("/dashboard/monitoring/api-health");
    await expect(page).toHaveURL(/\/dashboard\/login/);
    await expect(page.locator("iframe")).toHaveCount(0);
    expect(
      await page.evaluate(() => localStorage.getItem("USER_INFO")),
    ).toBeNull();
  });

  for (const url of [
    "https://unapproved.example/grafana/d/test",
    "https://app.hyperswitch.io/api/observability-plane/grafana/d/test",
    "javascript:alert(1)",
  ]) {
    test(`rejects an unapproved embed URL: ${url}`, async ({ page }) => {
      await setup(page);
      await session(page, 200, url);
      await page.goto("/dashboard/monitoring/explore");
      await expect(page.getByRole("alert")).toContainText(
        "outside the approved gateway",
      );
      await expect(page.locator("#monitoring-screen iframe")).toHaveCount(0);
    });
  }

  test("uses cookie-only gateway authorization without polling an idle view", async ({
    page,
  }) => {
    await setup(page);
    await session(page);
    await page.clock.install();
    let requests = 0;
    await page.route("**/api/observability-plane/grafana/**", async (route) => {
      requests++;
      expect(route.request().headers().authorization).toBeUndefined();
      await route.fulfill({
        contentType: "text/html",
        body: "<h1>Monitoring fixture</h1>",
      });
    });
    await page.goto("/dashboard/monitoring/api-health");
    await expect(
      page
        .frameLocator('iframe[title="API Health"]')
        .getByText("Monitoring fixture"),
    ).toBeVisible();
    const initialRequests = requests;
    expect(initialRequests).toBe(1);
    await page.clock.fastForward(180000);
    expect(requests).toBe(initialRequests);
    await expect(page.locator('iframe[title="API Health"]')).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Retry", exact: true }),
    ).toHaveCount(0);
  });

  test("shows a static error when bootstrap cannot connect", async ({
    page,
  }) => {
    await setup(page);
    await page.route("**/monitoring/grafana/session/*", (route) =>
      route.abort(),
    );
    await page.goto("/dashboard/monitoring/api-health");
    await expect(page.getByRole("alert")).toContainText(
      "Unable to connect to Monitoring.",
    );
    await expect(
      page.getByRole("button", { name: "Retry", exact: true }),
    ).toHaveCount(0);
    await expect(page.locator("#monitoring-screen iframe")).toHaveCount(0);
  });

  test("discards an old bootstrap response when switching views", async ({
    page,
  }) => {
    await setup(page);
    await session(page);
    let release: () => void = () => {};
    let requested = false;
    await page.route(
      "**/monitoring/grafana/session/api_health",
      async (route) => {
        requested = true;
        await new Promise<void>((resolve) => {
          release = resolve;
        });
        await route
          .fulfill({
            json: {
              embed_url: new URL(
                "/api/observability-plane/grafana/d/old/view",
                route.request().url(),
              ).href,
            },
          })
          .catch(() => {});
      },
    );
    await page.goto("/dashboard/monitoring/api-health");
    await expect.poll(() => requested).toBe(true);
    await page
      .getByRole("link", { name: "Business Metrics", exact: true })
      .click();
    await expect(
      page.locator('iframe[title="Business Metrics"]'),
    ).toBeVisible();
    release();
    await expect(page.locator("#monitoring-screen iframe")).toHaveAttribute(
      "src",
      /business_metrics/,
    );
  });

  test("propagates theme changes and remains usable at mobile width", async ({
    page,
  }) => {
    await setup(page);
    await session(page);
    await page.goto("/dashboard/monitoring/explore");
    await expect(page.locator('iframe[title="Explore"]')).toBeVisible();
    await page.evaluate(() =>
      window.postMessage(
        JSON.stringify({ eventType: "themeToggle", payload: "Dark" }),
        location.origin,
      ),
    );
    await expect(page.locator("#monitoring-screen iframe")).toHaveAttribute(
      "src",
      /theme=dark/,
    );
    await page.setViewportSize({ width: 390, height: 844 });
    await expect(page.locator("#monitoring-screen iframe")).toBeVisible();
    await expect
      .poll(
        async () =>
          (await page.locator("#monitoring-screen iframe").boundingBox())
            ?.width,
      )
      .toBeGreaterThan(200);
    const frame = await page.locator("#monitoring-screen iframe").boundingBox();
    expect(frame?.width).toBeLessThanOrEqual(390);
  });

  test("preserves backend kiosk configuration and URL fragments", async ({
    page,
  }, testInfo) => {
    await setup(page);
    const fragment = "#?kiosk=tv&kiosk=tv";
    const url = new URL(
      `/api/observability-plane/grafana/d/demo/view?kiosk=tv&theme=light&from=now${fragment}`,
      testInfo.project.use.baseURL,
    ).href;
    await session(page, 200, url);
    await page.goto("/dashboard/monitoring/api-health");
    const iframe = page.locator('iframe[title="API Health"]');
    await expect(iframe).toBeVisible();
    const src = new URL((await iframe.getAttribute("src"))!);
    expect(src.hash).toBe(fragment);
    expect(src.searchParams.get("kiosk")).toBe("tv");
    expect(src.searchParams.getAll("theme")).toEqual(["light"]);
  });

  test("does not add kiosk when the backend omits it", async ({
    page,
  }, testInfo) => {
    await setup(page);
    await session(
      page,
      200,
      new URL(
        "/api/observability-plane/grafana/d/demo/view?from=now",
        testInfo.project.use.baseURL,
      ).href,
    );
    await page.goto("/dashboard/monitoring/api-health");
    const iframe = page.locator('iframe[title="API Health"]');
    await expect(iframe).toBeVisible();
    const url = new URL((await iframe.getAttribute("src"))!);
    expect(url.searchParams.has("kiosk")).toBe(false);
    expect(url.searchParams.get("theme")).toBe("light");
  });

  test("unknown routes do not bootstrap an arbitrary destination", async ({
    page,
  }) => {
    await setup(page);
    let calls = 0;
    await page.route("**/monitoring/grafana/session/*", (route) => {
      calls++;
      return route.fulfill({ status: 404, json: {} });
    });
    await page.goto("/dashboard/monitoring/unapproved");
    await expect(page.locator("#monitoring-screen")).toHaveCount(0);
    await expect(page.getByText("Error 404!", { exact: true })).toBeVisible();
    expect(calls).toBe(0);
  });
});
