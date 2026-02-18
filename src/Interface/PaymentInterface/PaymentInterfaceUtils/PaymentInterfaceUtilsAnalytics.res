open LogicUtils

type analytics_attempt = {
  attempt_id: string,
  connector_transaction_id: string,
  capture_method: string,
  error_message: string,
  metadata: string,
}

type analytics_row = {
  payment_id: string,
  merchant_id: string,
  net_amount: float,
  status: string,
  amount: float,
  amount_capturable: float,
  amount_captured: float,
  client_secret: string,
  created_at: float, 
  created: float,    
  modified_at: float,
  currency: string,
  customer_id: string,
  description: string,
  setup_future_usage: string,
  apply_mit_exemption: string,
  customer_present: string,
  payment_method: string,
  payment_method_type: string,
  payment_method_data: option<string>,
  external_authentication_details: option<string>,
  payment_token: string,
  shipping: Dict.t<JSON.t>,
  shipping_email: string,
  shipping_phone: string,
  billing: Dict.t<JSON.t>,
  email: string,
  phone: string,
  metadata: string,
  return_url: string,
  authentication_type: string,
  statement_descriptor_name: string,
  statement_descriptor_suffix: string,
  next_action: string,
  cancellation_reason: string,
  error_code: string,
  error_message: string,
  unified_code: string,
  unified_message: string,
  connector: string,
  payment_experience: string,
  frm_message: string,
  merchant_connector_id: string,
  merchant_decision: string,
  profile_id: string,
  merchant_order_reference_id: string,
  attempt_count: int,
  connector_label: string,
  active_attempt_id: string,
  attempts_list: array<analytics_attempt>,
}

let analyticsAttemptItemToObjMapper = dict => {
  attempt_id: dict->getString("attempt_id", ""),
  connector_transaction_id: dict->getString("connector_transaction_id", ""),
  capture_method: dict->getString("capture_method", ""),
  error_message: dict->getString("error_message", ""),
  metadata: dict->getString("metadata", ""),
}

let getAnalyticsAttempts = json => {
  LogicUtils.getArrayDataFromJson(json, analyticsAttemptItemToObjMapper)
}

let getAnalyticsRow = (json: JSON.t): analytics_row => {
  let dict = json->getDictFromJsonObject
  {
    payment_id: dict->getString("payment_id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_captured: dict->getFloat("amount_captured", 0.0),
    client_secret: dict->getString("client_secret", ""),
    created_at: dict->getFloat("created_at", 0.0),
    created: dict->getFloat("created", 0.0), 
    modified_at: dict->getFloat("modified_at", 0.0),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
    apply_mit_exemption: dict->getString("apply_mit_exemption", ""),
    customer_present: dict->getString("customer_present", ""),
    payment_method: dict->getString("payment_method", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_data: dict->getOptionString("payment_method_data"),
    external_authentication_details: dict->getOptionString("external_authentication_details"),
    payment_token: dict->getString("payment_token", ""),
    shipping: dict->getDictFromNestedDict("shipping", "address"), 
    shipping_email: dict->getString("shipping_email", ""),
    shipping_phone: dict->getString("shipping_phone", ""),
    billing: dict->getDictFromNestedDict("billing", "address"),
    email: dict->getString("email", ""),
    phone: dict->getString("phone", ""),
    metadata: dict->getString("metadata", ""),
    return_url: dict->getString("return_url", ""),
    authentication_type: dict->getString("authentication_type", ""),
    statement_descriptor_name: dict->getString("statement_descriptor_name", ""),
    statement_descriptor_suffix: dict->getString("statement_descriptor_suffix", ""),
    next_action: dict->getString("next_action", ""),
    cancellation_reason: dict->getString("cancellation_reason", ""),
    error_code: dict->getString("error_code", ""),
    error_message: dict->getString("error_message", ""),
    unified_code: dict->getString("unified_code", ""),
    unified_message: dict->getString("unified_message", ""),
    connector: dict->getString("connector", ""),
    payment_experience: dict->getString("payment_experience", ""),
    frm_message: dict->getString("frm_message", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    merchant_decision: dict->getString("merchant_decision", ""),
    profile_id: dict->getString("profile_id", ""),
    merchant_order_reference_id: dict->getString("merchant_order_reference_id", ""),
    attempt_count: dict->getInt("attempt_count", 0),
    connector_label: dict->getString("connector_label", ""),
    active_attempt_id: dict->getString("active_attempt_id", ""),
    attempts_list: dict->getArrayFromDict("attempts_list", [])->JSON.Encode.array->getAnalyticsAttempts,
  }
}

let mapAnalyticsRowToCommonType = (row: analytics_row): PaymentInterfaceTypes.order => {
  let activeAttempt =
    row.attempts_list
    ->Array.find(attempt => attempt.attempt_id == row.active_attempt_id)
    ->Option.getOr({
       attempt_id: "",
       connector_transaction_id: "",
       capture_method: "",
       error_message: "",
       metadata: "",
    })

  // Resolving Fields
  let connector_transaction_id = activeAttempt.connector_transaction_id
  let capture_method = activeAttempt.capture_method
  let error_message = activeAttempt.error_message

  // Date Conversion
  let createdVal = if row.created_at != 0.0 { row.created_at } else { row.created }
  let modifiedVal = row.modified_at

  let safeDateConverter = (val) => {
    try {
       if (val == 0.0) {
         "" 
       } else {
         let valInMs = val /. 1000000.0
         let date = valInMs->Date.fromTime
         date->Date.toISOString
       }
    } catch {
    | _ => "" 
    }
  }

  // Metadata Logic
  let metadataDict = {
    let metaString = row.metadata
    let metaStringToUse = if metaString == "" {
      activeAttempt.metadata
    } else {
      metaString
    }

    if metaStringToUse != "" {
      try {
        let json = metaStringToUse->JSON.parseExn
        json->getDictFromJsonObject
      } catch {
      | _ => 
        Js.log("Failed to parse metadata JSON")
        Dict.make()
      }
    } else {
      Dict.make()
    }
  }

  {
    payment_id: row.payment_id,
    merchant_id: row.merchant_id,
    net_amount: row.net_amount,
    status: row.status,
    amount: row.amount,
    amount_capturable: row.amount_capturable,
    amount_captured: row.amount_captured,
    client_secret: row.client_secret,
    created_at: safeDateConverter(createdVal),
    modified_at: safeDateConverter(modifiedVal),
    last_updated: safeDateConverter(modifiedVal),
    currency: row.currency,
    customer_id: row.customer_id,
    description: row.description,
    refunds: [],
    mandate_id: "",
    mandate_data: "",
    setup_future_usage: row.setup_future_usage,
    apply_mit_exemption: row.apply_mit_exemption,
    customer_present: row.customer_present,
    capture_on: "",
    capture_method,
    payment_method: row.payment_method,
    payment_method_type: row.payment_method_type,
    payment_method_data: row.payment_method_data->Option.map(JSON.parseExn),
    external_authentication_details: row.external_authentication_details->Option.map(JSON.parseExn),
    payment_token: row.payment_token,
    shipping: row.shipping->JSON.Encode.object->JSON.stringify,
    shippingEmail: row.shipping_email,
    shippingPhone: row.shipping_phone,
    billing: row.billing->JSON.Encode.object->JSON.stringify,
    billingEmail: row.email, 
    billingPhone: row.phone,
    payment_method_billing_address: "",
    payment_method_billing_phone: "",
    payment_method_billing_email: "",
    payment_method_billing_first_name: "",
    payment_method_billing_last_name: "",
    metadata: metadataDict,
    email: row.email,
    name: "", 
    phone: row.phone,
    return_url: row.return_url,
    authentication_type: row.authentication_type,
    statement_descriptor: row.statement_descriptor_name,
    statement_descriptor_suffix: row.statement_descriptor_suffix,
    next_action: row.next_action,
    cancellation_reason: row.cancellation_reason,
    error: {
      error_code: row.error_code,
      error_message: error_message == "" ? row.error_message : error_message,
      unified_code: row.unified_code,
      unified_message: row.unified_message,
    },
    connector: row.connector,
    order_quantity: "",
    product_name: "",
    card_brand: "",
    payment_experience: row.payment_experience,
    frm_message: {
      frm_name: row.frm_message,
      frm_transaction_id: "",
      frm_transaction_type: "",
      frm_status: "",
      frm_score: 0,
      frm_reason: "",
      frm_error: "",
    },
    connector_payment_id: connector_transaction_id,
    connector_id: row.merchant_connector_id,
    frm_merchant_decision: row.merchant_decision,
    profile_id: row.profile_id,
    disputes: [],
    attempts: [], 
    merchant_order_reference_id: row.merchant_order_reference_id,
    attempt_count: row.attempt_count,
    connector_label: row.connector_label,
    split_payments: Dict.make(),
    extended_auth_last_applied_at: "",
    extended_auth_applied: false,
    request_extended_auth: false,
    hyperswitch_error_description: "",
  }
}

let mapAnalyticsHitToOrder = (hit: JSON.t): PaymentInterfaceTypes.order => {
    hit
    ->getAnalyticsRow
    ->mapAnalyticsRowToCommonType
}
