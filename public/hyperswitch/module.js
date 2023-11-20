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
