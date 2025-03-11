open AlternatePaymentMethodsTypes
open VerticalStepIndicatorTypes

let altPaymentMethods = [ApplePay, Klarna, GooglePay, SamsumgPay, Paypal, Paze]

let altPaymentMethodsToString = (altPaymentMethod: altPaymentMethodTypes) =>
  switch altPaymentMethod {
  | ApplePay => "ApplePay"
  | Klarna => "Klarna"
  | GooglePay => "GooglePay"
  | SamsumgPay => "SamsungPay"
  | Paypal => "Paypal"
  | Paze => "Paze"
  }

let altPaymentMethodsDisplayName = (altPaymentMethod: altPaymentMethodTypes) =>
  switch altPaymentMethod {
  | ApplePay => "Apple Pay"
  | Klarna => "Klarna"
  | GooglePay => "Google Pay"
  | SamsumgPay => "Samsung Pay"
  | Paypal => "Paypal"
  | Paze => "Paze"
  }

let sortByName = (c1, c2) => {
  LogicUtils.compareLogic(c2->altPaymentMethodsToString, c1->altPaymentMethodsToString)
}

let getSectionName = section => {
  switch section {
  | #ConfigureProcessor => "Configure your processor"
  | #ReviewAndConnect => "Review and Connect"
  }
}

let getSectionIcon = section => {
  switch section {
  | #ConfigureProcessor => "nd-shield"
  | #ReviewAndConnect => "nd-flag"
  }
}

let sections = [
  {
    id: (#ConfigureProcessor: sectionType :> string),
    name: #ConfigureProcessor->getSectionName,
    icon: #ConfigureProcessor->getSectionIcon,
    subSections: None,
  },
  {
    id: (#ReviewAndConnect: sectionType :> string),
    name: #ReviewAndConnect->getSectionName,
    icon: #ReviewAndConnect->getSectionIcon,
    subSections: None,
  },
]

let getSectionVariant = ({sectionId}) => {
  switch sectionId {
  | "ConfigureProcessor" => #ConfigureProcessor
  | "ReviewAndConnect" | _ => #ReviewAndConnect
  }
}
