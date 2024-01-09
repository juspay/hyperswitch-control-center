module InfoField = {
  @react.component
  let make = (~render, ~label) => {
    let str = render->Belt.Option.getWithDefault("")

    <UIUtils.RenderIf condition={str->String.length > 0}>
      <div>
        <h2 className="text-lg font-semibold"> {label->React.string} </h2>
        <h3 className=" break-words"> {str->React.string} </h3>
      </div>
    </UIUtils.RenderIf>
  }
}

module KeyAndCopyArea = {
  @react.component
  let make = (~copyValue) => {
    let showToast = ToastState.useShowToast()
    <div className={`flex flex-col md:flex-row gap-2 items-start`}>
      <p className="text-base text-grey-700 opacity-70 break-all overflow-scroll">
        {copyValue->React.string}
      </p>
      <div
        className="cursor-pointer h-20 w-20 pt-1"
        onClick={_ => {
          Clipboard.writeText(copyValue)
          showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
        }}>
        <img src={`/assets/CopyToClipboard.svg`} />
      </div>
    </div>
  }
}

module MenuOption = {
  open HeadlessUI
  @react.component
  let make = (
    ~updateStepValue=ConnectorTypes.IntegFields,
    ~setCurrentStep,
    ~disableConnector,
    ~isConnectorDisabled,
    ~pageName="connector",
  ) => {
    let showPopUp = PopUpState.useShowPopUp()
    let openConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action ? ",
        description: `You are about to ${isConnectorDisabled
            ? "Enable"
            : "Disable"->String.toLowerCase} this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => disableConnector(isConnectorDisabled)->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }

    let connectorStatusAvailableToSwitch = isConnectorDisabled ? "Enable" : "Disable"

    <Popover \"as"="div" className="relative inline-block text-left">
      {popoverProps => <>
        <Popover.Button> {buttonProps => <Icon name="menu-option" size=28 />} </Popover.Button>
        <Popover.Panel className="absolute z-20 right-0">
          {panelProps => {
            <div
              id="neglectTopbarTheme"
              className="relative flex flex-col bg-white py-3 overflow-hidden rounded ring-1 ring-black ring-opacity-5 w-40">
              {<>
                <Navbar.MenuOption
                  text="Update"
                  onClick={_ => {
                    setCurrentStep(_ => updateStepValue)
                  }}
                />
                <Navbar.MenuOption
                  text={connectorStatusAvailableToSwitch}
                  onClick={_ => {
                    openConfirmationPopUp()
                  }}
                />
              </>}
            </div>
          }}
        </Popover.Panel>
      </>}
    </Popover>
  }
}
module ConnectorSummaryGrid = {
  open PageLoaderWrapper
  @react.component
  let make = (
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~connector,
    ~isPayoutFlow,
    ~setScreenState,
  ) => {
    let businessProfiles = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
    let arrayOfBusinessProfile = businessProfiles->MerchantAccountUtils.getArrayOfBusinessProfile
    let currentProfileName =
      arrayOfBusinessProfile
      ->Array.find((ele: HSwitchSettingTypes.profileEntity) =>
        ele.profile_id === connectorInfo.profile_id
      )
      ->Belt.Option.getWithDefault(defaultBusinessProfile)
    let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
    let copyValueOfWebhookEndpoint = ConnectorUtils.getWebhooksUrl(
      ~connectorName={connectorInfo.merchant_connector_id},
      ~merchantId,
    )
    let connectorDetails = React.useMemo1(() => {
      try {
        if connector->String.length > 0 {
          let dict = isPayoutFlow
            ? Window.getPayoutConnectorConfig(connector)
            : Window.getConnectorConfig(connector)
          setScreenState(_ => Success)
          dict
        } else {
          Dict.make()->Js.Json.object_
        }
      } catch {
      | Js.Exn.Error(e) => {
          Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
          let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
          setScreenState(_ => PageLoaderWrapper.Error(err))
          Dict.make()->Js.Json.object_
        }
      }
    }, [connector])
    let (_, connectorAccountFields, _, _, _, _) = ConnectorUtils.getConnectorFields(
      connectorDetails,
    )

    <div className="p-2 md:px-10">
      <div className="grid grid-cols-4 my-12">
        <h4 className="text-lg font-semibold"> {"Integration status"->React.string} </h4>
        <div
          className={`text-black font-semibold text-sm ${connectorInfo.status->ConnectorTableUtils.connectorStatusStyle}`}>
          {connectorInfo.status->String.toUpperCase->React.string}
        </div>
      </div>
      <div className="grid grid-cols-4 my-12">
        <div className="flex items-start">
          <h4 className="text-lg font-semibold"> {"Webhook Endpoint"->React.string} </h4>
          <ToolTip
            height=""
            description="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
            toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
            toolTipPosition=Top
            tooltipWidthClass="w-fit"
          />
        </div>
        <div className="col-span-3">
          <KeyAndCopyArea copyValue={copyValueOfWebhookEndpoint} />
        </div>
      </div>
      <div className="grid grid-cols-4 my-12">
        <h4 className="text-lg font-semibold"> {"Profile"->React.string} </h4>
        <div className="col-span-3">
          {`${currentProfileName.profile_name} - ${connectorInfo.profile_id}`->React.string}
        </div>
      </div>
      <div className="grid grid-cols-4  my-12">
        <h4 className="text-lg font-semibold"> {"API Keys"->React.string} </h4>
        <div className="flex flex-col gap-6 col-span-3">
          {connectorAccountFields
          ->Dict.keysToArray
          ->Array.mapWithIndex((field, index) => {
            open LogicUtils
            let label = connectorAccountFields->getString(field, "")
            <InfoField
              key={index->string_of_int}
              label={label}
              render={connectorInfo->ConnectorUtils.getConnectorDetailsValue(field)}
            />
          })
          ->React.array}
        </div>
      </div>
      <div className="grid grid-cols-4  my-12">
        <h4 className="text-lg font-semibold"> {"PMTs"->React.string} </h4>
        <div className="flex flex-col gap-6 col-span-3">
          {connectorInfo.payment_methods_enabled
          ->Array.mapWithIndex((field, index) => {
            <InfoField
              key={index->string_of_int}
              label={field.payment_method->LogicUtils.snakeToTitle}
              render={Some(
                field.payment_method_types
                ->Array.map(item => item.payment_method_type->LogicUtils.snakeToTitle)
                ->Array.reduce([], (acc, curr) => {
                  if !(acc->Array.includes(curr)) {
                    acc->Array.push(curr)
                  }
                  acc
                })
                ->Array.joinWith(", "),
              )}
            />
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~connectorInfo,
  ~currentStep: ConnectorTypes.steps,
  ~setCurrentStep,
  ~isUpdateFlow,
  ~isPayoutFlow,
  ~showMenuOption=true,
) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  open APIUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let {setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let connectorInfo =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorTableUtils.getProcessorPayloadType
  let connectorCount = ListHooks.useListCount(~entityName=CONNECTOR)
  let isFeedbackModalToBeOpen =
    featureFlagDetails.feedback &&
    !isUpdateFlow &&
    connectorCount <= HSwitchUtils.feedbackModalOpenCountForConnectors
  let redirectPath = switch url.path {
  | list{"payoutconnectors", _} => "/payoutconnectors"
  | _ => "/connectors"
  }

  let isConnectorDisabled = connectorInfo.disabled
  let disableConnector = async isConnectorDisabled => {
    try {
      let connectorID = connectorInfo.merchant_connector_id
      let disableConnectorPayload = ConnectorUtils.getDisableConnectorPayload(
        connectorInfo.connector_type,
        isConnectorDisabled,
      )
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(connectorID), ())
      let _ = await updateDetails(url, disableConnectorPayload->Js.Json.object_, Post)
      showToast(~message=`Successfully Saved the Changes`, ~toastType=ToastSuccess, ())
      RescriptReactRouter.push("/connectors")
    } catch {
    | Js.Exn.Error(_) =>
      showToast(~message=`Failed to Disable connector!`, ~toastType=ToastError, ())
    }
  }

  let connectorStatusStyle = connectorStatus =>
    switch connectorStatus {
    | false => "border bg-green-600 bg-opacity-40 border-green-700 text-green-800"
    | _ => "border bg-red-600 bg-opacity-40 border-red-400 text-red-500"
    }

  <PageLoaderWrapper screenState>
    <div>
      <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon
            gateway={connectorInfo.connector_name->String.toUpperCase} className="w-14 h-14"
          />
          <h2 className="text-xl font-semibold">
            {connectorInfo.connector_name->LogicUtils.capitalizeString->React.string}
          </h2>
        </div>
        <div className="self-center">
          {switch currentStep {
          | Preview =>
            <div className="flex gap-6 items-center">
              <div
                className={`px-4 py-2 rounded-full w-fit font-medium text-sm !text-black ${isConnectorDisabled->connectorStatusStyle}`}>
                {(isConnectorDisabled ? "DISABLED" : "ENABLED")->React.string}
              </div>
              <UIUtils.RenderIf condition={showMenuOption}>
                <MenuOption setCurrentStep disableConnector isConnectorDisabled />
              </UIUtils.RenderIf>
            </div>

          | _ =>
            <Button
              onClick={_ => {
                if isFeedbackModalToBeOpen {
                  setShowFeedbackModal(_ => true)
                }
                RescriptReactRouter.push(redirectPath)
              }}
              text="Done"
              buttonType={Primary}
            />
          }}
        </div>
      </div>
      <ConnectorSummaryGrid connectorInfo connector isPayoutFlow setScreenState />
    </div>
  </PageLoaderWrapper>
}
