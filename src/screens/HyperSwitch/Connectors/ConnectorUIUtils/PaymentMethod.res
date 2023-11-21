let isSelectedAll = (
  selectedPaymentMethod: array<ConnectorTypes.paymentMethodEnabled>,
  allPaymentMethods,
  paymentMethod,
) => {
  open ConnectorUtils
  let paymentMethodObj = selectedPaymentMethod->getSelectedPaymentObj(paymentMethod)
  switch paymentMethod->getPaymentMethodFromString {
  | Card =>
    paymentMethodObj.card_provider->Belt.Option.getWithDefault([])->len == allPaymentMethods->len
  | _ => paymentMethodObj.provider->Belt.Option.getWithDefault([])->len == allPaymentMethods->len
  }
}

module CardRenderer = {
  open LogicUtils
  open ConnectorTypes
  open ConnectorUtils
  open Wallet
  @react.component
  let make = (
    ~updateDetails,
    ~paymentMethodsEnabled: array<paymentMethodEnabled>,
    ~paymentMethod,
    ~provider,
    ~_showAdvancedConfiguration,
    ~metaData,
    ~setMetaData,
    ~connector,
  ) => {
    let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
    let (selectedWallet, setSelectedWallet) = React.useState(_ => "")
    let selectedAll = isSelectedAll(paymentMethodsEnabled, provider, paymentMethod)

    let paymentObj = paymentMethodsEnabled->getSelectedPaymentObj(paymentMethod)
    let standardProviders = paymentObj.provider->Belt.Option.getWithDefault([])
    let cardProviders = paymentObj.card_provider->Belt.Option.getWithDefault([])

    let removeOrAddMethods = method => {
      switch paymentMethod->getPaymentMethodFromString {
      | Card =>
        if cardProviders->Js.Array2.includes(method) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method)->updateDetails
        } else {
          paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
        }

      | _ =>
        if standardProviders->Js.Array2.includes(method) {
          paymentMethodsEnabled->removeMethod(paymentMethod, method)->updateDetails
        } else {
          let methodVariant = method->getPaymentMethodTypeFromString
          if (
            (methodVariant === GooglePay || methodVariant === ApplePay) &&
              (connector->getConnectorNameTypeFromString !== TRUSTPAY &&
              connector->getConnectorNameTypeFromString !== AIRWALLEX &&
              connector->getConnectorNameTypeFromString !== STRIPE_TEST)
          ) {
            setShowWalletConfigurationModal(_ => !showWalletConfigurationModal)
            setSelectedWallet(_ => method)
          } else {
            paymentMethodsEnabled->addMethod(paymentMethod, method)->updateDetails
          }
        }
      }
    }

    let updateSelectAll = (paymentMethod, isSelectedAll) => {
      let arr = isSelectedAll ? [] : provider->LogicUtils.getUniqueArray
      paymentMethodsEnabled->Js.Array2.forEach(val => {
        if val.payment_method_type === paymentMethod {
          switch paymentMethod->getPaymentMethodTypeFromString {
          | Credit | Debit =>
            let length = val.card_provider->Belt.Option.getWithDefault([])->len
            val.card_provider
            ->Belt.Option.getWithDefault([])
            ->Array.splice(~start=0, ~remove=length, ~insert=arr)
            ->ignore
          | _ =>
            let length = val.provider->Belt.Option.getWithDefault([])->len

            val.provider
            ->Belt.Option.getWithDefault([])
            ->Array.splice(~start=0, ~remove=length, ~insert=arr)
            ->ignore
          }
        }
      })
      updateDetails(paymentMethodsEnabled)
    }

    let isSelected = value => {
      standardProviders->Js.Array2.includes(value) || cardProviders->Js.Array2.includes(value)
        ? true
        : false
    }

    let isNotVerifiablePaymentMethod = paymentMethodVariant => {
      switch paymentMethodVariant {
      | UnknownPaymentMethod(str) => str !== "is_verifiable"
      | _ => true
      }
    }
    let p2RegularTextStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P2,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700 opacity-50`

    <div className="flex flex-col gap-4 border rounded-md p-6">
      <div>
        <UIUtils.RenderIf
          condition={paymentMethod->getPaymentMethodFromString->isNotVerifiablePaymentMethod}>
          <div className="flex items-center border-b gap-2 py-2 break-all justify-between">
            <p className="font-semibold text-bold text-lg">
              {React.string(paymentMethod->snakeToTitle)}
            </p>
            <div className="flex gap-2 items-center">
              <BoolInput.BaseComponent
                isSelected={selectedAll}
                setIsSelected={_ => updateSelectAll(paymentMethod, selectedAll)}
                isDisabled=false
                boolCustomClass="rounded-lg"
              />
              <p className=p2RegularTextStyle> {"Select all"->React.string} </p>
            </div>
          </div>
        </UIUtils.RenderIf>
      </div>
      <UIUtils.RenderIf
        condition={paymentMethod->getPaymentMethodFromString === Wallet &&
          connector->getConnectorNameTypeFromString === ZEN}>
        <div className="border rounded p-2 bg-jp-gray-100 flex gap-4">
          <Icon name="outage_icon" size=15 />
          {"Zen doesn't support Googlepay and Applepay in sandbox."->React.string}
        </div>
      </UIUtils.RenderIf>
      <div className={`grid ${_showAdvancedConfiguration ? "grid-cols-2" : "grid-cols-4"} gap-4`}>
        {provider
        ->Array.mapWithIndex((value, i) => {
          <div key={i->string_of_int}>
            <div className="flex items-center gap-2 break-words">
              <div onClick={_e => removeOrAddMethods(value)}>
                <CheckBoxIcon isSelected={isSelected(value)} />
              </div>
              <p className=p2RegularTextStyle> {React.string(value->snakeToTitle)} </p>
            </div>
          </div>
        })
        ->React.array}
        <UIUtils.RenderIf
          condition={selectedWallet->getPaymentMethodTypeFromString === ApplePay ||
            selectedWallet->getPaymentMethodTypeFromString === GooglePay}>
          <Modal
            modalHeading={`Additional Details to enable ${selectedWallet->LogicUtils.snakeToTitle}`}
            headerTextClass="text-blue-800 font-bold text-xl"
            showModal={showWalletConfigurationModal}
            setShowModal={setShowWalletConfigurationModal}
            paddingClass=""
            revealFrom=Reveal.Right
            modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
            childClass={""}>
            <Wallets
              method={selectedWallet}
              metaData
              setMetaData
              setShowWalletConfigurationModal
              updateDetails
              paymentMethodsEnabled
              paymentMethod
            />
          </Modal>
        </UIUtils.RenderIf>
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
    ~metaData,
    ~setMetaData,
    ~isPayoutFlow,
  ) => {
    let pmts = React.useMemo1(() => {
      (
        isPayoutFlow
          ? Window.getPayoutConnectorConfig(connector)
          : Window.getConnectorConfig(connector)
      )->getDictFromJsonObject
    }, [connector])
    let keys =
      pmts->Js.Dict.keys->Js.Array2.filter(val => !Js.Array2.includes(configKeysToIgnore, val))

    <div className="flex flex-col gap-12">
      {keys
      ->Array.mapWithIndex((value, i) => {
        let provider = pmts->getStrArray(value)
        switch value->getPaymentMethodTypeFromString {
        | Credit | Debit =>
          <div key={i->string_of_int}>
            <CardRenderer
              updateDetails
              paymentMethodsEnabled
              provider
              paymentMethod={value}
              _showAdvancedConfiguration=false
              metaData
              setMetaData
              connector
            />
          </div>
        | _ =>
          <div key={i->string_of_int}>
            <CardRenderer
              updateDetails
              paymentMethodsEnabled
              paymentMethod={value}
              provider={pmts->getStrArray(value)}
              _showAdvancedConfiguration=false
              metaData
              setMetaData
              connector
            />
          </div>
        }
      })
      ->React.array}
    </div>
  }
}
