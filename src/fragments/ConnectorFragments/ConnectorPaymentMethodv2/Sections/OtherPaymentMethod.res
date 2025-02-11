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

  <div key={index->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
    <HeadingSection index pm availablePM pmIndex pmt=pm />
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
        <PaymentMethodTypes
          index=i label={pmtData.payment_method_type} pmtData pmIndex pmtIndex pm
        />
      })
      ->React.array}
    </div>
  </div>
}
