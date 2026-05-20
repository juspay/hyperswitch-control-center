import { Page, Locator } from "@playwright/test";

export class Webhooks {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Page Header / Listing
  get webhookHeading(): Locator {
    return this.page.getByText(/Webhook/i).first();
  }

  get searchByIdInput(): Locator {
    return this.page.getByPlaceholder("Search by ID");
  }

  get objectIdFilter(): Locator {
    return this.page.getByText("Object ID").first();
  }

  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  // Add Endpoint
  get addEndpointButton(): Locator {
    return this.page
      .locator('[data-button-for="addWebhook"], button:has-text("Add Endpoint")')
      .first();
  }

  get urlInput(): Locator {
    return this.page.locator('[name*="url"], [name*="endpoint_url"]');
  }

  get descriptionInput(): Locator {
    return this.page.locator('[name*="description"]');
  }

  get saveWebhookButton(): Locator {
    return this.page.locator('[data-button-for="saveWebhook"]');
  }

  get successOrCreatedToast(): Locator {
    return this.page.locator('[data-toast*="created"], [data-toast*="success"]');
  }

  // Event Subscription
  get firstEventCheckbox(): Locator {
    return this.page
      .locator(
        'input[type="checkbox"][name*="event"], [data-testid*="event-checkbox"]',
      )
      .first();
  }

  get saveEventsButton(): Locator {
    return this.page.locator('[data-button-for="saveEvents"]').first();
  }

  // Retry Policy
  get retryAttemptsInput(): Locator {
    return this.page
      .locator('[name*="retry_attempts"], [name*="max_retries"]')
      .first();
  }

  get retryIntervalInput(): Locator {
    return this.page.locator('[name*="retry_interval"]').first();
  }

  get saveRetryPolicyButton(): Locator {
    return this.page.locator('[data-button-for="saveRetryPolicy"]');
  }

  // Logs Tab
  get logsTab(): Locator {
    return this.page
      .locator('[role="tab"]:has-text("Logs"), [data-testid*="logs"]')
      .first();
  }

  // Endpoint Toggle
  get endpointToggle(): Locator {
    return this.page
      .locator(
        '[data-testid*="webhook-toggle"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
  }

  get disabledOrUpdatedToast(): Locator {
    return this.page.locator('[data-toast*="disabled"], [data-toast*="updated"]');
  }
}

export default Webhooks;
