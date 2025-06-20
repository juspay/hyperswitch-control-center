open LogicUtils

module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}

let getAttemptCell = (
  attempt: RevenueRecoveryOrderTypes.attempts,
  attemptColType: RevenueRecoveryOrderTypes.attemptColType,
): Table.cell => {
  switch attemptColType {
  | Status =>
    Label({
      title: attempt.status->String.toUpperCase,
      color: switch attempt.status->HSwitchOrderUtils.refundStatusVariantMapper {
      | Success => LabelGreen
      | Failure => LabelRed
      | _ => LabelLightGray
      },
    })
  | Id => DisplayCopyCell(attempt.id)
  | Error => Text(attempt.error)
  | AttemptTriggeredBy => Text(attempt.attempt_triggered_by->LogicUtils.snakeToTitle)
  | Created => Text(attempt.created)
  }
}

let getAttemptHeading = (attemptColType: RevenueRecoveryOrderTypes.attemptColType) => {
  switch attemptColType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="Attempt ID")
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | Error => Table.makeHeaderInfo(~key="Error", ~title="Error Reason")
  | AttemptTriggeredBy => Table.makeHeaderInfo(~key="AttemptTriggeredBy", ~title="Attempted By")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created")
  }
}

let attemptsItemToObjMapper: Dict.t<JSON.t> => RevenueRecoveryOrderTypes.attempts = dict => {
  id: dict->getString("id", ""),
  status: dict->getString("status", ""),
  error: dict->getDictfromDict("error")->getString("message", ""),
  attempt_triggered_by: dict
  ->getDictfromDict("feature_metadata")
  ->getDictfromDict("revenue_recovery")
  ->getString("attempt_triggered_by", "Internal"),
  created: dict->getString("created", ""),
}

let getAttempts: JSON.t => array<RevenueRecoveryOrderTypes.attempts> = json => {
  LogicUtils.getArrayDataFromJson(json, attemptsItemToObjMapper)
}

let allColumns: array<RevenueRecoveryOrderTypes.colType> = [
  Id,
  Status,
  OrderAmount,
  Connector,
  Created,
  PaymentMethodType,
]

let getHeading = (colType: RevenueRecoveryOrderTypes.colType) => {
  switch colType {
  | Id => Table.makeHeaderInfo(~key="Invoice_ID", ~title="Invoice ID")
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | OrderAmount => Table.makeHeaderInfo(~key="OrderAmount", ~title="Order Amount")
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created")
  | PaymentMethodType => Table.makeHeaderInfo(~key="PaymentMethodType", ~title="Payment Method")
  }
}

let getCell = (
  order: RevenueRecoveryOrderTypes.order,
  colType: RevenueRecoveryOrderTypes.colType,
): Table.cell => {
  let orderStatus = order.status->HSwitchOrderUtils.statusVariantMapper
  switch colType {
  | Id =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(order.id)
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
        LabelBlue
      | _ => LabelBlue
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

let defaultColumns: array<RevenueRecoveryOrderTypes.colType> = [
  Id,
  Status,
  OrderAmount,
  Connector,
  Created,
  PaymentMethodType,
]

let itemToObjMapperForIntents: Dict.t<JSON.t> => RevenueRecoveryOrderTypes.order = dict => {
  let attempts = dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts

  let revenueRecoveryMetadata =
    dict
    ->getDictfromDict("feature_metadata")
    ->getDictfromDict("payment_revenue_recovery_metadata")

  attempts->Array.reverse
  {
    id: dict->getString("id", ""),
    status: dict->getString("status", ""),
    order_amount: dict
    ->getDictfromDict("amount_details")
    ->getFloat("order_amount", 0.0),
    connector: revenueRecoveryMetadata->getString("connector", ""),
    created: dict->getString("created", ""),
    payment_method_type: revenueRecoveryMetadata->getString("payment_method_type", ""),
    payment_method_subtype: revenueRecoveryMetadata->getString("payment_method_subtype", ""),
    attempts,
  }
}

let itemToObjMapper: Dict.t<JSON.t> => RevenueRecoveryOrderTypes.order = dict => {
  let attempts = dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts

  attempts->Array.reverse
  {
    id: dict->getString("id", ""),
    status: dict->getString("status", ""),
    order_amount: dict
    ->getDictfromDict("amount")
    ->getFloat("order_amount", 0.0),
    connector: dict->getString("connector", ""),
    created: dict->getString("created", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_subtype: dict->getString("payment_method_subtype", ""),
    attempts,
  }
}
let getOrders: JSON.t => array<RevenueRecoveryOrderTypes.order> = json => {
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
          ~url=`v2/recovery/invoices/${order.id}/${profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
