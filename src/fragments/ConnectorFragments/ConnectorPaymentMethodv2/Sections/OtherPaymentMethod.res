@react.component
let make = (~index, ~pm, ~pmIndex, ~paymentMethodValues, ~connector) => {
  open LogicUtils
  open SectionHelper
  open ConnectorPaymentMethodV3Utils
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let connData =
    formState.values->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let availablePM =
    paymentMethodValues
    ->getArrayFromDict(pm, [])
    ->getPaymentMethodMapper(connector, pm)

  let showSelectAll = if (
    pm->getPaymentMethodFromString == Wallet && pm->getPaymentMethodFromString == BankDebit
  ) {
    false
  } else if (
    connector->ConnectorUtils.getConnectorNameTypeFromString == Processors(KLARNA) &&
      connData.metadata
      ->getDictFromJsonObject
      ->getString("klarna_region", "") !== "Europe"
  ) {
    false
  } else {
    true
  }

  <div key={index->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
    <HeadingSection index pm availablePM pmIndex pmt=pm showSelectAll />
    <RenderIf
      condition={pm->getPaymentMethodFromString === Wallet &&
        {
          switch connector->ConnectorUtils.getConnectorNameTypeFromString {
          | Processors(ZEN) => true
          | _ => false
          }
        }}>
      <div className="border rounded p-2 bg-jp-gray-100 flex gap-4">
        <Icon name="outage_icon" size=15 />
        {"Zen doesn't support Googlepay and Applepay in sandbox."->React.string}
      </div>
    </RenderIf>
    <div className="flex gap-8 p-6 flex-wrap">
      {availablePM
      ->Array.mapWithIndex((pmtData, i) => {
        let paymentMethodTypeValues = connData.payment_methods_enabled->Array.get(pmIndex)
        let pmtIndex = switch paymentMethodTypeValues {
        | Some(k) => {
            let isPMTEnabled =
              k.payment_method_types->Array.findIndex(val =>
                val.payment_method_type == pmtData.payment_method_type
              )
            isPMTEnabled == -1 ? k.payment_method_types->Array.length : isPMTEnabled
          }
        | None => 0
        }

        let label = switch (
          pmtData.payment_method_type->getPaymentMethodTypeFromString,
          pm->getPaymentMethodFromString,
          connector->ConnectorUtils.getConnectorNameTypeFromString,
        ) {
        | (PayPal, Wallet, Processors(PAYPAL)) =>
          pmtData.payment_experience->Option.getOr("") == "redirect_to_url"
            ? "PayPal Redirect"
            : "PayPal SDK"
        | (Klarna, PayLater, Processors(KLARNA)) =>
          pmtData.payment_experience->Option.getOr("") == "redirect_to_url"
            ? "Klarna Checkout"
            : "Klarna SDK"
        | (OpenBankingPIS, _, _) => "Open Banking PIS"
        | _ => pmtData.payment_method_type
        }

        let showCheckbox = switch (
          pmtData.payment_method_type->getPaymentMethodTypeFromString,
          pm->getPaymentMethodFromString,
          connector->ConnectorUtils.getConnectorNameTypeFromString,
        ) {
        | (Klarna, PayLater, Processors(KLARNA)) =>
          !(
            pmtData.payment_experience->Option.getOr("") == "redirect_to_url" &&
              connData.metadata
              ->getDictFromJsonObject
              ->getString("klarna_region", "")
              ->String.toLowerCase !== "europe"
          )

        | _ => true
        }
        <PaymentMethodTypes index=i label pmtData pmIndex pmtIndex pm showCheckbox />
      })
      ->React.array}
    </div>
  </div>
}
