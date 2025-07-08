type operationSection =
  | Refunds
  | Orders
  | Payouts
  | Disputes
  | Customers
  | Unkown

let textToVariantMapper = text => {
  switch text {
  | "Orders" => Orders
  | "Refunds" => Refunds
  | "Disputes" => Disputes
  | "Payouts" => Payouts
  | "Customers" => Customers
  | _ => Unkown
  }
}
let variantToTextMapper = val => {
  switch val {
  | Orders => "Orders"
  | Refunds => "Refunds"
  | Disputes => "Disputes"
  | Payouts => "Payouts"
  | Customers => "Customers"
  | _ => ""
  }
}
