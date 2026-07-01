import { randomUUID } from "crypto";

export function generateUniqueEmail(): string {
  return `playwright-${randomUUID().slice(0, 8)}@test.com`;
}

export function generateDateTimeString(): string {
  const now = new Date();
  const randomSuffix = Math.floor(Math.random() * 10000)
    .toString()
    .padStart(4, "0");
  return (
    now
      .toISOString()
      .replace(/[-:.T]/g, "")
      .slice(0, 14) + randomSuffix
  );
}

// Test merchants derive their merchant_id from company_name, so prefix every
// generated merchant/company name with "playwright" to make test-created
// merchant_ids identifiable (merchant_id = company_name lowercased).
export function generateMerchantName(): string {
  return `playwright_${generateDateTimeString()}`;
}

export function getInvalidEmails(): string[] {
  return [
    "username",
    "@test.com",
    "missing@test",
    "multiple@domains@test.com",
    "abc@@xy.zi",
    "dots..in@test.com",
    ".starts.with.dot@test.com",
    "ends.with.dot.@test.com",
    "username@.com",
    "username@test..com",
    "@#$%",
    "user@domain,com",
    "user@domain.123",
    "user@domain.c",
    "user@domain.",
    "12345678",
    "abc.in",
  ];
}
