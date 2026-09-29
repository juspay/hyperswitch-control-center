import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import {
  generateUniqueEmail,
  generateDateTimeString,
} from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const stubCutover = async (page: Page, counter: { calls: number }) => {
  await page.route("**/routing/entry**", async (route: Route) => {
    counter.calls += 1;
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

  test("forwards live themes and resets to defaults without reloading DE", async ({
    page,
  }) => {
    await page.route("**/decision-engine/routing/rules?**", (route) =>
      route.fulfill({
        contentType: "text/html",
        body: `<!doctype html><input aria-label="Unsaved rule"><pre id="theme"></pre>
          <script>
            const frameId = crypto.randomUUID();
            const ready = () => parent.postMessage({type: 'de:theme-ready', version: 1, frameId}, location.origin);
            addEventListener('message', event => {
              if (event.source !== parent || event.origin !== location.origin) return;
              if (event.data.type === 'de:theme-request') ready();
              if (event.data.type === 'de:theme-update' && event.data.frameId === frameId) {
                document.getElementById('theme').textContent = JSON.stringify(event.data.tokens);
              }
            });
            ready();
          </script>`,
      }),
    );
    await page.goto("/dashboard/routing-workspace/rule");
    const frame = page.frameLocator('iframe[title="Decision Engine"]');
    await expect(frame.locator("#theme")).toContainText('"primary":');
    await frame
      .getByRole("textbox", { name: "Unsaved rule" })
      .fill("draft rule");
    const initialCalls = counter.calls;
    await frame
      .locator("#theme")
      .evaluate(() =>
        parent.postMessage(
          { type: "de:theme-ready", version: 1.5, frameId: "invalid-version" },
          location.origin,
        ),
      );
    await page.evaluate(() =>
      window.postMessage(
        { type: "de:theme-ready", version: 1, frameId: "wrong-source" },
        location.origin,
      ),
    );
    await page.evaluate(() =>
      window.postMessage(
        {
          type: "init_config",
          init_config: {
            settings: {
              colors: { primary: "#7138a8", background: "#f2f0f7" },
              buttons: {
                primary: {
                  backgroundColor: "#24639a",
                  textColor: "#ffffff",
                  hoverBackgroundColor: "#194b76",
                },
              },
            },
          },
        },
        location.origin,
      ),
    );
    await expect(frame.locator("#theme")).toContainText('"primary":"#7138a8"');
    await expect(frame.locator("#theme")).toContainText(
      '"primaryButtonBackground":"#24639a"',
    );
    await expect(
      frame.getByRole("textbox", { name: "Unsaved rule" }),
    ).toHaveValue("draft rule");
    expect(counter.calls).toBe(initialCalls);
    await page.evaluate(() =>
      window.postMessage(
        { type: "init_config", init_config: null },
        location.origin,
      ),
    );
    await expect(frame.locator("#theme")).toContainText('"primary":"#006DF9"');
    await expect(
      frame.getByRole("textbox", { name: "Unsaved rule" }),
    ).toHaveValue("draft rule");
  });

  for (const section of ["volume", "rule"]) {
    test(`preserves ${section} and clears the old rule on profile switch`, async ({
      page,
    }) => {
      await page.goto(`/dashboard/routing-workspace/${section}?rule=old-rule`);
      const homePage = new HomePage(page);
      const profileName = `pw_profile_${generateDateTimeString()}`;
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
      await homePage.profileDropdown.click();
      await homePage.clickCreateNewOption();
      await homePage.newProfileNameInput.fill(profileName);
      await homePage.addProfileButton.click();
      await expect(homePage.ompDropdownItem(profileName)).toBeVisible();
      await homePage.ompDropdownItem(profileName).click();
      await expect(homePage.profileDropdown).toContainText(profileName);
      await expect(page).toHaveURL(
        new RegExp(`routing-workspace/${section}/?$`),
      );
      await expect(
        page.locator('iframe[title="Decision Engine"]'),
      ).toBeVisible();
      expect(targets.filter((target) => target !== null)).toEqual([section]);
    });
  }
});
