open VaultPaymentMethodDetailsTypes
open LogicUtils

type pspTokenColsTypes =
  | TokenId
  | Connector
  | MCAId
  | TokenType
  | Status

let defaultColumns = [TokenId, MCAId, TokenType, Status]

let getHeading = colType => {
  switch colType {
  | TokenId => Table.makeHeaderInfo(~key="token", ~title="Token")
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | MCAId => Table.makeHeaderInfo(~key="mca_id", ~title="MCA Id")
  | TokenType => Table.makeHeaderInfo(~key="tokentype", ~title="Token Type")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  }
}

let getCell = (
  pspTokens: VaultPaymentMethodDetailsTypes.connectorTokenType,
  colType,
): Table.cell => {
  switch colType {
  | TokenId => Text(pspTokens.token)
  | Connector => Text(pspTokens.connector)
  | MCAId => Text(pspTokens.connector_id)
  | TokenType => Text(pspTokens.token_type)
  | Status =>
    Label({
      title: pspTokens.status->String.toUpperCase,
      color: switch pspTokens.status->VaultPaymentMethodUtils.connectrTokensStatusToVariantMapper {
      | Active => LabelGreen
      | Inactive => LabelGray
      },
    })
  }
}
let itemToObjMapper = dict => {
  {
    connector_id: dict->getString("connector_id", ""),
    connector: dict->getString("connector", ""),
    token_type: dict->getString("token_type", ""),
    status: dict->getString("status", ""),
    connector_token_request_reference_id: dict->getString(
      "connector_token_request_reference_id",
      "",
    ),
    original_payment_authorized_amount: dict->getInt("original_payment_authorized_amount", 0),
    original_payment_authorized_currency: dict->getString(
      "original_payment_authorized_currency",
      "",
    ),
    metadata: dict->getDictfromDict("metadata"),
    token: dict->getString("token", ""),
  }
}

let getPSPTokens: JSON.t => array<connectorTokenType> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let pspTokensEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getPSPTokens,
  ~defaultColumns,
  ~allColumns={defaultColumns},
  ~getHeading,
  ~getCell,
  ~dataKey="",
)
