type amountType =
  | Reconciled
  | Pending
  | Mismatched

type accountTransactionCounts = {
  posted_confirmation_count: int,
  pending_confirmation_count: int,
  mismatched_confirmation_count: int,
  posted_transaction_count: int,
  pending_transaction_count: int,
  mismatched_transaction_count: int,
}

type accountTransactionData = {
  posted_confirmation_count: int,
  pending_confirmation_count: int,
  mismatched_confirmation_count: int,
  posted_transaction_count: int,
  pending_transaction_count: int,
  mismatched_transaction_count: int,
  posted_confirmation_amount: ReconEngineOverviewTypes.balanceType,
  pending_confirmation_amount: ReconEngineOverviewTypes.balanceType,
  mismatched_confirmation_amount: ReconEngineOverviewTypes.balanceType,
  posted_transaction_amount: ReconEngineOverviewTypes.balanceType,
  pending_transaction_amount: ReconEngineOverviewTypes.balanceType,
  mismatched_transaction_amount: ReconEngineOverviewTypes.balanceType,
}

@unboxed
type subHeaderType =
  | In
  | Out

type reconData = {
  \"in": string,
  out: string,
  inTxns: string,
  outTxns: string,
}

type reconStatusData = {
  statusType: amountType,
  data: reconData,
}

type nodeData = {
  label: string,
  statusData: array<reconStatusData>,
  selected: bool,
  onNodeClick: option<unit => unit>,
}

type nodeType = {
  id: string,
  \"type": string,
  sourcePosition?: string,
  targetPosition?: string,
  position: {"x": float, "y": float},
  data: nodeData,
}

type edgeType = {
  id: string,
  source: string,
  target: string,
  \"type": string,
  animated?: bool,
  label?: string,
  markerEnd?: {"type": string},
  style?: {"stroke": string, "strokeWidth": float},
}

type viewType =
  | Graph
  | Table
