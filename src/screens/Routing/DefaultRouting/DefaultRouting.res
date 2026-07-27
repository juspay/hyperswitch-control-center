open APIUtils
open Typography

@react.component
let make = (~urlEntityName, ~baseUrlForRedirection, ~connectorVariant) => {
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
  let (profile, setProfile) = React.useState(_ => profileId)
  let showToast = ToastAdapter.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (gateways, setGateways) = React.useState(() => [])
  let (defaultRoutingResponse, setDefaultRoutingResponse) = React.useState(_ => [])
  let modalObj = RoutingUtils.getModalObj(DEFAULTFALLBACK, "default")
  let typedConnectorValue = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=connectorVariant,
  )
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let alertCopy = switch connectorVariant {
  | ConnectorTypes.PayoutProcessor => "By default, payouts are routed in the order shown here i.e. top to bottom. To change the priority, just drag and drop the processors to reorder them."
  | _ => "By default, payments are routed in the order shown here i.e. top to bottom. To change the priority, just drag and drop the processors to reorder them."
  }

  let connectorPath = switch connectorVariant {
  | ConnectorTypes.PayoutProcessor => "/payoutconnectors"
  | _ => "/connectors"
  }

  let settingUpConnectorsState = routingRespArray => {
    let profileList =
      routingRespArray->Array.filter(value =>
        value->getDictFromJsonObject->getString("profile_id", "") === profile
      )

    let connectorList = switch profileList->Array.get(0) {
    | Some(json) =>
      json
      ->getDictFromJsonObject
      ->getArrayFromDict("connectors", [])
    | _ => routingRespArray
    }

    if connectorList->Array.length > 0 {
      setGateways(_ => connectorList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let getConnectorsList = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultFallbackUrl = `${getURL(~entityName=urlEntityName, ~methodType=Get)}/profile`
      let response = await fetchDetails(defaultFallbackUrl)
      let routingRespArray = response->getArrayFromJson([])
      setDefaultRoutingResponse(_ => routingRespArray)
      settingUpConnectorsState(routingRespArray)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getConnectorsList()->ignore
    None
  }, [])

  React.useEffect(() => {
    if defaultRoutingResponse->Array.length > 0 {
      settingUpConnectorsState(defaultRoutingResponse)
    }
    None
  }, [profile])

  let handleChangeOrder = async () => {
    try {
      // TODO : change
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultPayload = gateways
      let defaultFallbackUpdateUrl = `${getURL(
          ~entityName=urlEntityName,
          ~methodType=Post,
        )}/profile/${profile}`

      (
        await updateDetails(defaultFallbackUpdateUrl, defaultPayload->JSON.Encode.array, Post)
      )->ignore
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}/default`),
      )
      setScreenState(_ => PageLoaderWrapper.Success)
      showToast(~message="Configuration saved successfully!", ~toastType=ToastState.ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }->ignore
  }
  let openConfirmationPopUp = _ => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: modalObj.conType,
      description: modalObj.conText,
      handleConfirm: {text: "Yes, save it", onClick: _ => handleChangeOrder()->ignore},
      handleCancel: {text: "No, don't save"},
    })
  }

  <PageLoaderWrapper
    screenState
    customUI={<div className="mt-2 mb-6">
      <RoutingHelper.NoProcessorFound
        connectorPath subtitle="Please connect at least 1 connector to manage this configuration."
      />
    </div>}>
    <div className="flex flex-col gap-6 my-6">
      <Form initialValues={Dict.make()->JSON.Encode.object}>
        <div className="w-full md:w-1/2 lg:w-1/3">
          <BasicDetailsForm.BusinessProfileInp
            setProfile
            profile
            options={MerchantAccountUtils.businessProfileNameDropDownOption(
              businessProfileRecoilVal,
            )}
            label="Profile"
          />
        </div>
      </Form>
      <AlertV2Binding
        alertType=Primary
        slot={{slot: <Icon name="nd-info-circle" size=20 className="text-nd_primary_blue-500" />}}
        description=alertCopy
      />
      {
        let keyExtractor = (index, gateway: JSON.t, isDragging, _) => {
          let dragStyle = isDragging ? "shadow-lg" : ""

          let connectorName = gateway->getDictFromJsonObject->getString("connector", "")
          let merchantConnectorId =
            gateway->getDictFromJsonObject->getString("merchant_connector_id", "")
          let connectorLabel = ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
            typedConnectorValue,
            merchantConnectorId,
            ~version=V1,
          ).connector_label

          <div
            className={`bg-nd_gray-0 border border-nd_gray-150 rounded-lg p-4 shadow-sm ${dragStyle}`}>
            <div className="flex flex-row items-center gap-4">
              <Icon name="nd-grip-vertical" size=20 className="cursor-pointer text-nd_gray-400" />
              <TagBinding text={Int.toString(index + 1)} variant=Subtle size=Xs color=Primary />
              <div className="flex gap-2 items-center">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-6 h-6" />
                <p className={`${body.md.medium} text-nd_gray-700`}>
                  {connectorName->capitalizeString->React.string}
                </p>
                <p className={`${body.sm.medium} text-nd_gray-400`}>
                  {`(${connectorLabel})`->React.string}
                </p>
              </div>
            </div>
          </div>
        }
        <div className="border border-nd_gray-150 bg-nd_gray-25 rounded-lg p-4 max-w-700">
          <DragDropComponent
            listItems=gateways
            setListItems={v => setGateways(_ => v)}
            keyExtractor
            isHorizontal=false
            gap="gap-4"
          />
        </div>
      }
      <p className={`${body.md.regular} text-nd_gray-500`}>
        {React.string(
          "This rule is enabled by default and acts as a fallback, it's used only when no other configuration fails or matches.",
        )}
      </p>
      <ACLButton
        onClick={_ => {
          openConfirmationPopUp()
        }}
        text="Save Changes"
        buttonSize=Large
        buttonType=Primary
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        buttonState={gateways->Array.length > 0 ? Button.Normal : Button.Disabled}
        customButtonStyle="ml-1"
      />
    </div>
  </PageLoaderWrapper>
}
