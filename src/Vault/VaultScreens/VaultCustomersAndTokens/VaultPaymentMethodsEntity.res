open VaultPaymentMethodsTypes
open LogicUtils

let defaultColumns = [
  PaymentMethodId,
  PaymentMethodType,
  PaymentMethodData,
  PSPTokensization,
  NetworkTokenization,
  CreatedAt,
  LastUsed,
]

let getHeading = colType => {
  switch colType {
  | PaymentMethodId => Table.makeHeaderInfo(~key="payment_method_id", ~title="Payment Method Id")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | PaymentMethodData => Table.makeHeaderInfo(~key="payment_method", ~title="Payment Method Data")
  | PSPTokensization => Table.makeHeaderInfo(~key="psp_tokensization", ~title="PSP Tokensization")
  | NetworkTokenization =>
    Table.makeHeaderInfo(~key="network_tokensization", ~title="Network Tokensization")
  | CreatedAt => Table.makeHeaderInfo(~key="created", ~title="Created")
  | LastUsed => Table.makeHeaderInfo(~key="last_used_at", ~title="Last Used")
  }
}

let getCell = (paymentMethodsData, colType): Table.cell => {
  switch colType {
  | PaymentMethodId => Text(paymentMethodsData.payment_method_id)
  | PaymentMethodType => Text(paymentMethodsData.payment_method_type->Option.getOr(""))
  | PaymentMethodData => Text(paymentMethodsData.payment_method)
  | PSPTokensization =>
    Label({
      title: "ENABLED"->String.toUpperCase, // use from paymentMethodsData
      color: switch "ENABLED"->VaultPaymentMethodUtils.statusToVariantMapper {
      | Enabled => LabelGreen
      | Disabled => LabelRed
      },
    })
  | NetworkTokenization =>
    Label({
      title: "ENABLED"->String.toUpperCase, // use from paymentMethodsData
      color: switch "ENABLED"->VaultPaymentMethodUtils.statusToVariantMapper {
      | Enabled => LabelGreen
      | Disabled => LabelRed
      },
    })
  | CreatedAt => Date(paymentMethodsData.created)
  | LastUsed => Date(paymentMethodsData.last_used_at)
  }
}

let pspTokenMapper = dict => {
  {
    mca_id: dict->getString("mca_id", ""),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    tokentype: dict->getString("tokentype", ""),
    token: dict->getString("token", ""),
  }
}

let pspTokensizationMapper = json => {
  psp_token: json->getArrayDataFromJson(pspTokenMapper),
}

let networkTokenizationMapper = dict => {
  {
    enabled: dict->getBool("enabled", false),
    status: dict->getString("status", ""),
    token: dict->getString("token", ""),
  }
}

let itemToObjMapper = dict => {
  {
    merchant: dict->getString("merchant", ""),
    customer_id: dict->getOptionString("customer_id"),
    payment_method_id: dict->getString("payment_method_id", ""),
    payment_method_type: dict->getOptionString("payment_method_type"),
    payment_method: dict->getString("payment_method", ""),
    card: Some(dict->getJsonObjectFromDict("card")),
    metadata: dict->getJsonObjectFromDict("metadata"),
    tokenization_type: dict->getJsonObjectFromDict("tokenization_type"),
    psp_tokensization: dict->getJsonObjectFromDict("psp_tokensization")->pspTokensizationMapper,
    network_tokensization: dict
    ->getDictfromDict("newtork_tokensization")
    ->networkTokenizationMapper,
    bank_transfer: dict->getString("bank_transfer", ""),
    created: dict->getString("created", ""),
    last_used_at: dict->getString("last_used_at", ""),
    recurring_enabled: dict->getBool("recurring_enabled", false),
    network_transaction_id: dict->getString("network_transaction_id", ""),
  }
}

let getPaymentMethods: JSON.t => array<vaultPaymentMethods> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let vaultPaymentMethodsEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getPaymentMethods,
  ~defaultColumns,
  ~allColumns={defaultColumns},
  ~getHeading,
  ~getCell,
  ~dataKey="",
)
