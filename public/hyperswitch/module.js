let wasm;
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
