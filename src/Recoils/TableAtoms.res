let historyDefaultCols = Jotai.atom("hyperSwitchHistoryDefaultCols", HistoryEntity.defaultColumns)

let refundsMapDefaultCols = Jotai.atom("refundsMapDefaultCols", RefundEntity.defaultColumns)

let payoutsMapDefaultCols = Jotai.atom("payoutsMapDefaultCols", PayoutsEntity.defaultColumns)

let ordersMapDefaultCols = Jotai.atom("ordersMapDefaultCols", OrderEntity.defaultColumns)

let disputesMapDefaultCols = Jotai.atom("disputesMapDefaultCols", DisputesEntity.defaultColumns)

let apiDefaultCols = Jotai.atom("hyperSwitchApiDefaultCols", DeveloperUtils.defaultColumns)

let customersMapDefaultCols = Jotai.atom("customersMapDefaultCols", CustomersEntity.defaultColumns)

let revenueRecoveryMapDefaultCols = Jotai.atom(
  "revenueRecoveryMapDefaultCols",
  RevenueRecoveryEntity.defaultColumns,
)
let reconReportsDefaultCols = Jotai.atom(
  "reconReportsDefaultCols",
  ReportsTableEntity.defaultColumns,
)
let reconExceptionReportsDefaultCols = Jotai.atom(
  "reconExceptionReportsDefaultCols",
  ReportsExceptionTableEntity.defaultColumns,
)

let reconTransactionsOverviewDefaultCols = Jotai.atom(
  "reconTransactionsOverviewDefaultCols",
  TransactionsTableEntity.defaultColumnsOverview,
)

let reconTransactionsDefaultCols = Jotai.atom(
  "reconTransactionsDefaultCols",
  TransactionsTableEntity.defaultColumns,
)

let transactionsHierarchicalDefaultCols = Jotai.atom(
  "transactionsHierarchicalDefaultCols",
  HierarchicalTransactionsTableEntity.defaultColumns,
)
