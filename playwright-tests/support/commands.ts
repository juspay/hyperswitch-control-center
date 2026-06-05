import {
  request,
  type APIRequestContext,
  type Page,
  type Locator,
  expect,
} from "@playwright/test";
import { generateDateTimeString } from "./helper";
import { SignInPage } from "./pages/auth/SignInPage";
import { SignUpPage } from "./pages/auth/SignUpPage";
import { ResetPasswordPage } from "./pages/auth/ResetPasswordPage";
import { execFileSync } from 'child_process';
import fs from 'fs';
import path from 'path';

const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000";
const API_URL = process.env.HYPERSWITCH_API_URL || "http://localhost:8080";
const MAIL_URL = process.env.PLAYWRIGHT_MAIL_URL || "http://localhost:8025";

export async function signupUser(
  email: string,
  password: string,
  context?: APIRequestContext,
  companyName?: string,
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
      company_name: companyName ?? generateDateTimeString(),
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
  // CI backends occasionally take >30s on the first request when the worker
  // pool is cold. One retry with a fresh context recovers from transient
  // socket hangs without masking persistent failures.
  const attempt = async () =>
    ctx.post(`${API_URL}/api_keys/${merchantId}`, {
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
      timeout: 60000,
    });

  let response: Awaited<ReturnType<typeof attempt>>;
  try {
    response = await attempt();
  } catch (err) {
    response = await attempt();
  }

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

export async function createBusinessProfileAPI(
  merchantId: string,
  profileName: string,
  context?: APIRequestContext,
): Promise<string> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/business_profile`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data: {
        profile_name: profileName,
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createBusinessProfileAPI failed (${response.status()}): ${body}`,
    );
  }

  const body = await response.json();
  return body.profile_id as string;
}

export async function getDefaultProfileId(
  merchantId: string,
  context?: APIRequestContext,
): Promise<string> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.get(
    `${API_URL}/account/${merchantId}/business_profile`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `getDefaultProfileId failed (${response.status()}): ${body}`,
    );
  }

  const profiles = await response.json();
  const profileId = Array.isArray(profiles)
    ? profiles[0]?.profile_id
    : undefined;
  if (!profileId) {
    throw new Error("getDefaultProfileId: no profiles returned");
  }
  return profileId as string;
}

export async function createStripeConnectorAPI(
  merchantId: string,
  connectorLabel: string,
  context?: APIRequestContext,
  profileId?: string,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const resolvedProfileId =
    profileId ?? (await getDefaultProfileId(merchantId, ctx));

  const data: Record<string, unknown> = {
    connector_type: "payment_processor",
    connector_name: "stripe",
    connector_label: connectorLabel,
    profile_id: resolvedProfileId,
    connector_account_details: {
      api_key: "test_value",
      auth_type: "HeaderKey",
    },
    status: "active",
    test_mode: false,
    payment_methods_enabled: [
      {
        payment_method: "card",
        payment_method_types: [
          {
            payment_method_type: "credit",
            card_networks: ["Visa", "Mastercard"],
            minimum_amount: 0,
            maximum_amount: 68607706,
            recurring_enabled: true,
            installment_payment_enabled: false,
          },
        ],
      },
    ],
  };

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/connectors`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data,
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createStripeConnectorAPI failed (${response.status()}): ${body}`,
    );
  }
}

export async function createStripeConnectorAPIwithAPIKey(
  merchantId: string,
  connectorLabel: string,
  apiKey: string,
  context?: APIRequestContext,
  profileId?: string,
): Promise<void> {
  const ctx = context ?? (await request.newContext());
  const resolvedProfileId =
    profileId ?? (await getDefaultProfileId(merchantId, ctx));

  const data: Record<string, unknown> = {
    connector_type: "payment_processor",
    connector_name: "stripe",
    connector_label: connectorLabel,
    profile_id: resolvedProfileId,
    connector_account_details: {
      api_key: apiKey,
      auth_type: "HeaderKey",
    },
    status: "active",
    test_mode: false,
    payment_methods_enabled: [
      {
        payment_method: "card",
        payment_method_types: [
          {
            payment_method_type: "credit",
            card_networks: ["Visa", "Mastercard"],
            minimum_amount: 0,
            maximum_amount: 68607706,
            recurring_enabled: true,
            installment_payment_enabled: false,
          },
        ],
      },
    ],
  };

  const response = await ctx.post(
    `${API_URL}/account/${merchantId}/connectors`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey,
      },
      data,
    },
  );

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createStripeConnectorAPI failed (${response.status()}): ${body}`,
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

export async function createCustomerAPI(
  merchantId: string,
  customerId: string,
  context?: APIRequestContext,
): Promise<{ customer_id: string }> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(`${API_URL}/customers`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": apiKey,
    },
    data: {
      customer_id: customerId,
      name: "Joseph Doe",
      email: "abc@test.com",
      phone: "999999999",
      phone_country_code: "+65",
      description: "Playwright customer",
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createCustomerAPI failed (${response.status()}): ${body}`);
  }

  return await response.json();
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

export async function createRefundAPI(
  merchantId: string,
  paymentId: string,
  context?: APIRequestContext,
  amount: number = 5000,
  reason: string = "Test refund",
): Promise<{
  refund_id: string;
  payment_id: string;
  amount: number;
  currency: string;
  status: string;
  reason: string | null;
  error_code: string | null;
  error_message: string | null;
  connector: string;
  profile_id: string;
}> {
  const ctx = context ?? (await request.newContext());
  const apiKey = await createAPIKey(merchantId, "", ctx);

  const response = await ctx.post(`${API_URL}/refunds`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      "api-key": apiKey,
    },
    data: {
      payment_id: paymentId,
      amount,
      reason,
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(`createRefundAPI failed (${response.status()}): ${body}`);
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

// Create / replace the merchant's active surcharge rule via the same PUT the
// dashboard fires (routing/decision/surcharge). Lets Surcharge UI tests run
// against real backend data instead of mocking GET /surcharge.
//
// IMPORTANT: this endpoint is JWT-authenticated and the JWT must include the
// org_id / merchant_id / profile_id claims the dashboard mints after UI
// login. The cleanest way to get that JWT is to pull it out of the page's
// USER_INFO localStorage entry rather than re-issuing one via /user/v2/signin
// (which yields a shorter-lived token that the routing endpoints reject).
export async function createSurchargeAPI(
  page: Page,
  context?: APIRequestContext,
  overrides: Partial<{
    name: string;
    surchargeType: "rate" | "fixed";
    percentage: number;
    fixedAmount: number;
  }> = {},
): Promise<{
  name: string;
}> {
  const ctx = context ?? (await request.newContext());
  const token = await page.evaluate(() => {
    const raw = window.localStorage.getItem("USER_INFO");
    if (!raw) return "";
    try {
      return (JSON.parse(raw) as { token?: string }).token ?? "";
    } catch {
      return "";
    }
  });
  if (!token) {
    throw new Error(
      "createSurchargeAPI: no JWT in localStorage — make sure loginUI ran first",
    );
  }

  const name = overrides.name ?? "playwright_surcharge";
  const surchargeType = overrides.surchargeType ?? "rate";
  const surchargeValue =
    surchargeType === "rate"
      ? { percentage: overrides.percentage ?? 2.5 }
      : { amount: overrides.fixedAmount ?? 100 };

  // Backend schema for PUT /routing/decision/surcharge only accepts
  // { name, merchant_surcharge_configs, algorithm } — description is a
  // dashboard-side metadata field that never leaves the form.
  const response = await ctx.put(`${API_URL}/routing/decision/surcharge`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      Authorization: `Bearer ${token}`,
    },
    data: {
      name,
      algorithm: {
        defaultSelection: { surcharge_details: null },
        rules: [
          {
            name: "rule_1",
            connectorSelection: {
              surcharge_details: {
                surcharge: { type: surchargeType, value: surchargeValue },
                tax_on_surcharge: { percentage: 0.0 },
              },
            },
            // Statements are wrapped in { condition: [...] } per
            // generateStatements (AdvancedRoutingUtils.res:446-493).
            statements: [
              {
                condition: [
                  {
                    lhs: "amount",
                    comparison: "greater_than",
                    value: { type: "number", value: 0 },
                    metadata: {},
                  },
                ],
              },
            ],
          },
        ],
        metadata: {},
      },
      merchant_surcharge_configs: { show_surcharge_breakup_screen: true },
    },
  });

  if (!response.ok()) {
    const body = await response.text();
    throw new Error(
      `createSurchargeAPI failed (${response.status()}): ${body}`,
    );
  }

  return { name };
}

// Seeds an active 3DS exemption rule via the routing API so spec tests can
// assert against real backend data without driving the form UI.
//
// Mirrors createSurchargeAPI (JWT pulled from USER_INFO localStorage), but
// the 3DS exemption flow is a two-step write: POST /routing creates the
// rule and returns its id; POST /routing/{id}/activate publishes it as the
// active rule for transaction_type=three_ds_authentication.
export async function createThreeDsExemptionAPI(
  page: Page,
  context?: APIRequestContext,
  overrides: Partial<{
    name: string;
    description: string;
    authType:
      | "no_three_ds"
      | "challenge_requested"
      | "challenge_preferred"
      | "three_ds_exemption_requested_tra"
      | "three_ds_exemption_requested_low_value"
      | "issuer_three_ds_exemption_requested";
  }> = {},
): Promise<{
  name: string;
}> {
  const ctx = context ?? (await request.newContext());
  const token = await page.evaluate(() => {
    const raw = window.localStorage.getItem("USER_INFO");
    if (!raw) return "";
    try {
      return (JSON.parse(raw) as { token?: string }).token ?? "";
    } catch {
      return "";
    }
  });
  if (!token) {
    throw new Error(
      "createThreeDsExemptionAPI: no JWT in localStorage — make sure loginUI ran first",
    );
  }

  // profile_id rides inside the JWT payload (the dashboard mints it after
  // login). Decode the middle JWT segment so the request body can include
  // it the same way buildThreeDsExemptionPayloadBody does on the UI side.
  const segments = token.split(".");
  if (segments.length !== 3) {
    throw new Error(
      "createThreeDsExemptionAPI: invalid JWT format (expected 3 segments)",
    );
  }
  const jwtPayload = JSON.parse(
    Buffer.from(segments[1], "base64").toString("utf-8"),
  ) as { profile_id?: string };
  const profileId = jwtPayload.profile_id ?? "";

  const name = overrides.name ?? "playwright_3ds_exemption";
  const description = overrides.description ?? "";
  const authType = overrides.authType ?? "three_ds_exemption_requested_tra";

  // Step 1: create the routing record. Payload shape mirrors
  // buildThreeDsExemptionPayloadBody (ThreeDsExemptionUtils.res:26-51) —
  // statements are wrapped in { condition: [...] } per generateStatements.
  const createResponse = await ctx.post(`${API_URL}/routing`, {
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      Authorization: `Bearer ${token}`,
    },
    data: {
      name,
      profile_id: profileId,
      description,
      transaction_type: "three_ds_authentication",
      algorithm: {
        type: "three_ds_decision_rule",
        data: {
          defaultSelection: { decision: "no_three_ds" },
          rules: [
            {
              name: "rule_1",
              connectorSelection: { decision: authType },
              statements: [
                {
                  condition: [
                    {
                      lhs: "amount",
                      comparison: "greater_than",
                      value: { type: "number", value: 0 },
                      metadata: {},
                    },
                  ],
                },
              ],
            },
          ],
          metadata: {},
        },
      },
    },
  });

  if (!createResponse.ok()) {
    const body = await createResponse.text();
    throw new Error(
      `createThreeDsExemptionAPI create failed (${createResponse.status()}): ${body}`,
    );
  }

  const createBody = (await createResponse.json()) as { id?: string };
  const routingId = createBody.id ?? "";
  if (!routingId) {
    throw new Error(
      `createThreeDsExemptionAPI create returned no id: ${JSON.stringify(createBody)}`,
    );
  }

  // Step 2: activate the rule. The body matches the dashboard's onSubmit
  // path (HSwitchThreeDsExemption.res:275-286).
  const activateResponse = await ctx.post(
    `${API_URL}/routing/${routingId}/activate`,
    {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        Authorization: `Bearer ${token}`,
      },
      data: {
        transaction_type: "three_ds_authentication",
      },
    },
  );

  if (!activateResponse.ok()) {
    const body = await activateResponse.text();
    throw new Error(
      `createThreeDsExemptionAPI activate failed (${activateResponse.status()}): ${body}`,
    );
  }

  return { name };
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

// Disputes don't have a client-facing creation endpoint — in production they
// arrive via connector webhooks. For UI tests we mock the list/detail routes
// so we can drive the page with synthetic data and exercise different
// statuses or connectors deterministically.
export type DisputeOverrides = Partial<{
  dispute_id: string;
  payment_id: string;
  attempt_id: string;
  amount: string;
  currency: string;
  dispute_stage: string;
  dispute_status: string;
  connector: string;
  connector_status: string;
  connector_dispute_id: string;
  connector_reason: string | null;
  connector_reason_code: string | null;
  challenge_required_by: string | null;
  connector_created_at: string | null;
  connector_updated_at: string | null;
  created_at: string;
  profile_id: string;
  merchant_connector_id: string;
  is_already_refunded: boolean;
}>;

export function buildDispute(overrides: DisputeOverrides = {}) {
  return {
    dispute_id: "dp_playwright_mock_0001",
    payment_id: "pay_playwright_mock_0001",
    attempt_id: "pay_playwright_mock_0001_1",
    amount: "6500",
    currency: "USD",
    dispute_stage: "dispute",
    dispute_status: "dispute_opened",
    connector: "stripe",
    connector_status: "NeedsResponse",
    connector_dispute_id: "dsp_playwright_mock_0001",
    connector_reason: "fraudulent" as string | null,
    connector_reason_code: null as string | null,
    challenge_required_by: "2026-06-08T18:00:00.000Z" as string | null,
    connector_created_at: "2026-05-19T15:45:33.653Z" as string | null,
    connector_updated_at: null as string | null,
    created_at: "2026-05-19T15:45:34.196Z",
    profile_id: "pro_playwright_mock",
    merchant_connector_id: "mca_playwright_mock",
    is_already_refunded: false,
    ...overrides,
  };
}

// Sets up route handlers for the four endpoints the disputes list page hits:
//   GET  /disputes/list?...      → array filtered against ?dispute_status=, ?dispute_id=, ?payment_id=
//   GET  /disputes/filter        → derives connector / dispute_status / dispute_stage option lists from `disputes`
//   GET  /disputes/{id}          → returns the matching dispute, or 404
//   GET  /disputes/aggregate?... → returns per-status counts derived from `disputes`
// Pass an array built from buildDispute({...}) to vary status/connector/etc.
export async function mockDisputesList(
  page: Page,
  disputes: ReturnType<typeof buildDispute>[],
): Promise<void> {
  await page.route(/\/disputes\/(profile\/)?list(\?|$)/, async (route) => {
    const url = new URL(route.request().url());
    const params = url.searchParams;
    const statusParam = params.get("dispute_status");
    const disputeIdParam = params.get("dispute_id");
    const paymentIdParam = params.get("payment_id");

    let data = [...disputes];
    if (statusParam) {
      const wanted = statusParam.split(",").filter(Boolean);
      if (wanted.length > 0) {
        data = data.filter((d) => wanted.includes(d.dispute_status));
      }
    }
    // The disputes page sets BOTH `dispute_id` and `payment_id` to the
    // search box value, so match when either field matches.
    if (disputeIdParam || paymentIdParam) {
      data = data.filter(
        (d) =>
          (disputeIdParam && d.dispute_id === disputeIdParam) ||
          (paymentIdParam && d.payment_id === paymentIdParam),
      );
    }

    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(data),
    });
  });

  await page.route(/\/disputes\/(profile\/)?filter(\?|$)/, async (route) => {
    const connectors = Array.from(new Set(disputes.map((d) => d.connector)));
    const statuses = Array.from(
      new Set(disputes.map((d) => d.dispute_status)),
    );
    const stages = Array.from(new Set(disputes.map((d) => d.dispute_stage)));
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        connector: connectors,
        currency: ["USD"],
        dispute_status: statuses,
        dispute_stage: stages,
      }),
    });
  });

  await page.route(/\/disputes\/(profile\/)?aggregate(\?|$)/, async (route) => {
    const counts: Record<string, number> = {};
    for (const d of disputes) {
      counts[d.dispute_status] = (counts[d.dispute_status] ?? 0) + 1;
    }
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ status_with_count: counts }),
    });
  });

  await page.route(/\/disputes\/(dp_[^/?]+)(\?|$)/, async (route) => {
    const match = route.request().url().match(/\/disputes\/(dp_[^/?]+)/);
    const id = match ? match[1] : "";
    const found = disputes.find((d) => d.dispute_id === id);
    if (!found) {
      await route.fulfill({
        status: 404,
        contentType: "application/json",
        body: JSON.stringify({ error: { code: "HE_02", message: "not found" } }),
      });
      return;
    }
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(found),
    });
  });

  // ShowDisputes mounts DisputeLogs which eagerly fires three analytics
  // audit-log endpoints. With a synthetic dispute the real backend returns
  // 401 for each, and the global 401 handler kicks the user to /sign-in.
  // Stub them to empty arrays so the detail page can render.
  await page.route(
    /\/analytics\/v1\/(profile\/)?(api_event_logs|connector_event_logs|outgoing_webhook_event_logs|webhook_event_logs)(\?|$)/,
    async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify([]),
      });
    },
  );
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
      "Welcome to your Payments Control Center — one place for your team to track and manage every payment",
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
    await labelElement.waitFor({ state: "attached", timeout: 10000 });
    await labelElement.scrollIntoViewIfNeeded();
    await expect(labelElement).toBeVisible({
      timeout: 5000,
    });

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
    await input.waitFor({ state: "attached", timeout: 10000 });
    await input.scrollIntoViewIfNeeded();
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
    await expect(sectionHeader).toBeVisible({
      timeout: 5000,
    });

    // Find the section container (look for parent element with the section content)
    // Navigate to the closest parent that contains the payment methods for this section
    const sectionContainer = sectionHeader
      .locator("..")
      .locator("..")
      .locator("..", { has: sectionHeader });

    for (const method of section.methods) {
      // Convert method name to snake_case for data-testid matching
      const methodSnakeCase = method
        .toLowerCase()
        .replace(/\s+/g, "_")
        .replace(/[^\w]/g, "");

      // Try to find method within section container first, fallback to page-wide search
      let methodElement = sectionContainer
        .getByTestId(new RegExp(`.*_${methodSnakeCase}$`, "i"))
        .first();

      let count = await methodElement.count().catch(() => 0);

      // If not found in section, search globally (for backward compatibility)
      if (count === 0) {
        methodElement = page
          .getByTestId(new RegExp(`.*_${methodSnakeCase}$`, "i"))
          .first();
        count = await methodElement.count().catch(() => 0);
      }

      if (count > 0) {
        await expect(methodElement).toBeVisible({
          timeout: 5000,
        });
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
  const cvvInput = iframe.locator("[data-testid=cvvInput]");
  await cvvInput.waitFor({ state: "attached", timeout: 10000 });
  await cvvInput.scrollIntoViewIfNeeded();
  await cvvInput.fill("492");

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

export async function generateCerts() {
  const tmpDir = path.join(process.cwd(), 'tmp-certs');
  if (!fs.existsSync(tmpDir)) fs.mkdirSync(tmpDir);

  const keyPath = path.join(tmpDir, 'key.pem');
  const certPath = path.join(tmpDir, 'cert.pem');

  // Generate key + self-signed cert
  execFileSync(
    'openssl',
    [
      'req',
      '-x509',
      '-newkey', 'rsa:2048',
      '-keyout', keyPath,
      '-out', certPath,
      '-days', '1',
      '-nodes',
      '-subj', '/CN=test.local',
    ],
    { stdio: 'ignore' }
  );

  const cert = fs.readFileSync(certPath);
  const key = fs.readFileSync(keyPath);

  return {
    certBase64: cert.toString('base64'),
    keyBase64: key.toString('base64'),
  };
}

export async function safeScrollIntoView(
  locator: Locator,
  timeout: number = 10000,
): Promise<void> {
  await locator.waitFor({ state: "attached", timeout });
  await locator.scrollIntoViewIfNeeded();
}
