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

type refundStatus =
  | Success
  | Pending
  | Failure
  | None

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

let refundStatusVariantMapper: string => refundStatus = statusLabel => {
  switch statusLabel->String.toUpperCase {
  | "SUCCESS" => Success
  | "PENDING" => Pending
  | "FAILURE" => Failure
  | _ => None
  }
}

let isTestData = id => id->String.includes("test_")

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
    ~customTextCss="",
    ~endValue=30,
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
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
    }

    <div className="flex items-center">
      {if displayValue->LogicUtils.isNonEmptyString {
        <div className=customParentClass>
          <RenderIf condition={isTextVisible || displayValue->String.length <= endValue}>
            <div className=customTextCss> {displayValue->React.string} </div>
          </RenderIf>
          <RenderIf
            condition={!isTextVisible &&
            displayValue->LogicUtils.isNonEmptyString &&
            displayValue->String.length > endValue}>
            <div className="flex text-nowrap gap-1">
              <p className="">
                {`${displayValue->String.slice(~start=0, ~end=endValue)}`->React.string}
              </p>
              <span
                className="flex text-blue-811 text-sm font-extrabold"
                onClick={ev => handleClick(ev)}>
                {"..."->React.string}
              </span>
            </div>
          </RenderIf>
          <img
            src={`/assets/CopyToClipboard.svg`}
            className="cursor-pointer opacity-70 hover:opacity-100 py-1"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
          <a
            className="opacity-70 hover:opacity-100 py-1"
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
