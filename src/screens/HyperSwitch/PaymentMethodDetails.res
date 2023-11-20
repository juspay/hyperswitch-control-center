type paymentDetails = {
  type_: string,
  icon: option<React.element>,
  displayName: string,
}
let defaultPaymentDetails = {
  type_: "",
  icon: None,
  displayName: "",
}
let icon = (~size=22, ~width as _=size, name) => {
  <Icon name size=14 className="cursor-pointer" />
}
let details = [
  {
    type_: "card",
    icon: Some(icon("default-card", ~size=19)),
    displayName: "Card",
  },
  {
    type_: "crypto_currency",
    icon: Some(icon("crypto", ~size=19)),
    displayName: "Crypto",
  },
  {
    type_: "klarna",
    icon: Some(icon("klarna", ~size=19)),
    displayName: "Klarna",
  },
  {
    type_: "afterpay_clearpay",
    icon: Some(icon("afterpay", ~size=19)),
    displayName: "After Pay",
  },
  {
    type_: "affirm",
    icon: Some(icon("affirm", ~size=19)),
    displayName: "Affirm",
  },
  {
    type_: "sofort",
    icon: Some(icon("sofort", ~size=19)),
    displayName: "Sofort",
  },
  {
    type_: "bank_transfer",
    icon: Some(icon("default-card", ~size=19)),
    displayName: "ACH Bank Transfer",
  },
  {
    type_: "sepa_debit",
    icon: None,
    displayName: "SEPA Debit",
  },
  {
    type_: "giropay",
    icon: Some(icon("giropay", ~size=19, ~width=25)),
    displayName: "GiroPay",
  },
  {
    type_: "eps",
    icon: Some(icon("eps", ~size=19, ~width=25)),
    displayName: "EPS",
  },
  {
    type_: "ideal",
    icon: Some(icon("ideal", ~size=19, ~width=25)),
    displayName: "iDEAL",
  },
  {
    type_: "ban_connect",
    icon: None,
    displayName: "Ban Connect",
  },
  {
    type_: "ach_bank_debit",
    icon: Some(icon("ach-bank-debit", ~size=19, ~width=25)),
    displayName: "ACH Direct Debit",
  },
  {
    type_: "google_pay",
    icon: Some(icon("google_pay", ~size=25)),
    displayName: "Google Pay",
  },
  // {
  //   type_: "apple_pay",
  //   icon: Some(icon("default-card", ~size=19)),
  //   displayName: "Apple Pay",
  // },
  {
    type_: "paypal",
    icon: Some(icon("paypal", ~size=19)),
    displayName: "PayPal",
  },
]
