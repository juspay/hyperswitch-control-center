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
  | PaymentMethodId => Table.makeHeaderInfo(~key="id", ~title="Payment Method Id")
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

let paymentMethodDataCell = (last4_digits, cardNetwork) => {
  <div className="flex gap-4 ">
    <div className="w-9"> {`${last4_digits}`->React.string} </div>
    <div className="flex items-center  mr-6">
      <GatewayIcon gateway={cardNetwork->String.toUpperCase} className="w-6 h-6 mr-1" />
      <div className="capitalize">
        {cardNetwork
        ->capitalizeString
        ->React.string}
      </div>
    </div>
  </div>
}

let getCell = (paymentMethodsData, colType): Table.cell => {
  switch colType {
  | PaymentMethodId => Text(paymentMethodsData.id)
  | PaymentMethodType =>
    Text(paymentMethodsData.payment_method_type->Option.getOr("")->capitalizeString)
  | PaymentMethodData =>
    CustomCell(
      paymentMethodDataCell(
        paymentMethodsData.payment_method_data.card.last4_digits,
        paymentMethodsData.payment_method_data.card.card_network,
      ),
      "",
    )
  | PSPTokensization =>
    Label({
      title: paymentMethodsData.psp_tokenization_enabled ? "Enabled" : "Disabled",
      color: paymentMethodsData.psp_tokenization_enabled ? LabelGreen : LabelGray,
    })

  | NetworkTokenization => {
      let isEnabled =
        paymentMethodsData.network_tokensization.payment_method_data->LogicUtils.checkEmptyJson
      Label({
        title: isEnabled ? "Enabled" : "Disabled",
        color: isEnabled ? LabelGreen : LabelGray,
      })
    }
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

let cardTypeMapper = dict => {
  issuer_country: dict->getString("issuer_country", ""),
  last4_digits: dict->getString("last4_digits", ""),
  expiry_month: dict->getString("expiry_month", ""),
  expiry_year: dict->getString("expiry_year", ""),
  card_holder_name: dict->getString("card_holder_name", ""),
  card_fingerprint: dict->getString("card_fingerprint", ""),
  nick_name: dict->getString("nick_name", ""),
  card_network: dict->getString("card_network", ""),
  card_isin: dict->getString("card_isin", ""),
  card_issuer: dict->getString("card_issuer", ""),
  card_type: dict->getString("card_type", ""),
  saved_to_locker: dict->getString("saved_to_locker", ""),
}
let paymentMethodDataTypeMapper = dict => {
  let cardDict = dict->getDictfromDict("card")
  {
    card: cardDict->cardTypeMapper,
  }
}
let networkTokenizationMapper = dict => {
  payment_method_data: dict->getJsonObjectFromDict("payment_method_data"),
}

let itemToObjMapper = dict => {
  {
    customer_id: dict->getOptionString("customer_id"),
    id: dict->getString("id", ""),
    payment_method_type: dict->getOptionString("payment_method_type"),
    payment_method: dict->getString("payment_method", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    tokenization_type: dict->getJsonObjectFromDict("tokenization_type"),
    psp_tokensization: dict->getJsonObjectFromDict("psp_tokensization")->pspTokensizationMapper,
    network_tokensization: dict->getDictfromDict("network_tokenization")->networkTokenizationMapper,
    bank_transfer: dict->getString("bank_transfer", ""),
    created: dict->getString("created", ""),
    last_used_at: dict->getString("last_used_at", ""),
    recurring_enabled: dict->getBool("recurring_enabled", false),
    network_transaction_id: dict->getString("network_transaction_id", ""),
    payment_method_data: dict->getDictfromDict("payment_method_data")->paymentMethodDataTypeMapper,
    psp_tokenization_enabled: dict->getBool("psp_tokenization_enabled", false),
  }
}
let getArrayOfPaymentMethodListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->itemToObjMapper
  })
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
