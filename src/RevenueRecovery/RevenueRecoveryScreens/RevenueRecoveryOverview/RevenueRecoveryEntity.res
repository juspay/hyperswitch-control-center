open LogicUtils
open RevenueRecoveryOrderTypes

module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}

let getAttemptCell = (attempt: attempts, attemptColType: attemptColType): Table.cell => {
  switch attemptColType {
  // | Status =>
  //   Label({
  //     title: attempt.status->String.toUpperCase,
  //     color: switch attempt.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
  //     | #CHARGED => LabelGreen
  //     | #AUTHENTICATION_FAILED
  //     | #ROUTER_DECLINED
  //     | #AUTHORIZATION_FAILED
  //     | #VOIDED
  //     | #CAPTURE_FAILED
  //     | #VOID_FAILED
  //     | #FAILURE =>
  //       LabelRed
  //     | _ => LabelLightBlue
  //     },
  //   })

  | AttemptId => DisplayCopyCell(attempt.id)
  }
}

let attemptsColumns: array<attemptColType> = [AttemptId]

let attemptDetailsField = [AttemptId]

let getAttemptHeading = (attemptColType: attemptColType) => {
  switch attemptColType {
  | AttemptId =>
    Table.makeHeaderInfo(
      ~key="id",
      ~title="Attempt ID",
      ~description="You can validate the information shown here by cross checking the payment attempt identifier (Attempt ID) in your payment processor portal.",
    )
  }
}

let attemptsItemToObjMapper = dict => {
  id: dict->getString("id", ""),
  status: dict->getString("status", ""),
  amount: dict->getFloat("amount", 0.0),
  created: dict->getString("created_at", ""),
  attempt_by: dict
  ->getDictfromDict("feature_metadata")
  ->getDictfromDict("revenue_recovery")
  ->getString("attempt_triggered_by", ""),
  currency: dict
  ->getDictfromDict("amount")
  ->getString("currency", ""),
  connector: dict->getString("connector", ""),
  error_message: dict->getString("error_message", ""),
  payment_method: dict->getString("payment_method", ""),
  connector_reference_id: dict->getString("connector_reference_id", ""),
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
  attempt_amount: dict
  ->getDictfromDict("amount")
  ->getFloat("net_amount", 00.0),
}

let getAttempts: JSON.t => array<attempts> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let allColumns = [PaymentId]

let getHeading = (colType: colType) => {
  switch colType {
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  }
}

let getStatus = (order, primaryColor) => {
  let orderStatusLabel = order.status->capitalizeString
  let fixedStatusCss = "text-sm text-nd_green-400 font-medium px-2 py-1 rounded-md h-1/2"
  switch order.status->HSwitchOrderUtils.statusVariantMapper {
  | Succeeded
  | PartiallyCaptured =>
    <div className={`${fixedStatusCss} bg-green-50 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Failed
  | Cancelled =>
    <div className={`${fixedStatusCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Processing
  | RequiresCustomerAction
  | RequiresConfirmation
  | RequiresPaymentMethod =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedStatusCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getCell = (order, colType: colType, merchantId, orgId): Table.cell => {
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | PaymentId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payments/${order.invoice_id}/${order.profile_id}/${merchantId}/${orgId}`}
        displayValue={order.payment_id}
        copyValue={Some(order.payment_id)}
      />,
      "",
    )
  }
}

let concatValueOfGivenKeysOfDict = (dict, keys) => {
  Array.reduceWithIndex(keys, "", (acc, key, i) => {
    let val = dict->getString(key, "")
    let delimiter = if val->isNonEmptyString {
      if key !== "first_name" {
        i + 1 == keys->Array.length ? "." : ", "
      } else {
        " "
      }
    } else {
      ""
    }
    String.concat(acc, `${val}${delimiter}`)
  })
}

let defaultColumns: array<colType> = [PaymentId]

let itemToObjMapper = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  let getEmail = dict => {
    let defaultEmail = dict->getString("email", "")

    dict
    ->getDictfromDict("customer")
    ->getString("email", defaultEmail)
  }

  {
    payment_id: dict->getString("id", ""),
    invoice_id: dict->getString("id", ""),
    merchant_id: dict->getString("merchant_id", ""),
    net_amount: dict->getFloat("net_amount", 0.0),
    order_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("order_amount", 0.0),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    amount: dict->getFloat("amount", 0.0),
    amount_capturable: dict->getFloat("amount_capturable", 0.0),
    amount_received: dict->getFloat("amount_received", 0.0),
    created: dict->getString("created", ""),
    last_updated: dict->getString("modified_at", ""),
    currency: dict->getString("currency", ""),
    customer_id: dict->getString("customer_id", ""),
    description: dict->getString("description", ""),
    setup_future_usage: dict->getString("setup_future_usage", ""),
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
    ->concatValueOfGivenKeysOfDict(addressKeys),
    shippingEmail: dict->getDictfromDict("shipping")->getString("email", ""),
    shippingPhone: dict
    ->getDictfromDict("shipping")
    ->getDictfromDict("phone")
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
    profile_id: dict->getString("profile_id", ""),
    merchant_decision: dict->getString("merchant_decision", ""),
    merchant_connector_id: dict->getString("merchant_connector_id", ""),
    disputes: dict->getArrayFromDict("disputes", [])->JSON.Encode.array->DisputesEntity.getDisputes,
    attempts: dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts,
    merchant_order_reference_id: dict->getString("merchant_order_reference_id", ""),
    attempt_count: dict->getInt("attempt_count", 0),
    connector_label: dict->getString("connector_label", "NA"),
    attempt_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("net_amount", 0.0),
  }
}
let getOrders: JSON.t => array<order> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let revenueRecoveryEntity = (merchantId, orgId) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getOrders,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(order, colType) => getCell(order, colType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      order =>
        GlobalVars.appendDashboardPath(
          ~url=`v2/recovery/overview/${order.invoice_id}/${order.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
