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
      color: switch attempt.status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
      | #CHARGED => LabelGreen
      | #FAILURE => LabelRed
      | _ => LabelLightGray
      },
    })
  | Id => DisplayCopyCell(attempt.id)
  | Error => Text(attempt.error)
  | AttemptTriggeredBy => Text(attempt.attempt_triggered_by->LogicUtils.snakeToTitle)
  | Created => Text(attempt.created)
  | CardNetwork => Text(`${attempt.card_network} - ***** ${attempt.last4}`)
  | DeclineCode => Text(attempt.network_decline_code)
  | ErrorMessage => Text(attempt.network_error_message)
  }
}

let getAttemptHeading = (attemptColType: RevenueRecoveryOrderTypes.attemptColType) => {
  switch attemptColType {
  | Id => Table.makeHeaderInfo(~key="id", ~title="Attempt ID")
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | Error => Table.makeHeaderInfo(~key="Error", ~title="Error Reason")
  | AttemptTriggeredBy => Table.makeHeaderInfo(~key="AttemptTriggeredBy", ~title="Attempted By")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created")
  | CardNetwork => Table.makeHeaderInfo(~key="Card used", ~title="Card used")
  | DeclineCode => Table.makeHeaderInfo(~key=" DeclineCode", ~title=" Decline Code")
  | ErrorMessage => Table.makeHeaderInfo(~key="ErrorMessage", ~title="Error Message")
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
  created: dict->getString("created_at", ""),
  card_network: dict
  ->getDictfromDict("payment_method_data")
  ->getDictfromDict("card")
  ->getString("card_issuer", ""),
  last4: dict
  ->getDictfromDict("payment_method_data")
  ->getDictfromDict("card")
  ->getString("last4", ""),
  network_decline_code: dict
  ->getDictfromDict("error")
  ->getString("network_decline_code", ""),
  network_error_message: dict
  ->getDictfromDict("error")
  ->getString("network_error_message", ""),
  net_amount: dict->getDictfromDict("amount")->getFloat("net_amount", 0.0) /. 100.0,
}

let getAttempts: JSON.t => array<RevenueRecoveryOrderTypes.attempts> = json => {
  open HSwitchOrderUtils
  let errorObject = Dict.make()

  let attemptsList = json->getArrayFromJson([])

  attemptsList->Array.map(item => {
    let dict = item->getDictFromJsonObject

    let errorDict = dict->getDictfromDict("error")

    let networkDeclineCode = errorDict->getString("code", "")
    let networkErrorMessage = errorDict->getString("message", "")

    if (
      (networkDeclineCode->isEmptyString || networkErrorMessage->isEmptyString) &&
        dict->getString("status", "")->paymentAttemptStatusVariantMapper != #CHARGED
    ) {
      dict->Dict.set("error", errorObject->JSON.Encode.object)
    }

    if errorObject->isEmptyDict {
      errorObject->Dict.set("network_decline_code", networkDeclineCode->JSON.Encode.string)
      errorObject->Dict.set("network_error_message", networkErrorMessage->JSON.Encode.string)
    }

    dict->attemptsItemToObjMapper
  })
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
  | ModifiedAt => Table.makeHeaderInfo(~key="ModifiedAt", ~title="Last Attempted")
  | RecoveryProgress => Table.makeHeaderInfo(~key="RecoveryProgress", ~title="Recovery Progress")
  }
}

let getCell = (
  order: RevenueRecoveryOrderTypes.order,
  colType: RevenueRecoveryOrderTypes.colType,
): Table.cell => {
  open RevenueRecoveryOrderUtils
  let orderStatus = order.status->statusVariantMapper->statusStringMapper
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
      title: orderStatus,
      color: switch order.status->statusVariantMapper {
      | Recovered | PartiallyRecovered => LabelGreen
      | Scheduled => LabelOrange
      | Terminated => LabelRed
      | Processing => LabelBlue
      | Queued => LabelYellow
      | _ => LabelLightGray
      },
    })
  | OrderAmount =>
    CustomCell(<CurrencyCell amount={order.order_amount->Float.toString} currency={"USD"} />, "")
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
  | ModifiedAt => Date(order.modified_at)
  | RecoveryProgress =>
    CustomCell(
      <RecoveryInvoicesHelper.SegmentedProgressBar
        orderAmount=order.order_amount amountCaptured=order.amount_captured className="w-32"
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

let defaultColumns: array<RevenueRecoveryOrderTypes.colType> = [
  Id,
  OrderAmount,
  Status,
  RecoveryProgress,
  Created,
  ModifiedAt,
]

let itemToObjMapperForIntents: Dict.t<JSON.t> => RevenueRecoveryOrderTypes.order = dict => {
  let attempts = dict->getArrayFromDict("attempts", [])->JSON.Encode.array->getAttempts

  let revenueRecoveryMetadata =
    dict
    ->getDictfromDict("feature_metadata")
    ->getDictfromDict("revenue_recovery")

  attempts->Array.reverse
  {
    id: dict->getString("id", ""),
    status: dict->getString("status", ""),
    order_amount: dict
    ->getDictfromDict("amount_details")
    ->getFloat("order_amount", 0.0) /. 100.0,
    amount_captured: dict
    ->getDictfromDict("amount_details")
    ->getFloat("amount_captured", 0.0) /. 100.0,
    connector: revenueRecoveryMetadata->getString("connector", ""),
    created: dict->getString("created", ""),
    payment_method_type: revenueRecoveryMetadata->getString("payment_method_type", ""),
    payment_method_subtype: revenueRecoveryMetadata->getString("payment_method_subtype", ""),
    modified_at: dict->getString("modified_at", ""),
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
    ->getFloat("order_amount", 0.0) /. 100.0,
    amount_captured: dict
    ->getDictfromDict("amount")
    ->getFloat("amount_captured", 0.0) /. 100.0,
    connector: dict->getString("connector", ""),
    created: dict->getString("created", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    payment_method_subtype: dict->getString("payment_method_subtype", ""),
    modified_at: dict->getString("modified_at", ""),
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
