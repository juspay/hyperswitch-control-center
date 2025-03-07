type altPaymentMethodTypes =
  | ApplePay
  | Klarna
  | GooglePay
  | SamsumgPay
  | Paypal
  | Paze

type sectionType = [#ConfigureProcessor | #ReviewAndConnect]
