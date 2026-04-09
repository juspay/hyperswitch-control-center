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
