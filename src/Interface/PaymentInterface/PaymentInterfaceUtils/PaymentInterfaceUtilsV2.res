open LogicUtils
open PaymentInterfaceTypesV2

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

let getAttempts: JSON.t => array<attempts_v2> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
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

let refundMetaitemToObjMapper = dict => {
  {
    udf1: LogicUtils.getString(dict, "udf1", ""),
    new_customer: LogicUtils.getString(dict, "new_customer", ""),
    login_date: LogicUtils.getString(dict, "login_date", ""),
  }
}

let getRefundMetaData: JSON.t => refundMetaData_v2 = json => {
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

let errorMapper = (dict: dict<JSON.t>) => {
  {
    error_code: dict->getString("error_code", ""),
    error_message: dict->getString("error_message", ""),
    unified_code: dict->getString("unified_code", ""),
    unified_message: dict->getString("unified_message", ""),
  }
}

let mapDictToPaymentPayload: dict<JSON.t> => order_v2 = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  {
    merchant_reference_id: dict->getString("payment_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_captured: dict->getFloat("amount_received", 0.0),
    client_secret: dict->getString("client_secret", ""),
    created_at: dict->getString("created", ""),
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
    ->getDictfromDict("shipping")
    ->getDictfromDict("address")
    ->PaymentInterfaceUtils.concatValueOfGivenKeysOfDict(addressKeys),
    shippingEmail: dict->getDictfromDict("shipping")->getString("email", ""),
    shippingPhone: dict
    ->getDictfromDict("shipping")
    ->getDictfromDict("phone")
    ->getPhoneNumberString,
    billing: dict
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->PaymentInterfaceUtils.concatValueOfGivenKeysOfDict(addressKeys),
    payment_method_billing_address: dict
    ->getDictfromDict("payment_method_data")
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->PaymentInterfaceUtils.concatValueOfGivenKeysOfDict(addressKeys),
    payment_method_billing_first_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->getString("first_name", ""),
    payment_method_billing_last_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->getString("last_name", ""),
    payment_method_billing_phone: dict
    ->getDictfromDict("payment_method_data")
    ->getDictfromDict("billing")
    ->getString("email", ""),
    payment_method_billing_email: dict
    ->getDictfromDict("payment_method_data")
    ->getDictfromDict("billing")
    ->getString("", ""),
    billingEmail: dict->getDictfromDict("billing")->getString("email", ""),
    billingPhone: dict
    ->getDictfromDict("billing")
    ->getDictfromDict("phone")
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
  }
}

// common type

let mapAttemptsV1ToCommonType: attempts_v2 => PaymentInterfaceTypes.attempts = attempts => {
  {
    attempt_id: attempts.attempt_id,
    status: attempts.status,
    amount: attempts.amount,
    currency: attempts.currency,
    connector: attempts.connector,
    error_message: attempts.error_message,
    payment_method: attempts.payment_method,
    connector_transaction_id: attempts.connector_transaction_id,
    capture_method: attempts.capture_method,
    authentication_type: attempts.authentication_type,
    cancellation_reason: attempts.cancellation_reason,
    mandate_id: attempts.mandate_id,
    error_code: attempts.error_code,
    payment_token: attempts.payment_token,
    connector_metadata: attempts.connector_metadata,
    payment_experience: attempts.payment_experience,
    payment_method_type: attempts.payment_method_type,
    reference_id: attempts.reference_id,
    client_source: attempts.client_source,
    client_version: attempts.client_version,
  }
}

let errorMapper: error_v2 => PaymentInterfaceTypes.error = error => {
  {
    error_code: error.error_code,
    error_message: error.error_message,
    unified_code: error.unified_code,
    unified_message: error.unified_message,
  }
}

let mapRefundMetaDataToCommonType: refundMetaData_v2 => PaymentInterfaceTypes.refundMetaData = refundMetaData => {
  {
    udf1: refundMetaData.udf1,
    new_customer: refundMetaData.new_customer,
    login_date: refundMetaData.login_date,
  }
}

let mapRefundV2ToCommonType: refunds_v2 => PaymentInterfaceTypes.refunds = refund => {
  {
    refund_id: refund.refund_id,
    payment_id: refund.payment_id,
    amount: refund.amount,
    currency: refund.currency,
    reason: refund.reason,
    status: refund.status,
    metadata: refund.metadata->mapRefundMetaDataToCommonType,
    updated_at: refund.updated_at,
    created_at: refund.created_at,
    error_message: refund.error_message,
  }
}

let mapFrmV1ToCommonType: frmMessage_v2 => PaymentInterfaceTypes.frmMessage = frmMessage => {
  {
    frm_name: frmMessage.frm_name,
    frm_transaction_id: frmMessage.frm_transaction_id,
    frm_transaction_type: frmMessage.frm_transaction_type,
    frm_status: frmMessage.frm_status,
    frm_score: frmMessage.frm_score,
    frm_reason: frmMessage.frm_reason,
    frm_error: frmMessage.frm_error,
  }
}

let mapPaymentV2ToCommonType: order_v2 => PaymentInterfaceTypes.order = order => {
  {
    merchant_reference_id: order.merchant_order_reference_id,
    merchant_id: order.merchant_id,
    net_amount: order.net_amount,
    connector: order.connector,
    status: order.status,
    amount: order.amount,
    amount_capturable: order.amount_capturable,
    amount_captured: order.amount_captured,
    client_secret: order.client_secret,
    created_at: order.created_at,
    currency: order.currency,
    customer_id: order.customer_id,
    description: order.description,
    setup_future_usage: order.setup_future_usage,
    apply_mit_exemption: "",
    customer_present: order.customer_present,
    capture_method: order.capture_method,
    payment_method: order.payment_method,
    payment_method_type: order.payment_method_type,
    payment_method_data: order.payment_method_data,
    external_authentication_details: order.external_authentication_details,
    payment_token: order.payment_token,
    shipping: order.shipping,
    shippingEmail: order.shippingEmail,
    shippingPhone: order.shippingPhone,
    billing: order.billing,
    payment_method_billing_address: order.payment_method_billing_address,
    payment_method_billing_first_name: order.payment_method_billing_first_name,
    payment_method_billing_last_name: order.payment_method_billing_last_name,
    payment_method_billing_phone: order.payment_method_billing_phone,
    payment_method_billing_email: order.payment_method_billing_email,
    billingEmail: order.billingEmail,
    billingPhone: order.billingPhone,
    metadata: order.metadata,
    return_url: order.return_url,
    authentication_type: order.authentication_type,
    statement_descriptor: order.statement_descriptor,
    next_action: order.next_action,
    cancellation_reason: order.cancellation_reason,
    error: order.error->errorMapper,
    payment_experience: order.payment_experience,
    connector_payment_id: order.connector_payment_id,
    refunds: order.refunds->Array.map(mapRefundV2ToCommonType),
    profile_id: order.profile_id,
    frm_message: order.frm_message->mapFrmV1ToCommonType,
    frm_merchant_decision: order.frm_merchant_decision,
    connector_id: order.connector_id,
    disputes: order.disputes,
    attempts: order.attempts->Array.map(mapAttemptsV1ToCommonType),
    merchant_order_reference_id: order.merchant_order_reference_id,
    attempt_count: order.attempt_count,
    split_payments: order.split_payments,
    routing_algorithm: order.routing_algorithm,
    routing_algorithm_applied: order.routing_algorithm_applied,
    authentication_applied: order.authentication_applied,
  }
}
