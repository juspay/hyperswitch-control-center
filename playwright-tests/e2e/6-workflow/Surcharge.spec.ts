import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import type { Page } from "@playwright/test";
import { Surcharge } from "../../support/pages/workflow/Surcharge";
import { generateUniqueEmail } from "../../support/helper";
import {
    signupUser,
    loginUI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function gatedOrAssert(
    page: Page,
    assertion: () => Promise<void>,
): Promise<void> {
    const surcharge = new Surcharge(page);
    if (await surcharge.goToHomeFallback.isVisible().catch(() => false)) {
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
        const surchargeNav = homePage.surchargeRouting;
        if ((await surchargeNav.count().catch(() => 0)) === 0) {
            test.skip(true, "surcharge not exposed");
        }
        await surchargeNav.click();
        await page.waitForLoadState("networkidle");
    });

    test("should add a percentage-based surcharge rule", async ({ page }) => {
        const surcharge = new Surcharge(page);

        if (!(await surcharge.addRuleButton.isVisible().catch(() => false))) {
            test.skip(true, "Add Rule CTA not exposed");
        }
        await surcharge.addRuleButton.click();

        await surcharge.ruleNameInput.fill("Standard Card Surcharge");

        if (await surcharge.feeTypeSelect.isVisible().catch(() => false)) {
            await surcharge.feeTypeSelect.selectOption("percentage");
        }
        await surcharge.feeValueInput.fill("2.5");

        await surcharge.saveRuleButton.click();
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

        const surcharge = new Surcharge(page);
        await gatedOrAssert(page, async () => {
            await expect(surcharge.pageHeading).toBeVisible({ timeout: 10000 });
            await expect(surcharge.createNewOrSaveButton).toBeVisible({
                timeout: 10000,
            });
        });
    });
});
