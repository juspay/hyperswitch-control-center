let wasm;
let dynamicRoutingWasm;
async function init() {
  try {
    wasm = await import("/wasm/euclid.js");
    await wasm.default("/wasm/euclid_bg.wasm");
    return { status: true, wasm };
  } catch (e) {
    console.error(e, "FAILED TO LOAD WASM CONFIG");
    throw e;
  }
}

async function dynamicRoutingInit() {
  try {
    dynamicRoutingWasm = await import("/dynamo_wasm/procesmo.js");
    await dynamicRoutingWasm.default("/dynamo_wasm/procesmo_bg.wasm");
    return { status: true, dynamicRoutingWasm };
  } catch (e) {
    console.error(e, "FAILED TO LOAD DYNAMIC ROUTING WASM CONFIG");
    throw e;
  }
}

function validateExtract(data, config, metadata) {
  if (dynamicRoutingWasm) {
    return dynamicRoutingWasm.validate_extract(data, config, metadata);
  } else {
    return {};
  }
}

function getDefaultConfig() {
  if (dynamicRoutingWasm) {
    return dynamicRoutingWasm.default_config();
  } else {
    return {};
  }
}

function getConnectorConfig(connectorName) {
  if (wasm) {
    return wasm.getConnectorConfig(connectorName);
  } else {
    return {};
  }
}

function getPayoutConnectorConfig(connectorName) {
  if (wasm) {
    return wasm.getPayoutConnectorConfig(connectorName);
  } else {
    return {};
  }
}

function getDescriptionCategory() {
  if (wasm) {
    return wasm.getDescriptionCategory();
  } else {
    return {};
  }
}

function getPaymentMethodConfig(connectorName) {
  if (wasm) {
    return wasm.getPaymentMethodConfig(connectorName);
  } else {
    return {};
  }
}

function getRequestPayload(selectedPaymentMethods, response) {
  if (wasm) {
    return wasm.getRequestPayload(selectedPaymentMethods, response);
  } else {
    return [];
  }
}

function getResponsePayload(response) {
  if (wasm) {
    return wasm.getResponsePayload(response);
  } else {
    return {};
  }
}

function getParsedJson(str) {
  try {
    if (wasm) {
      return JSON.parse(wasm.parseToString(str));
    } else {
      return str;
    }
  } catch (e) {
    console.error(e, "FAILED TO PARSE THE STRING");
    throw e;
  }
}

function getThreeDsKeys() {
  if (wasm) {
    return wasm.getThreeDsKeys();
  } else {
    return [];
  }
}

function getThreeDsDecisionRuleKeys() {
  if (wasm) {
    return wasm.getThreeDsDecisionRuleKeys();
  } else {
    return [];
  }
}

function getSurchargeKeys() {
  if (wasm) {
    return wasm.getSurchargeKeys();
  } else {
    return [];
  }
}

function getAllKeys() {
  if (wasm) {
    return wasm.getAllKeys();
  } else {
    return [];
  }
}

function getKeyType(str) {
  if (wasm) {
    return wasm.getKeyType(str);
  } else {
    return "";
  }
}

function getAllConnectors() {
  if (wasm) {
    return wasm.getAllConnectors();
  } else {
    return [];
  }
}

function getVariantValues(str) {
  if (wasm) {
    return wasm.getVariantValues(str);
  } else {
    return [];
  }
}

function payPalCreateAccountWindow() {
  (function (d, s, id) {
    var js,
      ref = d.getElementsByTagName(s)[0];
    if (!d.getElementById(id)) {
      js = d.createElement(s);
      js.id = id;
      js.async = true;
      js.src =
        "https://www.paypal.com/webapps/merchantboarding/js/lib/lightbox/partner.js";
      ref.parentNode.insertBefore(js, ref);
    }
  })(document, "script", "paypal-js");
}

function getAuthenticationConnectorConfig(connectorName) {
  if (wasm) {
    return wasm.getAuthenticationConnectorConfig(connectorName);
  } else {
    return {};
  }
}

function getPMAuthenticationProcessorConfig(connectorName) {
  if (wasm) {
    return wasm.getPMAuthenticationProcessorConfig(connectorName);
  } else {
    return {};
  }
}

function getTaxProcessorConfig(connectorName) {
  if (wasm) {
    return wasm.getTaxProcessorConfig(connectorName);
  } else {
    return {};
  }
}

function getPayoutDescriptionCategory() {
  if (wasm) {
    return wasm.getPayoutDescriptionCategory();
  } else {
    return {};
  }
}

function getAllPayoutKeys() {
  if (wasm) {
    return wasm.getAllPayoutKeys();
  } else {
    return [];
  }
}

function getPayoutVariantValues(str) {
  if (wasm) {
    return wasm.getPayoutVariantValues(str);
  } else {
    return [];
  }
}
function getMerchantCategoryCodeWithName() {
  if (wasm) {
    return wasm.getMerchantCategoryCodeWithName();
  } else {
    return {};
  }
}

const getAccessibleColor = (hex) => {
  let color = hex.replace(/#/g, "");
  // if shorthand notation is passed in
  if (color.length !== 6) {
    color = `${color}${color}`;
  }
  // rgb values
  var r = parseInt(color.substr(0, 2), 16);
  var g = parseInt(color.substr(2, 2), 16);
  var b = parseInt(color.substr(4, 2), 16);
  var yiq = (r * 299 + g * 587 + b * 114) / 1000;
  return yiq >= 128 ? "#000000" : "#FFFFFF";
};

///////////////////////////////////////////////////////////////////////////////
// Change hex color into RGB
///////////////////////////////////////////////////////////////////////////////
const getRGBColor = (hex, type) => {
  let color = hex.replace(/#/g, "");
  // if shorthand notation is passed in
  if (color.length !== 6) {
    color = `${color}${color}`;
  }
  // rgb values
  var r = parseInt(color.substr(0, 2), 16);
  var g = parseInt(color.substr(2, 2), 16);
  var b = parseInt(color.substr(4, 2), 16);

  return `--color-${type}: ${r}, ${g}, ${b};`;
};

const getRGBvalue = (hex) => {
  let color = hex.replace(/#/g, "");
  if (color.length !== 6) {
    color = `${color}${color}`;
  }
  var r = parseInt(color.substr(0, 2), 16);
  var g = parseInt(color.substr(2, 2), 16);
  var b = parseInt(color.substr(4, 2), 16);

  return `${r}, ${g}, ${b}`;
};

const toSnakeCase = (str) => {
  return str
    .replace(/([A-Z])/g, "-$1")
    .replace(/\s+/g, "-")
    .replace(/^-/, "")
    .toLowerCase();
};

const generateVariablesForSection = (sectionData, sectionName) => {
  return (
    Object.entries(sectionData)
      .map(([key, value]) => {
        const processedValue =
          typeof value === "string" && value.startsWith("#")
            ? getRGBvalue(value)
            : value;
        return `  --${sectionName}-${toSnakeCase(key)}: ${processedValue};`;
      })
      .join("\n") + "\n"
  );
};

const generateButtonVariables = (buttons) => {
  return `
  /* Primary Button */
  ${generateVariablesForSection(buttons.primary, "btn-primary")}

  /* Secondary Button */
  ${generateVariablesForSection(buttons.secondary, "btn-secondary")}
  `;
};

function appendStyle(themesConfig) {
  const settings = themesConfig.settings;
  let cssVariables = `:root{
  /* Colors */
  ${generateVariablesForSection(settings.colors, "colors")}
   /* sidebar */
  ${generateVariablesForSection(settings.sidebar, "sidebar")}
  /* Typography */
  ${generateVariablesForSection(settings.typography, "base")}
 /* Buttons */
  ${generateButtonVariables(settings.buttons)}
  /* Borders */
  ${generateVariablesForSection(settings.borders, "borders")}
  /* Spacing */
  ${generateVariablesForSection(settings.spacing, "spacing")}

}`;
  let style = document.getElementById("custom-themes-style");
  if (style) {
    style.textContent = cssVariables;
  } else {
    style = document.createElement("style");
    style.id = "custom-themes-style";
    style.textContent = cssVariables;
    document.head.appendChild(style);
  }
}
