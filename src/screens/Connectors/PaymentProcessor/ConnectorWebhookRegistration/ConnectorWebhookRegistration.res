@react.component
let make = (~connector, ~initialValues, ~setCurrentStep, ~isUpdateFlow) => {
  open APIUtils
  open LogicUtils
  open ConnectorWebhookRegistrationTypes
  open ConnectorWebhookRegistrationUtils
  open Typography

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()
  let getConnectorWebhooks = ConnectorWebhookRegistrationHooks.useGetConnectorWebhooks()

  let mcaId = initialValues->getDictFromJsonObject->getString("merchant_connector_id", "")

  let connectorConfig = React.useMemo(() => {
    Window.getConnectorConfig(connector)->getDictFromJsonObject
  }, [connector])

  let (items, setItems) = React.useState((_): array<webhookItem> => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let connectedPmts = initialValues->getConnectedPmts
  let registerConfig =
    connectorConfig->getDictfromDict("connector_webhook_register_details")->makeRegisterConfig

  let displayItems = getDisplayItems(~registerConfig, ~connectedPmts)

  let getItemLabel = getItemLabel(~scopeType=registerConfig.scope_type, _)

  let failureTooltip = status =>
    switch status {
    | RegisterFailed(message) =>
      <ToolTip
        description=message
        toolTipFor={<Icon name="tooltip_info" className="text-nd_red-500" />}
        toolTipPosition=Top
      />
    | _ => React.null
    }

  let setSeededWebhookItems = registeredValues => {
    let (seededItems, isSeededItemsEmpty) = getSeededItemsWithEmptyState(
      ~scopeType=registerConfig.scope_type,
      ~displayItems,
      ~registeredValues,
    )
    setItems(_ => seededItems)
    setScreenState(_ => isSeededItemsEmpty ? PageLoaderWrapper.Custom : PageLoaderWrapper.Success)
  }

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let webhooks = isUpdateFlow ? await getConnectorWebhooks(mcaId) : []
      let registeredValues = webhooks->getRegisteredValues
      setSeededWebhookItems(registeredValues)
    } catch {
    | _ =>
      if isUpdateFlow {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch registered webhooks"))
      } else {
        setSeededWebhookItems([])
      }
    }
  }

  React.useEffect(() => {
    if mcaId->isNonEmptyString {
      fetchData()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Error("Connector ID not found"))
    }
    None
  }, [mcaId])

  let toggleSelection = (identifier, isSelected) =>
    setItems(prev =>
      prev->Array.map(item =>
        item.identifier === identifier
          ? {...item, status: isSelected ? Selected : Unselected}
          : item
      )
    )

  let selectedItems = items->getSelectedItems

  let notSpecificItem = items->getValueFromArray(0, {identifier: notSpecificId, status: Unselected})

  let registerWebhooks = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let selectedIdentifiers = selectedItems->Array.map(item => item.identifier)
      let body = makeRegisterBody(~scopeType=registerConfig.scope_type, ~selectedIdentifiers)

      let url = getURL(~entityName=V1(CONNECTOR_WEBHOOK), ~methodType=Post, ~id=Some(mcaId))
      let res = await updateDetails(url, body, Post)

      let response = res->getDictFromJsonObject->makeRegisterResponse
      let statusById = makeStatusByIdentifier(
        ~results=response.results,
        ~scopeType=registerConfig.scope_type,
      )

      setItems(prev =>
        prev->Array.map(item =>
          statusById
          ->getOptionValFromDict(item.identifier)
          ->mapOptionOrDefault(item, status => {...item, status})
        )
      )

      setScreenState(_ => PageLoaderWrapper.Success)
      let failedIdentifiers = response.results->getFailedIdentifiers
      if failedIdentifiers->isNonEmptyArray {
        let message = getFailedRegistrationMessage(
          ~scopeType=registerConfig.scope_type,
          ~failedIdentifiers,
        )
        showToast(~message, ~toastType=ToastError)
      } else {
        setCurrentStep(_ => ConnectorTypes.SummaryAndTest)
      }
    } catch {
    | _ => {
        showToast(~message="Failed to register webhooks", ~toastType=ToastError)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    }
  }

  let (emptyWebhookRegistrationTitle, emptyWebhookRegistrationSubtitle) =
    getEmptyWebhookRegistrationCopy(
      ~scopeType=registerConfig.scope_type,
      ~isConnectedPmtsEmpty=connectedPmts->isEmptyArray,
    )

  let emptyWebhookRegistrationUI =
    <DefaultLandingPage
      title=emptyWebhookRegistrationTitle
      subtitle=emptyWebhookRegistrationSubtitle
      customStyle="py-16 !m-0 h-80-vh"
      overridingStylesTitle="text-2xl font-semibold"
      overridingStylesSubtitle="!text-sm text-nd_gray-600 !w-3/4"
      buttonText="Continue to summary"
      onClickHandler={_ => setCurrentStep(_ => ConnectorTypes.SummaryAndTest)}
      isButton=true
    />

  <PageLoaderWrapper screenState customUI={emptyWebhookRegistrationUI}>
    <div className="flex flex-col">
      <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} />
          <h2 className={heading.md.semibold}>
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
            buttonState={selectedItems->isEmptyArray ? Disabled : Normal}
            onClick={_ => registerWebhooks()->ignore}
          />
        </div>
      </div>
      <div className="flex flex-col gap-3 p-6">
        {switch registerConfig.scope_type {
        | NotSpecific =>
          <RenderIf condition={items->isNonEmptyArray}>
            <div
              className="flex items-center justify-between border border-nd_gray-150 rounded-xl px-4 py-3">
              <div className="flex flex-col gap-1">
                <div className="flex items-center gap-2">
                  <p className={body.md.medium}> {registerConfig.label->React.string} </p>
                  {notSpecificItem.status->failureTooltip}
                </div>
                <p className={`${body.sm.regular} text-nd_gray-600`}>
                  {"Automatically register webhooks with this connector to receive event notifications."->React.string}
                </p>
              </div>
              <SwitchAdapter
                isSelected={notSpecificItem.status->isItemSelected}
                setIsSelected={sel => toggleSelection(notSpecificItem.identifier, sel)}
                isDisabled={notSpecificItem.status->isItemRegistered}
                boolCustomClass="rounded-xl"
                toggleBorder="border-nd_primary_blue-450"
                toggleEnableColor="bg-nd_primary_blue-450"
                customToggleHeight="20px"
                customToggleWidth="36px"
                customInnerCircleHeight="10px"
                transformValue="20px"
              />
            </div>
          </RenderIf>
        | PaymentMethodType | EventType =>
          items
          ->Array.map(item =>
            <div
              key={item.identifier}
              className="flex items-center gap-3 border border-nd_gray-150 rounded-xl px-4 py-3">
              <CheckBoxIconAdapter
                isSelected={item.status->isItemSelected}
                isDisabled={item.status->isItemRegistered}
                setIsSelected={sel => toggleSelection(item.identifier, sel)}
              />
              <p className={body.md.medium}> {item.identifier->getItemLabel->React.string} </p>
              {item.status->failureTooltip}
            </div>
          )
          ->React.array
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
