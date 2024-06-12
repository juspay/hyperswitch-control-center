open ApplePayIntegrationTypesV2
open LogicUtils
let paymentRequest = {
  label: "apple",
  supported_networks: ["visa", "masterCard", "amex", "discover"],
  merchant_capabilities: ["supports3DS"],
}

let sessionToken = (dict): sessionTokenData => {
  let sessionTokenDict = dict->getDictfromDict("manual")->getDictfromDict("session_token_data")
  {
    initiative: sessionTokenDict->getOptionString("initiative"),
    certificate: sessionTokenDict->getOptionString("certificate"),
    display_name: sessionTokenDict->getOptionString("display_name"),
    certificate_keys: sessionTokenDict->getOptionString("certificate_keys"),
    initiative_context: sessionTokenDict->getOptionString("initiative_context"),
    merchant_identifier: sessionTokenDict->getOptionString("merchant_identifier"),
    merchant_business_country: sessionTokenDict->getOptionString("merchant_business_country"),
  }
}

let sessionTokenSimplified = (dict): sessionTokenSimplified => {
  let sessionTokenDict = dict->getDictfromDict("simple")->getDictfromDict("session_token_data")
  {
    initiative_context: sessionTokenDict->getOptionString("initiative_context"),
    merchant_business_country: sessionTokenDict->getOptionString("merchant_business_country"),
  }
}
let manual = (dict): manual => {
  {
    session_token_data: dict->sessionToken,
    payment_request_data: paymentRequest,
  }
}

let simple = (dict): simple => {
  {
    session_token_data: dict->sessionTokenSimplified,
    payment_request_data: paymentRequest,
  }
}
