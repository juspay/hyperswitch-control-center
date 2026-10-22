import { test, expect } from "@playwright/test";
import webpack from "webpack";
import path from "node:path";
import fs from "node:fs/promises";
import os from "node:os";

let bundle: string;
let directory: string;
test.beforeAll(async () => {
  directory = await fs.mkdtemp(path.join(os.tmpdir(), "accordion-fixture-"));
  await new Promise<void>((resolve, reject) => {
    webpack(
      {
        mode: "development",
        entry: path.resolve("playwright-tests/accordion/fixture.js"),
        output: { path: directory, filename: "fixture.js" },
        devtool: false,
        performance: { hints: false },
      },
      (error, stats) => {
        if (error || stats?.hasErrors())
          reject(error || new Error(stats?.toString("errors-only")));
        else resolve();
      },
    );
  });
  bundle = await fs.readFile(path.join(directory, "fixture.js"), "utf8");
});
test.afterAll(async () => {
  if (directory) await fs.rm(directory, { recursive: true, force: true });
});

async function fixture(page: import("@playwright/test").Page, query = "") {
  await page.route("**/__accordion-fixture**", (route) =>
    route.fulfill({
      contentType: "text/html",
      body: '<style>.hidden{display:none}</style><div id="root"></div><script src="/accordion-fixture.js"></script>',
    }),
  );
  await page.route("**/accordion-fixture.js", (route) =>
    route.fulfill({ contentType: "text/javascript", body: bundle }),
  );
  await page.goto(`/__accordion-fixture${query}`);
}

for (const width of [1440, 390]) {
  test(`live webhook multiple-open and keyboard at ${width}px`, async ({
    page,
  }) => {
    test.skip(
      !process.env.PLAYWRIGHT_STORAGE_STATE,
      "Supply auth via PLAYWRIGHT_STORAGE_STATE; no credentials in tests",
    );
    await page.setViewportSize({ width, height: 1000 });
    // No business mutations are allowed. Unexpected writes are blocked, not replayed.
    await page.route("**/api/**", async (route) => {
      const request = route.request();
      if (["PUT", "PATCH", "DELETE"].includes(request.method()))
        await route.abort();
      else await route.continue();
    });
    await page.goto("/dashboard/payment-settings");
    await page.getByText("Webhook Configuration", { exact: true }).click();
    const root = page.locator('[data-accordion="accordion-v2"]');
    const payments = root.getByRole("button", {
      name: "Payments",
      exact: true,
    });
    const refunds = root.getByRole("button", { name: "Refunds", exact: true });
    await expect(payments).toHaveAttribute("aria-expanded", "false");
    await payments.click();
    await expect(payments).toHaveAttribute("aria-expanded", "true");
    await refunds.focus();
    await refunds.press("Enter");
    await expect(refunds).toHaveAttribute("aria-expanded", "true");
    await expect(payments).toHaveAttribute("aria-expanded", "true");
    await refunds.press("Space");
    await expect(refunds).toHaveAttribute("aria-expanded", "false");
    await payments.focus();
    await payments.press("ArrowDown");
    await expect(refunds).toBeFocused();
    await payments.click();
    await expect(payments).toHaveAttribute("aria-expanded", "false");
    const box = await root.boundingBox();
    expect(box!.width).toBeLessThanOrEqual(width);
    if (process.env.ACCORDION_EVIDENCE_DIR) {
      await root.screenshot({
        path: path.join(
          process.env.ACCORDION_EVIDENCE_DIR,
          `after-${width}.png`,
        ),
        mask: [root.locator("input")],
      });
    }
  });
}

test("compiled adapter single-open, callbacks, close and disabled binding", async ({
  page,
}) => {
  await fixture(page, "?single");
  const root = page.locator('[data-accordion="accordion-v2"]').first();
  const first = root.getByRole("button", { name: "First", exact: true });
  const second = root.getByRole("button", { name: "Second", exact: true });
  await expect(first).toHaveAttribute("aria-expanded", "true");
  await second.click();
  await expect(first).toHaveAttribute("aria-expanded", "false");
  await expect(second).toHaveAttribute("aria-expanded", "true");
  await second.click();
  await expect(second).toHaveAttribute("aria-expanded", "false");
  await first.click();
  await root.getByRole("button", { name: "Close First" }).click();
  await expect(first).toHaveAttribute("aria-expanded", "false");
  expect(
    await page.evaluate(
      () =>
        (window as unknown as { accordionEvents: string[] }).accordionEvents,
    ),
  ).toEqual(["Second:expand", "Second:collapse", "First:expand"]);
  await expect(
    page.getByRole("button", { name: "Disabled item" }),
  ).toBeDisabled();
  await expect(page.getByText("Must stay hidden")).not.toBeVisible();
});

for (const query of ["?legacy", "?custom"]) {
  test(`compiled adapter fallback ${query}`, async ({ page }) => {
    await fixture(page, query);
    const title = query === "?custom" ? "Second custom" : "Second";
    await page.getByText(title, { exact: true }).click();
    await expect(
      page.getByRole("button", { name: "Close Second" }),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Close First" }),
    ).toBeVisible();
    await page.getByRole("button", { name: "Close Second" }).click();
    await expect(
      page.getByRole("button", { name: "Close Second" }),
    ).not.toBeVisible();
    // The only v2 root is the separate disabled-item fixture.
    await expect(page.locator('[data-accordion="accordion-v2"]')).toHaveCount(
      1,
    );
  });
}
