open LogicUtils

let idCellEndValue = 24

type status =
  | Succeeded
  | Failed
  | Cancelled
  | Expired
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod
  | RequiresConfirmation
  | PartiallyCaptured
  | CancelledPostCapture
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

type refundStatus =
  | Success
  | Pending
  | Failure
  | None

type stripeChargeType =
  | Destination
  | Direct
  | None

@unboxed
type adyenRefundReason =
  | FRAUD
  | CUSTOMERREQUEST
  | RETURN
  | DUPLICATE
  | OTHER

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
  | "CANCELLED_POST_CAPTURE" => CancelledPostCapture
  | "EXPIRED" => Expired
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

let refundStatusVariantMapper: string => refundStatus = statusLabel => {
  switch statusLabel->String.toUpperCase {
  | "SUCCESS" | "SUCCEEDED" => Success
  | "PENDING" => Pending
  | "FAILURE" => Failure
  | _ => None
  }
}

let adyenRefundReasonToDisplayName = reason =>
  switch reason {
  | FRAUD => "Fraud"
  | CUSTOMERREQUEST => "Customer Request"
  | RETURN => "Return"
  | DUPLICATE => "Duplicate"
  | OTHER => "Other"
  }

let allAdyenRefundReasons = [FRAUD, CUSTOMERREQUEST, RETURN, DUPLICATE, OTHER]

let isTestData = id => id->String.includes("test_")

let amountField = FormRenderer.makeFieldInfo(
  ~name="amount",
  ~label="Refund Amount",
  ~customInput=InputFields.numericTextInput(),
  ~placeholder="Enter Refund Amount",
  ~isRequired=true,
)

// Amount field with precision based on currency
let amountFieldWithPrecision = (~precisionDigits) => {
  FormRenderer.makeFieldInfo(
    ~name="amount",
    ~label="Refund Amount",
    ~customInput=InputFields.numericTextInput(~precision=precisionDigits),
    ~placeholder="Enter Refund Amount",
    ~isRequired=true,
  )
}

let reasonField = FormRenderer.makeFieldInfo(
  ~name="reason",
  ~label="Reason",
  ~customInput=InputFields.textInput(),
  ~placeholder="Enter Refund Reason",
  ~isRequired=false,
)

let adyenReasonDropdownField = FormRenderer.makeFieldInfo(
  ~name="reason",
  ~label="Reason",
  ~customInput=InputFields.selectInput(
    ~options=allAdyenRefundReasons->Array.map((reason): SelectBox.dropdownOption => {
      {
        label: reason->adyenRefundReasonToDisplayName,
        value: (reason :> string),
      }
    }),
    ~buttonText="Select Reason",
    ~searchable=false,
  ),
  ~placeholder="Select Reason",
  ~isRequired=true,
)

let refundAddressField = FormRenderer.makeFieldInfo(
  ~name="metadata.address",
  ~label="Cryptocurrency Address",
  ~customInput=InputFields.textInput(),
  ~placeholder="Enter Address",
  ~isRequired=true,
)

let refundEmailField = FormRenderer.makeFieldInfo(
  ~name="metadata.email",
  ~label="Email",
  ~customInput=InputFields.textInput(),
  ~placeholder="Enter Email",
  ~isRequired=true,
)

let nonRefundConnectors = ["braintree", "klarna", "airwallex"]
let isSplitPaymentConnectors = ["stripe"]

let isSplitPaymentConnector = connector => {
  isSplitPaymentConnectors->Array.includes(connector)
}

let getStripeChargeVariantFromString = stripeChargeType => {
  switch stripeChargeType {
  | "destination" => Destination
  | "direct" => Direct
  | _ => None
  }
}

let getStripeChargeType = splitPaymentsDict => {
  let stripeChargeType =
    splitPaymentsDict->getDictfromDict("stripe_split_payment")->getString("charge_type", "")
  stripeChargeType->String.toLowerCase->getStripeChargeVariantFromString
}

let initialValuesDict = (~isSplitPayment, ~order: PaymentInterfaceTypes.order) => {
  let baseDict = Dict.make()

  // Set default reason to "RETURN" only for ADYEN connector
  switch order.connector->String.toLowerCase->ConnectorUtils.getConnectorNameTypeFromString {
  | Processors(ADYEN) => Dict.set(baseDict, "reason", "RETURN"->JSON.Encode.string)
  | _ => ()
  }

  switch (isSplitPayment, order.split_payments->getStripeChargeType) {
  | (true, Direct) =>
    Dict.set(
      baseDict,
      "split_refunds",
      Dict.fromArray([
        (
          "stripe_split_refund",
          Dict.fromArray([("revert_platform_fee", false->JSON.Encode.bool)])->JSON.Encode.object,
        ),
      ])->JSON.Encode.object,
    )
    baseDict
  | (true, Destination) =>
    Dict.set(
      baseDict,
      "split_refunds",
      Dict.fromArray([
        (
          "stripe_split_refund",
          Dict.fromArray([
            ("revert_platform_fee", false->JSON.Encode.bool),
            ("revert_transfer", false->JSON.Encode.bool),
          ])->JSON.Encode.object,
        ),
      ])->JSON.Encode.object,
    )
    baseDict
  | _ => baseDict
  }
}

let isNonRefundConnector = connector => {
  nonRefundConnectors->Array.includes(connector)
}

module CopyLinkTableCell = {
  @react.component
  let make = (
    ~displayValue: string,
    ~url,
    ~copyValue,
    ~customParentClass="flex items-center gap-2",
    ~customOnCopyClick=() => (),
    ~customTextCss="w-36",
    ~endValue=20,
    ~leftIcon: Button.iconType=NoIcon,
  ) => {
    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)
    let showToast = ToastState.useShowToast()
    let handleClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      setIsTextVisible(_ => true)
    }

    let copyVal = switch copyValue {
    | Some(val) => val
    | None => displayValue
    }
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    <div className="flex items-center">
      {if displayValue->isNonEmptyString {
        <div className=customParentClass>
          {switch leftIcon {
          | CustomIcon(element) => element
          | _ => React.null
          }}
          <RenderIf condition={isTextVisible || displayValue->String.length <= endValue}>
            <div> {displayValue->React.string} </div>
          </RenderIf>
          <RenderIf
            condition={!isTextVisible &&
            displayValue->isNonEmptyString &&
            displayValue->String.length > endValue}>
            <div className="flex text-nowrap gap-1 ">
              <p className={`${customTextCss} overflow-hidden`}>
                {`${displayValue->String.slice(~start=0, ~end=endValue)}`->React.string}
              </p>
              <span
                className="flex text-blue-811 text-sm font-extrabold cursor-pointer"
                onClick={ev => handleClick(ev)}>
                {"..."->React.string}
              </span>
            </div>
          </RenderIf>
          <Icon
            name="nd-copy"
            className="cursor-pointer opacity-70 h-7 py-1"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
          <a
            className="opacity-70 py-1"
            href={GlobalVars.appendDashboardPath(~url)}
            onClick={ev => ev->ReactEvent.Mouse.stopPropagation}
            target="_blank">
            <Icon size={14} name="external-link-alt" />
          </a>
        </div>
      } else {
        "NA"->React.string
      }}
    </div>
  }
}
