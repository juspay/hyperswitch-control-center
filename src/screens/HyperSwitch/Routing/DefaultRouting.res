open APIUtils
open APIUtilsTypes
open MerchantAccountUtils

@react.component
let make = () => {
  let updateDetails = useUpdateMethod()
  let fetchDetails = useGetMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let businessProfiles = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom
  let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
  let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile
  let (profile, setProfile) = React.useState(_ => defaultBusinessProfile.profile_id)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (gateways, setGateways) = React.useState(() => [])
  let (defaultRoutingResponse, setDefaultRoutingResponse) = React.useState(_ => [])
  let modalObj = RoutingUtils.getModalObj(DEFAULTFALLBACK, "default")

  let settingUpConnectorsState = routingRespArray => {
    let profileList =
      routingRespArray->Array.filter(value =>
        value->LogicUtils.getDictFromJsonObject->LogicUtils.getString("profile_id", "") === profile
      )

    let connectorList =
      profileList
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(Js.Json.null)
      ->LogicUtils.getDictFromJsonObject
      ->LogicUtils.getArrayFromDict("connectors", [])
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
      let defaultFallbackUrl = `${getURL(
          ~entityName=DEFAULT_FALLBACK,
          ~methodType=Get,
          (),
        )}/profile`
      let response = await fetchDetails(defaultFallbackUrl)
      let routingRespArray = response->LogicUtils.getArrayFromJson([])
      setDefaultRoutingResponse(_ => routingRespArray)
      settingUpConnectorsState(routingRespArray)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    getConnectorsList()->ignore
    None
  })

  React.useEffect1(() => {
    if defaultRoutingResponse->Array.length > 0 {
      settingUpConnectorsState(defaultRoutingResponse)
    }
    None
  }, [profile])

  let handleChangeOrder = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let defaultPayload = gateways
      let defaultFallbackUpdateUrl = `${getURL(
          ~entityName=DEFAULT_FALLBACK,
          ~methodType=Post,
          (),
        )}/profile/${profile}`
      (await updateDetails(defaultFallbackUpdateUrl, defaultPayload->Js.Json.array, Post))->ignore
      RescriptReactRouter.replace(`/routing/default`)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
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
    <Form initialValues={Dict.make()->Js.Json.object_}>
      <div className="w-full flex justify-between">
        <BasicDetailsForm.BusinessProfileInp
          setProfile={setProfile}
          profile={profile}
          options={arrayOfBusinessProfile->businessProfileNameDropDownOption}
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
          let keyExtractor = (index, gateway: Js.Json.t, isDragging) => {
            let style = isDragging ? "border rounded-md bg-jp-gray-100 dark:bg-jp-gray-950" : ""
            <div
              className={`h-14 px-3 flex flex-row items-center justify-between text-jp-gray-900 dark:text-jp-gray-600 border-jp-gray-500 dark:border-jp-gray-960
            ${index !== 0 ? "border-t" : ""} ${style}`}>
              <div className="flex flex-row items-center gap-4 ml-2">
                <Icon name="grip-vertical" size=14 className={"cursor-pointer"} />
                <div className="px-1.5 rounded-full bg-blue-800 text-white font-semibold text-sm">
                  {React.string(string_of_int(index + 1))}
                </div>
                <div>
                  {React.string(
                    gateway
                    ->LogicUtils.getDictFromJsonObject
                    ->LogicUtils.getString("connector", ""),
                  )}
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
      <Button
        onClick={_ => {
          openConfirmationPopUp()
        }}
        text="Save Changes"
        buttonSize=Small
        buttonType=Primary
        leftIcon={FontAwesome("check")}
        loadingText="Activating..."
        buttonState={gateways->Array.length > 0 ? Button.Normal : Button.Disabled}
      />
    </PageLoaderWrapper>
  </div>
}
