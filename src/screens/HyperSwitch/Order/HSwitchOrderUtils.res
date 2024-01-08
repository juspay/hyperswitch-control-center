type status =
  | Succeeded
  | Failed
  | Cancelled
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod
  | RequiresConfirmation
  | PartiallyCaptured
  | None

type paymentAttemptStatus = [
  | #STARTED
  | #AUTHENTICATION_FAILED
  | #ROUTER_DECLINED
  | #AUTHENTICATION_PENDING
  | #AUTHENTICATION_SUCCESSFUL
  | #AUTHORIZED
  | #AUTHORIZATION_FAILED
  | #CHARGED
  | #AUTHORIZING
  | #COD_INITIATED
  | #VOIDED
  | #VOID_INITIATED
  | #CAPTURE_INITIATED
  | #CAPTURE_FAILED
  | #VOID_FAILED
  | #AUTO_REFUNDED
  | #PARTIAL_CHARGED
  | #UNRESOLVED
  | #PENDING
  | #FAILURE
  | #PAYMENT_METHOD_AWAITED
  | #CONFIRMATION_AWAITED
  | #DEVICE_DATA_COLLECTION_PENDING
  | #NONE
]

let statusVariantMapper: string => status = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "SUCCEEDED" => Succeeded
  | "FAILED" => Failed
  | "CANCELLED" => Cancelled
  | "PROCESSING" => Processing
  | "REQUIRES_CUSTOMER_ACTION" => RequiresCustomerAction
  | "REQUIRES_PAYMENT_METHOD" => RequiresPaymentMethod
  | "REQUIRES_CONFIRMATION" => RequiresConfirmation
  | "PARTIALLY_CAPTURED" => PartiallyCaptured
  | _ => None
  }

let paymentAttemptStatusVariantMapper: string => paymentAttemptStatus = statusLabel =>
  switch statusLabel->String.toUpperCase {
  | "STARTED" => #STARTED
  | "AUTHENTICATION_FAILED" => #AUTHENTICATION_FAILED
  | "ROUTER_DECLINED" => #ROUTER_DECLINED
  | "AUTHENTICATION_PENDING" => #AUTHENTICATION_PENDING
  | "AUTHENTICATION_SUCCESSFUL" => #AUTHENTICATION_SUCCESSFUL
  | "AUTHORIZED" => #AUTHORIZED
  | "AUTHORIZATION_FAILED" => #AUTHORIZATION_FAILED
  | "CHARGED" => #CHARGED
  | "AUTHORIZING" => #AUTHORIZING
  | "COD_INITIATED" => #COD_INITIATED
  | "VOIDED" => #VOIDED
  | "VOID_INITIATED" => #VOID_INITIATED
  | "CAPTURE_INITIATED" => #CAPTURE_INITIATED
  | "CAPTURE_FAILED" => #CAPTURE_FAILED
  | "VOID_FAILED" => #VOID_FAILED
  | "AUTO_REFUNDED" => #AUTO_REFUNDED
  | "PARTIAL_CHARGED" => #PARTIAL_CHARGED
  | "UNRESOLVED" => #UNRESOLVED
  | "PENDING" => #PENDING
  | "FAILURE" => #FAILURE
  | "PAYMENT_METHOD_AWAITED" => #PAYMENT_METHOD_AWAITED
  | "CONFIRMATION_AWAITED" => #CONFIRMATION_AWAITED
  | "DEVICE_DATA_COLLECTION_PENDING" => #DEVICE_DATA_COLLECTION_PENDING
  | _ => #NONE
  }

let isTestPayment = id => id->String.includes("test_")

let eventLogHeader =
  <div className="font-bold text-lg mb-5"> {"Events and logs"->React.string} </div>

let amountField = FormRenderer.makeFieldInfo(
  ~name="amount",
  ~label="Refund Amount",
  ~customInput=InputFields.numericTextInput(),
  ~placeholder="Enter Refund Amount",
  ~isRequired=true,
  (),
)

let reasonField = FormRenderer.makeFieldInfo(
  ~name="reason",
  ~label="Reason",
  ~customInput=InputFields.textInput(),
  ~placeholder="Enter Refund Reason",
  ~isRequired=false,
  (),
)

let nonRefundConnectors = ["braintree", "klarna", "airwallex"]

let isNonRefundConnector = json => {
  nonRefundConnectors->Array.includes(
    LogicUtils.getDictFromJsonObject(json)->LogicUtils.getString("connectors", ""),
  )
}
