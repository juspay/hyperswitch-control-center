type connectorSummarySection = AuthenticationKeys | Metadata | PMTs | PaymentConnectors

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

    let url = RescriptReactRouter.useUrl()
    let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")

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

    let connectorInfodict = ConnectorInterface.mapDictToConnectorPayload(
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

    let (_, connectorAccountFields, _, _, connectorWebHookDetails, _, _) = getConnectorFields(
      connectorDetails,
    )

    let revenueRecovery =
      connectorInfodict.feature_metadata->getDictFromJsonObject->getDictfromDict("revenue_recovery")
    let max_retry_count = revenueRecovery->getInt("max_retry_count", 0)
    let billing_connector_retry_threshold =
      revenueRecovery->getInt("billing_connector_retry_threshold", 0)

    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-7">
        <div className="flex justify-between border-b pb-4 px-2 items-end">
          <p className="text-lg font-semibold text-nd_gray-600">
            {"Recovery Details"->React.string}
          </p>
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
      <div className="flex flex-col gap-7">
        <div className="flex justify-between border-b pb-4 px-2 items-end">
          <p className="text-lg font-semibold text-nd_gray-600">
            {"Billing Platform Details"->React.string}
          </p>
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
          <ConnectorWebhookPreview merchantId connectorName=connectorInfodict.id />
        </div>
        <ConnectorHelperV2.PreviewCreds
          connectorInfo=connectorInfodict
          connectorAccountFields
          customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl "
          customElementStyle="px-2 "
        />
        <div className="grid grid-cols-3 px-2">
          {connectorWebHookDetails
          ->Dict.toArray
          ->Array.map(item => {
            let (key, value) = item
            <div className="flex flex-col gap-0.5-rem ">
              <h4 className="text-nd_gray-400 "> {key->snakeToTitle->React.string} </h4>
              {value->JSON.Decode.string->Option.getOr("")->React.string}
            </div>
          })
          ->React.array}
        </div>
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

    let connectorInfodict = ConnectorInterface.mapDictToConnectorPayload(
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

    let (
      _,
      connectorAccountFields,
      connectorMetaDataFields,
      _,
      connectorWebHookDetails,
      connectorLabelDetailField,
      _,
    ) = getConnectorFields(connectorDetails)

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
      <PageLoaderWrapper screenState>
        <div className="flex flex-col gap-7">
          <div className="flex justify-between border-b pb-4 px-2 items-end">
            <p className="text-lg font-semibold text-nd_gray-600">
              {"Payment Processor Details"->React.string}
            </p>
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
                  <p className="text-lg font-semibold text-nd_gray-600">
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

@react.component
let make = () => {
  open LogicUtils
  let (paymentConnectorId, setPaymentConnectorId) = React.useState(_ => "")
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let removeFieldsFromRespose = json => {
    let dict = json->getDictFromJsonObject
    dict->Dict.delete("applepay_verified_domains")
    dict->Dict.delete("business_country")
    dict->Dict.delete("business_label")
    dict->Dict.delete("business_sub_label")
    dict->JSON.Encode.object
  }

  <div className="flex flex-col gap-7 p-6">
    <BreadCrumbNavigation
      path=[{title: "Recovery Overview", link: "/v2/recovery/overview"}]
      currentPageTitle="View Details"
      cursorStyle="cursor-pointer"
      customTextClass="text-nd_gray-400"
      titleTextClass="text-nd_gray-600 font-medium"
      fontWeight="font-medium"
      dividerVal=Slash
      childGapClass="gap-2"
    />
    <div className="flex flex-col gap-20 -ml-2">
      <BillingConnectorDetails removeFieldsFromRespose merchantId setPaymentConnectorId />
      <PaymentConnectorDetails connectorId=paymentConnectorId removeFieldsFromRespose merchantId />
    </div>
  </div>
}
