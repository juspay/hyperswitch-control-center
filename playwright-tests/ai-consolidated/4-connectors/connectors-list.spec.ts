import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payment processors list page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
    await page.goto("/dashboard/connectors");
    await page.waitForLoadState("networkidle");
  });

  test("should display 'Connect a new processor' subtitle and 'Request a Processor' CTA", async ({
    page,
  }) => {
    await expect(
      page.getByText(/Connect a new processor/i).first(),
    ).toBeVisible({ timeout: 10000 });
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should render a processor grid with multiple Connect buttons", async ({
    page,
  }) => {
    const connectBtns = page.getByRole("button", { name: "Connect" });
    await expect(connectBtns.first()).toBeVisible({ timeout: 20000 });
    const count = await connectBtns.count();
    expect(count).toBeGreaterThan(5);
  });

  test("should filter the processor grid when searching a known processor", async ({
    page,
  }) => {
    const search = page.getByPlaceholder("Search a processor");
    await search.fill("adyen");
    await page.waitForTimeout(500);
    await expect(page.getByText(/adyen/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("should render zero Connect buttons when the search term has no matches", async ({
    page,
  }) => {
    const search = page.getByPlaceholder("Search a processor");
    await search.fill("nonexistentprocessor_zzzzzzzz");
    await page.waitForTimeout(700);
    const connectVisible = await page
      .getByRole("button", { name: "Connect", exact: true })
      .filter({ visible: true })
      .count();
    expect(connectVisible).toBe(0);
  });
});
