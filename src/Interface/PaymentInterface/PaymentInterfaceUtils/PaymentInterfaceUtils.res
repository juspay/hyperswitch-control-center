open LogicUtils
open PaymentInterfaceTypes

let concatAddressFromDict = (dict, keys) => {
  keys
  ->Array.map(key => dict->getString(key, ""))
  ->Array.filter(val => val->String.trim->String.length > 0)
  ->Array.joinWith(", ") ++ "."
}

let attemptsItemToObjMapper = dict => {
  attempt_id: dict->getString("attempt_id", ""),
  status: dict->getString("status", ""),
  amount: dict->getFloat("amount", 0.0),
  currency: dict->getString("currency", ""),
  connector: dict->getString("connector", ""),
  error_message: dict->getString("error_message", ""),
  payment_method: dict->getString("payment_method", ""),
  connector_transaction_id: dict->getString("connector_transaction_id", ""),
  capture_method: dict->getString("capture_method", ""),
  authentication_type: dict->getString("authentication_type", ""),
  cancellation_reason: dict->getString("cancellation_reason", ""),
  mandate_id: dict->getString("mandate_id", ""),
  error_code: dict->getString("error_code", ""),
  payment_token: dict->getString("payment_token", ""),
  connector_metadata: dict->getString("connector_metadata", ""),
  payment_experience: dict->getString("payment_experience", ""),
  payment_method_type: dict->getString("payment_method_type", ""),
  reference_id: dict->getString("reference_id", ""),
  client_source: dict->getString("client_source", ""),
  client_version: dict->getString("client_version", ""),
}

let getAttempts: JSON.t => array<attempts> = json => {
  getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let itemToObjMapperForFRMDetails = dict => {
  {
    frm_name: dict->getString("frm_name", ""),
    frm_transaction_id: dict->getString("frm_transaction_id", ""),
    frm_transaction_type: dict->getString("frm_transaction_type", ""),
    frm_status: dict->getString("frm_status", ""),
    frm_score: dict->getInt("frm_score", 0),
    frm_reason: dict->getString("frm_reason", ""),
    frm_error: dict->getString("frm_error", ""),
  }
}

let getFRMDetails = dict => {
  dict->getJsonObjectFromDict("frm_message")->getDictFromJsonObject->itemToObjMapperForFRMDetails
}

let errorMapper = (dict: dict<JSON.t>) => {
  {
    error_code: dict->getString("error_code", ""),
    error_message: dict->getString("error_message", ""),
    unified_code: dict->getString("unified_code", ""),
    unified_message: dict->getString("unified_message", ""),
  }
}

let refundMetaitemToObjMapper = dict => {
  {
    udf1: getString(dict, "udf1", ""),
    new_customer: getString(dict, "new_customer", ""),
    login_date: getString(dict, "login_date", ""),
  }
}

let getRefundMetaData: JSON.t => refundMetaData = json => {
  json->JSON.Decode.object->Option.getOr(Dict.make())->refundMetaitemToObjMapper
}

let refunditemToObjMapper = dict => {
  refund_id: dict->getString("refund_id", ""),
  payment_id: dict->getString("payment_id", ""),
  amount: dict->getFloat("amount", 0.0),
  currency: dict->getString("currency", ""),
  reason: dict->getString("reason", ""),
  status: dict->getString("status", ""),
  error_message: dict->getString("error_message", ""),
  metadata: dict->getJsonObjectFromDict("metadata")->getRefundMetaData,
  updated_at: dict->getString("updated_at", ""),
  created_at: dict->getString("created_at", ""),
}

let mapDictToPaymentPayload: dict<JSON.t> => PaymentInterfaceTypes.order = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  {
    payment_id: dict->getString("payment_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_captured: dict->getFloat("amount_received", 0.0),
    client_secret: dict->getString("client_secret", ""),
    created_at: dict->getString("created", ""),
    modified_at: dict->getString("modified_at", ""),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
    apply_mit_exemption: dict->getString("apply_mit_exemption", ""),
    customer_present: dict->getString("off_session", ""),
    capture_method: dict->getString("capture_method", ""),
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_data: {
      let paymentMethodData = dict->getJsonObjectFromDict("payment_method_data")
      switch paymentMethodData->JSON.Classify.classify {
      | Object(value) => Some(value->getJsonObjectFromDict("card"))
      | _ => None
      }
    },
    external_authentication_details: {
      let externalAuthenticationDetails =
        dict->getJsonObjectFromDict("external_authentication_details")
      switch externalAuthenticationDetails->JSON.Classify.classify {
      | Object(_) => Some(externalAuthenticationDetails)
      | _ => None
      }
    },
    payment_token: dict->getString("payment_token", ""),
    shipping: dict
    ->getDictFromNestedDict("shipping", "address")
    ->concatAddressFromDict(addressKeys),
    shippingEmail: dict->getDictfromDict("shipping")->getString("email", ""),
    shippingPhone: dict
    ->getDictFromNestedDict("shipping", "phone")
    ->getPhoneNumberString,
    billing: dict
    ->getDictFromNestedDict("billing", "address")
    ->concatAddressFromDict(addressKeys),
    payment_method_billing_address: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->concatAddressFromDict(addressKeys),
    payment_method_billing_first_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->getString("first_name", ""),
    payment_method_billing_last_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->getString("last_name", ""),
    payment_method_billing_phone: dict
    ->getDictfromDict("payment_method_data")
    ->getStringFromNestedDict("billing", "email", ""),
    payment_method_billing_email: dict
    ->getDictfromDict("payment_method_data")
    ->getStringFromNestedDict("billing", "", ""),
    billingEmail: dict->getDictfromDict("billing")->getString("email", ""),
    billingPhone: dict
    ->getDictFromNestedDict("billing", "phone")
    ->getPhoneNumberString,
    metadata: dict->getJsonObjectFromDict("metadata")->getDictFromJsonObject,
    return_url: dict->getString("return_url", ""),
    authentication_type: dict->getString("authentication_type", ""),
    statement_descriptor: dict->getString("statement_descriptor_name", ""),
    next_action: dict->getString("next_action", ""),
    cancellation_reason: dict->getString("cancellation_reason", ""),
    error: dict->getDictfromDict("error")->errorMapper,
    payment_experience: dict->getString("payment_experience", ""),
    connector_payment_id: dict->getString("connector_transaction_id", ""),
    refunds: dict
    ->getArrayFromDict("refunds", [])
    ->JSON.Encode.array
    ->getArrayDataFromJson(refunditemToObjMapper),
    profile_id: dict->getString("profile_id", ""),
    frm_message: dict->getFRMDetails,
    frm_merchant_decision: dict->getString("merchant_decision", ""),
    connector_id: dict->getString("merchant_connector_id", ""),
    disputes: dict->getArrayFromDict("disputes", [])->JSON.Encode.array->DisputesEntity.getDisputes,
    attempts: dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts,
    merchant_order_reference_id: dict->getString("merchant_order_reference_id", ""),
    attempt_count: dict->getInt("attempt_count", 0),
    split_payments: dict->getDictfromDict("split_payments"),
    routing_algorithm: dict->getDictfromDict("routing_algorithm"),
    routing_algorithm_applied: dict->getDictfromDict("routing_algorithm_applied"),
    authentication_applied: dict->getString("authentication_applied", ""),
    is_split_payment: dict->getBool("is_split_payment", false),
  }
}
