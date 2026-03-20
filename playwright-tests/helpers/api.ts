import { request, type APIRequestContext } from "@playwright/test";
import { randomUUID } from "crypto";

const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000";
const API_URL = process.env.HYPERSWITCH_API_URL || "http://localhost:8080";

function generateDateTimeString(): string {
  const now = new Date();
  return now
    .toISOString()
    .replace(/[-:.T]/g, "")
    .slice(0, 14);
}

/**
 * Generate a unique email for test isolation.
 */
export function generateUniqueEmail(): string {
  return `test-${randomUUID()}@playwright.test`;
}

/**
 * Sign up a new user via the Hyperswitch backend API.
 * Mirrors Cypress `signup_API` command.
 */
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

/**
 * Sign in a user via the dashboard proxy endpoint.
 * Mirrors Cypress `login_API` command.
 * Returns the auth token from the response.
 * Handles 2FA skip if required.
 */
export async function loginUser(
  email: string,
  password: string,
  context?: APIRequestContext,
): Promise<{ token: string; merchantId: string }> {
  const ctx = context ?? (await request.newContext());
  const response = await ctx.post(`${BASE_URL}/api/user/signin`, {
    headers: {
      "Content-Type": "application/json",
    },
    data: {
      email,
      password,
      country: "IN",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`loginUser failed (${response.status()}): ${body}`);
  }

  const body = await response.json();

  // Handle 2FA: if token is present directly, use it.
  // If response indicates 2FA is required, attempt to skip it.
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

/**
 * Create an API key for a merchant.
 * Mirrors Cypress `createAPIKey` command.
 * Returns the generated api_key string.
 */
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

/**
 * Create a dummy connector (stripe_test) for a merchant.
 * Mirrors Cypress `createDummyConnectorAPI` command.
 */
export async function createDummyConnector(
  merchantId: string,
  token: string,
  connectorName: string,
  context?: APIRequestContext,
): Promise<void> {
  const ctx = context ?? (await request.newContext());

  // First create an API key, then use it to create the connector
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
      `createDummyConnector failed (${response.status()}): ${body}`,
    );
  }
}

/**
 * Create a payment via the Hyperswitch API.
 * Mirrors Cypress `createPaymentAPI` command.
 */
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
