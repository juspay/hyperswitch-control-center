open PaymentMethodBlockingTypes

let getPaymentMethodName = paymentMethod =>
  switch paymentMethod {
  | Card => "Card"
  | ApplePay => "Apple Pay"
  | GooglePay => "Google Pay"
  }

let getFieldName = (paymentMethod, key) => {
  let prefix = switch paymentMethod {
  | Card => "payment_method_blocking.card"
  | ApplePay => "payment_method_blocking.wallet.apple_pay"
  | GooglePay => "payment_method_blocking.wallet.google_pay"
  }
  `${prefix}.${key}`
}

let toggleFields = [
  {
    key: "block_virtual_cards",
    label: "Block virtual cards",
    description: "Blocks cards the BIN record identifies as virtual.",
  },
  {
    key: "block_non_reloadable_prepaid_cards",
    label: "Block non-reloadable prepaid cards",
    description: "Blocks prepaid cards that cannot be topped up.",
  },
  {
    key: "gambling_blocked",
    label: "Block gambling BINs",
    description: "Blocks BINs flagged for gambling.",
  },
  {
    key: "block_if_bin_info_unavailable",
    label: "Block if BIN info unavailable",
    description: "Blocks the payment when the BIN has no matching record in cards_info. Off by default, so unrecognised BINs are allowed through.",
  },
]
