import { Page, Locator } from "@playwright/test";

export class SystemPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // UnauthorizedPage renders its message through NoDataFound; match on a stable
  // substring to stay resilient to surrounding markup/punctuation.
  get unauthorizedMessage(): Locator {
    return this.page.getByText("don't have access to this module").first();
  }

  get goToHomeButton(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  // Surfaced by PageLoaderWrapper when setUpDashboard's API calls reject.
  get dashboardSetupError(): Locator {
    return this.page.getByText("Failed to setup dashboard!", { exact: true }).first();
  }

  async navigateToHome(): Promise<void> {
    await this.page.goto("/dashboard/home");
    await this.page.waitForLoadState("networkidle");
  }

  async navigateToUnauthorized(): Promise<void> {
    await this.page.goto("/dashboard/unauthorized");
    await this.page.waitForLoadState("networkidle");
  }

  async navigateToInvalidRoute(): Promise<void> {
    await this.page.goto("/dashboard/this-route-does-not-exist");
    await this.page.waitForLoadState("networkidle");
  }

  async clickGoToHome(): Promise<void> {
    await this.goToHomeButton.click();
    await this.page.waitForLoadState("networkidle");
  }

  // Force the dashboard bootstrap (GET /account) to fail so the page loader
  // wrapper drops into its error state.
  async failDashboardSetup(): Promise<void> {
    await this.page.route(/\/account(\?|$)/, async (route) => {
      if (route.request().method() === "GET") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { message: "setup failed" } }),
        });
      } else {
        await route.fallback();
      }
    });
  }
}

export default SystemPage;
