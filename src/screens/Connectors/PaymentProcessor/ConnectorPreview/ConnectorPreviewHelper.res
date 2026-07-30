module InfoField = {
  @react.component
  let make = (~label, ~str, ~showLabelAndFieldVertically, ~customValueCss="") => {
    let (containerCss, labelCss, valueCss) = showLabelAndFieldVertically
      ? ("flex-col w-full ", "w-full", "w-full")
      : ("", "flex-[1]", "flex-[3]")

    <div className={`flex ${containerCss} items-center w-full`}>
      <h2 className={`${labelCss} text-base font-semibold text-grey-700 opacity-70`}>
        {label->React.string}
      </h2>
      <h3
        className={`${valueCss} ${customValueCss} border p-1.5 bg-gray-50 rounded-lg overflow-scroll whitespace-nowrap`}>
        {str->React.string}
      </h3>
    </div>
  }
}

module CredsInfoField = {
  @react.component
  let make = (
    ~authKeys,
    ~connectorAccountFields,
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~showLabelAndFieldVertically,
    ~showConnectorLabelField,
  ) => {
    open LogicUtils
    let dict = authKeys->Identity.genericTypeToDictOfJson
    let authFields =
      dict
      ->Dict.keysToArray
      ->Array.filter(ele => ele !== "auth_type")
      ->Array.map(field => {
        let value = dict->getString(field, "")
        let label = connectorAccountFields->getString(field, "")
        <InfoField label str=value showLabelAndFieldVertically />
      })

    let connectorLabelField = {
      <InfoField
        label="Connector Label"
        str=connectorInfo.connector_label
        showLabelAndFieldVertically
        customValueCss="font-semibold text-base"
      />
    }
    showConnectorLabelField
      ? Array.concat(authFields, [connectorLabelField])->React.array
      : authFields->React.array
  }
}

module CashtoCodeCredsInfo = {
  @react.component
  let make = (~authKeys: ConnectorTypes.currencyAuthKey, ~showLabelAndFieldVertically) => {
    open LogicUtils
    let dict = authKeys.auth_key_map->Identity.genericTypeToDictOfJson
    dict
    ->Dict.keysToArray
    ->Array.map(ele => {
      let data = dict->getDictfromDict(ele)
      let keys = data->Dict.keysToArray

      {
        <>
          <InfoField label="Currency" str=ele showLabelAndFieldVertically />
          {keys
          ->Array.map(ele => {
            let value = data->getString(ele, "")
            <InfoField label={ele->snakeToTitle} str=value showLabelAndFieldVertically />
          })
          ->React.array}
        </>
      }
    })
    ->React.array
  }
}

module PreviewCreds = {
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~showLabelAndFieldVertically=false,
    ~showConnectorLabelField=true,
  ) => {
    switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) =>
      <CredsInfoField
        authKeys
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | BodyKey(bodyKey) =>
      <CredsInfoField
        authKeys=bodyKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | SignatureKey(signatureKey) =>
      <CredsInfoField
        authKeys=signatureKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | MultiAuthKey(multiAuthKey) =>
      <CredsInfoField
        authKeys=multiAuthKey
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | CertificateAuth(certificateAuth) =>
      <CredsInfoField
        authKeys=certificateAuth
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | CurrencyAuthKey(currencyAuthKey) =>
      <CashtoCodeCredsInfo authKeys=currencyAuthKey showLabelAndFieldVertically />
    | NoKey(noKeyAuth) =>
      <CredsInfoField
        authKeys=noKeyAuth
        connectorAccountFields
        connectorInfo
        showLabelAndFieldVertically
        showConnectorLabelField
      />
    | UnKnownAuthType(_) => React.null
    }
  }
}

module EnableDisableConnectorToggle = {
  @react.component
  let make = (~disableConnector, ~isConnectorDisabled) => {
    let connectorStatusAvailableToSwitch = isConnectorDisabled ? "Disabled" : "Enabled"

    <div className="flex gap-2 items-center">
      <SwitchAdapter
        isSelected={!isConnectorDisabled}
        setIsSelected={_ => disableConnector(isConnectorDisabled)->ignore}
        boolCustomClass="rounded-xl"
        customToggleHeight="20px"
        customToggleWidth="36px"
        customInnerCircleHeight="10px"
        transformValue="20px"
      />
      <span> {connectorStatusAvailableToSwitch->React.string} </span>
    </div>
  }
}

module RegisteredWebhooks = {
  @react.component
  let make = (
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~connector,
    ~setCurrentStep,
    ~webhookStepValue,
    ~isUpdateFlow,
  ) => {
    open LogicUtils
    open Typography
    open PageLoaderWrapper
    let getConnectorWebhooks = ConnectorWebhookRegistrationHooks.useGetConnectorWebhooks()

    let (registeredWebhooks, setRegisteredWebhooks) = React.useState((_): array<string> => [])
    let (screenState, setScreenState) = React.useState(_ => Success)

    let getRegisteredWebhooks = async () => {
      try {
        setScreenState(_ => Loading)
        let webhooks = await getConnectorWebhooks(connectorInfo.merchant_connector_id)
        let values = webhooks->ConnectorWebhookRegistrationUtils.getRegisteredValues
        setRegisteredWebhooks(_ => values)
        setScreenState(_ => Success)
      } catch {
      | _ =>
        setRegisteredWebhooks(_ => [])
        setScreenState(_ => Custom)
      }
    }

    React.useEffect(() => {
      getRegisteredWebhooks()->ignore
      None
    }, [connectorInfo.merchant_connector_id])

    <div className="grid grid-cols-4 border-b md:px-10 py-8">
      <div className="flex items-start">
        <h4 className={heading.sm.semibold}> {"Registered Webhooks"->React.string} </h4>
      </div>
      <div className="flex gap-12 col-span-3">
        <div className="flex flex-col gap-3 w-5/6">
          <PageLoaderWrapper
            screenState
            customLoader={<Shimmer styleClass="h-7 w-40 rounded-md" />}
            customUI={<AlertV2Binding
              description="Failed to fetch registered webhooks" alertType=Error
            />}>
            <RenderIf condition={registeredWebhooks->isEmptyArray}>
              <p className={`${body.md.regular} text-nd_gray-400 flex items-center h-7`}>
                {"No webhooks registered for this connector"->React.string}
              </p>
            </RenderIf>
            <RenderIf condition={registeredWebhooks->isNonEmptyArray}>
              {registeredWebhooks
              ->Array.mapWithIndex((item, index) =>
                <div key={index->Int.toString} className="flex items-center gap-2">
                  <p className={body.md.medium}>
                    {item->ConnectorUtils.getPaymentMethodDisplayName->React.string}
                  </p>
                  <TagBinding
                    text="Registered" color=Success variant=Subtle shape=Squarical size=Xs
                  />
                </div>
              )
              ->React.array}
            </RenderIf>
          </PageLoaderWrapper>
        </div>
        <RenderIf condition={isUpdateFlow}>
          {switch webhookStepValue {
          | Some(step) =>
            <div className="cursor-pointer" onClick={_ => setCurrentStep(_ => step)}>
              <ToolTip
                description={`Update the ${connector} webhook registrations`}
                toolTipFor={<Icon size=18 name="edit" className={` ml-2`} />}
                toolTipPosition=Top
              />
            </div>
          | None => React.null
          }}
        </RenderIf>
      </div>
    </div>
  }
}
