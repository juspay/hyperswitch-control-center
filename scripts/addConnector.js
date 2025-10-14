const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const readline = require("readline");

const CONNECTOR_CONFIG = {
  Processors: {
    typeField: "processorTypes",
    listName: "connectorList",
    infoFunctionName: "getProcessorInfo",
    nameFunctionName: "getConnectorNameString",
    reverseMapSection: "Processor",
    displayFunctionName: "getDisplayNameForProcessor",
    wrapperType: "Processors",
  },
  PayoutProcessor: {
    typeField: "payoutProcessorTypes",
    listName: "payoutConnectorList",
    infoFunctionName: "getPayoutProcessorInfo",
    nameFunctionName: "getPayoutProcessorNameString",
    reverseMapSection: "PayoutProcessor",
    displayFunctionName: "getDisplayNameForPayoutProcessor",
    wrapperType: "PayoutProcessor",
  },
  ThreeDsAuthenticator: {
    typeField: "threeDsAuthenticatorTypes",
    listName: "threedsAuthenticatorList",
    infoFunctionName: "getThreedsAuthenticatorInfo",
    nameFunctionName: "getThreeDsAuthenticatorNameString",
    reverseMapSection: "ThreeDsAuthenticator",
    displayFunctionName: "getDisplayNameForThreedsAuthenticator",
    wrapperType: "ThreeDsAuthenticator",
  },
  PMAuthenticationProcessor: {
    typeField: "pmAuthenticationProcessorTypes",
    listName: "pmAuthenticationConnectorList",
    infoFunctionName: "getOpenBankingProcessorInfo",
    nameFunctionName: "getPMAuthenticationConnectorNameString",
    reverseMapSection: "PMAuthenticationProcessor",
    displayFunctionName: "getDisplayNameForOpenBankingProcessor",
    wrapperType: "PMAuthenticationProcessor",
  },
  TaxProcessor: {
    typeField: "taxProcessorTypes",
    listName: "taxProcessorList",
    infoFunctionName: "getTaxProcessorInfo",
    nameFunctionName: "getTaxProcessorNameString",
    reverseMapSection: "TaxProcessor",
    displayFunctionName: "getDisplayNameForTaxProcessor",
    wrapperType: "TaxProcessor",
  },
};

const CONNECTOR_TYPES_PATH = path.join(
  process.cwd(),
  "src/screens/Connectors/ConnectorTypes.res",
);
const CONNECTOR_UTILS_PATH = path.join(
  process.cwd(),
  "src/screens/Connectors/ConnectorUtils.res",
);
const ICONS_DIR = path.join(process.cwd(), "public/hyperswitch/Gateway");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

function prompt(question) {
  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      resolve(answer.trim());
    });
  });
}

function readFile(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`File not found: ${filePath}`);
  }
  return fs.readFileSync(filePath, "utf-8");
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content, "utf-8");
}

function validateInputs(
  connectorName,
  displayName,
  description,
  connectorTypeChoice,
  logoPath,
) {
  if (!connectorName || !displayName || !description) {
    throw new Error("All fields are required");
  }

  if (connectorName !== connectorName.toUpperCase()) {
    throw new Error(
      "Connector Name must be UPPERCASE (e.g., TESTPAY, not TestPay or testpay)",
    );
  }

  if (!/^[A-Z]+$/.test(connectorName)) {
    throw new Error(
      "Connector Name must contain only uppercase letters (A-Z), no numbers or special characters",
    );
  }

  if (!logoPath) {
    throw new Error("Logo file path is required");
  }

  if (!fs.existsSync(logoPath)) {
    throw new Error(`Logo file not found at path: ${logoPath}`);
  }

  if (!logoPath.toLowerCase().endsWith(".svg")) {
    throw new Error("Logo file must be an SVG file (.svg)");
  }

  const connectorTypeMap = {
    1: "Processors",
    2: "PayoutProcessor",
    3: "ThreeDsAuthenticator",
    4: "PMAuthenticationProcessor",
    5: "TaxProcessor",
  };

  const connectorType = connectorTypeMap[connectorTypeChoice];
  if (!connectorType) {
    throw new Error("Invalid connector type selection");
  }

  return connectorType;
}

function updateConnectorTypes(connectorName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_TYPES_PATH);
  const lines = content.split("\n");

  const typeDefRegex = new RegExp(`type\\s+${config.typeField}\\s*=`);
  let typeDefIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (typeDefRegex.test(lines[i])) {
      typeDefIndex = i;
      break;
    }
  }

  if (typeDefIndex === -1) {
    throw new Error(`Could not find type definition for ${config.typeField}`);
  }

  let lastVariantIndex = typeDefIndex;
  for (let i = typeDefIndex + 1; i < lines.length; i++) {
    const line = lines[i].trim();

    if (line.startsWith("type ") || line === "") {
      break;
    }

    if (line.startsWith("|")) {
      lastVariantIndex = i;
    }
  }

  const newVariant = `  | ${connectorName}`;
  lines.splice(lastVariantIndex + 1, 0, newVariant);

  writeFile(CONNECTOR_TYPES_PATH, lines.join("\n"));
}

function addToConnectorList(connectorName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const listRegex = new RegExp(`let\\s+${config.listName}.*=\\s*\\[`);
  let listStartIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (listRegex.test(lines[i])) {
      listStartIndex = i;
      break;
    }
  }

  if (listStartIndex === -1) {
    throw new Error(`Could not find ${config.listName}`);
  }

  let listEndIndex = listStartIndex;
  for (let i = listStartIndex + 1; i < lines.length; i++) {
    if (lines[i].trim() === "]") {
      listEndIndex = i;
      break;
    }
  }

  const newEntry = `  ${config.wrapperType}(${connectorName}),`;
  lines.splice(listEndIndex, 0, newEntry);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function addInfoObject(connectorName, description, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const functionRegex = new RegExp(`let\\s+${config.nameFunctionName}`);
  let functionIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (functionRegex.test(lines[i])) {
      functionIndex = i;
      break;
    }
  }

  if (functionIndex === -1) {
    throw new Error(`Could not find ${config.nameFunctionName} function`);
  }

  const infoVarName = connectorName.toLowerCase() + "Info";
  const infoObject = [
    "",
    `let ${infoVarName} = {`,
    `  description: "${description}",`,
    `}`,
  ];

  lines.splice(functionIndex, 0, ...infoObject);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function addToGetInfoFunction(connectorName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const functionRegex = new RegExp(`let\\s+${config.infoFunctionName}\\s*=`);
  let functionIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (functionRegex.test(lines[i])) {
      functionIndex = i;
      break;
    }
  }

  if (functionIndex === -1) {
    throw new Error(`Could not find ${config.infoFunctionName} function`);
  }

  let closingBraceIndex = -1;
  let braceCount = 0;
  let inSwitch = false;

  for (let i = functionIndex; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.includes("switch")) inSwitch = true;
    if (inSwitch) {
      if (line.includes("{")) braceCount++;
      if (line.includes("}")) {
        braceCount--;
        if (braceCount === 0) {
          closingBraceIndex = i;
          break;
        }
      }
    }
  }

  if (closingBraceIndex === -1) {
    throw new Error(
      `Could not find closing brace for ${config.infoFunctionName}`,
    );
  }

  const infoVarName = connectorName.toLowerCase() + "Info";
  const newCase = `  | ${connectorName} => ${infoVarName}`;
  lines.splice(closingBraceIndex, 0, newCase);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function addToNameFunction(connectorName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const functionRegex = new RegExp(`let\\s+${config.nameFunctionName}`);
  let functionIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (functionRegex.test(lines[i])) {
      functionIndex = i;
      break;
    }
  }

  if (functionIndex === -1) {
    throw new Error(`Could not find ${config.nameFunctionName} function`);
  }

  let closingBraceIndex = -1;
  for (let i = functionIndex; i < lines.length; i++) {
    if (lines[i].trim() === "}") {
      closingBraceIndex = i;
      break;
    }
  }

  const lowercaseName = connectorName.toLowerCase();
  const newCase = `  | ${connectorName} => "${lowercaseName}"`;
  lines.splice(closingBraceIndex, 0, newCase);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function addToReverseMapping(connectorName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const functionRegex = /let\s+getConnectorNameTypeFromString/;
  let functionIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (functionRegex.test(lines[i])) {
      functionIndex = i;
      break;
    }
  }

  if (functionIndex === -1) {
    throw new Error("Could not find getConnectorNameTypeFromString function");
  }

  const sectionRegex = new RegExp(`\\|\\s+${config.reverseMapSection}\\s+=>`);
  let sectionIndex = -1;

  for (let i = functionIndex; i < lines.length; i++) {
    if (sectionRegex.test(lines[i])) {
      sectionIndex = i;
      break;
    }
  }

  if (sectionIndex === -1) {
    throw new Error(`Could not find ${config.reverseMapSection} section`);
  }

  let defaultCaseIndex = -1;
  for (let i = sectionIndex; i < lines.length; i++) {
    const line = lines[i].trim();
    if (line.startsWith("| _") || line.startsWith("|_")) {
      defaultCaseIndex = i;
      break;
    }
  }

  if (defaultCaseIndex === -1) {
    throw new Error("Could not find default case in reverse mapping");
  }

  const lowercaseName = connectorName.toLowerCase();
  const newCase = `    | "${lowercaseName}" => ${config.wrapperType}(${connectorName})`;
  lines.splice(defaultCaseIndex, 0, newCase);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function addToDisplayNameFunction(connectorName, displayName, connectorType) {
  const config = CONNECTOR_CONFIG[connectorType];
  const content = readFile(CONNECTOR_UTILS_PATH);
  const lines = content.split("\n");

  const functionRegex = new RegExp(`let\\s+${config.displayFunctionName}`);
  let functionIndex = -1;

  for (let i = 0; i < lines.length; i++) {
    if (functionRegex.test(lines[i])) {
      functionIndex = i;
      break;
    }
  }

  if (functionIndex === -1) {
    throw new Error(`Could not find ${config.displayFunctionName} function`);
  }

  let closingBraceIndex = -1;
  for (let i = functionIndex; i < lines.length; i++) {
    if (lines[i].trim() === "}") {
      closingBraceIndex = i;
      break;
    }
  }

  const newCase = `  | ${connectorName} => "${displayName}"`;
  lines.splice(closingBraceIndex, 0, newCase);

  writeFile(CONNECTOR_UTILS_PATH, lines.join("\n"));
}

function copyIconFile(connectorName, logoPath) {
  if (!fs.existsSync(ICONS_DIR)) {
    fs.mkdirSync(ICONS_DIR, { recursive: true });
  }

  const destPath = path.join(ICONS_DIR, `${connectorName}.svg`);
  fs.copyFileSync(logoPath, destPath);
}

function runPrettier() {
  try {
    execSync(
      "npx prettier --write src/screens/Connectors/ConnectorTypes.res src/screens/Connectors/ConnectorUtils.res",
      {
        stdio: "pipe",
      },
    );
  } catch (error) {
    console.warn("Formatter is failing, please try to run npm run re:format");
  }
}

function compileReScript() {
  try {
    execSync("npm run re:build", {
      stdio: "pipe",
    });
    return true;
  } catch (error) {
    console.error("ReScript compilation failed. Please check for errors.");
    return false;
  }
}

function displayWelcome() {
  console.log("\n🚀 Connector Addition Script\n");
  console.log("Requirements:");
  console.log("  • Connector Name: UPPERCASE only (e.g., STRIPE, PAYPAL)");
  console.log("  • Display Name: Proper case (e.g., Stripe, PayPal)");
  console.log("  • Logo: SVG file format\n");
}

async function collectInputs() {
  const connectorName = await prompt("Connector Name (UPPERCASE): ");
  const displayName = await prompt("Display Name: ");

  console.log("\nConnector Types:");
  console.log("  1. Processors");
  console.log("  2. PayoutProcessor");
  console.log("  3. ThreeDsAuthenticator");
  console.log("  4. PMAuthenticationProcessor");
  console.log("  5. TaxProcessor\n");

  const connectorTypeChoice = await prompt("Select Type (1-5): ");
  const description = await prompt("Description: ");
  const logoPath = await prompt("Logo path: ");

  return {
    connectorName,
    displayName,
    connectorTypeChoice,
    description,
    logoPath,
  };
}

async function confirmInputs(
  connectorName,
  displayName,
  connectorType,
  description,
  logoPath,
) {
  console.log("\nSummary:");
  console.log(`  Name: ${connectorName}`);
  console.log(`  Display: ${displayName}`);
  console.log(`  Type: ${connectorType}`);
  console.log(`  Description: ${description}`);
  console.log(`  Logo: ${logoPath}\n`);

  const confirm = await prompt("Proceed? (yes/no): ");
  return confirm.toLowerCase() === "yes" || confirm.toLowerCase() === "y";
}

function executeSteps(
  connectorName,
  displayName,
  description,
  connectorType,
  logoPath,
) {
  const steps = [
    {
      name: "Updating ConnectorTypes.res",
      fn: () => updateConnectorTypes(connectorName, connectorType),
    },
    {
      name: "Adding to connector list",
      fn: () => addToConnectorList(connectorName, connectorType),
    },
    {
      name: "Adding info object",
      fn: () => addInfoObject(connectorName, description, connectorType),
    },
    {
      name: "Adding to info mapping",
      fn: () => addToGetInfoFunction(connectorName, connectorType),
    },
    {
      name: "Adding to name mapping",
      fn: () => addToNameFunction(connectorName, connectorType),
    },
    {
      name: "Adding to reverse mapping",
      fn: () => addToReverseMapping(connectorName, connectorType),
    },
    {
      name: "Adding to display name",
      fn: () =>
        addToDisplayNameFunction(connectorName, displayName, connectorType),
    },
    {
      name: "Copying icon file",
      fn: () => copyIconFile(connectorName, logoPath),
    },
    { name: "Formatting code", fn: () => runPrettier() },
  ];

  console.log("\n🔧 Starting connector addition process...\n");

  steps.forEach((step, index) => {
    console.log(`Step ${index + 1}/${steps.length}: ${step.name}`);
    step.fn();
  });

  console.log("\nStep 10/10: Compiling ReScript");
  return compileReScript();
}

function displaySuccess(
  connectorName,
  displayName,
  connectorType,
  description,
  compilationSuccess,
) {
  console.log("\n✅ Connector added successfully!");
  console.log(`\n${displayName} (${connectorName}) - ${connectorType}`);

  console.log("\nFiles modified:");
  console.log("  • ConnectorTypes.res");
  console.log("  • ConnectorUtils.res");
  console.log("  • public/hyperswitch/Gateway/" + connectorName + ".svg");

  if (compilationSuccess) {
    console.log("\nNext: Restart dev server (npm start)\n");
  } else {
    console.log("\n⚠ Compilation failed. Run: npm run re:build\n");
  }
}

async function main() {
  try {
    displayWelcome();

    const {
      connectorName,
      displayName,
      connectorTypeChoice,
      description,
      logoPath,
    } = await collectInputs();

    const connectorType = validateInputs(
      connectorName,
      displayName,
      description,
      connectorTypeChoice,
      logoPath,
    );

    const confirmed = await confirmInputs(
      connectorName,
      displayName,
      connectorType,
      description,
      logoPath,
    );
    if (!confirmed) {
      console.log("\nCancelled.");
      return;
    }

    const compilationSuccess = executeSteps(
      connectorName,
      displayName,
      description,
      connectorType,
      logoPath,
    );

    displaySuccess(
      connectorName,
      displayName,
      connectorType,
      description,
      compilationSuccess,
    );
  } catch (error) {
    console.error("\n❌ Error:", error.message);
    process.exit(1);
  } finally {
    rl.close();
  }
}

if (require.main === module) {
  main();
}

module.exports = {
  updateConnectorTypes,
  addToConnectorList,
  addInfoObject,
  addToGetInfoFunction,
  addToNameFunction,
  addToReverseMapping,
  addToDisplayNameFunction,
  copyIconFile,
  runPrettier,
  compileReScript,
};
