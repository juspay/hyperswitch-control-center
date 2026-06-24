// Merges per-shard CTRF reports into one GitHub-flavoured Markdown summary
// with failed + flaky tests grouped by shard, and (optionally) writes a
// combined CTRF JSON for download.
//
// Usage:
//   node .github/scripts/ctrf-merge-summary.mjs <shards-dir> [merged-out.json]
//
// <shards-dir> is searched recursively for files named ctrf-shard-<N>.json
// (N is the shard number, parsed from the filename). Markdown is printed to
// stdout; the workflow appends it to $GITHUB_STEP_SUMMARY.
import {
  readdirSync,
  readFileSync,
  statSync,
  mkdirSync,
  writeFileSync,
} from "node:fs";
import { join, dirname, basename } from "node:path";

const dir = process.argv[2] || "ctrf-shards";
const mergedOut = process.argv[3];

const HEADING = "## 🎭 Playwright Test Results — Merged (all shards)";

// --- collect ctrf-shard-<N>.json files ------------------------------------
function walk(d) {
  let files = [];
  let entries = [];
  try {
    entries = readdirSync(d);
  } catch {
    return files;
  }
  for (const e of entries) {
    const p = join(d, e);
    if (statSync(p).isDirectory()) files = files.concat(walk(p));
    else if (/^ctrf-shard-\d+\.json$/.test(e)) files.push(p);
  }
  return files;
}

const files = walk(dir).sort();
if (files.length === 0) {
  console.log(HEADING);
  console.log("");
  console.log("⚠️ No CTRF reports found to merge.");
  process.exit(0);
}

// --- aggregate -------------------------------------------------------------
const totals = {
  tests: 0,
  passed: 0,
  failed: 0,
  skipped: 0,
  pending: 0,
  other: 0,
};
const failedByShard = new Map(); // shard -> [label]
const flakyByShard = new Map(); // shard -> [label]
const mergedTests = [];
let flakyCount = 0;

const label = (t) => {
  const title =
    [t.suite, t.name].filter(Boolean).join(" › ") || t.name || "(unnamed)";
  return title;
};
const push = (map, shard, value) => {
  if (!map.has(shard)) map.set(shard, []);
  map.get(shard).push(value);
};

for (const file of files) {
  const shard = Number(basename(file).match(/ctrf-shard-(\d+)\.json/)[1]);
  let report;
  try {
    report = JSON.parse(readFileSync(file, "utf8"));
  } catch {
    continue;
  }
  const results = report.results || {};
  const summary = results.summary || {};
  for (const k of Object.keys(totals)) totals[k] += Number(summary[k]) || 0;

  for (const t of results.tests || []) {
    mergedTests.push({ ...t, extra: { ...(t.extra || {}), shard } });
    if (t.status === "failed") push(failedByShard, shard, label(t));
    if (t.flaky) {
      flakyCount++;
      const retries = Number(t.retries) || 0;
      push(
        flakyByShard,
        shard,
        `${label(t)}${retries ? ` — passed after ${retries} ${retries === 1 ? "retry" : "retries"}` : ""}`,
      );
    }
  }
}

// --- optional merged CTRF JSON --------------------------------------------
if (mergedOut) {
  const merged = {
    reportFormat: "CTRF",
    specVersion: "0.0.0",
    results: {
      tool: { name: "playwright" },
      summary: { ...totals, start: 0, stop: 0 },
      tests: mergedTests,
    },
  };
  mkdirSync(dirname(mergedOut), { recursive: true });
  writeFileSync(mergedOut, JSON.stringify(merged, null, 2));
}

// --- render markdown -------------------------------------------------------
const out = [];
out.push(HEADING, "");
out.push("| Total | ✅ Passed | ❌ Failed | ⚠️ Flaky | ⏭️ Skipped |");
out.push("| :--: | :--: | :--: | :--: | :--: |");
out.push(
  `| ${totals.tests} | ${totals.passed} | ${totals.failed} | ${flakyCount} | ${totals.skipped} |`,
);
out.push("");

const section = (map, title, count, open) => {
  if (count === 0) return;
  out.push(
    `<details${open ? " open" : ""}><summary><b>${title} (${count})</b></summary>`,
    "",
  );
  for (const shard of [...map.keys()].sort((a, b) => a - b)) {
    const items = map.get(shard);
    out.push(`**Shard ${shard}/4** (${items.length})`, "");
    for (const item of items) out.push(`- \`${item}\``);
    out.push("");
  }
  out.push("</details>", "");
};

if (totals.failed === 0) {
  out.push("> ✅ No test failures across any shard.", "");
}
section(failedByShard, "❌ Failed", totals.failed, true);
section(flakyByShard, "⚠️ Flaky", flakyCount, false);

console.log(out.join("\n"));
