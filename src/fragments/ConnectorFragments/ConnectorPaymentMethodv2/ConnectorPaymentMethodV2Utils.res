open ConnectorUtils
open ConnectorTypes
let getPaymentMethodTypeDict = (~pm, ~pmt) => {
  let (cardNetworks, modifedPaymentMethodType) = switch pm->getPaymentMethodTypeFromString {
  | Credit => {
      let cardNetworks = [pmt->JSON.Encode.string]->JSON.Encode.array
      let pmt = pm->JSON.Encode.string
      (cardNetworks, pmt)
    }
  | Debit => {
      let cardNetworks = [pmt->JSON.Encode.string]->JSON.Encode.array
      let pmt = pm->JSON.Encode.string
      (cardNetworks, pmt)
    }
  | _ => {
      let cardNetworks = JSON.Encode.null
      let pmt = pmt->JSON.Encode.string
      (cardNetworks, pmt)
    }
  }
  let newPaymentMenthodType =
    [
      ("payment_method_type", modifedPaymentMethodType),
      ("card_networks", cardNetworks),
      ("minimum_amount", 0->JSON.Encode.int),
      ("maximum_amount", 68607706->JSON.Encode.int),
      ("recurring_enabled", true->JSON.Encode.bool),
    ]->Dict.fromArray
  newPaymentMenthodType
}

let isPMTSelectedUtils = (~selctPM: array<ConnectorTypes.paymentMethodEnabledType>, ~pm, ~pmt) => {
  selctPM
  ->Array.filter(val => {
    let t = val.payment_method_types->Array.filter(types => {
      if (
        pm->getPaymentMethodTypeFromString == Credit || pm->getPaymentMethodTypeFromString == Debit
      ) {
        types.card_networks->Array.some(
          networks => {
            networks->String.toLowerCase === pmt->String.toLowerCase
          },
        )
      } else {
        types.payment_method_type == pmt
      }
    })
    t->Array.length > 0
  })
  ->Array.length > 0
}

let removePMTUtil = (~pmEnabled: payment_methods_enabled, ~pm, ~pmt) => {
  pmEnabled
  ->Array.map(methods => {
    methods.payment_method_types =
      methods.payment_method_types->Array.filter(types =>
        if (
          (methods.payment_method->getPaymentMethodTypeFromString == Credit &&
            pm->getPaymentMethodTypeFromString == Credit) ||
            (methods.payment_method->getPaymentMethodTypeFromString == Debit &&
              pm->getPaymentMethodTypeFromString == Debit)
        ) {
          types.card_networks->Array.some(
            networks => {
              networks->String.toLowerCase !== pmt->String.toLowerCase
            },
          )
        } else {
          types.payment_method_type !== pmt
        }
      )
    methods
  })
  ->Array.filter(method => method.payment_method_types->Array.length > 0)
}

let removeEnabledPM = (~pmEnabled: payment_methods_enabled, ~pm) => {
  pmEnabled->Array.filter(methods => {
    methods.payment_method->String.toLowerCase !== pm->String.toLowerCase
  })
}

let isPMExists = (~pmEnabled: array<ConnectorTypes.paymentMethodEnabledType>, ~pm) => {
  pmEnabled->Array.some(method =>
    method.payment_method->String.toLowerCase === pm->String.toLowerCase
  )
}

let getSelectedPM = (~pmEnabled: array<ConnectorTypes.paymentMethodEnabledType>, ~pm) => {
  pmEnabled->Array.filter(methods => {
    pm == methods.payment_method
  })
}
