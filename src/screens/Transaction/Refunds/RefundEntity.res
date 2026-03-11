open LogicUtils
open HSwitchOrderUtils

type refunds = {
  profile_id: string,
  refund_id: string,
  payment_id: string,
  amount: float,
  currency: string,
  reason: string,
  status: string,
  metadata: string,
  updated_at: string,
  created_at: string,
  error_message: string,
  error_code: string,
  connector: string,
}

type refundsColType =
  | Amount
  | Created
  | Currency
  | ErrorCode
  | ErrorMessage
  | PaymentId
  | RefundReason
  | RefundId
  | RefundStatus
  | LastUpdated
  | MetaData
  | ConnectorName

let defaultColumns = [RefundId, ConnectorName, Amount, RefundStatus, PaymentId, Created]

let allColumns = [
  Amount,
  ConnectorName,
  Created,
  Currency,
  ErrorCode,
  ErrorMessage,
  LastUpdated,
  MetaData,
  PaymentId,
  RefundId,
  RefundReason,
  RefundStatus,
]

let useGetStatus = order => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.status->String.toUpperCase
  let fixedCss = "text-sm text-white font-bold p-1.5 rounded-lg"
  switch order.status->statusVariantMapper {
  | Succeeded =>
    <div className={`${fixedCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Failed
  | Cancelled =>
    <div className={`${fixedCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod =>
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = colType => {
  switch colType {
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | LastUpdated => Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | RefundId => Table.makeHeaderInfo(~key="refund_id", ~title="Refund ID")
  | RefundReason => Table.makeHeaderInfo(~key="reason", ~title="Refund Reason")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  | RefundStatus => Table.makeHeaderInfo(~key="status", ~title="Refund Status", ~dataType=DropDown)
  | MetaData => Table.makeHeaderInfo(~key="metaData", ~title="MetaData", ~dataType=DropDown)
  | ConnectorName => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  }
}

let getCell = (refundData, colType, merchantId, orgId): Table.cell => {
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(refundData.currency)
  switch colType {
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(refundData.amount /. conversionFactor)->Float.toString}
        currency={refundData.currency}
      />,
      "",
    )
  | Created => Date(refundData.created_at)
  | Currency => Text(refundData.currency)
  | ErrorCode => Text(refundData.error_code)
  | ErrorMessage => Text(refundData.error_message)
  | PaymentId =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap" displayValue=Some(refundData.payment_id)
      />,
      "",
    )
  | RefundReason => Text(refundData.reason)
  | RefundId =>
    CustomCell(
      <CopyLinkTableCell
        url={`/refunds/${refundData.refund_id}/${refundData.profile_id}/${merchantId}/${orgId}`}
        displayValue={refundData.refund_id}
        copyValue={Some(refundData.refund_id)}
        endValue={idCellEndValue}
      />,
      "",
    )
  | RefundStatus =>
    Label({
      title: refundData.status->String.toUpperCase,
      color: switch refundData.status->statusVariantMapper {
      | Succeeded => LabelGreen
      | Failed => LabelRed
      | Processing => LabelOrange
      | Cancelled => LabelRed
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelBlue
      | _ => LabelBlue
      },
    })
  | LastUpdated => Date(refundData.updated_at)
  | MetaData => Text(refundData.metadata)
  | ConnectorName =>
    CustomCell(<HelperComponents.ConnectorCustomCell connectorName=refundData.connector />, "")
  }
}

let itemToObjMapper = dict => {
  {
    profile_id: getString(dict, "profile_id", ""),
    amount: getFloat(dict, "amount", 0.0),
    created_at: getString(dict, "created_at", ""),
    currency: getString(dict, "currency", ""),
    error_message: getString(dict, "error_message", ""),
    metadata: getString(dict, "metadata", ""),
    payment_id: getString(dict, "payment_id", ""),
    reason: getString(dict, "reason", ""),
    refund_id: getString(dict, "refund_id", ""),
    status: getString(dict, "status", ""),
    updated_at: getString(dict, "updated_at", ""),
    error_code: getString(dict, "error_code", ""),
    connector: getString(dict, "connector", ""),
  }
}

let getRefunds: JSON.t => array<refunds> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let refundEntity = (merchantId, orgId) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getRefunds,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(refunds, refundsColType) => getCell(refunds, refundsColType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      refundData =>
        GlobalVars.appendDashboardPath(
          ~url=`/refunds/${refundData.refund_id}/${refundData.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
