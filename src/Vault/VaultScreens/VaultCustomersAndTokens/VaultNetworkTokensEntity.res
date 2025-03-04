open VaultPaymentMethodDetailsTypes
open LogicUtils

type networkTokenColsTypes =
  | Token
  | CardNetwork

let defaultColumns = [Token, CardNetwork]

let getHeading = colType => {
  switch colType {
  | Token => Table.makeHeaderInfo(~key="token", ~title="Token")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  }
}

let getCell = (networkTokens: networkTokensData, colType): Table.cell => {
  switch colType {
  | Token => Text(networkTokens.token)
  | CardNetwork => Text(networkTokens.card_network)
  }
}

let itemToObjMapper = (dict: dict<JSON.t>) => {
  {
    token: dict->getString("token", ""),
    card_network: dict->getString("card_network", ""),
  }
}
