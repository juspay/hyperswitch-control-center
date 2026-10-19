import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import {
  generateUniqueEmail,
  generateDateTimeString,
} from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Mirrors DecisionEngineUtils.sections (inSidebar: true), in sidebar order.
const SIDEBAR_SECTIONS = [
  { slug: "audit", label: "Decision Audit" },
  { slug: "multi_objective", label: "Multi Objective" },
  { slug: "rule", label: "Rule-Based" },
  { slug: "volume", label: "Volume Split" },
  { slug: "debit", label: "Debit Routing" },
  { slug: "ab-testing", label: "A/B Testing" },
  { slug: "simulator", label: "Decision Simulator" },
];

// Page title text, excluding the identically-named sidebar link.
const pageHeading = (page: Page, title: string) =>
  page.locator(
    `xpath=//div[normalize-space(text())="${title}"][not(ancestor::a)]`,
  );

const expectWorkspacePage = async (page: Page, label: string) => {
  const openInNewTab = page.getByRole("button", { name: "Open in new tab" });
  await expect(openInNewTab).toBeVisible();
  // The workspace header bar holds both the title and the new-tab button, so
  // scoping to it keeps sidebar entries with the same text out of the match.
  const headerBar = openInNewTab.locator(
    "xpath=ancestor::div[contains(@class,'h-12')][1]",
  );
  await expect(headerBar.getByText(label, { exact: true })).toBeVisible();
  const frame = page.locator('iframe[title="Decision Engine"]');
  await expect(frame).toBeVisible();
  await expect(frame).toHaveAttribute("src", /[?&]embed=1/);
  await expect(
    page.getByRole("link", { name: "Smart Routing Configurations" }),
  ).toHaveCount(0);
};

// Local has no cut-over profiles, so answer the routing/entry probe with one.
const mockCutover = async (page: Page) => {
  await page.route("**/routing/entry**", async (route: Route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        is_cutover: true,
        redirect_url: `${new URL(page.url()).origin}/decision-engine/routing/rules`,
      }),
    });
  });
};

// page.request bypasses page.route, so this always reads the real flag.
const embedEnabled = async (page: Page): Promise<boolean> => {
  const res = await page.request.get("/config/feature");
  if (!res.ok()) return false;
  const body = await res.json();
  return Boolean((body?.features ?? body)?.dev_embed_decision_engine);
};

const forceEmbedDecisionEngineOn = async (page: Page) => {
  await page.route("**/config/feature**", async (route: Route) => {
    // The page can close mid-request at teardown; drop it instead of failing.
    const res = await route.fetch().catch(() => null);
    if (!res) return;
    const body = await res.json();
    (body?.features ?? body).dev_embed_decision_engine = true;
    await route.fulfill({ response: res, json: body });
  });
};

test.describe("Decision Engine routing workspace", () => {
  test.beforeEach(async ({ page }) => {
    // Local has the embed off and no cutover → mock both. Integ/sandbox have
    // it on with every profile cut over → run against the real backend.
    if (!(await embedEnabled(page))) {
      await forceEmbedDecisionEngineOn(page);
      await mockCutover(page);
    }
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("sidebar lists every Decision Engine section and drops legacy Routing from Workflow", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    const deGroup = page.getByTestId("decisionenginerouting");
    await deGroup.getByText("Decision Engine Routing", { exact: true }).click();

    const links = deGroup.getByRole("link");
    await expect(links).toHaveText([
      ...SIDEBAR_SECTIONS.map((s) => s.label),
      "Default Fallback",
    ]);
    for (const { slug, label } of SIDEBAR_SECTIONS) {
      await expect(
        deGroup.getByRole("link", { name: label, exact: true }),
      ).toHaveAttribute(
        "href",
        new RegExp(`/routing-workspace/${slug}(\\?|$)`),
      );
    }
    await expect(
      deGroup.getByRole("link", { name: "Default Fallback", exact: true }),
    ).toHaveAttribute("href", /\/routing\/default(\?|$)/);

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    await expect(homePage.routing).toHaveCount(0);
  });

  test("each sidebar section opens its workspace page with heading, new-tab button and iframe", async ({
    page,
  }) => {
    test.setTimeout(120000);
    await page.goto("/dashboard/home");
    const deGroup = page.getByTestId("decisionenginerouting");
    await deGroup.getByText("Decision Engine Routing", { exact: true }).click();

    for (const { slug, label } of SIDEBAR_SECTIONS) {
      await test.step(label, async () => {
        await deGroup.getByRole("link", { name: label, exact: true }).click();
        await expect(page).toHaveURL(
          new RegExp(`/routing-workspace/${slug}/?$`),
        );
        await expectWorkspacePage(page, label);
      });
    }
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
    await expect(
      page.getByRole("link", { name: "Smart Routing Configurations" }),
    ).toHaveCount(0);
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
});
