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
  | Status =>
    Label({
      title: attempt.status->String.toUpperCase,
      color: switch attempt.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
      | #CHARGED => LabelGreen
      | #AUTHENTICATION_FAILED
      | #ROUTER_DECLINED
      | #AUTHORIZATION_FAILED
      | #VOIDED
      | #CAPTURE_FAILED
      | #VOID_FAILED
      | #FAILURE =>
        LabelRed
      | _ => LabelLightBlue
      },
    })
  | Id => DisplayCopyCell(attempt.id)
  | Error => Text(attempt.error)
  | AttemptTriggeredBy => Text(attempt.attempt_triggered_by->LogicUtils.snakeToTitle)
  | Created => Text(attempt.created)
  }
}

let getAttemptHeading = (attemptColType: attemptColType) => {
  switch attemptColType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="Attempt ID")
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | Error => Table.makeHeaderInfo(~key="Error", ~title="Error Reason")
  | AttemptTriggeredBy => Table.makeHeaderInfo(~key="AttemptTriggeredBy", ~title="Attempted By")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created")
  }
}

let attemptsItemToObjMapper = dict => {
  id: dict->getString("id", ""),
  status: dict->getString("status", ""),
  error: dict->getString("error", ""),
  attempt_triggered_by: dict
  ->getDictfromDict("feature_metadata")
  ->getDictfromDict("revenue_recovery")
  ->getString("attempt_triggered_by", ""),
  created: dict->getString("created", ""),
}

let getAttempts: JSON.t => array<attempts> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let allColumns: array<colType> = [Id, Status, OrderAmount, Connector, Created, PaymentMethodType]

let getHeading = (colType: colType) => {
  switch colType {
  | Id => Table.makeHeaderInfo(~key="Invoice_ID", ~title="Invoice ID")
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | OrderAmount => Table.makeHeaderInfo(~key="OrderAmount", ~title="Order Amount")
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created")
  | PaymentMethodType => Table.makeHeaderInfo(~key="PaymentMethodType", ~title="Payment Method")
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

let getCell = (order, colType: colType): Table.cell => {
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | Id =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=order.id
      />,
      "",
    )

  | Status =>
    Label({
      title: order.status->String.toUpperCase,
      color: switch orderStatus {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed
      | Cancelled =>
        LabelRed
      | Processing
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelLightBlue
      | _ => LabelLightBlue
      },
    })
  | OrderAmount =>
    CustomCell(
      <CurrencyCell amount={(order.order_amount /. 100.0)->Float.toString} currency={"USD"} />,
      "",
    )
  | Connector =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=order.connector
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(order.connector)}
      />,
      "",
    )
  | Created => Date(order.created)
  | PaymentMethodType => Text(order.payment_method_type)
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

let defaultColumns: array<colType> = [
  Id,
  Status,
  OrderAmount,
  Connector,
  Created,
  PaymentMethodType,
]

let itemToObjMapper = dict => {
  let attempts = dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts
  attempts->Array.reverse
  {
    id: dict->getString("id", ""),
    status: dict->getString("status", ""),
    order_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("order_amount", 0.0) *. 100.0,
    connector: dict->getString("connector", ""),
    created: dict->getString("created", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_subtype: dict->getString("payment_method_subtype", ""),
    attempts,
  }
}
let getOrders: JSON.t => array<order> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let revenueRecoveryEntity = (merchantId, orgId, profile_id) =>
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getOrders,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    ~getShowLink={
      order =>
        GlobalVars.appendDashboardPath(
          ~url=`v2/recovery/overview/${order.id}/${profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
