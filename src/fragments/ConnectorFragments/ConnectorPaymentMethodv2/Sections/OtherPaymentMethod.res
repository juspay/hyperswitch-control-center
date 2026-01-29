module SelectedCardValues = {
  @react.component
  let make = (~initialValues, ~index, ~pm) => {
    open LogicUtils
    open SectionHelper
    let data1 = initialValues->getDictFromJsonObject
    let data = ConnectorInterface.mapDictToTypedConnectorPayload(
      ConnectorInterface.connectorInterfaceV2,
      data1,
    )
    let paymentMethodData =
      data.payment_methods_enabled
      ->Array.filter(ele => ele.payment_method_type->String.toLowerCase == pm)
      ->Array.at(0)

    let pmtData = switch paymentMethodData {
    | Some(data) => data.payment_method_subtypes
    | _ => []
    }

    <SelectedPMT pmtData index pm />
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
  ~formValues: ConnectorTypes.connectorPayloadV2,
) => {
  open LogicUtils
  open SectionHelper
  open Typography
  open AdditionalDetailsSidebar
  open ConnectorPaymentMethodV2Utils
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let temp: array<ConnectorTypes.paymentMethodEnabled> = [
    {
      payment_method: "",
      payment_method_type: "",
    },
  ]
  let (meteDataInitialValues, connectorWalletsInitialValues) = React.useMemo(() => {
    (
      formValues.metadata->Identity.genericTypeToJson,
      formValues.connector_webhook_details->Identity.genericTypeToJson,
    )
  }, [])
  //

  let form = ReactFinalForm.useForm()
  let (selectedWallet, setSelectedWallet) = React.useState(_ =>
    Dict.make()->ConnectorInterfaceUtils.getPaymentMethodTypesV2
  )
  let (selectedPMTIndex, setSelectedPMTIndex) = React.useState(_ => 0)

  let data = formState.values->getDictFromJsonObject
  let connData: ConnectorTypes.connectorPayloadV2 = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    data,
  )
  let availablePM =
    paymentMethodValues
    ->getArrayFromDict(pm, [])
    ->getPaymentMethodMapper(connector, pm)

  let showSelectAll = if (
    pm->getPMFromString == Wallet ||
    pm->getPMFromString == BankDebit ||
    connector->ConnectorUtils.getConnectorNameTypeFromString == Processors(KLARNA) &&
      connData->checkKlaranRegion ||
    !isInEditState
  ) {
    false
  } else {
    true
  }

  let resetValues = () => {
    // Need to refactor
    form.change("metadata", meteDataInitialValues->Identity.genericTypeToJson)
    form.change(
      "connector_wallets_details",
      connectorWalletsInitialValues->Identity.genericTypeToJson,
    )
    //
  }
  let updateDetails = _val => {
    form.change(
      `payment_methods_enabled[${pmIndex->Int.toString}].payment_method_subtypes[${selectedPMTIndex->Int.toString}]`,
      selectedWallet->Identity.genericTypeToJson,
    )
    form.change(
      `payment_methods_enabled[${pmIndex->Int.toString}].payment_method_type`,
      "wallet"->Identity.genericTypeToJson,
    )
  }

  let onClick = (pmtData: ConnectorTypes.paymentMethodConfigTypeV2, pmtIndex) => {
    if isMetaDataRequired(pmtData.payment_method_subtype, connector) {
      setSelectedWallet(_ => pmtData)
      setSelectedPMTIndex(_ => pmtIndex)
    }
  }

  let paymentMethodTypeValues = connData.payment_methods_enabled->Array.get(pmIndex)

  let checkIfAdditionalDetailsRequired = (
    valueComing: ConnectorTypes.paymentMethodConfigTypeV2,
  ) => {
    pmtWithMetaData->Array.includes(valueComing.payment_method_subtype->getPMTFromString)
  }

  let methodsWithoutAdditionalDetails =
    availablePM->Array.filter(value => !checkIfAdditionalDetailsRequired(value))
  let methodsWithAdditionalDetails =
    availablePM->Array.filter(value => checkIfAdditionalDetailsRequired(value))

  {
    if isInEditState {
      <div
        key={index->Int.toString}
        className="flex flex-col border border-nd_gray-150 rounded-xl overflow-hidden ">
        <HeadingSection index pm availablePM pmIndex pmt=pm showSelectAll />
        <RenderIf
          condition={pm->getPMFromString === Wallet &&
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
        <div className="flex flex-col gap-6 p-6 w-full">
          <div className="flex gap-6 flex-wrap">
            {methodsWithoutAdditionalDetails
            ->Array.mapWithIndex((pmtData, i) => {
              // determine the index of the payment method type from the form state
              let pmtIndex = switch paymentMethodTypeValues {
              | Some(pmt) => {
                  let isPMTEnabled =
                    pmt.payment_method_subtypes->Array.findIndex(val =>
                      val.payment_method_subtype == pmtData.payment_method_subtype
                    )
                  isPMTEnabled == -1 ? pmt.payment_method_subtypes->Array.length : isPMTEnabled
                }
              | None => 0
              }

              let label = switch (
                pmtData.payment_method_subtype->getPMTFromString,
                pm->getPMFromString,
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
              | _ => pmtData.payment_method_subtype->snakeToTitle
              }

              let showCheckbox = switch (
                pmtData.payment_method_subtype->getPMTFromString,
                pm->getPMFromString,
                connector->ConnectorUtils.getConnectorNameTypeFromString,
              ) {
              | (Klarna, PayLater, Processors(KLARNA)) =>
                !(
                  pmtData.payment_experience->Option.getOr("") == "redirect_to_url" &&
                    connData->checkKlaranRegion
                )

              | _ => true
              }

              <PaymentMethodTypes
                pm
                label
                pmtData
                pmIndex
                pmtIndex
                connector
                showCheckbox
                index=i
                onClick={Some(() => onClick(pmtData, pmtIndex))}
                formValues
              />
            })
            ->React.array}
          </div>
          <RenderIf condition={version == V1 && methodsWithAdditionalDetails->Array.length > 0}>
            <div className="flex flex-col gap-4">
              <p className={`${body.md.medium} text-grey-700 opacity-50`}>
                {"Below payment method types requires additional details"->React.string}
              </p>
              <div className={`flex flex-col gap-4 w-full`}>
                {methodsWithAdditionalDetails
                ->Array.mapWithIndex((pmtData, i) => {
                  <Accordion
                    arrowPosition=Right
                    initialExpandedArray=[]
                    accordion={[
                      {
                        title: pmtData.payment_method_subtype,
                        renderContent: (~currentAccordianState as _, ~closeAccordionFn) =>
                          <AdditionalDetailsSidebarComp
                            method={None}
                            setMetaData={_ => ()}
                            updateDetails={_val => updateDetails(_val)}
                            paymentMethodsEnabled=temp
                            paymentMethod={pm}
                            setInitialValues={_ => ()}
                            pmtName={selectedWallet.payment_method_subtype}
                            closeAccordionFn
                            onCloseClickCustomFun={resetValues}
                          />,
                        onItemExpandClick: () => {
                          onClick(pmtData, i)
                        },
                        onItemCollapseClick: () => {
                          resetValues()
                        },
                        renderContentOnTop: Some(
                          () => {
                            let label = switch (
                              pmtData.payment_method_subtype->getPMTFromString,
                              pm->getPMFromString,
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
                            | _ => pmtData.payment_method_subtype->snakeToTitle
                            }

                            let pmtIndex = switch paymentMethodTypeValues {
                            | Some(pmt) => {
                                let isPMTEnabled =
                                  pmt.payment_method_subtypes->Array.findIndex(val =>
                                    val.payment_method_subtype == pmtData.payment_method_subtype
                                  )
                                isPMTEnabled == -1
                                  ? pmt.payment_method_subtypes->Array.length
                                  : isPMTEnabled
                              }
                            | None => 0
                            }

                            <PaymentMethodTypes
                              pm
                              label
                              pmtData
                              pmIndex
                              pmtIndex
                              connector
                              showCheckbox=true
                              index=i
                              onClick={Some(() => onClick(pmtData, pmtIndex))}
                              formValues
                              customLabelCss="!mt-3"
                            />
                          },
                        ),
                      },
                    ]}
                    accordianTopContainerCss="border border-nd_gray-150 rounded-lg "
                    contentExpandCss="p-0 "
                    accordianBottomContainerCss="!p-2 flex justify-between w-full !font-normal !text-fs-16"
                    gapClass="flex flex-col gap-8"
                  />
                })
                ->React.array}
              </div>
            </div>
          </RenderIf>
        </div>
      </div>
    } else {
      <SelectedCardValues initialValues index=pmIndex pm />
    }
  }
}
