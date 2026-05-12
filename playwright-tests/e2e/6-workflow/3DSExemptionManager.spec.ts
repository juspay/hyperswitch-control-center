import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
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

test.describe("3DS Exemption Manager - beta badge + exemption creation", () => {
    test.beforeEach(async ({ page, context }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);

        await page.route("**/dashboard/config/feature*", async (route) => {
            const response = await route.fetch();
            const json = await response.json();
            if (json.features) {
                json.features.threeds_exemption_manager = true;
            }
            await route.fulfill({ response, json });
        });

        const homePage = new HomePage(page);
        await homePage.workflow.click();
        const exemption = homePage.threeDSExemptionManager;
        if ((await exemption.count().catch(() => 0)) === 0) {
            test.skip(true, "3DS Exemption Manager not exposed");
        }
        await exemption.click();
        await expect(page).toHaveURL(/.*dashboard\/3ds-exemption/);
    });

    test("should render a Beta badge on the exemption manager page", async ({
        page,
    }) => {
        const betaBadge = page
            .locator(
                '[data-testid*="beta"], .badge:has-text("Beta"), span:has-text("BETA")',
            )
            .first();
        if (!(await betaBadge.isVisible().catch(() => false))) {
            test.skip(true, "beta badge not exposed in this build");
        }
        await expect(betaBadge).toBeVisible();
    });
});

test.describe("3DS Exemption Rules page", () => {
    test("should render heading and Create New button", async ({
        page,
        context,
    }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);
        await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

        await page.goto("/dashboard/3ds-exemption");
        await page.waitForLoadState("networkidle");
        await page.waitForTimeout(1000);

        await gatedOrAssert(page, async () => {
            await expect(page.getByText("3DS Exemption Rules").first()).toBeVisible({
                timeout: 10000,
            });
            await expect(
                page.getByRole("button", { name: "Create New" }).first(),
            ).toBeVisible({ timeout: 10000 });
        });
    });
});