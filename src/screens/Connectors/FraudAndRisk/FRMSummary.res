module InfoField = {
  open LogicUtils
  @react.component
  let make = (~label, ~flowTypeValue) => {
    <div className="flex flex-col gap-2 mb-7">
      <h4 className="text-lg font-semibold underline"> {label->snakeToTitle->React.string} </h4>
      <div className="flex flex-col gap-1">
        <h3 className="break-all">
          <span className="font-semibold mr-3"> {"Flow :"->React.string} </span>
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
      <div className="grid grid-cols-2 md:w-1/2 ml-12 my-12" key={i->Int.toString}>
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
let make = (~initialValues, ~currentStep) => {
  open LogicUtils
  open FRMUtils
  open APIUtils
  open ConnectorTypes
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()

  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let frmInfo = initialValues->getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let isfrmDisabled = initialValues->getDictFromJsonObject->getBool("disabled", false)

  let frmConfigs = switch frmInfo.frm_configs {
  | Some(config) => config
  | _ => []
  }

  let disableFRM = async isFRMDisabled => {
    try {
      let frmID = initialValues->getDictFromJsonObject->getString("merchant_connector_id", "")
      let disableFRMPayload = initialValues->FRMTypes.getDisableConnectorPayload(isFRMDisabled)
      let url = getURL(~entityName=FRAUD_RISK_MANAGEMENT, ~methodType=Post, ~id=Some(frmID))
      let _ = await updateDetails(url, disableFRMPayload->JSON.Encode.object, Post)
      showToast(~message=`Successfully Saved the Changes`, ~toastType=ToastSuccess)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/fraud-risk-management"))
    } catch {
    | Exn.Error(_) => showToast(~message=`Failed to Disable connector!`, ~toastType=ToastError)
    }
  }

  <div>
    <div className="flex justify-between border-b sticky top-0 bg-white pb-2">
      <div className="flex gap-2 items-center">
        <GatewayIcon gateway={String.toUpperCase(frmInfo.connector_name)} className=size />
        <h2 className="text-xl font-semibold">
          {frmInfo.connector_name->capitalizeString->React.string}
        </h2>
      </div>
      {switch currentStep {
      | Preview =>
        <div className="flex gap-6 items-center">
          <p
            className={`text-fs-13 font-bold ${isfrmDisabled ? "text-red-800" : "text-green-700"}`}>
            {(isfrmDisabled ? "INACTIVE" : "ACTIVE")->React.string}
          </p>
          <ConnectorPreview.MenuOption
            updateStepValue={ConnectorTypes.PaymentMethods}
            disableConnector={disableFRM}
            isConnectorDisabled={isfrmDisabled}
            pageName={url.path->LogicUtils.getListHead}
          />
        </div>
      | _ =>
        <Button
          onClick={_ => {
            mixpanelEvent(~eventName="frm_step3")
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/fraud-risk-management"))
          }}
          text="Done"
          buttonType={Primary}
        />
      }}
    </div>
    <div>
      <div className="grid grid-cols-2 md:w-1/2 m-12">
        <h4 className="text-lg font-semibold"> {"Profile id"->React.string} </h4>
        <div> {frmInfo.profile_id->React.string} </div>
      </div>
      <RenderIf condition={frmConfigs->Array.length > 0}>
        <ConfigInfo frmConfigs />
      </RenderIf>
    </div>
  </div>
}
