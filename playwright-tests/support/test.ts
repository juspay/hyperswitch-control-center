import { test as baseTest, expect, type Page } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

interface JSCoverageEntry {
  url: string;
  scriptId: string;
  source?: string;
  functions: Array<{
    functionName: string;
    isBlockCoverage: boolean;
    ranges: Array<{
      count: number;
      startOffset: number;
      endOffset: number;
    }>;
  }>;
}

interface IstanbulCoverage {
  [key: string]: unknown;
}

async function convertV8ToIstanbul(
  coverageEntries: JSCoverageEntry[],
): Promise<IstanbulCoverage> {
  const istanbulCoverage: IstanbulCoverage = {};

  if (coverageEntries.length === 0) {
    return istanbulCoverage;
  }

  try {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const v8toIstanbul = require("v8-to-istanbul");

    for (const entry of coverageEntries) {
      if (!entry.source || entry.url.includes("node_modules")) {
        continue;
      }

      const converter = v8toIstanbul.default(entry.url, 0, {
        source: entry.source,
      });

      await converter.load();
      converter.applyCoverage(entry.functions);

      const istanbulData = converter.toIstanbul();
      Object.assign(istanbulCoverage, istanbulData);
    }
  } catch {
    // v8-to-istanbul not installed or failed to load
  }

  return istanbulCoverage;
}

async function writeCoverage(coverage: IstanbulCoverage): Promise<void> {
  const coverageDir = path.join(process.cwd(), ".nyc_output");

  if (!fs.existsSync(coverageDir)) {
    fs.mkdirSync(coverageDir, { recursive: true });
  }

  const timestamp = Date.now();
  const randomSuffix = Math.random().toString(36).substring(2, 15);
  const coverageFile = path.join(
    coverageDir,
    `playwright_coverage_${timestamp}_${randomSuffix}.json`,
  );

  fs.writeFileSync(coverageFile, JSON.stringify(coverage, null, 2));
}

const test = baseTest.extend<{
  page: Page;
}>({
  page: async ({ page, browserName }, use) => {
    const isChromium = browserName === "chromium";
    const collectCoverage = isChromium && process.env.PW_COVERAGE === "true";

    if (collectCoverage) {
      await page.coverage.startJSCoverage({
        reportAnonymousScripts: false,
        resetOnNavigation: false,
      });
    }

    await use(page);

    if (collectCoverage) {
      const coverageEntries = await page.coverage.stopJSCoverage();
      const istanbulCoverage = await convertV8ToIstanbul(coverageEntries);

      if (Object.keys(istanbulCoverage).length > 0) {
        await writeCoverage(istanbulCoverage);
      }
    }
  },
});

export { test, expect };
