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

  @react.component
  let make = (
    ~updateDetails,
    ~paymentMethodsEnabled: array<paymentMethodEnabled>,
    ~paymentMethod,
    ~provider: array<paymentMethodConfigType>,
    ~_showAdvancedConfiguration,
    ~setMetaData,
    ~connector,
    ~setInitialValues,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let initalFormValue = React.useMemo(() => {
      formState.values->getDictFromJsonObject->getDictfromDict("metadata")
    }, [])
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
    let (selectedWallet, setSelectedWallet) = React.useState(_ => Dict.make()->itemProviderMapper)

    let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom

    let connectorsListPMAuth =
      connectorList->getProcessorsListFromJson(
        ~removeFromList=ConnectorTypes.PMAuthenticationProcessor,
      )
    let isPMAuthConnector = connectorsListPMAuth->Array.length > 0

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
      ((methodVariant === GooglePay || methodVariant === ApplePay) &&
        {
          switch connector->getConnectorNameTypeFromString {
          | Processors(TRUSTPAY)
          | Processors(AIRWALLEX)
          | Processors(STRIPE_TEST) => false
          | _ => true
          }
        }) || (paymentMethod->getPaymentMethodFromString === BankDebit && isPMAuthConnector)
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
          setShowWalletConfigurationModal(_ => !showWalletConfigurationModal)
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
      form.change("metadata", initalFormValue->Identity.genericTypeToJson)
      setSelectedWallet(_ => Dict.make()->itemProviderMapper)
    }

    let modalHeading = `Additional Details to enable ${paymentMethod->getPaymentMethodFromString !==
        BankDebit
        ? selectedWallet.payment_method_type->snakeToTitle
        : paymentMethod->snakeToTitle}`

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
                  <BoolInput.BaseComponent
                    isSelected={selectedAll}
                    setIsSelected={_ => updateSelectAll(paymentMethod, selectedAll)}
                    isDisabled=false
                    boolCustomClass="rounded-lg"
                  />
                  <p className=p2RegularTextStyle> {"Select all"->React.string} </p>
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
      <div className={`grid ${_showAdvancedConfiguration ? "grid-cols-2" : "grid-cols-4"} gap-4`}>
        {provider
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
                  <div onClick={_ => removeOrAddMethods(value)} className="cursor-pointer">
                    <CheckBoxIcon isSelected={isSelected(value)} />
                  </div>
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
        <RenderIf
          condition={selectedWallet.payment_method_type->getPaymentMethodTypeFromString ===
            ApplePay ||
          selectedWallet.payment_method_type->getPaymentMethodTypeFromString === GooglePay ||
          (paymentMethod->getPaymentMethodFromString === BankDebit && isPMAuthConnector)}>
          <Modal
            modalHeading
            headerTextClass={`${textColor.primaryNormal} font-bold text-xl`}
            headBgClass="sticky top-0 z-30 bg-white"
            showModal={showWalletConfigurationModal}
            setShowModal={setShowWalletConfigurationModal}
            onCloseClickCustomFun={removeSelectedWallet}
            paddingClass=""
            revealFrom=Reveal.Right
            modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
            childClass={""}>
            <AdditionalDetailsSidebarComp
              method={selectedWallet}
              setMetaData
              setShowWalletConfigurationModal
              updateDetails
              paymentMethodsEnabled
              paymentMethod
              onCloseClickCustomFun={removeSelectedWallet}
              setInitialValues
            />
          </Modal>
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
    ~setInitialValues,
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
              setInitialValues
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
              setInitialValues
            />
          </div>
        }
      })
      ->React.array}
    </div>
  }
}
