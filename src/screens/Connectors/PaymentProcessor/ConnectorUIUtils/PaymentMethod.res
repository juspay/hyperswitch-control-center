let isSelectedAll = (
  selectedPaymentMethod: array<ConnectorTypes.paymentMethodEnabled>,
  allPaymentMethods,
  paymentMethod,
) => {
  open ConnectorUtils
  let paymentMethodObj = selectedPaymentMethod->getSelectedPaymentObj(paymentMethod)
  switch paymentMethod->getPaymentMethodFromString {
  | Card =>
    paymentMethodObj.card_provider->Option.getOr([])->Array.length ==
      allPaymentMethods->Array.length
  | _ =>
    paymentMethodObj.provider->Option.getOr([])->Array.length == allPaymentMethods->Array.length
  }
}

module CardRenderer = {
  open LogicUtils
  open ConnectorTypes
  open ConnectorUtils
  open AdditionalDetailsSidebar
  open Typography

  @react.component
  let make = (
    ~updateDetails,
    ~paymentMethodsEnabled: array<paymentMethodEnabled>,
    ~paymentMethod,
    ~provider: array<paymentMethodConfigType>,
    ~_showAdvancedConfiguration,
    ~setMetaData,
    ~connector,
    ~initialValues,
    ~setInitialValues,
    ~connectorType=Processor,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let (meteDataInitialValues, connectorWalletsInitialValues) = React.useMemo(() => {
      let formValues = formState.values->getDictFromJsonObject
      (
        formValues->getDictfromDict("metadata"),
        formValues->getDictfromDict("connector_wallets_details"),
      )
    }, [])
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    // let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    // let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
    let (selectedWallet, setSelectedWallet) = React.useState(_ => Dict.make()->itemProviderMapper)

    let pmAuthProcessorList = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=PMAuthProcessor,
    )

    let isPMAuthConnector = pmAuthProcessorList->Array.length > 0

    let currentProfile = initialValues->getDictFromJsonObject->getString("profile_id", "")

    let isProfileIdConfiguredPMAuth =
      pmAuthProcessorList
      ->Array.filter(item => item.profile_id === currentProfile && !item.disabled)
      ->Array.length > 0

    let shouldShowPMAuthSidebar =
      featureFlagDetails.pmAuthenticationProcessor &&
      isPMAuthConnector &&
      isProfileIdConfiguredPMAuth

    let selectedAll = isSelectedAll(paymentMethodsEnabled, provider, paymentMethod)

    let paymentObj = paymentMethodsEnabled->getSelectedPaymentObj(paymentMethod)
    let standardProviders =
      paymentObj.provider->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)
    let cardProviders =
      paymentObj.card_provider->Option.getOr([]->JSON.Encode.array->getPaymentMethodMapper)

    let checkPaymentMethodType = (
      obj: paymentMethodConfigType,
      selectedMethod: paymentMethodConfigType,
    ) => obj.payment_method_type == selectedMethod.payment_method_type

    let checkPaymentMethodTypeAndExperience = (
      obj: paymentMethodConfigType,
      selectedMethod: paymentMethodConfigType,
    ) => {
      obj.payment_method_type == selectedMethod.payment_method_type &&
        obj.payment_experience == selectedMethod.payment_experience
    }

    let showSideModal = methodVariant => {
      ((methodVariant === GooglePay ||
      methodVariant === ApplePay ||
      methodVariant === SamsungPay ||
      methodVariant === Paze) &&
        {
          switch connector->getConnectorNameTypeFromString(~connectorType) {
          | Processors(TRUSTPAY)
          | Processors(STRIPE_TEST)
          | PayoutProcessor(WORLDPAY)
          | PayoutProcessor(WORLDPAYXML) => false
          | _ => true
          }
        }) || (paymentMethod->getPaymentMethodFromString === BankDebit && shouldShowPMAuthSidebar)
    }

    let removeOrAddMethods = (method: paymentMethodConfigType) => {
      switch (
        method.payment_method_type->getPaymentMethodTypeFromString,
        paymentMethod->getPaymentMethodFromString,
        connector->getConnectorNameTypeFromString,
      ) {
      | (PayPal, Wallet, Processors(PAYPAL)) =>
        if standardProviders->Array.some(obj => checkPaymentMethodTypeAndExperience(obj, method)) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method, connector)->updateDetails
        } else {
          paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
        }
      | (Klarna, PayLater, Processors(KLARNA)) =>
        if standardProviders->Array.some(obj => checkPaymentMethodTypeAndExperience(obj, method)) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method, connector)->updateDetails
        } else {
          paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
        }
      | (_, Card, _) =>
        if cardProviders->Array.some(obj => checkPaymentMethodType(obj, method)) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method, connector)->updateDetails
        } else {
          paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
        }
      | _ =>
        if standardProviders->Array.some(obj => checkPaymentMethodType(obj, method)) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method, connector)->updateDetails
        } else if showSideModal(method.payment_method_type->getPaymentMethodTypeFromString) {
          setSelectedWallet(_ => method)
        } else {
          paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
        }
      }
    }

    let updateSelectAll = (paymentMethod, isSelectedAll) => {
      let arr = isSelectedAll ? [] : provider
      paymentMethodsEnabled->Array.forEach(val => {
        if val.payment_method_type === paymentMethod {
          switch paymentMethod->getPaymentMethodTypeFromString {
          | Credit | Debit =>
            let length = val.card_provider->Option.getOr([])->Array.length
            val.card_provider
            ->Option.getOr([])
            ->Array.splice(~start=0, ~remove=length, ~insert=arr)
            ->ignore
          | _ =>
            let length = val.provider->Option.getOr([])->Array.length

            val.provider
            ->Option.getOr([])
            ->Array.splice(~start=0, ~remove=length, ~insert=arr)
            ->ignore
          }
        }
      })
      updateDetails(paymentMethodsEnabled)
    }

    let isSelected = selectedMethod => {
      switch (
        paymentMethod->getPaymentMethodFromString,
        connector->getConnectorNameTypeFromString,
      ) {
      | (Wallet, Processors(PAYPAL)) =>
        standardProviders->Array.some(obj =>
          checkPaymentMethodTypeAndExperience(obj, selectedMethod)
        )
      | (PayLater, Processors(KLARNA)) =>
        standardProviders->Array.some(obj =>
          checkPaymentMethodTypeAndExperience(obj, selectedMethod)
        )
      | _ =>
        standardProviders->Array.some(obj => checkPaymentMethodType(obj, selectedMethod)) ||
          cardProviders->Array.some(obj => checkPaymentMethodType(obj, selectedMethod))
      }
    }

    let isNotVerifiablePaymentMethod = paymentMethodVariant => {
      switch paymentMethodVariant {
      | UnknownPaymentMethod(str) => str !== "is_verifiable"
      | _ => true
      }
    }
    let p2RegularTextStyle = `${HSwitchUtils.getTextClass((P2, Medium))} text-grey-700 opacity-50`

    let removeSelectedWallet = () => {
      form.change("metadata", meteDataInitialValues->Identity.genericTypeToJson)
      form.change(
        "connector_wallets_details",
        connectorWalletsInitialValues->Identity.genericTypeToJson,
      )

      setSelectedWallet(_ => Dict.make()->itemProviderMapper)
    }

    let checkIfAdditionalDetailsRequired = (
      valueComing: ConnectorTypes.paymentMethodConfigType,
    ) => {
      showSideModal(valueComing.payment_method_type->getPaymentMethodTypeFromString)
    }

    let methodsWithoutAdditionalDetails =
      provider->Array.filter(val => !checkIfAdditionalDetailsRequired(val))
    let methodsWithAdditionalDetails =
      provider->Array.filter(val => checkIfAdditionalDetailsRequired(val))

    <div className="flex flex-col gap-4 border rounded-md p-6">
      <div>
        <RenderIf
          condition={paymentMethod->getPaymentMethodFromString->isNotVerifiablePaymentMethod}>
          <div className="flex items-center border-b gap-2 py-2 break-all justify-between">
            <p className="font-semibold text-bold text-lg">
              {React.string(paymentMethod->snakeToTitle)}
            </p>
            <RenderIf
              condition={paymentMethod->getPaymentMethodFromString !== Wallet &&
                paymentMethod->getPaymentMethodFromString !== BankDebit}>
              <AddDataAttributes
                attributes=[
                  ("data-testid", paymentMethod->String.concat("_")->String.concat("select_all")),
                ]>
                <div className="flex gap-2 items-center">
                  {switch connector->getConnectorNameTypeFromString {
                  | Processors(KLARNA) =>
                    <RenderIf
                      condition={initialValues
                      ->getDictFromJsonObject
                      ->getDictfromDict("metadata")
                      ->getString("klarna_region", "") === "Europe"}>
                      <div className="flex gap-2 items-center">
                        <BoolInput.BaseComponent
                          isSelected={selectedAll}
                          setIsSelected={_ => updateSelectAll(paymentMethod, selectedAll)}
                          isDisabled={false}
                          boolCustomClass="rounded-lg"
                        />
                        <p className={p2RegularTextStyle}> {"Select all"->React.string} </p>
                      </div>
                    </RenderIf>
                  | _ =>
                    <div className="flex gap-2 items-center">
                      <BoolInput.BaseComponent
                        isSelected={selectedAll}
                        setIsSelected={_ => updateSelectAll(paymentMethod, selectedAll)}
                        isDisabled={false}
                        boolCustomClass="rounded-lg"
                      />
                      <p className={p2RegularTextStyle}> {"Select all"->React.string} </p>
                    </div>
                  }}
                </div>
              </AddDataAttributes>
            </RenderIf>
          </div>
        </RenderIf>
      </div>
      <RenderIf
        condition={paymentMethod->getPaymentMethodFromString === Wallet &&
          {
            switch connector->getConnectorNameTypeFromString {
            | Processors(ZEN) => true
            | _ => false
            }
          }}>
        <div className="border rounded p-2 bg-jp-gray-100 flex gap-4">
          <Icon name="outage_icon" size=15 />
          {"Zen doesn't support Googlepay and Applepay in sandbox."->React.string}
        </div>
      </RenderIf>
      <div className="flex flex-col gap-8">
        <RenderIf condition={methodsWithoutAdditionalDetails->Array.length > 0}>
          <div
            className={`grid ${_showAdvancedConfiguration ? "grid-cols-2" : "grid-cols-4"} gap-4`}>
            {methodsWithoutAdditionalDetails
            ->Array.mapWithIndex((value, i) => {
              <div key={i->Int.toString}>
                <div className="flex">
                  <AddDataAttributes
                    attributes=[
                      (
                        "data-testid",
                        `${paymentMethod
                          ->String.concat("_")
                          ->String.concat(value.payment_method_type)
                          ->String.toLowerCase}`,
                      ),
                    ]>
                    <div className="flex items-center gap-2">
                      {switch connector->getConnectorNameTypeFromString {
                      | Processors(KLARNA) =>
                        <RenderIf
                          condition={!(
                            value.payment_experience->Option.getOr("") === "redirect_to_url" &&
                              initialValues
                              ->getDictFromJsonObject
                              ->getDictfromDict("metadata")
                              ->getString("klarna_region", "") !== "Europe"
                          )}>
                          <div onClick={_ => removeOrAddMethods(value)} className="cursor-pointer">
                            <CheckBoxIcon isSelected={isSelected(value)} />
                          </div>
                        </RenderIf>

                      | _ =>
                        <div onClick={_ => removeOrAddMethods(value)} className="cursor-pointer">
                          <CheckBoxIcon isSelected={isSelected(value)} />
                        </div>
                      }}
                      {switch (
                        value.payment_method_type->getPaymentMethodTypeFromString,
                        paymentMethod->getPaymentMethodFromString,
                        connector->getConnectorNameTypeFromString,
                      ) {
                      | (PayPal, Wallet, Processors(PAYPAL)) =>
                        <p
                          className={`${p2RegularTextStyle} cursor-pointer`}
                          onClick={_ => removeOrAddMethods(value)}>
                          {value.payment_experience->Option.getOr("") === "redirect_to_url"
                            ? "PayPal Redirect"->React.string
                            : "PayPal SDK"->React.string}
                        </p>
                      | (Klarna, PayLater, Processors(KLARNA)) =>
                        <RenderIf
                          condition={!(
                            value.payment_experience->Option.getOr("") === "redirect_to_url" &&
                              initialValues
                              ->getDictFromJsonObject
                              ->getDictfromDict("metadata")
                              ->getString("klarna_region", "") !== "Europe"
                          )}>
                          <p
                            className={`${p2RegularTextStyle} cursor-pointer`}
                            onClick={_ => removeOrAddMethods(value)}>
                            {value.payment_experience->Option.getOr("") === "redirect_to_url"
                              ? "Klarna Checkout"->React.string
                              : "Klarna SDK"->React.string}
                          </p>
                        </RenderIf>

                      | (OpenBankingPIS, _, _) =>
                        <p
                          className={`${p2RegularTextStyle} cursor-pointer`}
                          onClick={_ => removeOrAddMethods(value)}>
                          {"Open Banking PIS"->React.string}
                        </p>
                      | _ =>
                        <p
                          className={`${p2RegularTextStyle} cursor-pointer`}
                          onClick={_ => removeOrAddMethods(value)}>
                          {React.string(value.payment_method_type->snakeToTitle)}
                        </p>
                      }}
                    </div>
                  </AddDataAttributes>
                </div>
              </div>
            })
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf condition={methodsWithAdditionalDetails->Array.length > 0}>
          <div className="flex flex-col gap-4">
            <p className={`${body.md.medium} text-grey-700 opacity-50`}>
              {"Below payment method types requires additional details"->React.string}
            </p>
            <div className={`flex flex-col gap-4 `}>
              {methodsWithAdditionalDetails
              ->Array.map(value => {
                <Accordion
                  key={`${value.payment_method_type}-{i->Int.toString}`}
                  arrowPosition=Right
                  initialExpandedArray=[]
                  accordion={[
                    {
                      title: value.payment_method_type,
                      renderContent: (~currentAccordianState as _, ~closeAccordionFn) =>
                        <AdditionalDetailsSidebarComp
                          method={Some(selectedWallet)}
                          setMetaData
                          updateDetails
                          paymentMethodsEnabled
                          paymentMethod
                          setInitialValues
                          pmtName={selectedWallet.payment_method_type}
                          closeAccordionFn
                        />,
                      onItemCollapseClick: () => {
                        removeSelectedWallet()
                      },
                      onItemExpandClick: () => {
                        removeOrAddMethods(value)
                      },
                      renderContentOnTop: Some(
                        () => {
                          <div className="flex gap-2 items-center cursor-pointer">
                            <div className="cursor-pointer">
                              <CheckBoxIcon isSelected={isSelected(value)} />
                            </div>
                            <p className={`${p2RegularTextStyle} cursor-pointer`}>
                              {React.string(value.payment_method_type->snakeToTitle)}
                            </p>
                          </div>
                        },
                      ),
                    },
                  ]}
                  accordianTopContainerCss="border border-nd_gray-150 rounded-lg "
                  contentExpandCss="p-0 "
                  accordianBottomContainerCss="!p-2 flex justify-between w-full"
                  gapClass="flex flex-col gap-8"
                />
              })
              ->React.array}
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

module PaymentMethodsRender = {
  open LogicUtils
  open ConnectorUtils
  open ConnectorTypes
  @react.component
  let make = (
    ~_showAdvancedConfiguration: bool,
    ~connector,
    ~paymentMethodsEnabled: array<paymentMethodEnabled>,
    ~updateDetails,
    ~setMetaData,
    ~isPayoutFlow,
    ~initialValues,
    ~setInitialValues,
    ~connectorType=Processor,
  ) => {
    let pmts = React.useMemo(() => {
      (
        isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
      )->getDictFromJsonObject
    }, [connector])
    let keys = pmts->Dict.keysToArray->Array.filter(val => !Array.includes(configKeysToIgnore, val))

    <div className="flex flex-col gap-12">
      {keys
      ->Array.mapWithIndex((value, i) => {
        let provider = pmts->getArrayFromDict(value, [])->JSON.Encode.array->getPaymentMethodMapper
        switch value->getPaymentMethodTypeFromString {
        | Credit | Debit =>
          <div key={i->Int.toString}>
            <CardRenderer
              updateDetails
              paymentMethodsEnabled
              provider
              paymentMethod={value}
              _showAdvancedConfiguration=false
              setMetaData
              connector
              initialValues
              setInitialValues
              connectorType
            />
          </div>
        | _ =>
          <div key={i->Int.toString}>
            <CardRenderer
              updateDetails
              paymentMethodsEnabled
              paymentMethod={value}
              provider
              _showAdvancedConfiguration=false
              setMetaData
              connector
              initialValues
              setInitialValues
              connectorType
            />
          </div>
        }
      })
      ->React.array}
    </div>
  }
}
