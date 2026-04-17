/**
 * Exploration scout — NOT a test.
 *
 * Visits every dashboard page listed below, captures:
 *   - final URL (so we know which FF-gated pages redirect)
 *   - visible headings
 *   - counts of interactive elements (buttons, inputs, selects, links, tabs, grids, dropdowns)
 *   - the first 30 visible button labels
 *
 * Writes the result as JSON to .opencode/sessions/playwright-run/explore.json.
 * Run with: npx playwright test playwright-tests/ai-generated/_explore.spec.ts
 *
 * This file is checked in as a utility spec; it runs a single `test()` so the
 * exploration happens inside the Playwright harness (real browser, same
 * fixtures as every other spec). It's kept under ai-generated/ so it's
 * trivially deletable when no longer needed.
 */

import { test, expect } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

const ROUTES = [
  "/dashboard/home",
  "/dashboard/payments",
  "/dashboard/refunds",
  "/dashboard/disputes",
  "/dashboard/customers",
  "/dashboard/payouts",
  "/dashboard/connectors",
  "/dashboard/payoutconnectors",
  "/dashboard/3ds-authenticators",
  "/dashboard/fraud-risk-management",
  "/dashboard/pm-authentication-processor",
  "/dashboard/tax-processor",
  "/dashboard/billing-processor",
  "/dashboard/vault-processor",
  "/dashboard/analytics-payments",
  "/dashboard/analytics-refunds",
  "/dashboard/analytics-disputes",
  "/dashboard/analytics-routing",
  "/dashboard/performance-monitor",
  "/dashboard/new-analytics",
  "/dashboard/routing",
  "/dashboard/3ds",
  "/dashboard/3ds-exemption",
  "/dashboard/surcharge",
  "/dashboard/payoutrouting",
  "/dashboard/vault-onboarding",
  "/dashboard/vault-customers-tokens",
  "/dashboard/developer-api-keys",
  "/dashboard/payment-settings",
  "/dashboard/webhooks",
  "/dashboard/configure-pmts",
  "/dashboard/compliance",
  "/dashboard/organization-settings",
  "/dashboard/payment-link-theme",
  "/dashboard/users",
  "/dashboard/account-settings/profile",
  "/dashboard/apm",
  "/dashboard/recon",
  "/dashboard/upload-files",
  "/dashboard/run-recon",
  "/dashboard/recon-analytics",
  "/dashboard/reports",
  "/dashboard/config-settings",
];

interface PageFindings {
  url: string;
  finalUrl: string;
  bodyLen?: number;
  bodySnippet?: string;
  headings: string[];
  counts: {
    buttons: number;
    inputs: number;
    selects: number;
    links: number;
    tabs: number;
    grids: number;
    dropdowns: number;
    toggles: number;
  };
  buttonLabels: string[];
  inputPlaceholders: string[];
  tabLabels: string[];
  hasNoResultsFound: boolean;
  pageErrors: string[];
}

test.describe.configure({ mode: "serial" });

test("explore all dashboard pages", async ({ page, context }) => {
  test.setTimeout(600_000);

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const results: PageFindings[] = [];

  for (const route of ROUTES) {
    const pageErrors: string[] = [];
    const errorHandler = (err: Error) => pageErrors.push(err.message);
    page.on("pageerror", errorHandler);

    await page.goto(route, { waitUntil: "domcontentloaded" }).catch(() => {});
    await page
      .waitForLoadState("networkidle", { timeout: 10000 })
      .catch(() => {});
    // React hydration / animation settle — many ReScript routes mount with
    // a framer-motion transition that starts at opacity:0 and animates in.
    await page.waitForTimeout(1500);

    const finalUrl = page.url();

    const snapshot = await page.evaluate(() => {
      const isVisible = (el: Element): boolean => {
        const rect = (el as HTMLElement).getBoundingClientRect();
        if (rect.width === 0 || rect.height === 0) return false;
        const style = window.getComputedStyle(el as HTMLElement);
        return (
          style.display !== "none" &&
          style.visibility !== "hidden" &&
          style.opacity !== "0"
        );
      };
      const qAll = <T extends Element>(sel: string): T[] =>
        Array.from(document.querySelectorAll<T>(sel)).filter(isVisible);

      const buttons = qAll<HTMLElement>(
        'button, [role="button"], [data-button-for], [data-button-text]',
      );
      const inputs = qAll<HTMLInputElement>("input, textarea");
      const selects = qAll<HTMLSelectElement>("select");
      const links = qAll<HTMLAnchorElement>("a[href]");
      const tabs = qAll<HTMLElement>(
        '[role="tab"], [data-testid="tab"], [class*="transaction-view-tab"]',
      );
      const grids = qAll<HTMLElement>(
        '[role="grid"], table, [class*="grid-cols-"]',
      );
      const dropdowns = qAll<HTMLElement>(
        '[role="combobox"], [data-testid*="dropdown"], [class*="dropdown"]',
      );
      const toggles = qAll<HTMLElement>(
        '[role="switch"], [data-testid*="toggle"]',
      );
      const headings = qAll<HTMLElement>(
        'h1, h2, h3, [class*="card-header"], [id*="card-header"], [class*="text-fs-24"], [class*="text-fs-28"], [class*="text-fs-32"]',
      ).map((el) => (el.innerText || "").trim().replace(/\s+/g, " "));

      const btnLabel = (el: HTMLElement): string => {
        const dataFor = el.getAttribute("data-button-for");
        const dataText = el.getAttribute("data-button-text");
        const inner = (el.innerText || "").trim().replace(/\s+/g, " ");
        return inner || dataText || dataFor || "";
      };

      return {
        bodyLen: document.body.innerHTML.length,
        bodySnippet: document.body.innerText.slice(0, 200),
        counts: {
          buttons: buttons.length,
          inputs: inputs.length,
          selects: selects.length,
          links: links.length,
          tabs: tabs.length,
          grids: grids.length,
          dropdowns: dropdowns.length,
          toggles: toggles.length,
        },
        headings: headings.filter((t) => t.length > 0).slice(0, 10),
        buttonLabels: buttons
          .map(btnLabel)
          .filter((t) => t.length > 0 && t.length < 80)
          .slice(0, 30),
        inputPlaceholders: inputs
          .map((i) => i.placeholder)
          .filter(Boolean)
          .slice(0, 20),
        tabLabels: tabs
          .map((t) => (t.innerText || "").trim().replace(/\s+/g, " "))
          .filter((t) => t.length > 0)
          .slice(0, 20),
      };
    });

    const { counts, headings, buttonLabels, inputPlaceholders, tabLabels } =
      snapshot;
    const bodyLen = snapshot.bodyLen;
    const bodySnippet = snapshot.bodySnippet;

    const hasNoResultsFound = await page
      .getByText("No results found")
      .first()
      .isVisible()
      .catch(() => false);

    page.off("pageerror", errorHandler);

    results.push({
      url: route,
      finalUrl,
      bodyLen,
      bodySnippet,
      headings: headings.slice(0, 10),
      counts,
      buttonLabels,
      inputPlaceholders,
      tabLabels,
      hasNoResultsFound,
      pageErrors,
    });
  }

  const outPath = path.resolve(
    __dirname,
    "../../.opencode/sessions/playwright-run/explore.json",
  );
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(results, null, 2));

  console.log(
    `[explore] wrote ${results.length} page findings to ${outPath}`,
  );

  expect(results.length).toBe(ROUTES.length);
});
