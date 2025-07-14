let historyDefaultCols = Recoil.atom("hyperSwitchHistoryDefaultCols", HistoryEntity.defaultColumns)

let refundsMapDefaultCols = Recoil.atom("refundsMapDefaultCols", RefundEntity.defaultColumns)

let payoutsMapDefaultCols = Recoil.atom("payoutsMapDefaultCols", PayoutsEntity.defaultColumns)

let ordersMapDefaultCols = Recoil.atom("ordersMapDefaultCols", OrderEntity.defaultColumns)

let disputesMapDefaultCols = Recoil.atom("disputesMapDefaultCols", DisputesEntity.defaultColumns)

let apiDefaultCols = Recoil.atom("hyperSwitchApiDefaultCols", DeveloperUtils.defaultColumns)

let customersMapDefaultCols = Recoil.atom("customersMapDefaultCols", CustomersEntity.defaultColumns)

let revenueRecoveryMapDefaultCols = Recoil.atom(
  "revenueRecoveryMapDefaultCols",
  RevenueRecoveryEntity.defaultColumns,
)
let reconReportsDefaultCols = Recoil.atom(
  "reconReportsDefaultCols",
  ReportsTableEntity.defaultColumns,
)
let reconExceptionReportsDefaultCols = Recoil.atom(
  "reconExceptionReportsDefaultCols",
  ReportsExceptionTableEntity.defaultColumns,
)

let reconTransactionsDefaultCols = Recoil.atom(
  "reconTransactionsDefaultCols",
  TransactionsTableEntity.defaultColumns,
)
