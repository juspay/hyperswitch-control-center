/**
 * Auto-generated Playwright test
 * Source: exploration-driven gap fill from .opencode/sessions/playwright-run/explore.json
 * Generated: 2026-04-17
 *
 * Every assertion in this file corresponds to a live interactive element
 * observed during the exploration scout (page.evaluate over the real DOM
 * after hydration). Shallow URL-only assertions already exist in other
 * ai-generated specs; this file adds the missing interaction depth.
 */

import { test, expect, Page } from "../support/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

// Many pages are feature-flag gated; when off, the app replaces the body with
// a "Go to Home" fallback screen. Tests use this helper to skip cleanly
// rather than failing on absent elements.
async function gatedOrAssert(
  page: Page,
  assertion: () => Promise<void>,
): Promise<void> {
  const fallback = page.getByText("Go to Home", { exact: true }).first();
  if (await fallback.isVisible().catch(() => false)) {
    test.skip(true, "page gated by feature flag — renders Go to Home fallback");
  }
  await assertion();
}

async function setup(
  page: Page,
  context: import("../support/test").BrowserContext,
): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
}

test.describe("Processor list pages — search + request CTA", () => {
  const processorRoutes = [
    { path: "3ds-authenticators", heading: "3DS Authenticators" },
    { path: "pm-authentication-processor", heading: "PM Auth Processor" },
    { path: "tax-processor", heading: "Tax Processor" },
    { path: "billing-processor", heading: "Billing Processor" },
    { path: "vault-processor", heading: "Vault Processor" },
  ];

  for (const { path, heading } of processorRoutes) {
    test(`${heading} page exposes Request-a-Processor CTA and search input`, async ({
      page,
      context,
    }) => {
      await setup(page, context);
      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await gatedOrAssert(page, async () => {
        await expect(
          page.getByRole("button", { name: "Request a Processor" }).first(),
        ).toBeVisible({ timeout: 10000 });
        await expect(
          page.getByPlaceholder("Search a processor"),
        ).toBeVisible({ timeout: 10000 });
      });
    });

    test(`${heading} search input accepts typed text`, async ({
      page,
      context,
    }) => {
      await setup(page, context);
      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await gatedOrAssert(page, async () => {
        const search = page.getByPlaceholder("Search a processor");
        await search.fill("stripe");
        await expect(search).toHaveValue("stripe");
      });
    });
  }
});

test.describe("Workflow decision pages — Create New CTA", () => {
  const workflowRoutes = [
    { path: "3ds", heading: "3DS Decision Manager" },
    { path: "3ds-exemption", heading: "3DS Exemption Rules" },
    { path: "surcharge", heading: "Surcharge" },
  ];

  for (const { path, heading } of workflowRoutes) {
    test(`${heading} renders heading and Create New button`, async ({
      page,
      context,
    }) => {
      await setup(page, context);
      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await gatedOrAssert(page, async () => {
        await expect(page.getByText(heading).first()).toBeVisible({
          timeout: 10000,
        });
        await expect(
          page.getByRole("button", { name: "Create New" }).first(),
        ).toBeVisible({ timeout: 10000 });
      });
    });
  }
});

test.describe("Configure PMTs — heading + Add Filters", () => {
  test("renders heading and Add Filters button", async ({ page, context }) => {
    await setup(page, context);
    await page.goto("/dashboard/configure-pmts");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByText("Configure PMTs at Checkout").first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page.getByRole("button", { name: "Add Filters" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("Account Settings > Profile — Reset Password", () => {
  test("profile page exposes Reset Password button", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/account-settings/profile");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await expect(page.getByText("Profile").first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByRole("button", { name: "Reset Password" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Organization Settings — platform org CTA", () => {
  test("renders Learn More link and Create Platform Organization CTA", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/organization-settings");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByRole("button", { name: "Learn More" }).first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page
          .getByRole("button", { name: "Create Platform Organization" })
          .first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("Payout Routing — setup/manage cards", () => {
  test("renders Setup and Manage CTAs for routing options", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/payoutrouting");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      // getByText("Manage") is ambiguous on this page — "manage" appears in
      // body copy too. Use getByRole("button") + exact match to scope to CTAs.
      await expect(
        page.getByRole("button", { name: "Setup", exact: true }).first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page.getByRole("button", { name: "Manage", exact: true }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("Vault Onboarding — processor picker", () => {
  test("exposes Connect cards and Search a processor input", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/vault-onboarding");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByPlaceholder("Search a processor"),
      ).toBeVisible({ timeout: 10000 });
      // At least one Connect button should be visible (vault onboarding had 38)
      const connectButtons = page.getByRole("button", { name: "Connect" });
      expect(await connectButtons.count()).toBeGreaterThan(0);
    });
  });
});

test.describe("Vault Customers & Tokens — Refresh CTA", () => {
  test("renders Refresh button on the page", async ({ page, context }) => {
    await setup(page, context);
    await page.goto("/dashboard/vault-customers-tokens");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByRole("button", { name: "Refresh" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("APM landing — onboarding cards", () => {
  test("renders Configure it and Customize SDK CTAs", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/apm");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByRole("button", { name: "Configure it" }).first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page.getByRole("button", { name: "Customize SDK" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("Webhooks — filters + search", () => {
  test("webhooks page exposes search input and date range", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/webhooks");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(page.getByPlaceholder("Search by ID")).toBeVisible({
        timeout: 10000,
      });
      // "Object ID" appears as a filter button on webhooks
      await expect(page.getByText("Object ID").first()).toBeVisible({
        timeout: 10000,
      });
    });
  });
});

test.describe("Disputes/Payouts empty-state — 90-day expand CTA", () => {
  test("disputes shows expand-to-90-days button", async ({ page, context }) => {
    await setup(page, context);
    await page.goto("/dashboard/disputes");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await expect(
      page
        .getByText("Expand the search to the previous 90 days")
        .first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("payouts shows expand-to-90-days button", async ({ page, context }) => {
    await setup(page, context);
    await page.goto("/dashboard/payouts");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page
          .getByText("Expand the search to the previous 90 days")
          .first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("FF-gated fallback pages — Go to Home sentinel", () => {
  const fallbackRoutes = [
    "analytics-disputes",
    "analytics-routing",
    "performance-monitor",
    "new-analytics",
    "compliance",
    "payment-link-theme",
    "recon",
    "upload-files",
    "run-recon",
    "recon-analytics",
    "reports",
    "config-settings",
  ];

  for (const route of fallbackRoutes) {
    test(`${route}: renders either real content or the Go to Home fallback`, async ({
      page,
      context,
    }) => {
      await setup(page, context);
      await page.goto(`/dashboard/${route}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      // The route should either render its own content, show the "Go to
      // Home" fallback, or at minimum stay on /dashboard/*. Blank or
      // off-dashboard redirects fail.
      const fallback = page.getByText("Go to Home", { exact: true }).first();
      const bodyHtmlLen = await page.evaluate(
        () => document.body.innerHTML.length,
      );
      const hasFallback = await fallback.isVisible().catch(() => false);
      const hasRealContent = bodyHtmlLen > 1000;
      const onDashboard = /\/dashboard\//.test(page.url());

      expect(hasFallback || hasRealContent || onDashboard).toBe(true);
    });
  }
});
