let historyDefaultCols = Recoil.atom(.
  "hyperSwitchHistoryDefaultCols",
  HistoryEntity.defaultColumns,
)

let refundsMapDefaultCols = Recoil.atom(. "refundsMapDefaultCols", RefundEntity.defaultColumns)

let ordersMapDefaultCols = Recoil.atom(. "ordersMapDefaultCols", OrderEntity.defaultColumns)

let disputesMapDefaultCols = Recoil.atom(. "disputesMapDefaultCols", DisputesEntity.defaultColumns)

let apiDefaultCols = Recoil.atom(. "hyperSwitchApiDefaultCols", DeveloperUtils.defaultColumns)

let customersMapDefaultCols = Recoil.atom(.
  "customersMapDefaultCols",
  CustomersEntity.defaultColumns,
)
