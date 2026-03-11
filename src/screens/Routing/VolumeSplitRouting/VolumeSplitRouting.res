open APIUtils
open RoutingTypes
open VolumeSplitRoutingPreviewer
open LogicUtils

module VolumeRoutingView = {
  open RoutingUtils
  @react.component
  let make = (
    ~setScreenState,
    ~routingId,
    ~pageState,
    ~setPageState,
    ~connectors: array<ConnectorTypes.connectorPayloadCommonType>,
    ~isActive,
    ~profile,
    ~setFormState,
    ~initialValues,
    ~onSubmit,
    ~urlEntityName,
    ~connectorList,
    ~baseUrlForRedirection,
  ) => {
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let showToast = ToastState.useShowToast()
    let listLength = connectors->Array.length
    let (showModal, setShowModal) = React.useState(_ => false)
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    let gateways =
      initialValues
      ->getJsonObjectFromDict("algorithm")
      ->getDictFromJsonObject
      ->getArrayFromDict("data", [])

    let handleActivateConfiguration = async activatingId => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let activateRuleURL = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=activatingId)
        let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
        showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess)
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
        )
        setScreenState(_ => Success)
      } catch {
      | Exn.Error(e) =>
        switch Exn.message(e) {
        | Some(message) =>
          if message->String.includes("IR_16") {
            showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess)
            RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
            setScreenState(_ => Success)
          } else {
            showToast(
              ~message="Failed to Activate the Configuration!",
              ~toastType=ToastState.ToastError,
            )
            setScreenState(_ => Error(message))
          }
        | None => setScreenState(_ => Error("Something went wrong"))
        }
      }
    }

    let handleDeactivateConfiguration = async _ => {
      try {
        setScreenState(_ => Loading)
        let deactivateRoutingURL = `${getURL(
            ~entityName=urlEntityName,
            ~methodType=Post,
          )}/deactivate`
        let body = [("profile_id", profile->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
        let _ = await updateDetails(deactivateRoutingURL, body, Post)
        showToast(~message="Successfully Deactivated !", ~toastType=ToastState.ToastSuccess)
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
        )
        setScreenState(_ => Success)
      } catch {
      | Exn.Error(e) =>
        switch Exn.message(e) {
        | Some(message) => {
            showToast(
              ~message="Failed to Deactivate the Configuration!",
              ~toastType=ToastState.ToastError,
            )
            setScreenState(_ => Error(message))
          }
        | None => setScreenState(_ => Error("Something went wrong"))
        }
      }
    }

    let connectorOptions = React.useMemo(() => {
      connectors
      ->Array.filter(item => item.profile_id === profile)
      ->Array.map((item): SelectBox.dropdownOption => {
        {
          label: item.disabled ? `${item.connector_label} (disabled)` : item.connector_label,
          value: item.id,
        }
      })
    }, [profile])

    <>
      <div
        className="flex flex-col gap-4 p-6 my-2 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
        <div className="flex flex-col lg:flex-row  ">
          <div>
            <div className="font-bold mb-1"> {React.string("Volume Based Configuration")} </div>
            <div className="text-jp-gray-800 dark:text-jp-gray-700 text-sm">
              {"Volume Based Configuration is helpful when you want a specific traffic distribution for each of the configured connectors. For eg: Stripe (70%), Adyen (20%), Checkout (10%)."->React.string}
            </div>
          </div>
        </div>
      </div>
      <div className="flex w-full flex-start">
        {switch pageState {
        | Create =>
          <div className="flex flex-col gap-4">
            {listLength > 0
              ? <>
                  <AddPLGateway
                    id="algorithm.data"
                    gatewayOptions={connectorOptions}
                    isExpanded={true}
                    isFirst={true}
                    showPriorityIcon={false}
                    showDistributionIcon={false}
                    showFallbackIcon={false}
                    dropDownButtonText="Add Processors"
                    connectorList
                  />
                  <ConfigureRuleButton setShowModal />
                  <CustomModal.RoutingCustomModal
                    showModal
                    setShowModal
                    cancelButton={<FormRenderer.SubmitButton
                      text="Save Rule"
                      buttonSize=Button.Small
                      buttonType=Button.Secondary
                      customSumbitButtonStyle="w-1/5 rounded-lg"
                      tooltipWidthClass="w-48"
                    />}
                    submitButton={<AdvancedRoutingUIUtils.SaveAndActivateButton
                      onSubmit handleActivateConfiguration
                    />}
                    headingText="Activate Current Configuration?"
                    subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
                    leftIcon="warning-modal"
                    iconSize=35
                  />
                </>
              : <NoDataFound message="Please configure at least 1 connector" renderType=InfoBox />}
          </div>
        | Preview =>
          <div className="flex flex-col w-full gap-3">
            <div
              className="flex flex-col gap-4 p-6 my-2 bg-white rounded-md border border-jp-gray-600 ">
              <GatewayView gateways={gateways->getGatewayTypes} connectorList />
            </div>
            <div className="flex flex-col md:flex-row gap-4">
              <ACLButton
                text={"Duplicate & Edit Configuration"}
                buttonType={Secondary}
                authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                onClick={_ => {
                  setFormState(_ => RoutingTypes.EditConfig)
                  setPageState(_ => Create)
                }}
                customButtonStyle="w-1/5"
              />
              <RenderIf condition={!isActive}>
                <ACLButton
                  text={"Activate Configuration"}
                  buttonType={Primary}
                  authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                  onClick={_ => {
                    handleActivateConfiguration(routingId)->ignore
                  }}
                  buttonState={Normal}
                />
              </RenderIf>
              <RenderIf condition={isActive}>
                <ACLButton
                  text={"Deactivate Configuration"}
                  buttonType={Primary}
                  authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                  onClick={_ => {
                    handleDeactivateConfiguration()->ignore
                  }}
                  buttonState=Normal
                />
              </RenderIf>
            </div>
          </div>
        | _ => React.null
        }}
      </div>
    </>
  }
}

@react.component
let make = (
  ~routingRuleId,
  ~isActive,
  ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  ~urlEntityName,
  ~baseUrlForRedirection,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (profile, setProfile) = React.useState(_ => profileId)
  let (formState, setFormState) = React.useState(_ => RoutingTypes.EditReplica)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make())
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageState, setPageState) = React.useState(() => Create)
  let (connectors, setConnectors) = React.useState(_ => [])
  let currentTabName = Recoil.useRecoilValueFromAtom(HyperswitchAtom.currentTabNameRecoilAtom)
  let showToast = ToastState.useShowToast()
  let getConnectorsList = () => {
    setConnectors(_ => connectorList)
  }
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()

  let activeRoutingDetails = async () => {
    let routingUrl = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId)
    let routingJson = await fetchDetails(routingUrl)
    let routingJsonToDict = routingJson->getDictFromJsonObject
    setFormState(_ => ViewConfig)
    setInitialValues(_ => routingJsonToDict)
    setProfile(_ => routingJsonToDict->getString("profile_id", profileId))
  }

  let getDetails = async _ => {
    try {
      setScreenState(_ => Loading)
      getConnectorsList()
      switch routingRuleId {
      | Some(_id) => {
          await activeRoutingDetails()
          setPageState(_ => Preview)
        }

      | None => {
          let currentTime = getTimeInCustomTimeZone(
            "ddd, DD MMM YYYY HH:mm:ss",
            ~includeTimeZone=true,
          )
          let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
          setInitialValues(_ => {
            let dict = RoutingUtils.constructNameDescription(
              ~routingType=VOLUME_SPLIT,
              ~currentTime,
              ~currentDate,
            )
            dict->Dict.set("profile_id", profile->JSON.Encode.string)
            dict->Dict.set(
              "algorithm",
              {
                "type": "volume_split",
              }->Identity.genericTypeToJson,
            )
            dict
          })
          setPageState(_ => Create)
        }
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let validate = (values: JSON.t) => {
    let errors = Dict.make()
    let dict = values->getDictFromJsonObject

    AdvancedRoutingUtils.validateNameAndDescription(
      ~dict,
      ~errors,
      ~validateFields=[Name, Description],
    )

    let validateGateways = dict => {
      let gateways = dict->getArrayFromDict("data", [])
      if gateways->Array.length === 0 {
        Some("Need atleast 1 Gateway")
      } else {
        let distributionPercentages = gateways->Belt.Array.keepMap(json => {
          json->JSON.Decode.object->Option.flatMap(val => val->(getOptionFloat(_, "split")))
        })
        let distributionPercentageSum =
          distributionPercentages->Array.reduce(0., (sum, distribution) => sum +. distribution)
        let hasZero = distributionPercentages->Array.some(ele => ele === 0.)
        let isDistributeChecked = !(distributionPercentages->Array.some(ele => ele === 100.0))

        let isNotValid =
          isDistributeChecked &&
          (distributionPercentageSum > 100. || hasZero || distributionPercentageSum !== 100.)

        if isNotValid {
          Some("Distribution Percent not correct")
        } else {
          None
        }
      }
    }

    let volumeBasedDistributionDict = dict->getObj("algorithm", Dict.make())
    switch volumeBasedDistributionDict->validateGateways {
    | Some(error) => errors->Dict.set("Volume Based Distribution", error->JSON.Encode.string)
    | None => ()
    }
    errors->JSON.Encode.object
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let updateUrl = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=None)
      let res = await updateDetails(updateUrl, values, Post)
      showToast(
        ~message="Successfully Created a new Configuration !",
        ~toastType=ToastState.ToastSuccess,
      )
      setScreenState(_ => Success)
      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
      }
      Nullable.make(res)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong!")
      showToast(~message="Failed to Save the Configuration !", ~toastType=ToastState.ToastError)
      setScreenState(_ => PageLoaderWrapper.Error(err))
      Exn.raiseError(err)
    }
  }

  React.useEffect(() => {
    getDetails()->ignore
    None
  }, [routingRuleId])

  <div className="my-6">
    <PageLoaderWrapper screenState>
      <Form
        onSubmit={(values, _) => onSubmit(values, true)}
        validate
        initialValues={initialValues->JSON.Encode.object}>
        <div className="w-full flex justify-between">
          <div className="w-full">
            <BasicDetailsForm
              currentTabName formState setInitialValues profile setProfile routingType=VOLUME_SPLIT
            />
          </div>
        </div>
        <RenderIf condition={formState != CreateConfig}>
          <VolumeRoutingView
            setScreenState
            pageState
            setPageState
            connectors
            routingId={routingRuleId}
            isActive
            initialValues
            profile
            setFormState
            onSubmit
            urlEntityName
            connectorList
            baseUrlForRedirection
          />
        </RenderIf>
      </Form>
    </PageLoaderWrapper>
  </div>
}
