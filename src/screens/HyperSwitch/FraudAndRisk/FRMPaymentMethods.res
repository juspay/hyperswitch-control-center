module RadioSection = {
  open ConnectorTypes
  open FRMTypes
  open FRMInfo
  @react.component
  let make = (~option, ~frmConfigs, ~paymentMethodTypeInfo, ~sectionType, ~setConfigJson) => {
    let isOptionSelected =
      switch sectionType {
      | FlowType => paymentMethodTypeInfo.flow
      | ActionType => paymentMethodTypeInfo.action
      } === option

    let handleOnClick = () => {
      switch sectionType {
      | FlowType =>
        if paymentMethodTypeInfo.flow !== option {
          switch option->getFlowTypeVariantFromString {
          | PreAuth => paymentMethodTypeInfo.action = CancelTxn->getActionTypeNameString
          | PostAuth => paymentMethodTypeInfo.action = AutoRefund->getActionTypeNameString
          }
          paymentMethodTypeInfo.flow = option
        }
      | ActionType => paymentMethodTypeInfo.action = option
      }

      setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
    }

    <div>
      <div className="flex items-center gap-2 break-all">
        <div onClick={_ => handleOnClick()}>
          <RadioIcon isSelected={isOptionSelected} />
        </div>
        {switch sectionType {
        | FlowType => option->getFlowTypeLabel->React.string
        | ActionType => option->getActionTypeLabel->LogicUtils.snakeToTitle->React.string
        }}
      </div>
    </div>
  }
}

module ToggleSwitch = {
  open FRMUtils
  @react.component
  let make = (~isOpen, ~handleOnChange, ~isToggleDisabled) => {
    let cursorType = isToggleDisabled ? "cursor-not-allowed" : "cursor-pointer"

    let enabledClasses = if isOpen {
      `bg-green-700 ${cursorType} ${toggleDefaultStyle}`
    } else {
      `bg-gray-300 ${cursorType} ${toggleDefaultStyle}`
    }

    let enabledSpanClasses = if isOpen {
      `translate-x-7 ${accordionDefaultStyle}`
    } else {
      `translate-x-1 ${accordionDefaultStyle}`
    }

    <HeadlessUI.Switch checked={isOpen} onChange={_ => handleOnChange()} className={enabledClasses}>
      {checked => {
        <>
          <div ariaHidden=true className={enabledSpanClasses} />
        </>
      }}
    </HeadlessUI.Switch>
  }
}

module FormField = {
  @react.component
  let make = (
    ~options,
    ~label,
    ~paymentMethodTypeInfo,
    ~frmConfigs,
    ~sectionType,
    ~setConfigJson,
    ~description,
  ) => {
    <div className="w-max">
      <div className="flex">
        <h3 className="font-semibold text-bold text-lg pb-2">
          {label->LogicUtils.snakeToTitle->React.string}
        </h3>
        <div className="w-10 h-7 text-gray-300">
          <ToolTip
            description
            tooltipWidthClass="w-96"
            toolTipFor={<Icon name="info-circle" size=15 />}
            toolTipPosition=ToolTip.Top
          />
        </div>
      </div>
      <div className={`grid grid-cols-2 md:grid-cols-4 gap-4`}>
        {options
        ->Array.mapWithIndex((option, i) => {
          <RadioSection
            key={i->string_of_int} option paymentMethodTypeInfo frmConfigs sectionType setConfigJson
          />
        })
        ->React.array}
      </div>
    </div>
  }
}

module CheckBoxRenderer = {
  open FRMUtils
  open FRMInfo
  @react.component
  let make = (
    ~frmConfigInfo: ConnectorTypes.frm_config,
    ~frmConfigs,
    ~connectorPaymentMethods,
    ~isUpdateFlow,
  ) => {
    let showPopUp = PopUpState.useShowPopUp()
    let frmConfigInput = ReactFinalForm.useField("frm_configs").input
    let setConfigJson = {frmConfigInput.onChange}

    let isToggleDisabled = switch connectorPaymentMethods {
    | Some(paymentMethods) => paymentMethods->Dict.keysToArray->Array.length <= 0
    | _ => true
    }

    let initToggleValue = isUpdateFlow
      ? frmConfigInfo.payment_methods->Array.length > 0
      : !isToggleDisabled

    let (isOpen, setIsOpen) = React.useState(_ => initToggleValue)

    let showConfitmation = () => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Heads up!",
        description: {
          "Disabling the current toggle will result in the permanent deletion of all configurations associated with it"->React.string
        },
        handleConfirm: {
          text: "Yes, disable it",
          onClick: {
            _ => {
              frmConfigInfo.payment_methods = []
              setIsOpen(_ => !isOpen)
              setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
            }
          },
        },
        handleCancel: {
          text: "No",
          onClick: {
            _ => ()
          },
        },
      })
    }

    let handleOnChange = () => {
      if !isToggleDisabled {
        if !isOpen {
          switch connectorPaymentMethods {
          | Some(paymentMethods) => {
              frmConfigInfo.payment_methods = paymentMethods->generateFRMPaymentMethodsConfig
              setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
            }
          | _ => ()
          }
          setIsOpen(_ => !isOpen)
        } else if frmConfigInfo.payment_methods->Array.length > 0 {
          if isUpdateFlow {
            showConfitmation()
          } else {
            frmConfigInfo.payment_methods = []
            setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
            setIsOpen(_ => !isOpen)
          }
        }
      }
    }

    React.useEffect0(() => {
      if isOpen && !isUpdateFlow {
        switch connectorPaymentMethods {
        | Some(paymentMethods) => {
            frmConfigInfo.payment_methods = paymentMethods->generateFRMPaymentMethodsConfig
            setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
          }
        | _ => ()
        }
      }
      None
    })

    <div>
      <div
        className="w-full px-5 py-3 bg-light-gray-bg flex items-center gap-3 justify-between border">
        <div className="font-semibold text-bold text-lg">
          {frmConfigInfo.gateway->LogicUtils.snakeToTitle->React.string}
        </div>
        <div className="mt-2">
          {if isToggleDisabled {
            <ToolTip
              description="No payment methods available"
              toolTipFor={<ToggleSwitch isOpen handleOnChange isToggleDisabled />}
              toolTipPosition=ToolTip.Top
            />
          } else {
            <ToggleSwitch isOpen handleOnChange isToggleDisabled />
          }}
        </div>
      </div>
      {frmConfigInfo.payment_methods
      ->Array.mapWithIndex((paymentMethodInfo, index) => {
        <UIUtils.RenderIf condition={isOpen} key={index->string_of_int}>
          {paymentMethodInfo.payment_method_types
          ->Array.mapWithIndex((paymentMethodTypeInfo, i) => {
            <Accordion
              key={i->string_of_int}
              initialExpandedArray=[0]
              accordion={[
                {
                  title: paymentMethodTypeInfo.payment_method_type->LogicUtils.snakeToTitle,
                  renderContent: () => {
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
                      <FormField
                        options={flowTypeAllOptions}
                        label="Choose one of the flows"
                        paymentMethodTypeInfo
                        frmConfigs
                        sectionType={FlowType}
                        setConfigJson
                        description="i. \"PreAuth\" flow is used to verify the transactions before authorizing payment.
                        ii. \"PostAuth\" flow is triggered post the transaction is processed by the gateway."
                      />
                      <FormField
                        options={paymentMethodTypeInfo.flow->getActionTypeAllOptions}
                        label="Choose one of the actions"
                        paymentMethodTypeInfo
                        frmConfigs
                        sectionType={ActionType}
                        setConfigJson
                        description="i. \"Actions [Pre]\" If FRM deems a transaction as risky, consider cancelling the transaction or process the transaction but flag it for manual review.
                        ii. \"Actions [Post]\" If FRM deems a transaction as risky, consider auto-refunding or flag the processed transaction for manual review."
                      />
                    </div>
                  },
                  renderContentOnTop: None,
                },
              ]}
              accordianTopContainerCss="border"
              accordianBottomContainerCss="p-5"
              contentExpandCss="px-10 pb-6 pt-3 !border-t-0"
              titleStyle="font-semibold text-bold text-md"
            />
          })
          ->React.array}
        </UIUtils.RenderIf>
      })
      ->React.array}
    </div>
  }
}

module PaymentMethodsRenderer = {
  open FRMUtils
  open LogicUtils
  @react.component
  let make = (~isUpdateFlow) => {
    let (pageState, setPageState) = React.useState(_ => PageLoaderWrapper.Loading)
    let frmConfigInput = ReactFinalForm.useField("frm_configs").input
    let frmConfigs = parseFRMConfig(frmConfigInput.value)
    let (connectorConfig, setConnectorConfig) = React.useState(_ => Dict.make())
    let setConfigJson = frmConfigInput.onChange
    let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()

    let getConfiguredConnectorDetails = async () => {
      try {
        let response = await fetchConnectorListResponse()
        let connectorsConfig =
          response
          ->getArrayFromJson([])
          ->Array.map(getDictFromJsonObject)
          ->FRMUtils.filterList(~removeFromList=FRMPlayer, ())
          ->getConnectorConfig

        let updateFRMConfig =
          connectorsConfig
          ->createAllOptions
          ->Array.map(defaultConfig => {
            switch frmConfigs->Array.find(item => item.gateway === defaultConfig.gateway) {
            | Some(config) => config
            | _ => defaultConfig
            }
          })

        setConnectorConfig(_ => connectorsConfig)
        setConfigJson(updateFRMConfig->Identity.anyTypeToReactEvent)
        setPageState(_ => Success)
      } catch {
      | _ => setPageState(_ => Error("Failed to fetch"))
      }
    }

    React.useEffect0(() => {
      getConfiguredConnectorDetails()->ignore
      None
    })

    <PageLoaderWrapper screenState={pageState}>
      <div className="flex flex-col gap-4">
        {frmConfigs
        ->Array.mapWithIndex((configInfo, i) => {
          <CheckBoxRenderer
            key={i->string_of_int}
            frmConfigInfo={configInfo}
            frmConfigs
            connectorPaymentMethods={connectorConfig->Dict.get(configInfo.gateway)}
            isUpdateFlow
          />
        })
        ->React.array}
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~setCurrentStep, ~retrivedValues=None, ~setInitialValues, ~isUpdateFlow: bool) => {
  open FRMInfo
  open FRMUtils
  open LogicUtils
  let initialValues = retrivedValues->Belt.Option.getWithDefault(Dict.make()->Js.Json.object_)

  let onSubmit = (values, _) => {
    open Promise
    let valuesDict = values->getDictFromJsonObject

    // filter connector frm config having no payment method config
    let filteredArray =
      valuesDict
      ->getJsonObjectFromDict("frm_configs")
      ->parseFRMConfig
      ->Array.filter(config => config.payment_methods->Array.length > 0)

    valuesDict->Dict.set("frm_configs", filteredArray->Identity.genericTypeToJson)
    setInitialValues(_ => valuesDict->Js.Json.object_)
    setCurrentStep(prev => prev->getNextStep)

    Js.Nullable.null->resolve
  }

  let validate = _values => {
    let errors = Dict.make()
    errors->Js.Json.object_
  }

  <Form initialValues onSubmit validate>
    <div className="flex">
      <div className="flex flex-col w-full">
        <div className="w-full flex justify-end mb-5">
          <FormRenderer.SubmitButton text="Proceed" />
        </div>
        <div className="flex flex-col gap-2 col-span-3">
          <PaymentMethodsRenderer isUpdateFlow />
        </div>
      </div>
    </div>
    <FormValuesSpy />
  </Form>
}
