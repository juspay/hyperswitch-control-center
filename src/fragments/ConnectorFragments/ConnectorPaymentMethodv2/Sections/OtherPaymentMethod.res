module SelectedCardValues = {
  @react.component
  let make = (~initialValues, ~index, ~pm) => {
    open LogicUtils
    open SectionHelper
    let data = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
    let paymentMethodData =
      data.payment_methods_enabled
      ->Array.filter(ele => ele.payment_method->String.toLowerCase == pm)
      ->Array.at(0)

    let pmtData = switch paymentMethodData {
    | Some(data) => data.payment_method_types
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
) => {
  open LogicUtils
  open SectionHelper
  open AdditionalDetailsSidebar
  open ConnectorPaymentMethodV3Utils
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let temp: array<ConnectorTypes.paymentMethodEnabled> = [
    {
      payment_method: "",
      payment_method_type: "",
    },
  ]
  let (meteDataInitialValues, connectorWalletsInitialValues) = React.useMemo(() => {
    let formValues = formState.values->getDictFromJsonObject
    (
      formValues->getDictfromDict("metadata"),
      formValues->getDictfromDict("connector_wallets_details"),
    )
  }, [])
  //

  let form = ReactFinalForm.useForm()
  let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
  let (selectedWallet, setSelectedWallet) = React.useState(_ => Dict.make()->itemProviderMapper)
  let (selectedPMTIndex, setSelectedPMTIndex) = React.useState(_ => 0)

  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let connData =
    formState.values->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
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

  let title = switch pm->getPMFromString {
  | BankDebit => pm->snakeToTitle
  | Wallet => selectedWallet.payment_method_type->snakeToTitle
  | _ => ""
  }
  let resetValues = () => {
    setShowWalletConfigurationModal(_ => false)
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
      `payment_methods_enabled[${pmIndex->Int.toString}].payment_method_types[${selectedPMTIndex->Int.toString}]`,
      selectedWallet->Identity.genericTypeToJson,
    )
    form.change(
      `payment_methods_enabled[${pmIndex->Int.toString}].payment_method`,
      "wallet"->Identity.genericTypeToJson,
    )
  }

  let onClick = (pmtData: ConnectorTypes.paymentMethodConfigType, pmtIndex) => {
    if isMetaDataRequired(pmtData.payment_method_type, connector) {
      setSelectedWallet(_ => pmtData)
      setSelectedPMTIndex(_ => pmtIndex)
      setShowWalletConfigurationModal(_ => true)
    }
  }

  let modalHeading = `Additional Details to enable ${title}`

  {
    if isInEditState {
      <div
        key={index->Int.toString} className="border border-nd_gray-150 rounded-xl overflow-hidden">
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
        <div className="flex gap-6 p-6 flex-wrap">
          {availablePM
          ->Array.mapWithIndex((pmtData, i) => {
            let paymentMethodTypeValues = connData.payment_methods_enabled->Array.get(pmIndex)
            // determine the index of the payment method type from the form state
            let pmtIndex = switch paymentMethodTypeValues {
            | Some(pmt) => {
                let isPMTEnabled =
                  pmt.payment_method_types->Array.findIndex(val =>
                    val.payment_method_type == pmtData.payment_method_type
                  )
                isPMTEnabled == -1 ? pmt.payment_method_types->Array.length : isPMTEnabled
              }
            | None => 0
            }

            let label = switch (
              pmtData.payment_method_type->getPMTFromString,
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
            | _ => pmtData.payment_method_type->snakeToTitle
            }

            let showCheckbox = switch (
              pmtData.payment_method_type->getPMTFromString,
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
            />
          })
          ->React.array}
          <RenderIf
            condition={pmtWithMetaData->Array.includes(
              selectedWallet.payment_method_type->getPMTFromString,
            )}>
            <Modal
              modalHeading
              headerTextClass={`${textColor.primaryNormal} font-bold text-xl`}
              headBgClass="sticky top-0 z-30 bg-white"
              showModal={showWalletConfigurationModal}
              setShowModal={setShowWalletConfigurationModal}
              onCloseClickCustomFun={resetValues}
              paddingClass=""
              revealFrom=Reveal.Right
              modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
              childClass={""}>
              <RenderIf condition={showWalletConfigurationModal}>
                // Need to refactor
                <AdditionalDetailsSidebarComp
                  method={selectedWallet}
                  setMetaData={_ => ()}
                  setShowWalletConfigurationModal
                  updateDetails={_val => updateDetails(_val)}
                  paymentMethodsEnabled=temp
                  paymentMethod={pm}
                  onCloseClickCustomFun={resetValues}
                  setInitialValues={_ => ()}
                />
              </RenderIf>
            </Modal>
          </RenderIf>
        </div>
      </div>
    } else {
      <SelectedCardValues initialValues index=pmIndex pm />
    }
  }
}
