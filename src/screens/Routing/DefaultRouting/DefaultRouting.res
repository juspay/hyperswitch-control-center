open APIUtils
open MerchantAccountUtils

@react.component
let make = (~urlEntityName, ~baseUrlForRedirection, ~connectorVariant) => {
  open LogicUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (profile, setProfile) = React.useState(_ => profileId)
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (gateways, setGateways) = React.useState(() => [])
  let (defaultRoutingResponse, setDefaultRoutingResponse) = React.useState(_ => [])
  let modalObj = RoutingUtils.getModalObj(DEFAULTFALLBACK, "default")
  let typedConnectorValue = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=connectorVariant,
  )
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

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

  <div>
    <Form initialValues={Dict.make()->JSON.Encode.object}>
      <div className="w-full flex justify-between">
        <BasicDetailsForm.BusinessProfileInp
          setProfile={setProfile}
          profile={profile}
          options={businessProfileNameDropDownOption([businessProfileRecoilVal], ~profileId)}
          label="Profile"
        />
      </div>
    </Form>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound message="Please connect atleast 1 connector" renderType=Painting />}>
      <div
        className="flex flex-col gap-4 p-6 my-6 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
        <div className="flex flex-col lg:flex-row ">
          <div>
            <div className="font-bold mb-1"> {React.string("Default Fallback")} </div>
            <div className="text-jp-gray-800 dark:text-jp-gray-700 text-sm flex flex-col">
              <p>
                {React.string(
                  "Default Fallback is helpful when you wish to define a simple pecking order of priority among the configured connectors. You may add the gateway and do a simple drag and drop.",
                )}
              </p>
              <p> {React.string("For example: 1. Stripe, 2. Adyen, 3.Braintree")} </p>
            </div>
          </div>
        </div>
        {
          let keyExtractor = (index, gateway: JSON.t, isDragging, _) => {
            let style = isDragging ? "border rounded-md bg-jp-gray-100 dark:bg-jp-gray-950" : ""

            let connectorName = gateway->getDictFromJsonObject->getString("connector", "")
            let merchantConnectorId =
              gateway->getDictFromJsonObject->getString("merchant_connector_id", "")
            let connectorLabel = ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
              typedConnectorValue,
              merchantConnectorId,
              ~version=V1,
            ).connector_label

            <div
              className={`h-14 px-3 flex flex-row items-center justify-between text-jp-gray-900 dark:text-jp-gray-600 border-jp-gray-500 dark:border-jp-gray-960
            ${index !== 0 ? "border-t" : ""} ${style}`}>
              <div className="flex flex-row items-center gap-4 ml-2">
                <Icon name="grip-vertical" size=14 className={"cursor-pointer"} />
                <div
                  className={`px-1.5 rounded-full ${primaryColor} text-white font-semibold text-sm`}>
                  {React.string(Int.toString(index + 1))}
                </div>
                <div className="flex gap-1 items-center">
                  <p> {connectorName->React.string} </p>
                  <p className="text-sm opacity-50 "> {`(${connectorLabel})`->React.string} </p>
                </div>
              </div>
            </div>
          }
          <div className="flex border border-jp-gray-500 dark:border-jp-gray-960 rounded-md ">
            <DragDropComponent
              listItems=gateways
              setListItems={v => setGateways(_ => v)}
              keyExtractor
              isHorizontal=false
            />
          </div>
        }
      </div>
      <ACLButton
        onClick={_ => {
          openConfirmationPopUp()
        }}
        text="Save Changes"
        buttonSize=Small
        buttonType=Primary
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        leftIcon={FontAwesome("check")}
        buttonState={gateways->Array.length > 0 ? Button.Normal : Button.Disabled}
      />
    </PageLoaderWrapper>
  </div>
}
