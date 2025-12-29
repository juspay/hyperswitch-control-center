type connectorSummarySection = AuthenticationKeys | Metadata | PMTs | PaymentConnectors
open Typography

module WebhooksConfiguration = {
  @react.component
  let make = () => {
    open APIUtils
    open FormRenderer

    let getURL = useGetURL()
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId(
      ~version=UserInfoTypes.V2,
    )
    let {state: {commonInfo: {profileId}}} = React.useContext(UserInfoProvider.defaultContext)
    let businessProfileRecoilVal =
      HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let (isEditMode, setIsEditMode) = React.useState(_ => false)
    let (merchantBusinessProfileInfo, setMerchantBusinessProfileInfo) = React.useState(() =>
      JSON.Encode.null->BusinessProfileInterfaceUtilsV2.mapJsonToBusinessProfileV2
    )

    let onSubmit = async (values, _) => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=V2(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
        let _ = await updateDetails(url, values, Put, ~version=V2)
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
        setIsEditMode(_ => false)

        showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Success)
          showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
        }
      }
      Nullable.null
    }

    let getMerchantDetails = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let profile = await fetchBusinessProfileFromId(~profileId=Some(profileId))
        setMerchantBusinessProfileInfo(_ =>
          profile->BusinessProfileInterfaceUtilsV2.mapJsonToBusinessProfileV2
        )
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Success)
      }
    }

    React.useEffect(() => {
      getMerchantDetails()->ignore
      None
    }, [])

    let webhookUrl = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="webhook_details.webhook_url",
      ~placeholder="Enter Webhook URL",
      ~customInput=InputFields.textInput(
        ~autoComplete="off",
        ~customStyle="rounded-xl",
        ~isDisabled={!isEditMode},
      ),
      ~isRequired=false,
    )

    let paymentResponseHashKey =
      merchantBusinessProfileInfo.payment_response_hash_key->Option.getOr("")

    <PageLoaderWrapper screenState sectionHeight="h-28">
      <Form
        initialValues={businessProfileRecoilVal
        ->PaymentSettingsV2Utils.parseBusinessProfileForPaymentBehaviour
        ->Identity.genericTypeToJson}
        onSubmit
        validate={values => {
          PaymentSettingsV2Utils.validateMerchantAccountFormV2(
            ~values,
            ~isLiveMode=featureFlagDetails.isLiveMode,
            ~businessProfileRecoilVal,
          )
        }}>
        <div className="flex flex-col gap-5">
          <div className="flex flex-col gap-1">
            <div className="flex justify-between border-b mt-7 pb-2 items-end">
              <p className={`${heading.sm.semibold}`}> {"Webhook URL"->React.string} </p>
              <div className="flex gap-4">
                {if isEditMode {
                  <>
                    <Button
                      text="Cancel"
                      onClick={_ => setIsEditMode(_ => false)}
                      buttonType={Secondary}
                      buttonSize={Small}
                      customButtonStyle="w-fit"
                    />
                    <FormRenderer.SubmitButton
                      text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
                    />
                  </>
                } else {
                  <div
                    className="flex gap-2 items-center cursor-pointer"
                    onClick={_ => setIsEditMode(_ => true)}>
                    <Icon name="nd-edit" size=14 />
                    <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
                  </div>
                }}
              </div>
            </div>
            <FieldRenderer
              field={webhookUrl}
              labelClass={`!text-fs-15 !text-grey-700 ${body.md.semibold}`}
              fieldWrapperClass="max-w-md  "
            />
          </div>
          <RenderIf condition={paymentResponseHashKey->String.length !== 0}>
            <div className="flex flex-col gap-1 ">
              <div className="flex justify-between border-b mt-7 pb-2 items-end">
                <p className={`${heading.sm.semibold}`}>
                  {"Payment Response Hash Key"->React.string}
                </p>
              </div>
              <HelperComponents.CopyTextCustomComp
                displayValue={Some(paymentResponseHashKey)}
                customTextCss={`break-all truncate md:whitespace-normal ${body.md.regular} text-nd_gray-800`}
                customParentClass="flex items-center gap-5 mt-3"
                customIconCss="text-jp-gray-700"
              />
            </div>
          </RenderIf>
        </div>
      </Form>
    </PageLoaderWrapper>
  }
}

module BillingConnectorDetails = {
  open PageLoaderWrapper
  open LogicUtils
  open APIUtils
  open ConnectorUtils
  @react.component
  let make = (~removeFieldsFromRespose, ~merchantId, ~setPaymentConnectorId) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (screenState, setScreenState) = React.useState(_ => Loading)
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

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
        setInitialValues(_ => json->removeFieldsFromRespose)
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

    let {connector_name: connectorName, connector_webhook_details} = connectorInfodict

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

    let {connectorAccountFields} = getConnectorFields(connectorDetails)

    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-9">
        <div className="flex justify-between border-b pb-4 px-2 items-end">
          <p className={heading.md.semibold}> {"Billing Platform Details"->React.string} </p>
        </div>
        <div className="grid grid-cols-3 px-2">
          <div className="flex flex-col gap-0.5-rem ">
            <h4 className="text-nd_gray-400 "> {"Biller Platform "->React.string} </h4>
            <div className="flex gap-2 align-center">
              <GatewayIcon
                gateway={connectorName->String.toUpperCase} className=" w-7 h-7 rounded-sm"
              />
              {connectorName->React.string}
            </div>
          </div>
          <RenderIf
            condition={connectorName->getConnectorNameTypeFromString(
              ~connectorType=BillingProcessor,
            ) != BillingProcessor(CUSTOMBILLING)}>
            <ConnectorWebhookPreview merchantId connectorName=connectorInfodict.id />
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
            <div className="mt-5">
              <WebhooksConfiguration />
            </div>
          </div>
        | _ =>
          <>
            <ConnectorHelperV2.PreviewCreds
              connectorInfo=connectorInfodict
              connectorAccountFields
              customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
              customElementStyle="px-2 "
            />
            <div className="grid grid-cols-3 px-2">
              {connector_webhook_details
              ->getDictFromJsonObject
              ->Dict.toArray
              ->Array.mapWithIndex((item, index) => {
                let (key, value) = item

                <div className="flex flex-col gap-0.5-rem " key={index->Int.toString}>
                  <h4 className="text-nd_gray-400 "> {key->snakeToTitle->React.string} </h4>
                  {value->JSON.Decode.string->Option.getOr("")->React.string}
                </div>
              })
              ->React.array}
            </div>
          </>
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
  let make = (~connectorId, ~removeFieldsFromRespose, ~merchantId) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let updateAPIHook = useUpdateMethod(~showErrorToast=false)
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
        setInitialValues(_ => json->removeFieldsFromRespose)
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
        setCurrentActiveSection(_ => None)
        setInitialValues(_ => response->removeFieldsFromRespose)
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
              <div className="flex flex-col gap-0.5-rem ">
                <h4 className="text-nd_gray-400 "> {"Payment Processor"->React.string} </h4>
                <div className="flex gap-2 align-center">
                  <GatewayIcon
                    gateway={connector_name->String.toUpperCase} className=" w-7 h-7 rounded-sm"
                  />
                  {connector_name->React.string}
                </div>
              </div>
              <div className="flex flex-col gap-0.5-rem ">
                <h4 className="text-nd_gray-400 "> {"Processor status"->React.string} </h4>
                <div className="flex flex-row gap-2 items-center ">
                  <ConnectorHelperV2.ProcessorStatus connectorInfo=connectorInfodict />
                </div>
              </div>
            </div>
            <div className="flex flex-col gap-12 mt-7">
              <div className="grid grid-cols-3 px-2">
                <div className="flex flex-col gap-0.5-rem ">
                  <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
                  {connectorInfodict.profile_id->React.string}
                </div>
                <ConnectorWebhookPreview merchantId connectorName=connectorInfodict.id />
              </div>
              <div className="flex flex-col gap-4">
                <div className="flex justify-between border-b pb-4 px-2 items-end">
                  <p className={`${heading.sm.semibold} text-nd_gray-600`}>
                    {"Authentication keys"->React.string}
                  </p>
                </div>
                <ConnectorHelperV2.PreviewCreds
                  connectorInfo=connectorInfodict
                  connectorAccountFields={connectorAccountFields}
                  customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
                  customElementStyle="px-2 "
                />
              </div>
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
  let make = (~removeFieldsFromRespose) => {
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (screenState, setScreenState) = React.useState(_ => Loading)
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

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
        setInitialValues(_ => json->removeFieldsFromRespose)
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

    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-7">
        <div className="flex justify-between border-b pb-4 px-2 items-end">
          <p className={heading.md.semibold}> {"Retries configuration"->React.string} </p>
        </div>
        <div className="grid grid-cols-3 px-2">
          <div className="flex flex-col gap-0.5-rem ">
            <h4 className="text-nd_gray-400 "> {"Connector Retry Threshold"->React.string} </h4>
            {billing_connector_retry_threshold->Int.toString->React.string}
          </div>
          <div className="flex flex-col gap-0.5-rem ">
            <h4 className="text-nd_gray-400 "> {"Max Retry Count"->React.string} </h4>
            {max_retry_count->Int.toString->React.string}
          </div>
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = () => {
  open LogicUtils
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
  let (paymentConnectorId, setPaymentConnectorId) = React.useState(_ => "")
  let {state: {commonInfo: {merchantId}}} = React.useContext(UserInfoProvider.defaultContext)

  let removeFieldsFromRespose = json => {
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
          <BillingConnectorDetails removeFieldsFromRespose merchantId setPaymentConnectorId />
          <PaymentConnectorDetails
            connectorId=paymentConnectorId removeFieldsFromRespose merchantId
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
          <RetriesConfiguration removeFieldsFromRespose />
        </div>
      },
    })
  }

  <div className="flex flex-col -ml-2">
    <div className="flex justify-between px-2 items-end">
      <PageUtils.PageHeading title="Configuration" />
    </div>
    <Tabs
      tabs
      showBorder=true
      includeMargin=false
      initialIndex={tabIndex}
      onTitleClick={index => setTabIndex(_ => index)}
      selectTabBottomBorderColor="bg-nd_primary_blue-500"
    />
  </div>
}
