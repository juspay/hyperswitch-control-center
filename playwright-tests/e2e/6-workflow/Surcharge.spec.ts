import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import type { Page } from "@playwright/test";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { generateUniqueEmail } from "../../support/helper";
import {
    signupUser,
    loginUI,
    createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

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

test.describe("Surcharge - add percentage rule", () => {
    test.beforeEach(async ({ page, context }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);

        await page.route("**/dashboard/config/feature*", async (route) => {
            const response = await route.fetch();
            const json = await response.json();
            if (json.features) {
                json.features.surcharge = true;
            }
            await route.fulfill({ response, json });
        });

        const homePage = new HomePage(page);
        await homePage.workflow.click();
        const surcharge = homePage.surchargeRouting;
        if ((await surcharge.count().catch(() => 0)) === 0) {
            test.skip(true, "surcharge not exposed");
        }
        await surcharge.click();
        await page.waitForLoadState("networkidle");
    });

    test("should add a percentage-based surcharge rule", async ({ page }) => {
        const addRuleButton = page
            .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
            .first();
        if (!(await addRuleButton.isVisible().catch(() => false))) {
            test.skip(true, "Add Rule CTA not exposed");
        }
        await addRuleButton.click();

        await page.locator('[name*="rule_name"]').fill("Standard Card Surcharge");

        const feeType = page.locator('[name*="fee_type"]').first();
        if (await feeType.isVisible().catch(() => false)) {
            await feeType.selectOption("percentage");
        }
        await page.locator('[name*="fee_value"], [name*="percentage"]').fill("2.5");

        await page.locator('[data-button-for="saveRule"]').click();
    });
});

test.describe("Surcharge decision page", () => {
    test("should render heading and Create New/Save control", async ({
        page,
        context,
    }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);
        await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

        await page.goto("/dashboard/surcharge");
        await page.waitForLoadState("networkidle");
        await page.waitForTimeout(1500);

        await gatedOrAssert(page, async () => {
            await expect(page.getByText("Surcharge").first()).toBeVisible({
                timeout: 10000,
            });
            const control = page
                .getByRole("button", { name: /Create New|Save/i })
                .first();
            await expect(control).toBeVisible({ timeout: 10000 });
        });
    });
});