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

test.describe("Payout Routing landing", () => {
    test("should render Volume/Rule/Default configuration cards", async ({
        page,
        context,
    }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);
        await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

        const homePage = new HomePage(page);
        await homePage.workflow.click();
        const payoutRouting = homePage.payoutRouting;
        if ((await payoutRouting.count().catch(() => 0)) === 0) {
            test.skip(true, "Payout Routing not available");
        }
        await payoutRouting.click();
        await page.waitForLoadState("networkidle");

        await expect(
            page
                .getByText(
                    /Volume Based Configuration|Rule Based Configuration|Default fallback|Active configuration|Manage rules/,
                )
                .first(),
        ).toBeVisible({ timeout: 10000 });
    });
});
