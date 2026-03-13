module InfoField = {
  open LogicUtils
  open Typography
  @react.component
  let make = (~label, ~flowTypeValue) => {
    <div className="flex flex-col gap-2 mb-7">
      <h4 className={`${body.lg.semibold}`}> {label->snakeToTitle->React.string} </h4>
      <div className="flex flex-col gap-1">
        <h3 className="break-all">
          <span className={`${body.lg.semibold} mr-3`}> {"Flow :"->React.string} </span>
          {flowTypeValue->React.string}
        </h3>
      </div>
    </div>
  }
}

module ConfigInfo = {
  open LogicUtils
  open ConnectorTypes
  open FRMInfo
  @react.component
  let make = (~frmConfigs) => {
    frmConfigs
    ->Array.mapWithIndex((config, i) => {
      <div className="grid grid-cols-4 p-8" key={i->Int.toString}>
        <h4 className="text-lg font-semibold"> {config.gateway->snakeToTitle->React.string} </h4>
        <div>
          {config.payment_methods
          ->Array.mapWithIndex((paymentMethod, ind) => {
            if paymentMethod.payment_method_types->Option.getOr([])->Array.length == 0 {
              <InfoField
                key={ind->Int.toString}
                label={paymentMethod.payment_method}
                flowTypeValue={paymentMethod.flow->getFlowTypeLabel}
              />
            } else {
              paymentMethod.payment_method_types
              ->Option.getOr([])
              ->Array.mapWithIndex(
                (paymentMethodType, index) => {
                  <RenderIf condition={index == 0}>
                    <InfoField
                      key={index->Int.toString}
                      label={paymentMethod.payment_method}
                      flowTypeValue={paymentMethodType.flow->getFlowTypeLabel}
                    />
                  </RenderIf>
                },
              )
              ->React.array
            }
          })
          ->React.array}
        </div>
      </div>
    })
    ->React.array
  }
}

@react.component
let make = (
  ~initialValues,
  ~currentStep,
  ~setInitialValues,
  ~updateMerchantDetails,
  ~isUpdateFlow,
) => {
  open LogicUtils
  open FRMUtils
  open APIUtils
  open ConnectorTypes
  open Typography

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let frmInfo = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV1,
    initialValues->getDictFromJsonObject,
  )
  let (showEditForm, setShowEditForm) = React.useState(_ => false)
  let connectorName = frmInfo.connector_name

  let isfrmDisabled = initialValues->getDictFromJsonObject->getBool("disabled", false)
  let connectorType =
    frmInfo.connector_name->ConnectorUtils.getConnectorNameTypeFromString(~connectorType=FRMPlayer)
  let frmFields = switch connectorType {
  | FRM(frmType) => frmType->ConnectorUtils.getFrmInfo
  | _ => {description: ""}
  }
  let frmConfigs = switch frmInfo.frm_configs {
  | Some(config) => config
  | _ => []
  }

  let connectorAccountFields = {
    let fields = Dict.make()
    frmFields.validate
    ->Option.getOr([])
    ->Array.forEach(field => {
      let fieldName = field.name->String.replace("connector_account_details.", "")
      fields->Dict.set(fieldName, field.label->Option.getOr("")->JSON.Encode.string)
    })
    fields
  }

  let disableFRM = async isFRMDisabled => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let frmID = initialValues->getDictFromJsonObject->getString("merchant_connector_id", "")
      let disableFRMPayload = initialValues->FRMTypes.getDisableConnectorPayload(isFRMDisabled)
      let url = getURL(~entityName=V1(FRAUD_RISK_MANAGEMENT), ~methodType=Post, ~id=Some(frmID))
      let res = await updateDetails(url, disableFRMPayload, Post)
      setInitialValues(_ => res)
      let _ = await fetchConnectorListResponse()
      setScreenState(_ => PageLoaderWrapper.Success)
      showToast(~message=`Successfully Saved the Changes`, ~toastType=ToastSuccess)
    } catch {
    | Exn.Error(_) => showToast(~message=`Failed to Disable connector!`, ~toastType=ToastError)
    }
  }

  <PageLoaderWrapper screenState>
    <div>
      <div className="flex justify-between border-b sticky top-0 bg-white pb-2">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={String.toUpperCase(frmInfo.connector_name)} className=size />
          <h2 className="text-xl font-semibold">
            {frmInfo.connector_name
            ->ConnectorUtils.getDisplayNameForConnector(~connectorType=FRMPlayer)
            ->React.string}
          </h2>
        </div>
        {switch currentStep {
        | Preview =>
          <div className="flex gap-6 items-center">
            <ConnectorPreviewHelper.EnableDisableConnectorToggle
              disableConnector={disableFRM} isConnectorDisabled={isfrmDisabled}
            />
          </div>
        | _ =>
          <Button
            onClick={_ => {
              mixpanelEvent(~eventName="frm_step3")
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(~url="/fraud-risk-management"),
              )
            }}
            text="Done"
            buttonType={Primary}
          />
        }}
      </div>
      <div>
        <div className="grid grid-cols-4 p-8 border-b">
          <h4 className="text-lg font-semibold"> {"Profile id"->React.string} </h4>
          <div> {frmInfo.profile_id->React.string} </div>
        </div>
        <div className="grid grid-cols-4 p-6 border-b">
          <h4 className={`${heading.sm.semibold}`}> {"Credentials"->React.string} </h4>
          <div className="flex flex-col gap-6 col-span-3">
            <div className="flex gap-12">
              <RenderIf condition={!showEditForm}>
                <div className="flex flex-col gap-6 w-5/6 ">
                  <ConnectorPreviewHelper.PreviewCreds
                    connectorAccountFields
                    connectorInfo=frmInfo
                    showConnectorLabelField=false
                    showLabelAndFieldVertically=true
                  />
                </div>
              </RenderIf>
              <RenderIf condition={isUpdateFlow && !showEditForm}>
                <div
                  className="cursor-pointer py-2"
                  onClick={_ => {
                    setShowEditForm(_ => true)
                  }}>
                  <ToolTip
                    height=""
                    description={`Update the ${connectorName} creds`}
                    toolTipFor={<Icon size=18 name="edit" className={`mt-1 ml-1`} />}
                    toolTipPosition=Top
                    tooltipWidthClass="w-fit"
                  />
                </div>
              </RenderIf>
              <RenderIf condition={isUpdateFlow && showEditForm}>
                <FRMUpdateAuthCreds connectorInfo=frmInfo updateMerchantDetails setShowEditForm />
              </RenderIf>
            </div>
          </div>
        </div>
        <RenderIf condition={frmConfigs->Array.length > 0}>
          <ConfigInfo frmConfigs />
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
