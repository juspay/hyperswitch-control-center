type balanceType = {
  value: float,
  currency: string,
}

type accountType = {
  account_name: string,
  account_id: string,
  profile_id: string,
  currency: string,
  initial_balance: balanceType,
  pending_balance: balanceType,
  posted_balance: balanceType,
}

type accountRefType = {
  id: string,
  account_id: string,
}

type reconRuleType = {
  rule_id: string,
  rule_name: string,
  rule_description: string,
  sources: array<accountRefType>,
  targets: array<accountRefType>,
}
