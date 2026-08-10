import { readdirSync, readFileSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.cwd();
const sourceRoot = join(root, "src");

const walk = (directory) =>
  readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory()
      ? walk(path)
      : path.endsWith(".res")
        ? [path]
        : [];
  });

// These modules only define data; their callers filter the data behind hyperswitch_resources.
const gatedDataModules = new Set([
  "src/screens/AlternatePaymentMethods/AltPaymentMethodsUtils.res",
  "src/screens/DefaultHome/DefaultHomeUtils.res",
  "src/screens/Developer/APIKeys/DeveloperUtils.res",
  "src/Vault/VaultScreens/VaultHomeUtils.res",
  "src/RevenueRecovery/RevenueRecoveryScreens/RecoveryProcessors/RecoveryProcessorsPaymentProcessors/RecoveryConnectorUtils.res",
]);

// Terms and footer components are only mounted by AuthWrapper's hyperswitch_resources gate.
const gatedComponentModules = new Set([
  "src/entryPoints/AuthModule/Common/CommonAuth.res",
]);

const hostedResource =
  /docs\.hyperswitch\.io|hyperswitch\.io\/(?:docs|blog|terms-of-services|privacy-policy)|hyperswitch-io\.slack\.com|biz@hyperswitch\.io|juspay\.in/;
const visibleBrandCopy =
  /(?:React\.string|title=|heading=|subTitle=|description=|label=|entity_name:|name:)\s*[^\n]*Hyperswitch/i;

const failures = [];
for (const path of walk(sourceRoot)) {
  const file = relative(root, path);
  const source = readFileSync(path, "utf8");
  const hasGate =
    source.includes("hyperswitchResources") ||
    source.includes("getApprovedComplianceConfig") ||
    gatedDataModules.has(file) ||
    gatedComponentModules.has(file);

  source.split("\n").forEach((line, index) => {
    const trimmed = line.trim();
    if (
      trimmed.startsWith("//") ||
      trimmed.startsWith("/*") ||
      trimmed.startsWith("*")
    )
      return;

    if (hostedResource.test(line) && !hasGate) {
      failures.push(
        `${file}:${index + 1} hosted resource is not protected by hyperswitch_resources`,
      );
    }

    const codeOnly =
      /(?:bg-|text-|border-|\/assets\/|Favicon|HyperswitchAtom|#Hyperswitch|hyperswitch_error|type |module )/i.test(
        line,
      );
    const identityDefault =
      file === "src/context/ThemeProvider.res" ||
      file === "src/utils/WhitelabelUtils.res";
    if (
      visibleBrandCopy.test(line) &&
      !codeOnly &&
      !hasGate &&
      !identityDefault
    ) {
      failures.push(
        `${file}:${index + 1} visible Hyperswitch copy has no whitelabel mechanism`,
      );
    }
  });
}

if (failures.length > 0) {
  console.error(
    "Whitelabel audit failed:\n" +
      failures.map((failure) => `- ${failure}`).join("\n"),
  );
  process.exit(1);
}

console.log("Whitelabel copy audit passed");
