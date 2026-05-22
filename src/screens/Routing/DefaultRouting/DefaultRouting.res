open APIUtils

@react.component
let make = (~urlEntityName, ~baseUrlForRedirection, ~connectorVariant) => {
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (gateways, setGateways) = React.useState(() => [])
  let (defaultRoutingResponse, setDefaultRoutingResponse) = React.useState(_ => [])
  let modalObj = RoutingUtils.getModalObj(DEFAULTFALLBACK, "default")
  let typedConnectorValue = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=connectorVariant,
  )
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let settingUpConnectorsState = routingRespArray => {
    let profileList =
      routingRespArray->Array.filter(value =>
        value->getDictFromJsonObject->getString("profile_id", "") === profileId
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
  }, [profileId])

  let handleChangeOrder = async () => {
    try {
      // TODO : change
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultPayload = gateways
      let defaultFallbackUpdateUrl = `${getURL(
          ~entityName=urlEntityName,
          ~methodType=Post,
        )}/profile/${profileId}`

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

  <div>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound message="Please connect at least 1 connector" renderType=Painting />}>
      <div className="flex flex-col gap-6 my-6">
        <div className="flex flex-col gap-2">
          <h1 className="text-2xl font-semibold text-jp-gray-900 dark:text-jp-gray-100">
            {React.string("Default Fallback")}
          </h1>
          <p className="text-base text-jp-gray-700 dark:text-jp-gray-500">
            {React.string(
              "Set which payment gateway should be tried first, second, and so on. Simply reorder them with drag and drop.",
            )}
          </p>
        </div>
        <AlertV2Binding
          alertType=Primary
          description="By default, payments are routed in the order shown here i.e. top to bottom. To change the priority, just drag and drop the processors to reorder them."
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
              className={`bg-white border border-jp-gray-300 rounded-lg p-4 shadow-sm ${dragStyle}`}>
              <div className="flex flex-row items-center gap-4">
                <Icon name="nd-grip-vertical" size=20 className={"cursor-pointer"} />
                <TagBinding
                  text={Int.toString(index + 1)}
                  variant=TagBinding.Subtle
                  size=TagBinding.Xs
                  color=TagBinding.Primary
                />
                <div className="flex gap-2 items-center">
                  <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-6 h-6" />
                  <p className="text-sm text-jp-gray-900 dark:text-jp-gray-100">
                    {connectorName->capitalizeString->React.string}
                  </p>
                  <p className="text-sm opacity-50"> {`(${connectorLabel})`->React.string} </p>
                </div>
              </div>
            </div>
          }
          <div className="border border-jp-gray-300 bg-nd_gray-25 rounded-lg p-4 max-w-[700px]">
            <DragDropComponent
              listItems=gateways
              setListItems={v => setGateways(_ => v)}
              keyExtractor
              isHorizontal=false
              gap="gap-4"
            />
          </div>
        }
        <p className="text-sm text-jp-gray-700 ">
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
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
