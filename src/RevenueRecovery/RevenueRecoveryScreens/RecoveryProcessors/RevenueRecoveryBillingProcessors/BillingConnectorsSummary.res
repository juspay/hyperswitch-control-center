type connectorSummarySection = AuthenticationKeys | Metadata | PMTs | PaymentConnectors
open Typography

module EditSectionHeader = {
  @react.component
  let make = (~title, ~isEditing, ~onEdit, ~onCancel) => {
    <div className="flex justify-between border-b pb-4 px-2 items-end">
      <p className={`${heading.sm.semibold} text-nd_gray-600`}> {title->React.string} </p>
      <div className="flex gap-4">
        {if isEditing {
          <>
            <Button
              text="Cancel"
              onClick={_ => onCancel()}
              buttonType={Secondary}
              buttonSize={Small}
              customButtonStyle="w-fit"
            />
            <FormRenderer.SubmitButton
              text="Save" buttonSize={Small} customSubmitButtonStyle="w-fit"
            />
          </>
        } else {
          <div className="flex gap-2 items-center cursor-pointer" onClick={_ => onEdit()}>
            <Icon name="nd-edit" size=14 />
            <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
          </div>
        }}
      </div>
    </div>
  }
}

/* custom billing has no external platform to hold webhook settings, so the
   payment webhook url and the events it fires for live here, reusing the payment
   settings form limited to payment events */
module WebhooksConfiguration = {
  @react.component
  let make = () => {
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId(
      ~version=UserInfoTypes.V2,
    )
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let (paymentResponseHashKey, setPaymentResponseHashKey) = React.useState(_ => "")

    React.useEffect(() => {
      let getHashKey = async () => {
        try {
          let profile = await fetchBusinessProfileFromId(~profileId=Some(profileId))
          let info = profile->BusinessProfileInterfaceUtilsV2.mapJsonToBusinessProfileV2
          setPaymentResponseHashKey(_ => info.payment_response_hash_key->Option.getOr(""))
        } catch {
        | _ => ()
        }
      }
      getHashKey()->ignore
      None
    }, [])

    <div className="flex flex-col gap-4">
      <div className="px-2">
        <WebhookConfiguration allowedApiFields=["payment_statuses_enabled"] />
        <RenderIf condition={paymentResponseHashKey->String.length !== 0}>
          <div className="flex flex-col gap-2 mt-6">
            <h4 className="text-nd_gray-400"> {"Payment Response Hash Key"->React.string} </h4>
            <HelperComponents.CopyTextCustomComp
              displayValue={Some(paymentResponseHashKey)}
              customTextCss={`break-all truncate md:whitespace-normal ${body.md.regular} text-nd_gray-800`}
              customParentClass="flex items-center gap-5"
              customIconCss="text-jp-gray-700"
            />
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

/* view mode can't use ConnectorWebhookDetails, it needs the url's name param,
 so the saved values are listed directly */
module WebhookDetailsView = {
  @react.component
  let make = (~webhookDetails) => {
    open LogicUtils
    let entries =
      webhookDetails
      ->getDictFromJsonObject
      ->Dict.toArray
      ->Array.filter(((_, value)) => value->JSON.Decode.string->Option.getOr("")->isNonEmptyString)
    <>
      <RenderIf condition={entries->Array.length > 0}>
        <div className="grid grid-cols-2 gap-10 max-w-3xl px-2">
          {entries
          ->Array.map(((key, value)) =>
            <div className="flex flex-col gap-2 min-w-0" key>
              <h4 className="text-nd_gray-400"> {key->snakeToTitle->React.string} </h4>
              <p className="break-all">
                {value->JSON.Decode.string->Option.getOr("")->React.string}
              </p>
            </div>
          )
          ->React.array}
        </div>
      </RenderIf>
      <RenderIf condition={entries->Array.length === 0}>
        <p className="text-nd_gray-400 px-2"> {"No webhook details configured"->React.string} </p>
      </RenderIf>
    </>
  }
}

/* ConnectorAuthKeys and ConnectorWebhookDetails read the connector from the
 url's name param, so entering edit mode has to put it there */
let setConnectorNameInUrl = connectorName => {
  let url =
    connectorName->LogicUtils.isNonEmptyString
      ? `/v2/recovery/summary?name=${connectorName}`
      : `/v2/recovery/summary`
  RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
}

module BillingConnectorDetails = {
  open PageLoaderWrapper
  open LogicUtils
  open APIUtils
  open ConnectorUtils
  @react.component
  let make = (~removeFieldsFromResponse, ~merchantId, ~setPaymentConnectorId) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false)
    let showToast = ToastAdapter.useShowToast()
    let (screenState, setScreenState) = React.useState(_ => Loading)
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let (currentActiveSection, setCurrentActiveSection) = React.useState(_ => None)

    let billingConnectorListFromRecoil = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=BillingProcessor,
    )

    let (connectorID, _) =
      billingConnectorListFromRecoil->BillingProcessorsUtils.getConnectorDetails

    let getConnectorDetails = async () => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Get,
          ~id=Some(connectorID),
        )
        let json = await fetchDetails(connectorUrl, ~version=V2)
        setInitialValues(_ => json->removeFieldsFromResponse)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch details"))
      }
    }

    React.useEffect(() => {
      getConnectorDetails()->ignore
      None
    }, [])

    let connectorInfodict = ConnectorInterface.mapDictToTypedConnectorPayload(
      ConnectorInterface.connectorInterfaceV2,
      initialValues->LogicUtils.getDictFromJsonObject,
    )

    let {connector_name: connectorName} = connectorInfodict

    let connectorDetails = React.useMemo(() => {
      try {
        if connectorName->LogicUtils.isNonEmptyString {
          let dict = BillingProcessorsUtils.getConnectorConfig(connectorName)

          let revenueRecovery =
            connectorInfodict.feature_metadata
            ->getDictFromJsonObject
            ->getDictfromDict("revenue_recovery")
          let paymentConnectors =
            revenueRecovery->getObj("billing_account_reference", Dict.make())->Dict.toArray

          let id = switch paymentConnectors->Array.get(0) {
          | Some(val) => {
              let (id, _) = val
              id
            }
          | _ => ""
          }

          setPaymentConnectorId(_ => id)

          dict
        } else {
          JSON.Encode.null
        }
      } catch {
      | Exn.Error(e) => {
          Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
          let _ = Exn.message(e)->Option.getOr("Something went wrong")
          JSON.Encode.null
        }
      }
    }, [connectorInfodict.id])

    let {
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
    } = getConnectorFields(connectorDetails)

    let handleClick = (section: option<connectorSummarySection>) => {
      if section->Option.isNone {
        setInitialValues(_ => JSON.stringify(initialValues)->safeParse)
        setConnectorNameInUrl("")
      } else {
        setConnectorNameInUrl(connectorName)
      }
      setCurrentActiveSection(_ => section)
    }

    let isEditing = (section: connectorSummarySection) => currentActiveSection == Some(section)

    let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Put,
          ~id=Some(connectorID),
        )
        let dict = values->getDictFromJsonObject
        dict->Dict.delete("profile_id")
        dict->Dict.delete("id")
        dict->Dict.delete("connector_name")
        if currentActiveSection != Some(AuthenticationKeys) {
          dict->Dict.delete("connector_account_details")
        }
        dict->Dict.set("merchant_id", merchantId->JSON.Encode.string)
        let response = await updateAPIHook(connectorUrl, dict->JSON.Encode.object, Put, ~version=V2)
        setCurrentActiveSection(_ => None)
        setConnectorNameInUrl("")
        setInitialValues(_ => response->removeFieldsFromResponse)
        setScreenState(_ => Success)
        showToast(~message="Billing platform details updated", ~toastType=ToastState.ToastSuccess)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Failed to update billing platform")
          showToast(
            ~message=err->safeParse->getDictFromJsonObject->getString("message", err),
            ~toastType=ToastState.ToastError,
          )
          setScreenState(_ => Success)
        }
      }
      Nullable.null
    }

    let validateMandatoryField = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      validateConnectorRequiredFields(
        connectorName->getConnectorNameTypeFromString(~connectorType=BillingProcessor),
        valuesFlattenJson,
        connectorAccountFields,
        connectorMetaDataFields,
        connectorWebHookDetails,
        connectorLabelDetailField,
        errors->JSON.Encode.object,
      )
    }

    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-9">
        <div className="flex justify-between border-b pb-4 px-2 items-end">
          <p className={heading.md.semibold}> {"Billing Platform Details"->React.string} </p>
        </div>
        <div className="grid grid-cols-3 gap-y-6 px-2">
          <div className="flex flex-col gap-2 ">
            <h4 className="text-nd_gray-400 "> {"Biller Platform "->React.string} </h4>
            <div className="flex gap-2 align-center">
              <GatewayIcon
                gateway={connectorName->String.toUpperCase} className=" w-7 h-7 rounded-sm"
              />
              {connectorName->React.string}
            </div>
          </div>
          <div className="flex flex-col gap-2 min-w-0">
            <h4 className="text-nd_gray-400 "> {"Connector label"->React.string} </h4>
            <p className="break-all"> {connectorInfodict.connector_label->React.string} </p>
          </div>
          <div className="flex flex-col gap-2 ">
            <h4 className="text-nd_gray-400 "> {"Merchant Connector ID"->React.string} </h4>
            <HelperComponents.CopyTextCustomComp
              displayValue={Some(connectorInfodict.id)}
              customTextCss="!font-jetbrains-mono text-nd_gray-600"
            />
          </div>
          <RenderIf
            condition={connectorName->getConnectorNameTypeFromString(
              ~connectorType=BillingProcessor,
            ) != BillingProcessor(CUSTOMBILLING)}>
            <div className="min-w-0">
              <ConnectorWebhookPreview
                merchantId
                connectorName=connectorInfodict.connector_name
                version=V2
                connectorId=connectorInfodict.id
                isRecoveryWebhook=true
                containerClass="flex items-center min-w-0"
                textCss="truncate"
              />
            </div>
          </RenderIf>
        </div>
        {switch connectorName->getConnectorNameTypeFromString(~connectorType=BillingProcessor) {
        | BillingProcessor(CUSTOMBILLING) =>
          <div className="px-2">
            <KeyManagementHelper.ApiKeysTable
              dataNotFoundComponent={<div className="p-1">
                <div
                  className={`h-56 -my-1 -mx-2 border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
                  {"No API Keys Available"->React.string}
                </div>
              </div>}
            />
          </div>
        | _ =>
          <Form onSubmit initialValues validate=validateMandatoryField>
            <div className="flex flex-col gap-12">
              <div className="flex flex-col gap-4">
                <EditSectionHeader
                  title="Authentication keys"
                  isEditing={isEditing(AuthenticationKeys)}
                  onEdit={() => handleClick(Some(AuthenticationKeys))}
                  onCancel={() => handleClick(None)}
                />
                {if isEditing(AuthenticationKeys) {
                  <ConnectorAuthKeys
                    initialValues showVertically=false processorType=BillingProcessor
                  />
                } else {
                  <ConnectorHelperV2.PreviewCreds
                    connectorInfo=connectorInfodict
                    connectorAccountFields
                    customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
                    customElementStyle="px-2 "
                  />
                }}
              </div>
              <RenderIf condition={connectorWebHookDetails->Dict.keysToArray->Array.length > 0}>
                <div className="flex flex-col gap-4">
                  <EditSectionHeader
                    title="Webhook details"
                    isEditing={isEditing(Metadata)}
                    onEdit={() => handleClick(Some(Metadata))}
                    onCancel={() => handleClick(None)}
                  />
                  {isEditing(Metadata)
                    ? <div className="grid grid-cols-2 gap-10 flex-wrap max-w-3xl px-2">
                        <ConnectorWebhookDetails
                          labelTextStyleClass="text-nd_gray-400"
                          labelClass="font-normal"
                          isInEditState=true
                          connectorInfo=connectorInfodict
                          processorType=BillingProcessor
                        />
                      </div>
                    : <WebhookDetailsView
                        webhookDetails=connectorInfodict.connector_webhook_details
                      />}
                </div>
              </RenderIf>
            </div>
          </Form>
        }}
      </div>
    </PageLoaderWrapper>
  }
}

module PaymentConnectorDetails = {
  open PageLoaderWrapper
  open LogicUtils
  open APIUtils
  open ConnectorUtils
  @react.component
  let make = (~connectorId, ~removeFieldsFromResponse, ~merchantId) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false)
    let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList(
      ~entityName=V2(V2_CONNECTOR),
      ~version=V2,
    )
    let (screenState, setScreenState) = React.useState(_ => Loading)
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let (currentActiveSection, setCurrentActiveSection) = React.useState(_ => None)

    let getConnectorDetails = async () => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Get,
          ~id=Some(connectorId),
        )

        let json = await fetchDetails(connectorUrl, ~version=V2)
        setInitialValues(_ => json->removeFieldsFromResponse)
        setScreenState(_ => Success)
      } catch {
      | _ =>
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch payment connector details"))
      }
    }

    React.useEffect(() => {
      if connectorId->isNonEmptyString {
        getConnectorDetails()->ignore
      }
      None
    }, [connectorId])

    let connectorInfodict = ConnectorInterface.mapDictToTypedConnectorPayload(
      ConnectorInterface.connectorInterfaceV2,
      initialValues->LogicUtils.getDictFromJsonObject,
    )

    let {connector_name} = connectorInfodict

    let connectorDetails = React.useMemo(() => {
      try {
        if connector_name->LogicUtils.isNonEmptyString {
          let dict = Window.getConnectorConfig(connector_name)
          dict
        } else {
          JSON.Encode.null
        }
      } catch {
      | Exn.Error(e) => {
          Js.log2("FAILED TO LOAD PAYMENT CONNECTOR CONFIG", e)
          let _ = Exn.message(e)->Option.getOr("Something went wrong")
          JSON.Encode.null
        }
      }
    }, [connectorInfodict.id])

    let {
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
    } = getConnectorFields(connectorDetails)

    let handleClick = (section: option<connectorSummarySection>) => {
      if section->Option.isNone {
        setInitialValues(_ => JSON.stringify(initialValues)->safeParse)
        setConnectorNameInUrl("")
      } else {
        setConnectorNameInUrl(connector_name)
      }
      setCurrentActiveSection(_ => section)
    }

    let isEditing = (section: connectorSummarySection) => currentActiveSection == Some(section)

    let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Get,
          ~id=Some(connectorId),
        )
        let dict = values->getDictFromJsonObject
        switch currentActiveSection {
        | Some(AuthenticationKeys) => {
            dict->Dict.delete("profile_id")
            dict->Dict.delete("id")
            dict->Dict.delete("connector_name")
          }
        | _ => {
            dict->Dict.delete("profile_id")
            dict->Dict.delete("id")
            dict->Dict.delete("connector_name")
            dict->Dict.delete("connector_account_details")
          }
        }
        dict->Dict.set("merchant_id", merchantId->JSON.Encode.string)
        let response = await updateAPIHook(connectorUrl, dict->JSON.Encode.object, Put, ~version=V2)
        /* the processors list above reads the shared connector list, so refresh it
         to pick up the new disabled state */
        let _ = await fetchConnectorListResponse()
        setCurrentActiveSection(_ => None)
        setConnectorNameInUrl("")
        setInitialValues(_ => response->removeFieldsFromResponse)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to update"))
      }
      Nullable.null
    }

    let validateMandatoryField = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      let profileId = valuesFlattenJson->getString("profile_id", "")
      if profileId->String.length === 0 {
        Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
      }
      let paymentConnectorTypeFromName = connector_name->getConnectorNameTypeFromString

      validateConnectorRequiredFields(
        paymentConnectorTypeFromName,
        valuesFlattenJson,
        connectorAccountFields,
        connectorMetaDataFields,
        connectorWebHookDetails,
        connectorLabelDetailField,
        errors->JSON.Encode.object,
      )
    }

    <RenderIf condition={connectorId->isNonEmptyString}>
      <PageLoaderWrapper screenState sectionHeight="h-96">
        <div className="flex flex-col gap-7">
          <div className="flex justify-between border-b pb-4 px-2 items-end">
            <p className=heading.md.semibold> {"Payment Processor Details"->React.string} </p>
          </div>
          <Form onSubmit={onSubmit} initialValues={initialValues} validate=validateMandatoryField>
            <div className="grid grid-cols-3 px-2">
              <div className="flex flex-col gap-2 ">
                <h4 className="text-nd_gray-400 "> {"Payment Processor"->React.string} </h4>
                <div className="flex gap-2 align-center">
                  <GatewayIcon
                    gateway={connector_name->String.toUpperCase} className=" w-7 h-7 rounded-sm"
                  />
                  {connector_name->React.string}
                </div>
              </div>
              <div className="flex flex-col gap-2 ">
                <h4 className="text-nd_gray-400 "> {"Processor status"->React.string} </h4>
                <div className="flex flex-row gap-2 items-center ">
                  <ConnectorHelperV2.ProcessorStatus connectorInfo=connectorInfodict />
                </div>
              </div>
              <div className="flex flex-col gap-2 min-w-0">
                <h4 className="text-nd_gray-400 "> {"Connector label"->React.string} </h4>
                <p className="break-all"> {connectorInfodict.connector_label->React.string} </p>
              </div>
            </div>
            <div className="flex flex-col gap-12 mt-7">
              <div className="grid grid-cols-3 px-2">
                <div className="flex flex-col gap-2 ">
                  <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
                  {connectorInfodict.profile_id->React.string}
                </div>
                <div className="flex flex-col gap-2 ">
                  <h4 className="text-nd_gray-400 "> {"Merchant Connector ID"->React.string} </h4>
                  <HelperComponents.CopyTextCustomComp
                    displayValue={Some(connectorInfodict.id)}
                    customTextCss="!font-jetbrains-mono text-nd_gray-600"
                  />
                </div>
                <div className="min-w-0">
                  <ConnectorWebhookPreview
                    merchantId
                    connectorName=connectorInfodict.connector_name
                    version=V2
                    connectorId=connectorInfodict.id
                    containerClass="flex items-center min-w-0"
                    textCss="truncate"
                  />
                </div>
              </div>
              <div className="flex flex-col gap-4">
                <EditSectionHeader
                  title="Authentication keys"
                  isEditing={isEditing(AuthenticationKeys)}
                  onEdit={() => handleClick(Some(AuthenticationKeys))}
                  onCancel={() => handleClick(None)}
                />
                {if isEditing(AuthenticationKeys) {
                  <ConnectorAuthKeys initialValues showVertically=false />
                } else {
                  <ConnectorHelperV2.PreviewCreds
                    connectorInfo=connectorInfodict
                    connectorAccountFields={connectorAccountFields}
                    customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
                    customElementStyle="px-2 "
                  />
                }}
              </div>
              <RenderIf condition={connectorWebHookDetails->Dict.keysToArray->Array.length > 0}>
                <div className="flex flex-col gap-4">
                  <EditSectionHeader
                    title="Webhook details"
                    isEditing={isEditing(Metadata)}
                    onEdit={() => handleClick(Some(Metadata))}
                    onCancel={() => handleClick(None)}
                  />
                  {isEditing(Metadata)
                    ? <div className="grid grid-cols-2 gap-10 flex-wrap max-w-3xl px-2">
                        <ConnectorWebhookDetails
                          labelTextStyleClass="text-nd_gray-400"
                          labelClass="font-normal"
                          isInEditState=true
                          connectorInfo=connectorInfodict
                        />
                      </div>
                    : <WebhookDetailsView
                        webhookDetails=connectorInfodict.connector_webhook_details
                      />}
                </div>
              </RenderIf>
            </div>
          </Form>
        </div>
      </PageLoaderWrapper>
    </RenderIf>
  }
}

module RetriesConfiguration = {
  open PageLoaderWrapper
  open LogicUtils
  open APIUtils
  @react.component
  let make = (~removeFieldsFromResponse, ~merchantId) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false)
    let showToast = ToastAdapter.useShowToast()
    let (screenState, setScreenState) = React.useState(_ => Loading)
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let (isEditMode, setIsEditMode) = React.useState(_ => false)

    let billingConnectorListFromRecoil = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=BillingProcessor,
    )

    let (connectorID, _) =
      billingConnectorListFromRecoil->BillingProcessorsUtils.getConnectorDetails

    let getConnectorDetails = async () => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Get,
          ~id=Some(connectorID),
        )
        let json = await fetchDetails(connectorUrl, ~version=V2)
        setInitialValues(_ => json->removeFieldsFromResponse)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch details"))
      }
    }

    React.useEffect(() => {
      getConnectorDetails()->ignore
      None
    }, [])

    let connectorInfodict = ConnectorInterface.mapDictToTypedConnectorPayload(
      ConnectorInterface.connectorInterfaceV2,
      initialValues->LogicUtils.getDictFromJsonObject,
    )

    let revenueRecovery =
      connectorInfodict.feature_metadata
      ->getDictFromJsonObject
      ->getDictfromDict("revenue_recovery")
    let max_retry_count = revenueRecovery->getInt("max_retry_count", 0)
    let billing_connector_retry_threshold =
      revenueRecovery->getInt("billing_connector_retry_threshold", 0)

    let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
      try {
        setScreenState(_ => Loading)
        let connectorUrl = getURL(
          ~entityName=V2(V2_CONNECTOR),
          ~methodType=Put,
          ~id=Some(connectorID),
        )
        let dict = RecoveryConnectorUtils.getUpdatableConnectorBody(
          ~valuesDict=values->getDictFromJsonObject,
          ~merchantId,
        )
        let response = await updateAPIHook(connectorUrl, dict->JSON.Encode.object, Put, ~version=V2)
        setInitialValues(_ => response->removeFieldsFromResponse)
        setIsEditMode(_ => false)
        showToast(~message="Retries configuration updated", ~toastType=ToastState.ToastSuccess)
        setScreenState(_ => Success)
      } catch {
      | _ => {
          setScreenState(_ => Success)
          showToast(~message="Failed to update", ~toastType=ToastState.ToastError)
        }
      }
      Nullable.null
    }

    /* mirrors the bounds the onboarding retry step enforces */
    let validateRetryFields = values => {
      let errors = Dict.make()
      let retryValues =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("feature_metadata")
        ->getDictfromDict("revenue_recovery")
      let threshold = retryValues->getInt("billing_connector_retry_threshold", 0)
      let maxRetry = retryValues->getInt("max_retry_count", 0)

      if threshold === 0 {
        errors->Dict.set(
          "feature_metadata.revenue_recovery.billing_connector_retry_threshold",
          "Please enter start retry count"->JSON.Encode.string,
        )
      } else if threshold > 15 {
        errors->Dict.set(
          "feature_metadata.revenue_recovery.billing_connector_retry_threshold",
          "Start retry count should be less than 15"->JSON.Encode.string,
        )
      }

      if maxRetry === 0 {
        errors->Dict.set(
          "feature_metadata.revenue_recovery.max_retry_count",
          "Please enter max retry count"->JSON.Encode.string,
        )
      } else if maxRetry > 15 {
        errors->Dict.set(
          "feature_metadata.revenue_recovery.max_retry_count",
          "Max retry count should be less than 15"->JSON.Encode.string,
        )
      }

      errors->JSON.Encode.object
    }

    let startOfRecoveryInfo =
      <ToolTip
        toolTipPosition=Top
        description="After how many external retries (retries done by the billing engine) should the recovery process start"
        toolTipFor={<Icon name="info-circle-unfilled" size=14 />}
      />

    let totalRetriesInfo =
      <ToolTip
        toolTipPosition=Top
        description="The total number of retries, including external retries, that should be done within the grace period"
        toolTipFor={<Icon name="info-circle-unfilled" size=14 />}
      />

    let retryField = (~label, ~name, ~placeholder, ~customLabelIcon=?) =>
      FormRenderer.makeFieldInfo(
        ~label,
        ~customLabelIcon?,
        ~name,
        ~placeholder,
        ~customInput=InputFields.numericTextInput(~customStyle="rounded-xl"),
        ~isRequired=true,
      )

    <PageLoaderWrapper screenState>
      <Form onSubmit initialValues validate=validateRetryFields>
        <div className="flex flex-col gap-7">
          <div className="flex justify-end px-2">
            <div className="flex gap-4">
              <RenderIf condition={isEditMode}>
                <Button
                  text="Cancel"
                  onClick={_ => setIsEditMode(_ => false)}
                  buttonType={Secondary}
                  buttonSize={Small}
                  customButtonStyle="w-fit"
                />
                <FormRenderer.SubmitButton
                  text="Save" buttonSize={Small} customSubmitButtonStyle="w-fit"
                />
              </RenderIf>
              <RenderIf condition={!isEditMode}>
                <div
                  className="flex gap-2 items-center cursor-pointer"
                  onClick={_ => setIsEditMode(_ => true)}>
                  <Icon name="nd-edit" size=14 />
                  <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
                </div>
              </RenderIf>
            </div>
          </div>
          <div className="grid grid-cols-2 px-2 gap-10 max-w-3xl">
            <div className="flex flex-col gap-2 ">
              <RenderIf condition={!isEditMode}>
                <div className="flex gap-2 items-center">
                  <h4 className="text-nd_gray-400 "> {"Start of recovery"->React.string} </h4>
                  {startOfRecoveryInfo}
                </div>
              </RenderIf>
              <RenderIf condition={isEditMode}>
                <FormRenderer.FieldRenderer
                  labelClass="!font-normal !text-nd_gray-400"
                  field={retryField(
                    ~label="Start of recovery",
                    ~customLabelIcon=startOfRecoveryInfo,
                    ~name="feature_metadata.revenue_recovery.billing_connector_retry_threshold",
                    ~placeholder="ex 3",
                  )}
                />
              </RenderIf>
              <RenderIf condition={!isEditMode}>
                {billing_connector_retry_threshold->Int.toString->React.string}
              </RenderIf>
            </div>
            <div className="flex flex-col gap-2 ">
              <RenderIf condition={!isEditMode}>
                <div className="flex gap-2 items-center">
                  <h4 className="text-nd_gray-400 "> {"Total retries"->React.string} </h4>
                  {totalRetriesInfo}
                </div>
              </RenderIf>
              <RenderIf condition={isEditMode}>
                <FormRenderer.FieldRenderer
                  labelClass="!font-normal !text-nd_gray-400"
                  field={retryField(
                    ~label="Total retries",
                    ~customLabelIcon=totalRetriesInfo,
                    ~name="feature_metadata.revenue_recovery.max_retry_count",
                    ~placeholder="ex 15",
                  )}
                />
              </RenderIf>
              <RenderIf condition={!isEditMode}>
                {max_retry_count->Int.toString->React.string}
              </RenderIf>
            </div>
            /* not editable until the backend accepts updates for these two */
            <div className="flex flex-col gap-2 ">
              <h4 className="text-nd_gray-400 "> {"Partial Authorization"->React.string} </h4>
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~label="",
                  ~name="feature_metadata.revenue_recovery.partial_auth_enabled",
                  ~customInput=InputFields.switchInput(~isDisabled=true),
                  ~isRequired=false,
                )}
              />
            </div>
            <div className="flex flex-col gap-2 ">
              <h4 className="text-nd_gray-400 "> {"Grace Period"->React.string} </h4>
              <p> {"30 days"->React.string} </p>
            </div>
          </div>
        </div>
      </Form>
    </PageLoaderWrapper>
  }
}

@react.component
let make = () => {
  open LogicUtils
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let (paymentConnectorId, setPaymentConnectorId) = React.useState(_ => "")
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let billingConnectorListFromRecoil = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=BillingProcessor,
  )
  let (billingConnectorId, billingConnectorName) =
    billingConnectorListFromRecoil->BillingProcessorsUtils.getConnectorDetails

  let removeFieldsFromResponse = json => {
    let dict = json->getDictFromJsonObject
    dict->Dict.delete("applepay_verified_domains")
    dict->Dict.delete("business_country")
    dict->Dict.delete("business_label")
    dict->Dict.delete("business_sub_label")
    dict->JSON.Encode.object
  }

  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let tabs: array<Tabs.tab> = [
    {
      title: "Processor details",
      renderContent: () => {
        <div className="flex flex-col gap-20 mt-10">
          <BillingConnectorDetails removeFieldsFromResponse merchantId setPaymentConnectorId />
          <RenderIf condition={billingConnectorId->isNonEmptyString}>
            <RecoveryPaymentProcessorsSection
              billingConnectorId
              billingConnectorName
              merchantId
              selectedProcessorId=paymentConnectorId
              onSelectProcessor={id => setPaymentConnectorId(_ => id)}
            />
          </RenderIf>
          <PaymentConnectorDetails
            connectorId=paymentConnectorId removeFieldsFromResponse merchantId
          />
        </div>
      },
    },
  ]

  // TODO: remove once we have upload file flow on prod
  if !isLiveMode {
    tabs->Array.push({
      title: "Retries Configuration",
      renderContent: () => {
        <div className="flex flex-col gap-20 mt-10">
          <RetriesConfiguration removeFieldsFromResponse merchantId />
        </div>
      },
    })
  }

  /* other billers keep their webhook setup on their own platform, only custom
   billing has nothing external to hold it */
  if (
    billingConnectorName->ConnectorUtils.getConnectorNameTypeFromString(
      ~connectorType=BillingProcessor,
    ) == BillingProcessor(CUSTOMBILLING)
  ) {
    tabs->Array.push({
      title: "Webhooks",
      renderContent: () => {
        <div className="flex flex-col gap-20 mt-10">
          <WebhooksConfiguration />
        </div>
      },
    })
  }

  <div className="flex flex-col -ml-2">
    <div className="flex justify-between px-2 items-end">
      <PageUtils.PageHeading title="Configuration" />
    </div>
    <Tabs tabs initialIndex={tabIndex} onTitleClick={index => setTabIndex(_ => index)} />
  </div>
}
