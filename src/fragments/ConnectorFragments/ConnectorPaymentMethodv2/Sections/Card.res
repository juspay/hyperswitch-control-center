@react.component
let make = (~index, ~pm, ~pmIndex, ~paymentMethodValues, ~connector, ~isInEditState) => {
  open LogicUtils
  open SectionHelper
  open ConnectorPaymentMethodV3Utils

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let connData =
    formState.values->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType

  let data =
    paymentMethodValues
    ->getArrayFromDict("card", [])
    ->getPaymentMethodMapper(connector, pm)
  let credit = data->Array.filter(ele => ele.payment_method_type->getPMTFromString == Credit)
  let debit = data->Array.filter(ele => ele.payment_method_type->getPMTFromString == Debit)
  let paymentMethodTypeValues = connData.payment_methods_enabled->Array.get(pmIndex)
  <>
    <div
      className="border border-nd_gray-150 rounded-xl overflow-hidden"
      key={`${index->Int.toString}-credit`}>
      <HeadingSection
        index pm availablePM=credit pmIndex pmt="credit" showSelectAll={isInEditState}
      />
      <div className="flex gap-8 p-6 flex-wrap">
        {credit
        ->Array.mapWithIndex((pmtData, i) => {
          // determine the index of the payment method type from the form state
          let pmtIndex = switch paymentMethodTypeValues {
          | Some(pmt) => {
              let isPMTEnabled = pmt.payment_method_types->Array.findIndex(val => {
                if val.payment_method_type->getPMTFromString == Credit {
                  val.card_networks->Array.some(
                    networks => {
                      pmtData.card_networks->Array.includes(networks)
                    },
                  )
                } else {
                  false
                }
              })
              isPMTEnabled == -1 ? pmt.payment_method_types->Array.length : isPMTEnabled
            }
          | None => 0
          }
          <PaymentMethodTypes
            pm
            pmtData
            pmIndex
            pmtIndex
            connector
            isInEditState
            index=i
            label={pmtData.card_networks->Array.joinWith(",")}
          />
        })
        ->React.array}
      </div>
    </div>
    <div
      className="border border-nd_gray-150 rounded-xl overflow-hidden"
      key={`${index->Int.toString}-debit`}>
      <HeadingSection
        index pm availablePM=debit pmIndex pmt="debit" showSelectAll={isInEditState}
      />
      <div className="flex gap-8 p-6 flex-wrap">
        {debit
        ->Array.mapWithIndex((pmtData, i) => {
          // determine the index of the payment method type from the form state
          let pmtIndex = switch paymentMethodTypeValues {
          | Some(pmt) => {
              let isPMTEnabled = pmt.payment_method_types->Array.findIndex(val => {
                if val.payment_method_type->getPMTFromString == Debit {
                  val.card_networks->Array.some(
                    networks => {
                      pmtData.card_networks->Array.includes(networks)
                    },
                  )
                } else {
                  false
                }
              })
              isPMTEnabled == -1 ? pmt.payment_method_types->Array.length : isPMTEnabled
            }
          | None => 0
          }
          <PaymentMethodTypes
            pm
            pmtData
            pmIndex
            pmtIndex
            connector
            isInEditState
            index=i
            label={pmtData.card_networks->Array.joinWith(",")}
          />
        })
        ->React.array}
      </div>
    </div>
  </>
}
