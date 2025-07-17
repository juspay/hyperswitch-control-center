type accountType = {
  account_name: string,
  account_id: string,
  currency: string,
  pending_balance: string,
  posted_balance: string,
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

type accountDetailsType = {
  account_id: string,
  account_name: string,
}
