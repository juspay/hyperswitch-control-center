type transactionPayload = {
  transaction_id: string,
  credit_account: string,
  debit_account: string,
  amount: int,
  currency: string,
  variance: int,
  status: string,
  created_at: string,
}

type transactionColType =
  | TransactionId
  | CreditAccount
  | DebitAccount
  | Amount
  | Currency
  | Variance
  | Status
  | CreatedAt
