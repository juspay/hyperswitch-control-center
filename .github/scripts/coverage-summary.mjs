// Renders nyc's coverage-summary.json as a presentable GitHub-flavoured
// Markdown table (progress bars + status emoji) for the Actions job summary.
// Usage: node .github/scripts/coverage-summary.mjs <path-to-coverage-summary.json>
// Prints Markdown to stdout; the workflow appends it to $GITHUB_STEP_SUMMARY.
import { readFileSync } from "node:fs";

const file = process.argv[2] || "coverage-report-merged/coverage-summary.json";

const HEADING = "## 📊 Playwright Code Coverage — Merged (all shards)";
const FOOTER =
  "_Full browsable HTML report (open `index.html`), plus json-summary + lcov: " +
  "download the `playwright-coverage-merged` artifact below._";

const out = [];
let total;
try {
  total = JSON.parse(readFileSync(file, "utf8")).total;
} catch {
  console.log(HEADING);
  console.log("");
  console.log(
    "⚠️ Merged coverage summary not generated (no coverage data from shards).",
  );
  process.exit(0);
}

const BAR_LEN = 20;
const status = (pct) => (pct >= 80 ? "🟢" : pct >= 50 ? "🟡" : "🔴");
const bar = (pct) => {
  const filled = Math.round((pct / 100) * BAR_LEN);
  return "`" + "█".repeat(filled) + "░".repeat(BAR_LEN - filled) + "`";
};

// Lines first (the headline metric), then the rest.
const rows = [
  ["Lines", total.lines],
  ["Statements", total.statements],
  ["Functions", total.functions],
  ["Branches", total.branches],
];

out.push(HEADING, "");
out.push("| Metric | Coverage | Progress | Covered / Total |");
out.push("| :--- | :---: | :--- | ---: |");
for (const [name, m] of rows) {
  const pct = typeof m.pct === "number" ? m.pct : 0;
  out.push(
    `| ${status(pct)} **${name}** | ${pct.toFixed(2)}% | ${bar(pct)} | ${m.covered} / ${m.total} |`,
  );
}

const linesPct = typeof total.lines.pct === "number" ? total.lines.pct : 0;
out.push(
  "",
  `> ${status(linesPct)} Overall line coverage: **${linesPct.toFixed(2)}%**`,
  "",
);
out.push(FOOTER);

console.log(out.join("\n"));
