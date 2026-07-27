@react.component
let make = (~connector, ~initialValues, ~setCurrentStep, ~isUpdateFlow) => {
  open APIUtils
  open LogicUtils
  open ConnectorWebhookRegisterationTypes
  open ConnectorWebhookRegistrationUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)

  let mcaId = initialValues->getDictFromJsonObject->getString("merchant_connector_id", "")

  let connectorConfig = React.useMemo(() => {
    try {
      Window.getConnectorConfig(connector)->getDictFromJsonObject
    } catch {
    | _ => Dict.make()
    }
  }, [connector])

  let (registeredPmts, setRegisteredPmts) = React.useState((_): array<string> => [])
  let (selected, setSelected) = React.useState((_): array<string> => [])
  let (failures, setFailures) = React.useState((_): Dict.t<string> => Dict.make())
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let getRegisteredWebhooks = async () => {
    try {
      let url = getURL(~entityName=V1(CONNECTOR_WEBHOOK), ~methodType=Get, ~id=Some(mcaId))
      let res = await fetchDetails(url)
      let registered =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("webhooks", [])
        ->Array.filterMap(webhook => {
          let value =
            webhook->getDictFromJsonObject->getDictfromDict("scope")->getString("value", "")
          value->isNonEmptyString ? Some(value) : None
        })
      setRegisteredPmts(_ => registered)
    } catch {
    | _ => ()
    }
  }

  let fetchData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    if isUpdateFlow {
      await getRegisteredWebhooks()
    }
    setScreenState(_ => PageLoaderWrapper.Success)
  }

  React.useEffect(() => {
    if mcaId->isNonEmptyString {
      fetchData()->ignore
    }
    None
  }, [mcaId])

  let connectedPmts =
    initialValues
    ->getDictFromJsonObject
    ->getArrayFromDict("payment_methods_enabled", [])
    ->Array.flatMap(pmEnabled =>
      pmEnabled
      ->getDictFromJsonObject
      ->getArrayFromDict("payment_method_types", [])
      ->Array.map(pmt => pmt->getDictFromJsonObject->getString("payment_method_type", ""))
    )
  let registerConfig =
    connectorConfig->getDictfromDict("connector_webhook_register_details")->makeRegisterConfig

  let displayItems = switch registerConfig.scope_type {
  | PaymentMethodType =>
    registerConfig.payment_method_types->Array.filter(pmt => connectedPmts->Array.includes(pmt))
  | EventType => registerConfig.event_types
  | NotSpecific => []
  }

  let getItemLabel = item =>
    switch registerConfig.scope_type {
    | EventType => item->snakeToTitle
    | PaymentMethodType | NotSpecific => item->ConnectorUtils.getPaymentMethodDisplayName
    }

  let toggleSelection = (pmt, isSelected) =>
    setSelected(prev =>
      isSelected ? prev->Array.concat([pmt]) : prev->Array.filter(item => item !== pmt)
    )

  let registerWebhooks = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let scope = switch registerConfig.scope_type {
      | NotSpecific => [("type", NotSpecific->scopeTypeToRequestType->JSON.Encode.string)]
      | PaymentMethodType | EventType => [
          ("type", registerConfig.scope_type->scopeTypeToRequestType->JSON.Encode.string),
          ("values", selected->Array.map(JSON.Encode.string)->JSON.Encode.array),
        ]
      }
      let body =
        [("scope", scope->Dict.fromArray->JSON.Encode.object)]->Dict.fromArray->JSON.Encode.object

      let url = getURL(~entityName=V1(CONNECTOR_WEBHOOK), ~methodType=Post, ~id=Some(mcaId))
      let res = await updateDetails(url, body, Post)

      let response = res->getDictFromJsonObject->makeRegisterResponse
      let succeeded = []
      let failed = Dict.make()
      response.results->Array.forEach(result => {
        switch result.status {
        | Succeeded => succeeded->Array.push(result.identifier)
        | Failed =>
          let message =
            result.error->mapOptionOrDefault("Registration failed", error => error.message)
          failed->Dict.set(result.identifier, message)
        }
      })

      setRegisteredPmts(prev => prev->Array.concat(succeeded))
      setFailures(_ => failed)
      setSelected(prev =>
        prev->Array.filter(pmt =>
          !(succeeded->Array.includes(pmt)) && !(failed->Dict.get(pmt)->Option.isSome)
        )
      )

      setScreenState(_ => PageLoaderWrapper.Success)
      if failed->isEmptyDict {
        setCurrentStep(_ => ConnectorTypes.SummaryAndTest)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col">
      <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} />
          <h2 className="text-xl font-semibold">
            {connector->ConnectorUtils.getDisplayNameForConnector->React.string}
          </h2>
        </div>
        <div className="flex gap-3 self-center">
          <Button
            text="Skip this step"
            buttonType=Secondary
            onClick={_ => setCurrentStep(_ => ConnectorTypes.SummaryAndTest)}
          />
          <Button
            text="Register webhook"
            buttonType=Primary
            buttonState={selected->isEmptyArray ? Disabled : Normal}
            onClick={_ => registerWebhooks()->ignore}
          />
        </div>
      </div>
      <div className="flex flex-col gap-3 p-6">
        {displayItems
        ->Array.map(item => {
          let isRegistered = registeredPmts->Array.includes(item)
          let isSelected = isRegistered || selected->Array.includes(item)
          <div
            key={item}
            className="flex items-center gap-3 border border-nd_gray-150 rounded-xl px-4 py-3">
            <CheckBoxIconAdapter
              isSelected isDisabled={isRegistered} setIsSelected={sel => toggleSelection(item, sel)}
            />
            <p className={Typography.body.md.medium}> {item->getItemLabel->React.string} </p>
            {switch failures->Dict.get(item) {
            | Some(message) =>
              <ToolTip
                description=message
                toolTipFor={<Icon name="tooltip_info" className="text-nd_red-500" />}
                toolTipPosition=Top
              />
            | None => React.null
            }}
          </div>
        })
        ->React.array}
      </div>
    </div>
  </PageLoaderWrapper>
}
