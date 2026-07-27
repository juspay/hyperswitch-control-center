import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Webhooks } from "../../support/pages/developers/Webhooks";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// A configured webhook with a couple of delivered events. One event delivered
// successfully, the other failed — used to assert the table, columns and the
// success/failed delivery-status indicators.
const WEBHOOK_EVENTS = {
  total_count: 2,
  events: [
    {
      event_id: "evt_success_1",
      event_class: "payments",
      event_type: "payment_succeeded",
      merchant_id: "merchant_1",
      profile_id: "profile_1",
      object_id: "pay_success_1",
      is_delivery_successful: true,
      initial_attempt_id: "evt_success_1",
      created: "2026-05-29T10:00:00.000Z",
    },
    {
      event_id: "evt_failed_1",
      event_class: "refunds",
      event_type: "refund_succeeded",
      merchant_id: "merchant_1",
      profile_id: "profile_1",
      object_id: "ref_failed_1",
      is_delivery_successful: false,
      initial_attempt_id: "evt_failed_1",
      created: "2026-05-29T11:00:00.000Z",
    },
  ],
};

// The attempts payload backing the detail view for the successful event above.
const WEBHOOK_ATTEMPTS = [
  {
    event_id: "evt_success_1",
    event_class: "payments",
    event_type: "payment_succeeded",
    merchant_id: "merchant_1",
    profile_id: "profile_1",
    object_id: "pay_success_1",
    is_delivery_successful: true,
    initial_attempt_id: "evt_success_1",
    created: "2026-05-29T10:00:00.000Z",
    delivery_attempt: "initial_attempt",
    request: {
      body: '{"event_type":"payment_succeeded","object_id":"pay_success_1"}',
      headers: [["content-type", "application/json"]],
    },
    response: {
      body: '{"status":"received"}',
      headers: [["content-type", "application/json"]],
      status_code: 200,
      error_message: "",
    },
  },
];

async function mockWebhookEvents(page: Page, events = WEBHOOK_EVENTS) {
  await page.route("**/events/profile/list", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(events),
    });
  });
}

async function mockWebhookAttempts(page: Page, attempts = WEBHOOK_ATTEMPTS) {
  await page.route("**/events/*/*/attempts", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(attempts),
    });
  });
}

// Mirrors the backend search: the list call carries an `object_id` or `event_id`
// key when searching, so only the matching events are returned.
async function mockWebhookSearch(page: Page, events = WEBHOOK_EVENTS) {
  await page.route("**/events/profile/list", async (route) => {
    const body = (route.request().postDataJSON() ?? {}) as Record<
      string,
      unknown
    >;
    let filtered = events.events;
    if (typeof body.object_id === "string") {
      filtered = filtered.filter((e) => e.object_id === body.object_id);
    } else if (typeof body.event_id === "string") {
      filtered = filtered.filter((e) => e.event_id === body.event_id);
    }
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ total_count: filtered.length, events: filtered }),
    });
  });
}

test.describe("Webhooks events listing and detail", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  async function openWebhooks(page: Page) {
    const homePage = new HomePage(page);
    await homePage.developer.click();
    await homePage.webhooks.click();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);
  }

  test("should render heading, search-by-id input and the Object ID / Event ID type selector", async ({
    page,
  }) => {
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await expect(webhooks.pageHeading).toBeVisible({ timeout: 10000 });
    await expect(webhooks.searchByIdInput).toBeVisible({ timeout: 10000 });

    await webhooks.searchTypeSelector.click();
    await expect(webhooks.objectIdOption).toBeVisible({ timeout: 10000 });
    await expect(webhooks.eventIdOption).toBeVisible({ timeout: 10000 });

    await expect(webhooks.dateRangeFilter).toBeVisible({ timeout: 10000 });
    await expect(webhooks.notConfiguredMessage).toBeVisible({ timeout: 10000 });
  });

  test("should populate the events table with rows when webhook events exist", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await expect(webhooks.cellByText("pay_success_1")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("ref_failed_1")).toBeVisible({
      timeout: 10000,
    });
  });

  test("should render the Event ID, Object ID, Delivery Status and Created columns", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await expect(webhooks.columnHeader("Event ID")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Object ID")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Profile ID")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Event Class")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Event Type")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Delivery Status")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Created")).toBeVisible({
      timeout: 10000,
    });
  });

  test("should surface successful and failed delivery-status indicators", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await expect(webhooks.cellByText("True")).toBeVisible({ timeout: 10000 });
    await expect(webhooks.cellByText("False")).toBeVisible({ timeout: 10000 });
  });

  test("should open the event detail view with request/response tabs on row click", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await mockWebhookAttempts(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await webhooks.cellByText("payment_succeeded").click();
    await expect(page).toHaveURL(/dashboard\/webhooks\/evt_success_1/, {
      timeout: 10000,
    });
    await expect(webhooks.breadcrumb).toBeVisible({ timeout: 10000 });
    await expect(webhooks.requestTab).toBeVisible({ timeout: 10000 });
    await expect(webhooks.responseTab).toBeVisible({ timeout: 10000 });
  });

  test("should display the request and  response status code and body in the detail view", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await mockWebhookAttempts(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await webhooks.cellByText("payment_succeeded").click();
    await expect(page).toHaveURL(/dashboard\/webhooks\/evt_success_1/, {
      timeout: 10000,
    });

    await expect(webhooks.webhookDeliveryLabel).toBeVisible({ timeout: 10000 });
    await expect(webhooks.retryWebhookButton).toBeVisible({ timeout: 10000 });
    await expect(
      page.getByText(
        'Headerscontent-type: application/jsonBody1{ 2 "event_type": "payment_succeeded", 3 "object_id": "pay_success_1" 4}',
      ),
    ).toBeVisible();

    await webhooks.responseTab.click();
    await expect(webhooks.statusCodeLabel).toBeVisible({ timeout: 10000 });
    await expect(webhooks.cellByText("200")).toBeVisible({ timeout: 10000 });
    await expect(
      page.getByText(
        'Status Code: 200Headerscontent-type: application/jsonBody1{ 2 "status": "received" 3}',
      ),
    ).toBeVisible();
  });

  test("should render the attempts table columns and row cells in the detail view", async ({
    page,
  }) => {
    await mockWebhookEvents(page);
    await mockWebhookAttempts(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await webhooks.cellByText("payment_succeeded").click();
    await expect(page).toHaveURL(/dashboard\/webhooks\/evt_success_1/, {
      timeout: 10000,
    });

    // Breadcrumb: Webhooks / Webhooks home
    await expect(webhooks.breadcrumbRoot).toBeVisible({ timeout: 10000 });
    await expect(webhooks.breadcrumb).toBeVisible({ timeout: 10000 });

    // Attempts table columns: S.No, Delivery Status, Delivery Attempt, Created
    await expect(webhooks.columnHeader("S.No")).toBeVisible({ timeout: 10000 });
    await expect(webhooks.columnHeader("Delivery Status")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Delivery Attempt")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.columnHeader("Created")).toBeVisible({
      timeout: 10000,
    });

    // Row cells: 1, True, initial_attempt, May 29, 2026 03:30:00 PM IST
    await expect(webhooks.detailTableCell(1, 1)).toContainText("1");
    await expect(webhooks.detailTableCell(1, 2)).toContainText("True");
    await expect(webhooks.detailTableCell(1, 3)).toContainText(
      "initial_attempt",
    );
  });

  test("should filter the events list when searching by Object ID and Event ID", async ({
    page,
  }) => {
    await mockWebhookSearch(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    // Both events are listed before any search is applied
    await expect(webhooks.cellByText("pay_success_1")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("ref_failed_1")).toBeVisible({
      timeout: 10000,
    });

    // Search by Object ID (the default search type) narrows the list to the match
    await webhooks.searchByIdInput.fill("pay_success_1");
    await webhooks.searchByIdInput.press("Enter");
    await expect(webhooks.cellByText("pay_success_1")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("ref_failed_1")).toBeHidden();

    // Switch the search type to Event ID and search the other event
    await webhooks.searchTypeSelector.click();
    await webhooks.eventIdOption.click();
    await webhooks.searchByIdInput.fill("evt_failed_1");
    await webhooks.searchByIdInput.press("Enter");
    await expect(webhooks.cellByText("ref_failed_1")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("pay_success_1")).toBeHidden();
  });

  test("should add a Manual Retry attempt alongside the Initial attempt when Retry Webhook is clicked", async ({
    page,
  }) => {
    const initialAttempt = {
      ...WEBHOOK_ATTEMPTS[0],
      event_id: "evt_success_1",
      delivery_attempt: "initial_attempt",
      created: "2026-05-29T10:00:00.000Z",
    };
    const retryAttempt = {
      ...WEBHOOK_ATTEMPTS[0],
      event_id: "evt_retry_1",
      delivery_attempt: "manual_retry",
      created: "2026-05-29T10:05:00.000Z",
    };

    // The attempts list initially has only the Initial attempt; after a retry it
    // returns the Initial attempt plus the new Manual Retry attempt.
    let attemptsCallCount = 0;
    await page.route("**/events/*/*/attempts", async (route) => {
      attemptsCallCount += 1;
      const attempts =
        attemptsCallCount === 1
          ? [initialAttempt]
          : [initialAttempt, retryAttempt];
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify(attempts),
      });
    });
    await page.route("**/events/*/*/retry", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({}),
      });
    });
    await mockWebhookEvents(page);
    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    await webhooks.cellByText("payment_succeeded").click();
    await expect(page).toHaveURL(/dashboard\/webhooks\/evt_success_1/, {
      timeout: 10000,
    });

    // Only the Initial attempt is present before retrying
    await expect(webhooks.detailTableCell(1, 3)).toContainText(
      "initial_attempt",
    );
    await expect(webhooks.deliveryAttemptLabel("Initial Attempt")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("manual_retry")).toBeHidden();

    // Trigger a manual retry
    await webhooks.retryWebhookButton.click();

    // A new Manual Retry attempt is added while the first row stays the Initial attempt
    await expect(webhooks.detailTableCell(2, 3)).toContainText("manual_retry", {
      timeout: 10000,
    });
    await expect(webhooks.detailTableCell(1, 3)).toContainText(
      "initial_attempt",
    );

    // The new row surfaces the "Manual Retry" delivery label, the first the "Initial Attempt"
    await webhooks.cellByText("manual_retry").click();
    await expect(webhooks.deliveryAttemptLabel("Manual Retry")).toBeVisible({
      timeout: 10000,
    });
    await webhooks.cellByText("initial_attempt").click();
    await expect(webhooks.deliveryAttemptLabel("Initial Attempt")).toBeVisible({
      timeout: 10000,
    });
  });

  test("should paginate the events list across pages", async ({ page }) => {
    // 25 events across two pages (resultsPerPage = 20). The mock honours the
    // request offset so each page returns its own slice.
    const allEvents = Array.from({ length: 25 }, (_, i) => ({
      ...WEBHOOK_EVENTS.events[0],
      event_id: `evt_page_${i}`,
      object_id: `pay_event_${i}`,
      initial_attempt_id: `evt_page_${i}`,
    }));

    await page.route("**/events/profile/list", async (route) => {
      const body = (route.request().postDataJSON() ?? {}) as Record<
        string,
        unknown
      >;
      const offset = typeof body.offset === "number" ? body.offset : 0;
      const limit = typeof body.limit === "number" ? body.limit : 50;
      const slice = allEvents.slice(offset, offset + limit);
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ total_count: allEvents.length, events: slice }),
      });
    });

    await openWebhooks(page);
    const webhooks = new Webhooks(page);

    // Page 1 shows the first 20 events and the paginator with a page-2 control
    await expect(webhooks.cellByText("pay_event_0")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("pay_event_20")).toBeHidden();
    await expect(webhooks.paginationInfo).toBeVisible({ timeout: 10000 });
    await expect(webhooks.paginationPageButton(2)).toBeVisible({
      timeout: 10000,
    });

    // Moving to page 2 loads the remaining events
    await webhooks.paginationPageButton(2).click();
    await expect(webhooks.cellByText("pay_event_20")).toBeVisible({
      timeout: 10000,
    });
    await expect(webhooks.cellByText("pay_event_0")).toBeHidden();
  });
});
