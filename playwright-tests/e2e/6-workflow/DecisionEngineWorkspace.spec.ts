import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

// ---------------------------------------------------------------------------
// Embedded Decision Engine routing workspace.
//
// `routing/entry` is stubbed rather than driven off a real cut-over profile:
// cut-over is decided by the router's open_router flags plus Superposition, which
// the Playwright stack does not run. Stubbing also makes the probe countable,
// which is the point of the first test — the hook used to fire one request per
// live SidebarHooks consumer (sidebar, global search bar, search results page).
//
// Requires `dev_embed_decision_engine` on the dashboard under test; the suite
// skips rather than fails when it is off, so it is safe on an env without it.
// ---------------------------------------------------------------------------

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const stubCutover = async (page: Page, counter: { calls: number }) => {
  await page.route("**/routing/entry**", async (route: Route) => {
    counter.calls += 1;
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        is_cutover: true,
        // Same-origin so the frame stays inside the harness; the frame's own
        // content is not what these tests assert on.
        redirect_url: `${new URL(page.url()).origin}/decision-engine/routing/rules`,
      }),
    });
  });
};

const embedEnabled = async (page: Page): Promise<boolean> => {
  const res = await page.request.get("/config/feature");
  if (!res.ok()) return false;
  const body = await res.json();
  return Boolean((body?.features ?? body)?.dev_embed_decision_engine);
};

test.describe("Decision Engine routing workspace", () => {
  const counter = { calls: 0 };

  test.beforeEach(async ({ page }) => {
    counter.calls = 0;
    await stubCutover(page, counter);
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    test.skip(!(await embedEnabled(page)), "dev_embed_decision_engine is off");
  });

  test("probes routing/entry once per session, not once per sidebar consumer", async ({
    page,
  }) => {
    counter.calls = 0;
    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");
    // One shared probe per merchant+profile. Before the fix this was one per
    // live useDecisionEngineCutover instance.
    expect(counter.calls).toBe(1);
  });

  test("sidebar exposes the Decision Engine group and keeps Default Fallback reachable", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await page.getByText("Decision Engine Routing", { exact: true }).click();
    await expect(
      page.getByRole("link", { name: "Default Fallback" }),
    ).toBeVisible();
    await page.getByRole("link", { name: "Default Fallback" }).click();
    await expect(page).toHaveURL(/\/routing\/default/);
  });

  test("workspace heading does not link back to the legacy routing screen", async ({
    page,
  }) => {
    await page.goto("/dashboard/routing-workspace/rule");
    await expect(page.getByText("Rule-Based").first()).toBeVisible();
    await expect(
      page.getByRole("link", { name: "Smart Routing Configurations" }),
    ).toHaveCount(0);
  });

  for (const section of ["volume", "rule"]) {
    test(`restores ${section} without minting an intermediate section`, async ({
      page,
    }) => {
      await page.goto(`/dashboard/routing-workspace/${section}`);
      await expect(
        page.locator('iframe[title="Decision Engine"]'),
      ).toBeVisible();
      const targets: Array<string | null> = [];
      page.on("request", (request) => {
        const url = new URL(request.url());
        if (url.pathname.endsWith("/routing/entry")) {
          targets.push(url.searchParams.get("target"));
        }
      });
      // Match the SPA navigation performed by the OMP switch, preserving refs.
      await page.evaluate(() => {
        window.history.pushState({}, "", "/dashboard/routing-workspace");
        window.dispatchEvent(new PopStateEvent("popstate"));
      });
      await expect(page).toHaveURL(new RegExp(`routing-workspace/${section}`));
      await expect(
        page.locator('iframe[title="Decision Engine"]'),
      ).toBeVisible();
      expect(targets).toEqual([section]);
    });
  }
});
