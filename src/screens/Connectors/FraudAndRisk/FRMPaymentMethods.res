module ToggleSwitch = {
  open FRMUtils
  @react.component
  let make = (~isOpen, ~handleOnChange, ~isToggleDisabled) => {
    let cursorType = isToggleDisabled ? "cursor-not-allowed" : "cursor-pointer"

    let enabledClasses = if isOpen {
      `bg-primary ${cursorType} ${toggleDefaultStyle}`
    } else {
      `bg-gray-300 ${cursorType} ${toggleDefaultStyle}`
    }

    let enabledSpanClasses = if isOpen {
      `translate-x-7 ${accordionDefaultStyle}`
    } else {
      `translate-x-1 ${accordionDefaultStyle}`
    }

    <HeadlessUI.Switch checked={isOpen} onChange={_ => handleOnChange()} className={enabledClasses}>
      {_checked => {
        <>
          <div ariaHidden=true className={enabledSpanClasses} />
        </>
      }}
    </HeadlessUI.Switch>
  }
}
module CheckBoxRenderer = {
  open FRMUtils
  open FormRenderer
  open Typography
  @react.component
  let make = (
    ~fromConfigIndex,
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
        } else if isUpdateFlow {
          showConfitmation()
        } else {
          frmConfigInfo.payment_methods = []
          setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
          setIsOpen(_ => !isOpen)
        }
      }
    }

    let paymentMethodsConfig = switch connectorPaymentMethods {
    | Some(paymentMethods) => paymentMethods->generateFRMPaymentMethodsConfig
    | _ => []
    }

    React.useEffect(() => {
      if isOpen && !isUpdateFlow {
        frmConfigInfo.payment_methods = paymentMethodsConfig
        setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
      }
      None
    }, [])

    <div>
      <div
        className="w-full px-5 py-3 bg-light-gray-bg flex items-center gap-3 justify-between border">
        <div className="flex font-semibold text-bold text-lg gap-2 items-center">
          <GatewayIcon gateway={frmConfigInfo.gateway->String.toUpperCase} className="w-10 h-10" />
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
      {paymentMethodsConfig
      ->Array.mapWithIndex((paymentMethodInfo, index) => {
        <RenderIf
          condition={isOpen && paymentMethodsConfig->Array.length > 0} key={index->Int.toString}>
          <div className="flex flex-col border px-5 py-3 ">
            <div className="flex justify-between items-center">
              <p className={`${body.lg.semibold}`}>
                {paymentMethodInfo.payment_method->LogicUtils.snakeToTitle->React.string}
              </p>
              <FormRenderer.FieldRenderer
                field={makeFieldInfo(
                  ~name=`frm_configs[${fromConfigIndex}].payment_methods[${index->Int.toString}].flow`,
                  ~label="",
                  ~customInput=(~input, ~placeholder) =>
                    customAuthtypeInput(
                      ~input,
                      ~placeholder,
                      ~paymentMethodName=paymentMethodInfo.payment_method,
                      ~frmConfigInfo,
                      ~frmConfigs,
                      ~setConfigJson,
                    ),
                )}
              />
            </div>
            <RenderIf
              condition={frmConfigInfo.payment_methods->Array.some(pm =>
                pm.payment_method === paymentMethodInfo.payment_method
              )}>
              <p className={`${body.lg.medium} text-nd_gray-300`}>
                {"Enabled with Pre-Authorization"->React.string}
              </p>
            </RenderIf>
          </div>
        </RenderIf>
      })
      ->React.array}
    </div>
  }
}

module PaymentMethodsRenderer = {
  open FRMUtils
  @react.component
  let make = (~isUpdateFlow) => {
    let (pageState, setPageState) = React.useState(_ => PageLoaderWrapper.Loading)
    let frmConfigInput = ReactFinalForm.useField("frm_configs").input
    let frmConfigs = parseFRMConfig(frmConfigInput.value)
    let (connectorConfig, setConnectorConfig) = React.useState(_ => Dict.make())
    let setConfigJson = frmConfigInput.onChange
    let connectorsList = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=PaymentProcessor,
    )

    let getConfiguredConnectorDetails = async () => {
      try {
        let connectorsConfig = connectorsList->getConnectorConfig
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

    React.useEffect(() => {
      getConfiguredConnectorDetails()->ignore
      None
    }, [])

    <PageLoaderWrapper screenState={pageState}>
      <div className="flex flex-col gap-4">
        {frmConfigs
        ->Array.mapWithIndex((configInfo, i) => {
          <CheckBoxRenderer
            key={i->Int.toString}
            frmConfigInfo={configInfo}
            frmConfigs
            connectorPaymentMethods={connectorConfig->Dict.get(configInfo.gateway)}
            isUpdateFlow
            fromConfigIndex={i->Int.toString}
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
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let initialValues = retrivedValues->Option.getOr(Dict.make()->JSON.Encode.object)

  let onSubmit = (values, _) => {
    open Promise
    mixpanelEvent(~eventName="frm_step1")
    let valuesDict = values->getDictFromJsonObject

    // filter connector frm config having no payment method config
    let filteredArray =
      valuesDict
      ->getJsonObjectFromDict("frm_configs")
      ->parseFRMConfig
      ->Array.filter(config => config.payment_methods->Array.length > 0)

    valuesDict->Dict.set(
      "frm_configs",
      filteredArray->Array.length > 0
        ? filteredArray->Identity.genericTypeToJson
        : JSON.Encode.null,
    )
    setInitialValues(_ => valuesDict->JSON.Encode.object)
    setCurrentStep(prev => prev->getNextStep)

    Nullable.null->resolve
  }

  let validate = _values => {
    let errors = Dict.make()
    errors->JSON.Encode.object
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
  </Form>
}
