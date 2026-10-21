import { randomUUID } from "crypto";
import type { Locator, Page } from "@playwright/test";

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

// Blend accordions animate their height open/closed. Scrolling mid-animation
// lands on a different offset each run, so wait for every running animation
// to settle before scrolling or taking a screenshot. Infinite animations
// (spinners, pulses) are skipped since they never finish.
export async function waitForAnimationsToFinish(page: Page): Promise<void> {
  await page.evaluate(() =>
    Promise.all(
      document
        .getAnimations()
        .filter((a) =>
          Number.isFinite(Number(a.effect?.getComputedTiming().endTime)),
        )
        .map((a) => a.finished.catch(() => undefined)),
    ),
  );
}

// scrollIntoViewIfNeeded only scrolls when the target is off-screen, and the
// page's scroll container keeps growing for a few hundred ms after an
// accordion opens (its scrollHeight was seen going 1253 -> 1535 -> 1714px), so
// any scroll taken mid-growth is clamped to a different offset each run. Wait
// for the container's height to settle, then scroll the target to a fixed
// block position (headings to the top, fields to the centre): the offset is
// then fixed by content alone.
export async function scrollIntoViewStable(
  locator: Locator,
  block: ScrollLogicalPosition = "start",
): Promise<void> {
  await locator.waitFor({ state: "visible" });
  await locator.evaluate(async (el, block) => {
    const scrollsY = (node: HTMLElement) =>
      /(auto|scroll)/.test(getComputedStyle(node).overflowY) &&
      node.scrollHeight > node.clientHeight;
    let scroller: HTMLElement | null = el.parentElement;
    while (scroller && !scrollsY(scroller)) {
      scroller = scroller.parentElement;
    }
    const target = scroller ?? document.documentElement;
    const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
    let last = -1;
    let stableFor = 0;
    for (let i = 0; i < 50 && stableFor < 3; i++) {
      const height = target.scrollHeight;
      stableFor = height === last ? stableFor + 1 : 0;
      last = height;
      await sleep(100);
    }
    el.scrollIntoView({ block, inline: "nearest" });
  }, block);
}
