open LogicUtils
open PaymentInterfaceTypesV1

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

let getAttempts: JSON.t => array<attempts_v1> = json => {
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

let getRefundMetaData: JSON.t => refundMetaData_v1 = json => {
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

let mapDictToPaymentPayload: dict<JSON.t> => order_v1 = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  let getEmail = dict => {
    let defaultEmail = dict->getString("email", "")
    dict->getStringFromNestedDict("customer", "email", defaultEmail)
  }

  {
    payment_id: dict->getString("payment_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_received: dict->getFloat("amount_received", 0.0),
    client_secret: dict->getString("client_secret", ""),
    created: dict->getString("created", ""),
    last_updated: dict->getString("last_updated", ""),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    mandate_id: dict->getString("mandate_id", ""),
    mandate_data: dict->getString("mandate_data", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
    off_session: dict->getString("off_session", ""),
    capture_on: dict->getString("capture_on", ""),
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
    shipping: getDictFromNestedDict(
      dict,
      "shipping",
      "address",
    )->PaymentInterfaceUtils.concatAddressFromDict(addressKeys),
    shippingEmail: dict->getStringFromNestedDict("shipping", "email", ""),
    shippingPhone: dict
    ->getDictFromNestedDict("shipping", "phone")
    ->getPhoneNumberString,
    billing: dict
    ->getDictFromNestedDict("billing", "address")
    ->PaymentInterfaceUtils.concatAddressFromDict(addressKeys),
    payment_method_billing_address: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->PaymentInterfaceUtils.concatAddressFromDict(addressKeys),
    payment_method_billing_first_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->getString("first_name", ""),
    payment_method_billing_last_name: dict
    ->getDictfromDict("payment_method_data")
    ->getDictFromNestedDict("billing", "address")
    ->getString("last_name", ""),
    payment_method_billing_phone: dict
    ->getDictFromNestedDict("payment_method_data", "billing")
    ->getString("email", ""),
    payment_method_billing_email: dict
    ->getDictFromNestedDict("payment_method_data", "billing")
    ->getString("", ""),
    billingEmail: dict->getStringFromNestedDict("billing", "email", ""),
    billingPhone: dict
    ->getDictFromNestedDict("billing", "phone")
    ->getPhoneNumberString,
    metadata: dict->getJsonObjectFromDict("metadata")->getDictFromJsonObject,
    email: dict->getEmail,
    name: dict->getString("name", ""),
    phone: dict
    ->getDictfromDict("customer")
    ->getPhoneNumberString(~phoneKey="phone", ~codeKey="phone_country_code"),
    return_url: dict->getString("return_url", ""),
    authentication_type: dict->getString("authentication_type", ""),
    statement_descriptor_name: dict->getString("statement_descriptor_name", ""),
    statement_descriptor_suffix: dict->getString("statement_descriptor_suffix", ""),
    next_action: dict->getString("next_action", ""),
    cancellation_reason: dict->getString("cancellation_reason", ""),
    error_code: dict->getString("error_code", ""),
    error_message: dict->getString("error_message", ""),
    order_quantity: dict->getString("order_quantity", ""),
    product_name: dict->getString("product_name", ""),
    card_brand: dict->getString("card_brand", ""),
    payment_experience: dict->getString("payment_experience", ""),
    connector_transaction_id: dict->getString("connector_transaction_id", ""),
    refunds: dict
    ->getArrayFromDict("refunds", [])
    ->JSON.Encode.array
    ->getArrayDataFromJson(refunditemToObjMapper),
    profile_id: dict->getString("profile_id", ""),
    frm_message: dict->getFRMDetails,
    merchant_decision: dict->getString("merchant_decision", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    disputes: dict->getArrayFromDict("disputes", [])->JSON.Encode.array->DisputesEntity.getDisputes,
    attempts: dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts,
    merchant_order_reference_id: dict->getString("merchant_order_reference_id", ""),
    attempt_count: dict->getInt("attempt_count", 0),
    connector_label: dict->getString("connector_label", "NA"),
    split_payments: dict->getDictfromDict("split_payments"),
  }
}

let mapRefundMetaDataToCommonType: refundMetaData_v1 => PaymentInterfaceTypes.refundMetaData = refundMetaData => {
  {
    udf1: refundMetaData.udf1,
    new_customer: refundMetaData.new_customer,
    login_date: refundMetaData.login_date,
  }
}

let mapAttemptsV1ToCommonType: attempts_v1 => PaymentInterfaceTypes.attempts = attempts => {
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

let mapFrmV1ToCommonType: frmMessage_v1 => PaymentInterfaceTypes.frmMessage = frmMessage => {
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

let mapRefundV1ToCommonType: refunds_v1 => PaymentInterfaceTypes.refunds = refund => {
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

let mapErrorObject: order_v1 => PaymentInterfaceTypes.error = order => {
  {
    error_code: order.error_code,
    error_message: order.error_message,
    unified_code: "",
    unified_message: "",
  }
}

let mapPaymentV1ToCommonType: order_v1 => PaymentInterfaceTypes.order = order => {
  {
    merchant_reference_id: order.payment_id,
    merchant_id: order.merchant_id,
    net_amount: order.net_amount,
    connector: order.connector,
    status: order.status,
    amount: order.amount,
    amount_capturable: order.amount_capturable,
    amount_captured: order.amount_received,
    client_secret: order.client_secret,
    created_at: order.created,
    last_updated: order.last_updated,
    currency: order.currency,
    customer_id: order.customer_id,
    description: order.description,
    mandate_id: order.mandate_id,
    mandate_data: order.mandate_data,
    setup_future_usage: order.setup_future_usage,
    apply_mit_exemption: "",
    customer_present: order.off_session,
    capture_on: order.capture_on,
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
    email: order.email,
    name: order.name,
    phone: order.phone,
    return_url: order.return_url,
    authentication_type: order.authentication_type,
    statement_descriptor: order.statement_descriptor_name,
    statement_descriptor_suffix: order.statement_descriptor_suffix,
    next_action: order.next_action,
    cancellation_reason: order.cancellation_reason,
    error: mapErrorObject(order),
    order_quantity: order.order_quantity,
    product_name: order.product_name,
    card_brand: order.card_brand,
    payment_experience: order.payment_experience,
    connector_payment_id: order.connector_transaction_id,
    refunds: order.refunds->Array.map(mapRefundV1ToCommonType),
    profile_id: order.profile_id,
    frm_message: order.frm_message->mapFrmV1ToCommonType,
    frm_merchant_decision: order.merchant_decision,
    connector_id: order.merchant_connector_id,
    disputes: order.disputes,
    attempts: order.attempts->Array.map(mapAttemptsV1ToCommonType),
    merchant_order_reference_id: order.merchant_order_reference_id,
    attempt_count: order.attempt_count,
    connector_label: order.connector_label,
    split_payments: order.split_payments,
  }
}
