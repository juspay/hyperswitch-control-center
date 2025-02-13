open VaultPaymentMethodDetailsTypes
open LogicUtils

type networkTokenColsTypes =
  | TokenId
  | Network
  | Status
  | Created

let defaultColumns = [TokenId, Network, Status, Created]

let getHeading = colType => {
  switch colType {
  | TokenId => Table.makeHeaderInfo(~key="token", ~title="Token")
  | Network => Table.makeHeaderInfo(~key="enabled", ~title="Network")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  }
}

let getCell = (networkTokens, colType): Table.cell => {
  switch colType {
  | TokenId => Text(networkTokens.token)
  | Network => Text(networkTokens.enabled ? "true" : "false")
  | Status =>
    Label({
      title: networkTokens.status->String.toUpperCase,
      color: switch networkTokens.status->VaultPaymentMethodUtils.statusToVariantMapper {
      | Enabled => LabelGreen
      | Disabled => LabelRed
      },
    })
  | Created => Text(networkTokens.created)
  }
}

let itemToObjMapper = (dict: dict<JSON.t>) => {
  {
    token: dict->getString("token", ""),
    enabled: dict->getBool("enabled", false),
    status: dict->getString("status", ""),
    created: dict->getString("created", ""),
  }
}

let getNetworkTokens: JSON.t => array<network_tokens> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let networkTokensEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getNetworkTokens,
  ~defaultColumns,
  ~allColumns={defaultColumns},
  ~getHeading,
  ~getCell,
  ~dataKey="",
)
