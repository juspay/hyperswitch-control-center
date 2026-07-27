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

  // Events Listing
  get pageHeading(): Locator {
    return this.page.getByText("Webhooks", { exact: true }).first();
  }

  get searchTypeSelector(): Locator {
    return this.page
      .getByRole("button", { name: /Object ID|Event ID/ })
      .first();
  }

  get objectIdOption(): Locator {
    return this.page.getByRole("button", { name: "Object ID" }).last();
  }

  get eventIdOption(): Locator {
    return this.page.getByRole("button", { name: "Event ID" }).last();
  }

  get dateRangeFilter(): Locator {
    return this.page.locator('div').filter({ hasText: /^CustomSelect date range$/ }).first();
  }

  get notConfiguredMessage(): Locator {
    return this.page.getByText("Webhook URL is not configured", {
      exact: false,
    });
  }

  get noDataMessage(): Locator {
    return this.page.getByText("No data found", { exact: false });
  }

  get refreshButton(): Locator {
    return this.page.getByRole("button", { name: "Refresh" });
  }

  columnHeader(title: string): Locator {
    return this.page.locator(`[data-table-heading="${title}"]`);
  }

  cellByText(text: string): Locator {
    return this.page.getByText(text, { exact: true }).first();
  }

  get paginationInfo(): Locator {
    return this.page.getByText("Showing", { exact: false });
  }

  paginationPageButton(pageNumber: number): Locator {
    return this.page.getByRole("button", {
      name: `${pageNumber}`,
      exact: true,
    });
  }

  // Event Detail
  get breadcrumb(): Locator {
    return this.page.getByText("Webhooks home", { exact: true });
  }

  get requestTab(): Locator {
    return this.page.getByText("Request", { exact: true }).first();
  }

  get responseTab(): Locator {
    return this.page.getByText("Response", { exact: true }).first();
  }

  get retryWebhookButton(): Locator {
    return this.page.getByRole("button", { name: "Retry Webhook" });
  }

  get breadcrumbRoot(): Locator {
    return this.page.getByText("Webhooks", { exact: true }).first();
  }

  // The attempts table uses the LoadedTable title " " (single space), so the
  // data-table-location values are suffixed " _tr{row}_td{col}".
  detailTableCell(row: number, col: number): Locator {
    return this.page.locator(`[data-table-location$="_tr${row}_td${col}"]`);
  }

  get webhookDeliveryLabel(): Locator {
    return this.page.getByText("Webhook Delivery", { exact: false });
  }

  deliveryAttemptLabel(title: string): Locator {
    return this.page.getByText(title, { exact: true });
  }

  get statusCodeLabel(): Locator {
    return this.page.getByText("Status Code", { exact: false }).first();
  }

  get headersLabel(): Locator {
    return this.page.getByText("Headers", { exact: true }).first();
  }

  get bodyLabel(): Locator {
    return this.page.getByText("Body", { exact: true }).first();
  }

  // Add Endpoint
  get addEndpointButton(): Locator {
    return this.page
      .locator(
        '[data-button-for="addWebhook"], button:has-text("Add Endpoint")',
      )
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
    return this.page.locator(
      '[data-toast*="created"], [data-toast*="success"]',
    );
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
    return this.page.locator(
      '[data-toast*="disabled"], [data-toast*="updated"]',
    );
  }
}

export default Webhooks;
