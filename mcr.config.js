// Shared monocart-coverage-reports config.
// Imported by playwright.config.ts (per-shard collection) and used by the
// merge-coverage CI job (`npx mcr -c mcr.config.js -i merged-raw -o ...`)
// so filters + report shape stay in sync across both entry points.
module.exports = {
  name: "Hyperswitch E2E Coverage",
  outputDir: "./coverage-report",
  entryFilter: (entry) => {
    const url = entry.url || "";
    if (!url) return false;
    if (url.includes("node_modules")) return false;
    if (url.includes("webpack-internal:")) return false;
    return true;
  },
  sourceFilter: (sourcePath) =>
    sourcePath.includes("src/") && !sourcePath.includes("node_modules"),
  reports: [
    ["v8", { outputFile: "index.html" }],
    ["console-summary"],
    [
      "markdown-summary",
      { metrics: ["bytes", "lines", "branches", "functions"] },
    ],
    ["json-summary", { outputFile: "coverage-summary.json" }],
  ],
};
