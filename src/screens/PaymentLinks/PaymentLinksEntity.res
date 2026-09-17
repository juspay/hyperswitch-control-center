open LogicUtils
open PaymentLinksTypes

type paymentLinkColType =
  | PaymentLinkId
  | PaymentId
  | MerchantId
  | ProcessorMerchantId
  | ProfileId
  | Status
  | Amount
  | Currency
  | Description
  | CreatedAt
  | ExpiresAt
  | PaymentLinkUrl
  | SecureLink

let defaultColumns = [
  PaymentLinkId,
  PaymentId,
  ProfileId,
  Status,
  Amount,
  PaymentLinkUrl,
  CreatedAt,
]

let allColumns = [
  PaymentLinkId,
  PaymentId,
  MerchantId,
  ProcessorMerchantId,
  ProfileId,
  Status,
  Amount,
  Currency,
  Description,
  CreatedAt,
  ExpiresAt,
  PaymentLinkUrl,
  SecureLink,
]

let getHeading = colType => {
  switch colType {
  | PaymentLinkId => Table.makeHeaderInfo(~key="payment_link_id", ~title="Payment Link ID")
  | PaymentId => Table.makeHeaderInfo(~key="payment_id", ~title="Payment ID")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  | ProcessorMerchantId =>
    Table.makeHeaderInfo(~key="processor_merchant_id", ~title="Processor Merchant ID")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile ID")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~dataType=DropDown)
  | Amount => Table.makeHeaderInfo(~key="amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | ExpiresAt => Table.makeHeaderInfo(~key="expiry", ~title="Expires At")
  | PaymentLinkUrl => Table.makeHeaderInfo(~key="link_to_pay", ~title="Payment Link URL")
  | SecureLink => Table.makeHeaderInfo(~key="secure_link", ~title="Secure Link")
  }
}

let getCell = (paymentLink, colType): Table.cell => {
  switch colType {
  | PaymentLinkId => DisplayCopyCell(paymentLink.payment_link_id)
  | PaymentId => DisplayCopyCell(paymentLink.payment_id)
  | MerchantId => Text(paymentLink.merchant_id)
  | ProcessorMerchantId => Text(paymentLink.processor_merchant_id)
  | ProfileId => Text(paymentLink.profile_id)
  | Status =>
    Label({
      title: paymentLink.status->String.toUpperCase,
      color: switch paymentLink.status {
      | "active" => LabelGreen
      | "expired" => LabelGray
      | _ => LabelGray
      },
    })
  | Amount =>
    Currency(
      paymentLink.amount /. CurrencyUtils.getCurrencyConversionFactor(paymentLink.currency),
      paymentLink.currency,
    )
  | Currency => Text(paymentLink.currency)
  | Description => Text(paymentLink.description)
  | CreatedAt => Date(paymentLink.created_at)
  | ExpiresAt => Date(paymentLink.expiry)
  | PaymentLinkUrl => Link(paymentLink.link_to_pay)
  | SecureLink =>
    paymentLink.secure_link->isNonEmptyString ? Link(paymentLink.secure_link) : Text("-")
  }
}

let itemToObjMapper = dict => {
  {
    payment_link_id: getString(dict, "payment_link_id", ""),
    payment_id: getString(dict, "payment_id", ""),
    merchant_id: getString(dict, "merchant_id", ""),
    processor_merchant_id: getString(dict, "processor_merchant_id", ""),
    profile_id: getString(dict, "profile_id", ""),
    link_to_pay: getString(dict, "link_to_pay", ""),
    amount: getFloat(dict, "amount", 0.0),
    currency: getString(dict, "currency", ""),
    description: getString(dict, "description", ""),
    status: getString(dict, "status", ""),
    created_at: getString(dict, "created_at", ""),
    expiry: getString(dict, "expiry", ""),
    secure_link: getString(dict, "secure_link", ""),
  }
}

let getPaymentLinks: JSON.t => array<paymentLink> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let paymentLinkEntity = orgId =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getPaymentLinks,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell,
    ~dataKey="",
    ~getShowLink={
      paymentLink =>
        GlobalVars.appendDashboardPath(
          ~url=`/payments/${paymentLink.payment_id}/${paymentLink.profile_id}/${paymentLink.merchant_id}/${orgId}`,
        )
    },
  )
