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
  const response = await ctx.post(`${BASE_URL}/api/user/signin`, {
    headers: { "Content-Type": "application/json" },
    data: { email, password, country: "IN" },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`loginUser failed (${response.status()}): ${body}`);
  }

  const body = await response.json();

  let token: string = body.token ?? body.token_type ?? "";
  let merchantId: string = body.merchant_id ?? "";

  if (!token && body.two_factor_auth_required) {
    const skipResponse = await ctx.post(`${BASE_URL}/api/user/2fa/skip`, {
      headers: {
        "Content-Type": "application/json",
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

export async function createDummyConnector(
  merchantId: string,
  token: string,
  connectorName: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());

  const apiKey = await createAPIKey(merchantId, token, ctx);

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
        connector_label: connectorName,
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
                card_networks: ["Mastercard", "Visa"],
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
                card_networks: ["Mastercard", "Visa"],
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
      `createDummyConnector failed (${response.status()}): ${body}`,
    );
  }
}

export async function createPayment(
  merchantId: string,
  apiKey: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const response = await ctx.post(`${API_URL}/payments`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": apiKey,
    },
    data: {
      amount: 10000,
      currency: "USD",
      confirm: true,
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
    throw new Error(`createPayment failed (${response.status()}): ${body}`);
  }
}

export async function visitSignupPage(page: Page): Promise<void> {
  const signinPage = new SignInPage(page);
  await page.goto("/");
  await signinPage.signUpLink.click();
  await expect(page).toHaveURL(/.*register/);
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

export async function createAuth(context?: APIRequestContext): Promise<void> {
  const ctx = context ?? (await request.newContext());

  const response = await ctx.post(`${API_URL}/user/auth`, {
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    data: {
      owner_id: "okta_test",
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
      email_domain: "cypresstest.in",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createAuth failed (${response.status()}): ${body}`);
  }
}

export async function getAuthIdByEmail(
  context?: APIRequestContext,
): Promise<string> {
  const ctx = context ?? (await request.newContext());

  const response = await ctx.get(
    `${API_URL}/user/auth/list?email_domain=cypresstest.in`,
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
    const labelElement = page.getByText(section.label);
    await labelElement.scrollIntoViewIfNeeded();
    await expect(labelElement).toBeVisible();

    for (const method of section.methods) {
      const methodElement = page.getByText(method);
      await methodElement.scrollIntoViewIfNeeded();
      await expect(methodElement).toBeVisible();
    }
  }
}
