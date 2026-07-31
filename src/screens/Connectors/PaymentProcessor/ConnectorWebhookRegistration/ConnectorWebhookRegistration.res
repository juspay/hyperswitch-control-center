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
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (items, setItems) = React.useState(_ => [])
  let getConnectorWebhooks = ConnectorWebhookRegistrationHooks.useGetConnectorWebhooks()

  let mcaId = initialValues->getDictFromJsonObject->getString("merchant_connector_id", "")
  let connectedPmts = initialValues->getConnectedPmts

  let connectorConfig = React.useMemo(() => {
    Window.getConnectorConfig(connector)
    ->getDictFromJsonObject
    ->getDictfromDict("connector_webhook_register_details")
  }, [connector])

  let scopeType = connectorConfig->getString("scope_type", "")->scopeTypeFromString
  let displayValues = switch scopeType {
  | PaymentMethodType =>
    connectorConfig
    ->getStrArrayFromDict("payment_method_types", [])
    ->Array.filter(pmt => connectedPmts->Array.includes(pmt))
  | EventType => connectorConfig->getStrArrayFromDict("event_types", [])
  | NotSpecific => []
  }
  let selectedItems = items->getSelectedItems

  let failureMessage = status =>
    switch status {
    | Failed(messages) =>
      messages
      ->Array.mapWithIndex((message, index) =>
        <div
          key={index->Int.toString}
          className={`flex items-center ${body.xs.medium} text-nd_red-500`}>
          <FormErrorIcon />
          {message->React.string}
        </div>
      )
      ->React.array
    | _ => React.null
    }

  let fetchData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let alreadyRegistered = await getConnectorWebhooks(mcaId)
      setItems(_ =>
        displayValues->Array.map(identifier => {
          identifier,
          status: alreadyRegistered->Array.includes(identifier) ? Success : Unselected,
        })
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch registered webhooks"))
    }
  }

  React.useEffect(() => {
    if isUpdateFlow {
      fetchData()->ignore
    } else {
      setItems(_ => displayValues->Array.map(identifier => {identifier, status: Unselected}))
      setScreenState(_ => PageLoaderWrapper.Success)
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

  let registerWebhooks = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let selectedIdentifiers = selectedItems->Array.map(item => item.identifier)
      let body = makeRequestBody(~scopeType, ~selectedIdentifiers)

      let url = getURL(~entityName=V1(CONNECTOR_WEBHOOK), ~methodType=Post, ~id=Some(mcaId))
      let res = await updateDetails(url, body, Post)

      let results =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("results", [])
        ->Array.map(getDictFromJsonObject)

      let updatedItems = items->Array.map(item => {
        let matching =
          results->Array.filter(result => result->getString("identifier", "") === item.identifier)

        if matching->isEmptyArray {
          item
        } else {
          let errors = matching->Array.filterMap(result =>
            switch result->getString("status", "")->resultStatusFromString {
            | Succeeded => None
            | Failed =>
              Some(result->getDictfromDict("error")->getString("message", "Registration failed"))
            }
          )
          {
            ...item,
            status: errors->isEmptyArray ? Success : Failed(errors->removeDuplicate),
          }
        }
      })

      setItems(_ => updatedItems)

      setScreenState(_ => PageLoaderWrapper.Success)

      let failedLabels = updatedItems->Array.filterMap(item =>
        switch item.status {
        | Failed(_) => Some(item.identifier->ConnectorUtils.getPaymentMethodDisplayName)
        | _ => None
        }
      )

      if failedLabels->isNonEmptyArray {
        showToast(
          ~message=`Webhook registration failed for ${failedLabels->Array.joinWith(", ")}`,
          ~toastType=ToastError,
        )
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

  <PageLoaderWrapper screenState>
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
        <RenderIf condition={items->isEmptyArray}>
          <p className={`${body.md.regular} text-nd_gray-600`}>
            {"No payment methods connected for this connector"->React.string}
          </p>
        </RenderIf>
        {items
        ->Array.map(item =>
          <div
            key={item.identifier}
            className="flex items-center gap-3 border border-nd_gray-150 rounded-xl px-4 py-3">
            <CheckBoxIconAdapter
              isSelected={item.status == Selected || item.status == Success}
              isDisabled={item.status == Success}
              setIsSelected={sel => toggleSelection(item.identifier, sel)}
            />
            <div className="flex flex-col gap-1">
              <p className={body.md.medium}>
                {getItemLabel(~scopeType, item.identifier)->React.string}
              </p>
              {item.status->failureMessage}
            </div>
          </div>
        )
        ->React.array}
      </div>
    </div>
  </PageLoaderWrapper>
}
