import {
  request,
  type APIRequestContext,
  type Page,
  expect,
} from "@playwright/test";
import { generateDateTimeString } from "./helper";
import { SignInPage } from "./pages/auth/SignInPage";
import { SignUpPage } from "./pages/auth/SignUpPage";
import { ResetPasswordPage } from "./pages/auth/ResetPasswordPage";

const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000";
const API_URL = process.env.HYPERSWITCH_API_URL || "http://localhost:8080";
const MAIL_URL = process.env.PLAYWRIGHT_MAIL_URL || "http://localhost:8025";

export async function signupUser(
  email: string,
  password: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const response = await ctx.post(`${API_URL}/user/signup_with_merchant_id`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: {
      email,
      password,
      company_name: generateDateTimeString(),
      name: "Playwright_test_user",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`signupUser failed (${response.status()}): ${body}`);
  }
}

export async function loginUser(
  email: string,
  password: string,
  context?: APIRequestContext,
): Promise<{ token: string; merchantId: string }> {
  const ctx = context ?? (await request.newContext());
  const response = await ctx.post(`${API_URL}/user/v2/signin`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: { email, password },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`loginUser failed (${response.status()}): ${body}`);
  }

  const body = await response.json();

  let token: string = body.token ?? body.token_type ?? "";
  let merchantId: string = body.merchant_id ?? "";

  if (!token && body.two_factor_auth_required) {
    const skipResponse = await ctx.post(`${API_URL}/user/v2/2fa/skip`, {
      headers: {
        "Content-Type": "application/json",
        "api-key": "test_admin",
        Authorization: `Bearer ${body.interim_token ?? body.token}`,
      },
    });

    if (skipResponse.ok()) {
      const skipBody = await skipResponse.json();
      token = skipBody.token ?? "";
      merchantId = skipBody.merchant_id ?? merchantId;
    }
  }

  return { token, merchantId };
}

export async function createAPIKey(
  merchantId: string,
  token: string,
  context?: APIRequestContext,
): Promise<string> {
  const ctx = context ?? (await request.newContext());
  const response = await ctx.post(`${API_URL}/api_keys/${merchantId}`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": "test_admin",
    },
    data: {
      name: "API Key 1",
      description: null,
      expiration: "2060-09-23T01:02:03.000Z",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createAPIKey failed (${response.status()}): ${body}`);
  }

  const body = await response.json();
  return body.api_key as string;
}

export async function createDummyConnectorAPI(
  merchantId: string,
  connectorLabel: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/connectors`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data: {
        connector_type: "payment_processor",
        connector_name: "stripe_test",
        connector_label: connectorLabel,
        connector_account_details: {
          api_key: "test_key",
          auth_type: "HeaderKey",
        },
        status: "active",
        test_mode: true,
        payment_methods_enabled: [
          {
            payment_method: "card",
            payment_method_types: [
              {
                payment_method_type: "debit",
                card_networks: ["Mastercard"],
                minimum_amount: 0,
                maximum_amount: 68607706,
                recurring_enabled: true,
                installment_payment_enabled: false,
              },
              {
                payment_method_type: "debit",
                card_networks: ["Visa"],
                minimum_amount: 0,
                maximum_amount: 68607706,
                recurring_enabled: true,
                installment_payment_enabled: false,
              },
            ],
          },
          {
            payment_method: "card",
            payment_method_types: [
              {
                payment_method_type: "credit",
                card_networks: ["Mastercard"],
                minimum_amount: 0,
                maximum_amount: 68607706,
                recurring_enabled: true,
                installment_payment_enabled: false,
              },
              {
                payment_method_type: "credit",
                card_networks: ["Visa"],
                minimum_amount: 0,
                maximum_amount: 68607706,
                recurring_enabled: true,
                installment_payment_enabled: false,
              },
            ],
          },
        ],
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createDummyConnectorAPI failed (${response.status()}): ${body}`,
    );
  }
}

export async function createAuthenticationConnectorAPI(
  merchantId: string,
  connectorLabel: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/connectors`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data: {
        connector_type: "authentication_processor",
        connector_name: "juspaythreedsserver",
        connector_label: connectorLabel,
        connector_account_details: {
          auth_type: "NoKey",
        },
        status: "active",
        test_mode: true,
        payment_methods_enabled: [],
        connector_webhook_details: null,
        disabled: false,
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createAuthenticationConnectorAPI failed (${response.status()}): ${body}`,
    );
  }
}

export async function createPaymentAPI(
  merchantId: string,
  context?: APIRequestContext,
  amount: number = 12345,
  confirm: boolean = true,
): Promise<{
  payment_id: string;
  profile_id: string;
  amount: number;
  currency: string;
  status: string;
  payment_method: string;
  payment_method_type: string;
  connector_transaction_id: string;
  merchant_order_reference_id: string;
  description: string;
  metadata: Record<string, string>;
}> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(`${API_URL}/payments`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": apiKey,
    },
    data: {
      amount,
      currency: "USD",
      confirm,
      capture_method: "automatic",
      customer_id: "test_customer",
      authentication_type: "no_three_ds",
      return_url: "https://google.com",
      email: "abc@test.com",
      name: "Joseph Doe",
      phone: "999999999",
      phone_country_code: "+65",
      merchant_order_reference_id: "abcd",
      description: "Its my first payment",
      statement_descriptor_name: "Juspay",
      statement_descriptor_suffix: "Router",
      payment_method: "card",
      payment_method_type: "credit",
      payment_method_data: {
        card: {
          card_number: "4242424242424242",
          card_exp_month: "01",
          card_exp_year: "2027",
          card_holder_name: "joseph Doe",
          card_cvc: "100",
          nick_name: "hehe",
        },
      },
      billing: {
        address: {
          city: "Toronto",
          country: "CA",
          line1: "1562",
          line2: "HarrisonStreet",
          line3: "HarrisonStreet",
          zip: "M3C 0C1",
          state: "ON",
          first_name: "Joseph",
          last_name: "Doe",
        },
        phone: {
          number: "8056594427",
          country_code: "+91",
        },
        email: "abc@test.com",
      },
      shipping: {
        address: {
          city: "Toronto",
          country: "CA",
          line1: "1562",
          line2: "HarrisonStreet",
          line3: "HarrisonStreet",
          zip: "M3C 0C1",
          state: "ON",
          first_name: "Joseph",
          last_name: "Doe",
        },
        phone: {
          number: "8056594427",
          country_code: "+91",
        },
        email: "abc@test.com",
      },
      metadata: {
        key: "value",
      },
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createPaymentAPI failed (${response.status()}): ${body}`);
  }

  return await response.json();
}

export async function createPayoutConnectorAPI(
  merchantId: string,
  connectorLabel: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/connectors`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data: {
        connector_type: "payout_processor",
        connector_name: "adyen",
        connector_label: connectorLabel,
        disabled: false,
        test_mode: true,
        payment_methods_enabled: [
          {
            payment_method: "card",
            payment_method_types: [
              {
                payment_method_type: "debit",
                card_networks: ["Visa"],
                minimum_amount: 0,
                maximum_amount: 68607706,
                recurring_enabled: true,
                installment_payment_enabled: false,
              },
            ],
          },
        ],
        metadata: {
          endpoint_prefix: "test_key",
        },
        connector_account_details: {
          api_key: "test_key",
          key1: "test_key",
          api_secret: "test_key",
          auth_type: "SignatureKey",
        },
        additional_merchant_data: null,
        status: "active",
        pm_auth_config: null,
        connector_wallets_details: null,
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createPayoutConnectorAPI failed (${response.status()}): ${body}`,
    );
  }
}

export async function createPayoutAPI(
  merchantId: string,
  context?: APIRequestContext,
): Promise<{
  payment_id: string;
  profile_id: string;
  amount: number;
  currency: string;
  status: string;
  payment_method: string;
  payment_method_type: string;
  connector_transaction_id: string;
  merchant_order_reference_id: string;
  description: string;
  metadata: Record<string, string>;
}> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(`${API_URL}/payouts/create`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": apiKey,
    },
    data: {
      amount: 12345,
      currency: "EUR",
      customer_id: "test_customer",
      email: "abc@test.com",
      name: "Joseph Doe",
      phone: "999999999",
      phone_country_code: "+65",
      description: "Its my first payment",
      payout_type: "card",
      payout_method_data: {
        card: {
          card_number: "4111111111111111",
          expiry_month: "3",
          expiry_year: "2030",
          card_holder_name: "John Doe",
        },
      },
      billing: {
        address: {
          line1: "1562",
          line2: "HarrisonStreet",
          line3: "HarrisonStreet",
          city: "Toronto",
          state: "ON",
          country: "CA",
          zip: "M3C 0C1",
          first_name: "Joseph",
          last_name: "Doe",
        },
        phone: {
          number: "8056594427",
          country_code: "+91",
        },
        email: "abc@test.com",
      },
      entity_type: "NaturalPerson",
      recurring: true,
      metadata: {
        key: "value",
      },
      confirm: true,
      auto_fulfill: true,
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createPayoutAPI failed (${response.status()}): ${body}`);
  }

  return await response.json();
}

export async function visitSignupPage(page: Page): Promise<void> {
  const signinPage = new SignInPage(page);
  await page.goto("/");
  await signinPage.signUpLink.click();
  await expect(page).toHaveURL(/.*register/);
}

export async function signupAPI(
  name?: string,
  pass?: string,
  context?: APIRequestContext,
): Promise<void> {
  const username = name || process.env.PLAYWRIGHT_USERNAME || "";
  const password = pass || process.env.PLAYWRIGHT_PASSWORD || "";
  const ctx = context ?? (await request.newContext());

  const response = await ctx.post(`${API_URL}/user/signup_with_merchant_id`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: {
      email: username,
      password: password,
      company_name: generateDateTimeString(),
      name: "Playwright_test_user",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`signupAPI failed (${response.status()}): ${body}`);
  }
}

export async function loginAPI(
  name?: string,
  pass?: string,
  context?: APIRequestContext,
): Promise<void> {
  const username = name || process.env.PLAYWRIGHT_USERNAME || "";
  const password = pass || process.env.PLAYWRIGHT_PASSWORD || "";
  const ctx = context ?? (await request.newContext());

  const response = await ctx.post(`${API_URL}/user/v2/signin`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: { email: username, password },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`loginAPI failed (${response.status()}): ${body}`);
  }
}

export async function mockV2MerchantList(page: Page): Promise<void> {
  await page.route("**/v2/user/list/merchant", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify([]),
    });
  });
}

export async function enableEmailFeatureFlag(page: Page): Promise<void> {
  await page.route("**/dashboard/config/feature?domain=", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        theme: {
          primary_color: "#006DF9",
          primary_hover_color: "#005ED6",
          sidebar_color: "#242F48",
        },
        endpoints: {
          api_url: "http://localhost:9000/api",
        },
        features: {
          email: true,
        },
      }),
    });
  });
  await page.goto("/");
}

export async function mockMagicLinkSigninSuccess(
  page: Page,
  userEmail?: string,
): Promise<void> {
  const email = userEmail || process.env.PLAYWRIGHT_USERNAME || "";

  await page.route(
    "**/api/user/connect_account?auth_id=&domain=",
    async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          is_email_sent: true,
        }),
      });
    },
  );
}

export async function loginUI(
  page: Page,
  name?: string,
  pass?: string,
): Promise<void> {
  const signinPage = new SignInPage(page);
  const username = name || process.env.PLAYWRIGHT_USERNAME || "";
  const password = pass || process.env.PLAYWRIGHT_PASSWORD || "";

  await page.goto("/");
  await signinPage.emailInput.fill(username);
  await signinPage.passwordInput.fill(password);
  await signinPage.signinButton.click();
  await signinPage.skip2FAButton.click();
  await expect(
    page.getByText(
      "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
    ),
  ).toBeVisible();
}

export async function deleteConnector(
  mcaId: string,
  merchantId: string,
  token: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());

  const response = await ctx.delete(
    `${API_URL}/account/${merchantId}/connectors/${mcaId}`,
    {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`deleteConnector failed (${response.status()}): ${body}`);
  }
}

export async function createAuth(
  context?: APIRequestContext,
  ownerId: string = "okta_test",
  emailDomain: string = "playwrighttest.in",
): Promise<void> {
  const ctx = context ?? (await request.newContext());

  const response = await ctx.post(`${API_URL}/user/auth`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: {
      owner_id: ownerId,
      owner_type: "organization",
      auth_method: {
        auth_type: "open_id_connect",
        private_config: {
          base_url: process.env.PLAYWRIGHT_SSO_BASE_URL || "",
          client_id: process.env.PLAYWRIGHT_SSO_CLIENT_ID || "",
          client_secret: process.env.PLAYWRIGHT_SSO_CLIENT_SECRET || "",
        },
        public_config: {
          name: "okta",
        },
      },
      allow_signup: false,
      email_domain: emailDomain,
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createAuth failed (${response.status()}): ${body}`);
  }
}

export async function getAuthIdByEmail(
  context?: APIRequestContext,
  emailDomain: string = "playwrighttest.in",
): Promise<string> {
  const ctx = context ?? (await request.newContext());

  const response = await ctx.get(
    `${API_URL}/user/auth/list?email_domain=${emailDomain}`,
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`getAuthIdByEmail failed (${response.status()}): ${body}`);
  }

  const body = await response.json();
  return body[0]?.auth_id as string;
}

export async function assertConnectorFieldLabels(
  page: Page,
  fieldLabels: string[],
): Promise<void> {
  for (const label of fieldLabels) {
    const labelElement = page.locator("label", { hasText: label });
    await expect(labelElement).toBeVisible();

    const inputId = await labelElement.getAttribute("for");
    if (inputId) {
      await expect(page.locator(`#${inputId}`)).toBeAttached();
    }
  }
}

export async function fillConnectorFields(
  page: Page,
  fields: {
    default: string;
    overrides?: Record<string, string>;
  },
): Promise<void> {
  const inputs = page
    .locator('.grid.grid-cols-2 input[type="text"]')
    .locator("visible=true");

  const count = await inputs.count();
  for (let i = 0; i < count; i++) {
    const input = inputs.nth(i);
    const placeholder = (await input.getAttribute("placeholder")) || "";
    const value = fields.overrides?.[placeholder] ?? fields.default;

    await input.clear();
    await input.fill(value);
  }
}

export async function assertPaymentMethodTypes(
  page: Page,
  sections: Record<
    string,
    {
      label: string;
      methods: string[];
    }
  >,
): Promise<void> {
  for (const section of Object.values(sections)) {
    const sectionHeader = page.getByText(section.label, { exact: true });
    await sectionHeader.scrollIntoViewIfNeeded();
    await expect(sectionHeader).toBeVisible();

    for (const method of section.methods.slice(0, 2)) {
      const methodElement = page
        .getByTestId(new RegExp(`.*_${method.toLowerCase()}$`))
        .first();
      const count = await methodElement.count().catch(() => 0);
      if (count > 0) {
        await expect(methodElement).toBeVisible();
      }
    }
  }
}

export async function createConnectorUI(page: Page): Promise<void> {
  await page.locator("[data-testid=connectors]").click();
  await page.locator("[data-testid=paymentprocessors]").click();
  await expect(page.getByText("Payment Processors")).toBeVisible();
  await expect(page.getByText("Connect a Dummy Processor")).toBeVisible();
  await page.locator("[data-button-for=connectNow]").click({ force: true });

  const modal = page.locator(
    '[data-component="modal:Connect a Dummy Processor"]',
  );
  await expect(modal).toBeVisible({ timeout: 10000 });
  await expect(modal.locator("button")).toHaveCount(4);

  await expect(page.getByText("Stripe Dummy")).toBeVisible();
  await page
    .locator('[data-testid="stripe_test"]')
    .locator("button")
    .click({ force: true });

  await expect(page).toHaveURL(/.*dashboard\/connectors/);
  await expect(page.getByText("Credentials")).toBeVisible();

  await page.locator("[name=connector_account_details\\.api_key]").clear();
  await page
    .locator("[name=connector_account_details\\.api_key]")
    .fill("dummy_api_key");
  await page.locator("[name=connector_label]").clear();
  await page
    .locator("[name=connector_label]")
    .fill("stripe_test_default_label");
  await page.locator("[data-button-for=connectAndProceed]").click();

  await page.locator("[data-testid=credit_select_all]").click();
  await page.locator("[data-testid=credit_mastercard]").click();
  await page.locator("[data-testid=debit_cartesbancaires]").click();
  await page.locator("[data-testid=pay_later_klarna]").click();
  await page.locator("[data-testid=wallet_we_chat_pay]").click();
  await page.locator("[data-button-for=proceed]").click();

  await expect(
    page.locator('[data-toast="Connector Created Successfully!"]'),
  ).toBeVisible({ timeout: 10000 });
  await page.locator("[data-button-for=done]").click();

  await expect(page).toHaveURL(/.*dashboard\/connectors/);
  await expect(page.getByText("stripe_test_default_label")).toBeVisible();
}

export async function processPaymentSdkUI(page: Page): Promise<void> {
  const context = page.context();
  await context.clearCookies();

  await page.locator("[data-testid=connectors]").click();
  await page.locator("[data-testid=paymentprocessors]").click();
  await expect(page.getByText("Payment Processors")).toBeVisible();
  await page.locator("[data-testid=home]").first().click();
  await page.locator("[data-button-for=tryItOut]").click();

  await expect(
    page.locator('[data-breadcrumb="Explore Demo Checkout Experience"]'),
  ).toBeAttached();

  await page.locator("[data-testid=amount]").locator("input").clear();
  await page.locator("[data-testid=amount]").locator("input").fill("77");
  await page.locator("[data-button-for=showPreview]").click();

  await page.waitForTimeout(2000);

  const iframe = page.frameLocator("iframe").first();
  const cardInput = iframe.locator("[data-testid=cardNoInput]");
  await cardInput.waitFor({ state: "visible", timeout: 20000 });
  await cardInput.fill("4242424242424242");
  await iframe.locator("[data-testid=expiryInput]").fill("0127");
  await iframe.locator("[data-testid=cvvInput]").scrollIntoViewIfNeeded();
  await iframe.locator("[data-testid=cvvInput]").fill("492");

  await page.locator("[data-button-for=payUSD77]").click();
  await expect(page.getByText("Payment Successful")).toBeAttached();
}

export async function signUpWithEmail(
  page: Page,
  username: string,
  password: string,
): Promise<void> {
  const signinPage = new SignInPage(page);
  const resetPasswordPage = new ResetPasswordPage(page);

  await expect(page).toHaveURL(/.*register/);

  const signupPage = new SignUpPage(page);
  await signupPage.emailInput.fill(username);
  await signupPage.signUpButton.click();

  await expect(page.locator("[data-testid=card-header]")).toContainText(
    "Please check your inbox",
  );

  await page.goto(MAIL_URL);
  await page.locator("div.messages > div:nth-child(2)").click();
  await page.waitForTimeout(1000);

  const iframe = page.frameLocator("iframe").first();
  const verifyLink = await iframe.locator("a").first().getAttribute("href");
  if (verifyLink) {
    await page.goto(verifyLink);
  }

  await signinPage.skip2FAButton.click();

  await resetPasswordPage.createPassword.fill(password);
  await resetPasswordPage.confirmPassword.fill(password);
  await resetPasswordPage.confirmButton.click();

  await signinPage.emailInput.fill(username);
  await signinPage.passwordInput.fill(password);
  await signinPage.signinButton.click();
  await signinPage.skip2FAButton.click();
}

export async function redirectFromMailInbox(
  page: Page,
  email: string,
  emailSubject: string = "Welcome to the Hyperswitch community!",
): Promise<void> {
  await page.goto(MAIL_URL);
  await page.locator('[id="search"]').fill(email);
  await page.locator('[id="search"]').press("Enter");
  await page
    .locator("div.msglist-message")
    .filter({ hasText: emailSubject })
    .filter({ hasText: email })
    .first()
    .click();
  await page.waitForTimeout(1000);

  const iframe = page.frameLocator("iframe").first();
  const verifyLink = await iframe.locator("a").first().getAttribute("href");
  if (verifyLink) {
    await page.goto(verifyLink);
  }
}

export async function signinFromMailInbox(page: Page): Promise<void> {
  await page.goto(MAIL_URL);
  await page
    .locator("div.messages > div")
    .getByText("Unlock Hyperswitch: Use Your Magic Link to Sign In")
    .first()
    .click();
  await page.waitForTimeout(1000);

  const iframe = page.frameLocator("iframe").first();
  const verifyLink = await iframe.locator("a").first().getAttribute("href");
  if (verifyLink) {
    await page.goto(verifyLink);
  }
}

export async function ompLineage(
  page: Page,
): Promise<{ orgId: string; merchantId: string; profileId: string }> {
  const rawUserInfo = await page.evaluate(() => {
    return window.localStorage.getItem("USER_INFO");
  });

  if (!rawUserInfo) {
    throw new Error(
      "ompLineage: USER_INFO not found in localStorage. User may not be logged in.",
    );
  }

  let userInfo: { token?: string };
  try {
    userInfo = JSON.parse(rawUserInfo);
  } catch (e) {
    throw new Error(
      `ompLineage: Failed to parse USER_INFO from localStorage: ${(e as Error).message}`,
    );
  }

  const token = userInfo?.token;
  if (!token) {
    throw new Error(
      "ompLineage: token not found in USER_INFO. User may not be authenticated.",
    );
  }

  const ctx = await request.newContext();
  const response = await ctx.get(`${API_URL}/user`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok()) {
    throw new Error(
      `ompLineage: Failed to fetch user info (${response.status()})`,
    );
  }

  const body = await response.json();
  return {
    orgId: body.org_id ?? "",
    merchantId: body.merchant_id ?? "",
    profileId: body.profile_id ?? "",
  };
}
