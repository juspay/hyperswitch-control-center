open VaultPaymentMethodDetailsTypes
open LogicUtils

type pspTokenColsTypes =
  | TokenId
  | Connector
  | MCAId
  | TokenType
  | Status
  | Created

let defaultColumns = [TokenId, Connector, MCAId, TokenType, Status, Created]

let getHeading = colType => {
  switch colType {
  | TokenId => Table.makeHeaderInfo(~key="token", ~title="Token")
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Connector")
  | MCAId => Table.makeHeaderInfo(~key="mca_id", ~title="MCA Id")
  | TokenType => Table.makeHeaderInfo(~key="tokentype", ~title="Token Type")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  }
}

let getCell = (pspTokens: VaultPaymentMethodDetailsTypes.psp_tokens, colType): Table.cell => {
  switch colType {
  | TokenId => Text(pspTokens.token)
  | Connector => Text(pspTokens.connector)
  | MCAId => Text(pspTokens.mca_id)
  | TokenType => Text(pspTokens.tokentype)
  | Status => Text(pspTokens.status)
  | Created => Text(pspTokens.created)
  }
}
let itemToObjMapper = (dict: dict<JSON.t>) => {
  {
    mca_id: dict->getString("token", ""),
    connector: dict->getString("connector", ""),
    status: dict->getString("status", ""),
    created: dict->getString("created", ""),
    tokentype: dict->getString("tokentype", ""),
    token: dict->getString("token", ""),
  }
}

let getPSPTokens: JSON.t => array<psp_tokens> = json => {
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
