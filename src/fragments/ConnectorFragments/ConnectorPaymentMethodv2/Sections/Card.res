module SelectedCardValues = {
  @react.component
  let make = (~initialValues, ~index) => {
    open LogicUtils
    open SectionHelper
    open ConnectorPaymentMethodV2Utils
    let data1 = initialValues->getDictFromJsonObject
    let data = ConnectorInterface.mapDictToTypedConnectorPayload(
      ConnectorInterface.connectorInterfaceV2,
      data1,
    )
    let cardData =
      data.payment_methods_enabled
      ->Array.filter(ele => ele.payment_method_type->getPMFromString == Card)
      ->Array.at(0)
    let credit = switch cardData {
    | Some(data) =>
      data.payment_method_subtypes->Array.filter(ele =>
        ele.payment_method_subtype->getPMTFromString == Credit
      )
    | _ => []
    }
    let debit = switch cardData {
    | Some(data) =>
      data.payment_method_subtypes->Array.filter(ele =>
        ele.payment_method_subtype->getPMTFromString == Debit
      )
    | _ => []
    }
    <>
      <SelectedPMT pmtData={credit} index pm="credit" />
      <SelectedPMT pmtData={debit} index pm="debit" />
    </>
  }
}

@react.component
let make = (
  ~index,
  ~pm,
  ~pmIndex,
  ~paymentMethodValues,
  ~connector,
  ~isInEditState,
  ~initialValues,
  ~formValues: ConnectorTypes.connectorPayloadCommonType,
) => {
  open LogicUtils
  open SectionHelper
  open ConnectorPaymentMethodV2Utils

  let data =
    paymentMethodValues
    ->getArrayFromDict("card", [])
    ->getPaymentMethodMapper(connector, pm)
  let credit = data->Array.filter(ele => ele.payment_method_subtype->getPMTFromString == Credit)
  let debit = data->Array.filter(ele => ele.payment_method_subtype->getPMTFromString == Debit)
  let paymentMethodTypeValues = formValues.payment_methods_enabled->Array.get(pmIndex)

  {
    if isInEditState {
      <>
        <div
          className="border border-nd_gray-150 rounded-xl overflow-hidden"
          key={`${index->Int.toString}-credit`}>
          <HeadingSection index pm availablePM=credit pmIndex pmt="credit" showSelectAll={true} />
          <div className="flex gap-6 p-6 flex-wrap">
            {credit
            ->Array.mapWithIndex((pmtData, i) => {
              // determine the index of the payment method type from the form state
              let pmtIndex = switch paymentMethodTypeValues {
              | Some(pmt) => {
                  let isPMTEnabled = pmt.payment_method_subtypes->Array.findIndex(val => {
                    if val.payment_method_subtype->getPMTFromString == Credit {
                      val.card_networks->Array.some(
                        networks => {
                          pmtData.card_networks->Array.includes(networks)
                        },
                      )
                    } else {
                      false
                    }
                  })
                  isPMTEnabled == -1 ? pmt.payment_method_subtypes->Array.length : isPMTEnabled
                }
              | None => 0
              }
              <PaymentMethodTypes
                pm
                pmtData
                pmIndex
                pmtIndex
                connector
                index=i
                label={pmtData.card_networks->Array.joinWith(",")}
                formValues
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
          <div className="flex gap-6 p-6 flex-wrap">
            {debit
            ->Array.mapWithIndex((pmtData, i) => {
              // determine the index of the payment method type from the form state
              let pmtIndex = switch paymentMethodTypeValues {
              | Some(pmt) => {
                  let isPMTEnabled = pmt.payment_method_subtypes->Array.findIndex(val => {
                    if val.payment_method_subtype->getPMTFromString == Debit {
                      val.card_networks->Array.some(
                        networks => {
                          pmtData.card_networks->Array.includes(networks)
                        },
                      )
                    } else {
                      false
                    }
                  })
                  isPMTEnabled == -1 ? pmt.payment_method_subtypes->Array.length : isPMTEnabled
                }
              | None => 0
              }
              <PaymentMethodTypes
                key={i->Int.toString}
                pm
                pmtData
                pmIndex
                pmtIndex
                connector
                index=i
                label={pmtData.card_networks->Array.joinWith(",")}
                formValues
              />
            })
            ->React.array}
          </div>
        </div>
      </>
    } else {
      <SelectedCardValues initialValues index />
    }
  }
}
