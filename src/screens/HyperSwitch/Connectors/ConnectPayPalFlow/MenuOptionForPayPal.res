@react.component
let make = (
  ~updateStepValue=ConnectorTypes.IntegFields,
  ~setCurrentStep,
  ~disableConnector,
  ~isConnectorDisabled,
  ~pageName="connector",
  ~connectorInfoDict,
  ~setScreenState,
  ~isUpdateFlow,
  ~setInitialValues,
) => {
  open HeadlessUI
  open UIUtils
  let showPopUp = PopUpState.useShowPopUp()
  let showToast = ToastState.useShowToast()
  let deleteTrackingDetails = PayPalFlowUtils.useDeleteTrackingDetails()
  let updateConnectorAccountDetails = PayPalFlowUtils.useDeleteConnectorAccountDetails()
  let setSetupAccountStatus = Recoil.useSetRecoilState(HyperswitchAtom.paypalAccountStatusAtom)
  let connectorInfo = connectorInfoDict->ConnectorTableUtils.getProcessorPayloadType

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

  let updateConnectorAuthType = async values => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let res = await updateConnectorAccountDetails(
        values,
        connectorInfo.merchant_connector_id,
        connectorInfo.connector_name,
        isUpdateFlow,
        true,
        "inactive",
      )
      setInitialValues(_ => res)
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getOr("Something went wrong!")
        Js.Exn.raiseError(err)
      }
    }
  }

  let handleNewPayPalAccount = async () => {
    try {
      await deleteTrackingDetails(connectorInfo.merchant_connector_id, connectorInfo.connector_name)
      await updateConnectorAuthType(connectorInfoDict->JSON.Encode.object)
      setCurrentStep(_ => ConnectorTypes.AutomaticFlow)
      setSetupAccountStatus(._ => PayPalFlowTypes.Redirecting_to_paypal)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getOr("Something went wrong!")
        showToast(~message=err, ~toastType=ToastError, ())
      }
    }
  }

  let popupForNewPayPalAccount = _ => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Confirm Action ?",
      description: `By changing this the old account details will be lost `->React.string,
      handleConfirm: {
        text: "Confirm",
        onClick: _ => {
          handleNewPayPalAccount()->ignore
        },
      },
      handleCancel: {text: "Cancel"},
    })
  }

  <Popover \"as"="div" className="relative inline-block text-left">
    {popoverProps => <>
      <Popover.Button> {buttonProps => <Icon name="menu-option" size=28 />} </Popover.Button>
      <Popover.Panel className="absolute z-20 right-0 top-10">
        {panelProps => {
          <div
            id="neglectTopbarTheme"
            className="relative flex flex-col bg-white py-3 overflow-hidden rounded ring-1 ring-black ring-opacity-5 w-max">
            {<>
              <RenderIf
                condition={connectorInfo.connector_account_details.auth_type->ConnectorUtils.mapAuthType ===
                  #SignatureKey}>
                <Navbar.MenuOption
                  text="Create new PayPal account"
                  onClick={_ => {
                    popupForNewPayPalAccount()
                    panelProps["close"]()
                  }}
                />
              </RenderIf>
              <Navbar.MenuOption
                text="Change configurations"
                onClick={_ => {
                  setCurrentStep(_ => ConnectorTypes.AutomaticFlow)
                  setSetupAccountStatus(._ => PayPalFlowTypes.Connect_paypal_landing)
                }}
              />
              <RenderIf
                condition={connectorInfo.connector_account_details.auth_type->ConnectorUtils.mapAuthType ===
                  #BodyKey}>
                <Navbar.MenuOption
                  text="Update"
                  onClick={_ => {
                    setCurrentStep(_ => ConnectorTypes.IntegFields)
                    setSetupAccountStatus(._ => PayPalFlowTypes.Manual_setup_flow)
                  }}
                />
              </RenderIf>
              <RenderIf
                condition={connectorInfo.connector_account_details.auth_type->ConnectorUtils.mapAuthType ===
                  #SignatureKey}>
                <Navbar.MenuOption
                  text="Update Payment Methods"
                  onClick={_ => {
                    setCurrentStep(_ => updateStepValue)
                  }}
                />
              </RenderIf>
              <Navbar.MenuOption
                text={connectorStatusAvailableToSwitch}
                onClick={_ => {
                  panelProps["close"]()
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
