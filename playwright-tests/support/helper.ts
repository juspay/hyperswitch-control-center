import { randomUUID } from "crypto";

export function generateUniqueEmail(): string {
  return `playwright-${randomUUID().slice(0, 8)}@test.com`;
}

export function generateDateTimeString(): string {
  const now = new Date();
  return now
    .toISOString()
    .replace(/[-:.T]/g, "")
    .slice(0, 14);
}
