open ReconEngineTypes

@unboxed
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
  posted_confirmation_amount: balanceType,
  pending_confirmation_amount: balanceType,
  mismatched_confirmation_amount: balanceType,
  posted_transaction_amount: balanceType,
  pending_transaction_amount: balanceType,
  mismatched_transaction_amount: balanceType,
}

@unboxed
type subHeaderType =
  | Debit
  | Credit

type reconData = {
  inAmount: string,
  outAmount: string,
  inTxns: string,
  outTxns: string,
}

type reconStatusData = {
  statusType: amountType,
  data: reconData,
}

type nodeData = {
  label: string,
  accountType: string,
  statusData: array<reconStatusData>,
  selected: bool,
  onNodeClick: option<unit => unit>,
}

type nodePositionType = {
  x: float,
  y: float,
}

type nodeType = {
  id: string,
  @as("type") nodeType: string,
  sourcePosition?: string,
  targetPosition?: string,
  position: nodePositionType,
  data: nodeData,
}

type edgeStyleType = {
  stroke: string,
  strokeWidth: float,
}

type edgeMarkerType = {@as("type") edgeMarkerType: string}

type edgeType = {
  id: string,
  source: string,
  target: string,
  @as("type") edgeType: string,
  animated?: bool,
  label?: string,
  markerEnd?: edgeMarkerType,
  style?: edgeStyleType,
}

type viewType =
  | Graph
  | Table
