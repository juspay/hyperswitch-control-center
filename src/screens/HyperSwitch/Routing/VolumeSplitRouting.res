open APIUtils
open RoutingTypes
open RoutingPreviewer

open LogicUtils

module VolumeRoutingView = {
  open RoutingUtils
  @react.component
  let make = (
    ~initialRule,
    ~setScreenState,
    ~routingId,
    ~pageState,
    ~connectors: array<ConnectorTypes.connectorPayload>,
    ~isActive,
    ~initialValues,
    ~isConfigButtonEnabled,
    ~profile,
  ) => {
    let updateDetails = useUpdateMethod(~showErrorToast=false, ())
    let showToast = ToastState.useShowToast()
    let listLength = connectors->Js.Array2.length
    let (showModal, setShowModal) = React.useState(_ => false)
    let connectorListJson = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
    let connectorList = React.useMemo0(() => {
      connectorListJson->safeParse->ConnectorTableUtils.getArrayOfConnectorListPayloadType
    })

    let initalValue = switch initialRule {
    | Some(initialRule) => initialRule
    | None => Js.Dict.empty()
    }

    let gateways =
      initalValue
      ->getJsonObjectFromDict("json")
      ->getDictFromJsonObject
      ->getObj("volumeBasedDistribution", Js.Dict.empty())
      ->getArrayFromDict("gateways", [])

    let onSubmit = async (values, isSaveRule) => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let data =
          values
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("json")
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("volumeBasedDistribution")
          ->Js.Json.decodeObject
          ->Belt.Option.getWithDefault(Js.Dict.empty())
          ->getArrayFromDict("gateways", [])
        let payload = getVolumeSplit(data, itemBodyGateWayObjMapper, Some(connectorList))

        let updateUrl = getURL(~entityName=ROUTING, ~methodType=Post, ~id=None, ())

        let res = await updateDetails(
          updateUrl,
          getRoutingPayload(
            payload,
            "volume_split",
            initialValues->getString("name", ""),
            initialValues->getString("description", ""),
            initialValues->getString("profile_id", ""),
          )->Js.Json.object_,
          Post,
        )
        showToast(
          ~message="Successfully Created a new Configuration !",
          ~toastType=ToastState.ToastSuccess,
          (),
        )
        setScreenState(_ => Success)
        if isSaveRule {
          RescriptReactRouter.replace(`/routing`)
        }
        Js.Nullable.return(res)
      } catch {
      | Js.Exn.Error(e) =>
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong!")
        showToast(
          ~message="Failed to Save the Configuration !",
          ~toastType=ToastState.ToastError,
          (),
        )
        setScreenState(_ => PageLoaderWrapper.Error(err))
        Js.Exn.raiseError(err)
      }
    }

    let validate = (values: Js.Json.t) => {
      let errors = Js.Dict.empty()
      let dict = values->getDictFromJsonObject
      let validateGateways = dict => {
        let gateways = dict->getArrayFromDict("gateways", [])
        if gateways->Js.Array2.length === 0 {
          Some("Need atleast 1 Gateway")
        } else {
          let distributionPercentages = gateways->Belt.Array.keepMap(json => {
            json->Js.Json.decodeObject->Belt.Option.flatMap(getOptionFloat(_, "distribution"))
          })
          let distributionPercentageSum =
            distributionPercentages->Array.reduce(0., (sum, distribution) => sum +. distribution)
          let hasZero = distributionPercentages->Js.Array2.some(ele => ele === 0.)
          let isDistributeChecked = !(distributionPercentages->Js.Array2.some(ele => ele === 100.0))

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

      let volumeBasedDistributionDict =
        dict->getObj("json", Js.Dict.empty())->getObj("volumeBasedDistribution", Js.Dict.empty())

      switch volumeBasedDistributionDict->validateGateways {
      | Some(error) => errors->Js.Dict.set("Volume Based Distribution", error->Js.Json.string)
      | None => ()
      }

      errors->Js.Json.object_
    }
    let handleActivateConfiguration = async activatingId => {
      try {
        setScreenState(_ => Loading)
        let activateRuleURL = getURL(~entityName=ROUTING, ~methodType=Post, ~id=activatingId, ())
        let _ = await updateDetails(activateRuleURL, Js.Dict.empty()->Js.Json.object_, Post)
        showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess, ())
        RescriptReactRouter.replace(`/routing?`)
        setScreenState(_ => Success)
      } catch {
      | Js.Exn.Error(e) =>
        switch Js.Exn.message(e) {
        | Some(message) =>
          if message->Js.String2.includes("IR_16") {
            showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess, ())
            RescriptReactRouter.replace(`/routing`)
            setScreenState(_ => Success)
          } else {
            showToast(
              ~message="Failed to Activate the Configuration!",
              ~toastType=ToastState.ToastError,
              (),
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
        let deactivateRoutingURL = `${getURL(~entityName=ROUTING, ~methodType=Post, ())}/deactivate`
        let body = [("profile_id", profile->Js.Json.string)]->Js.Dict.fromArray->Js.Json.object_
        let _ = await updateDetails(deactivateRoutingURL, body, Post)
        showToast(~message="Successfully Deactivated !", ~toastType=ToastState.ToastSuccess, ())
        RescriptReactRouter.replace(`/routing?`)
        setScreenState(_ => Success)
      } catch {
      | Js.Exn.Error(e) =>
        switch Js.Exn.message(e) {
        | Some(message) => {
            showToast(
              ~message="Failed to Deactivate the Configuration!",
              ~toastType=ToastState.ToastError,
              (),
            )
            setScreenState(_ => Error(message))
          }
        | None => setScreenState(_ => Error("Something went wrong"))
        }
      }
    }

    let connectorOptions = React.useMemo1(() => {
      connectors
      ->Js.Array2.filter(item => item.profile_id === profile)
      ->Js.Array2.map((item): SelectBox.dropdownOption => {
        {
          label: item.connector_label,
          value: item.merchant_connector_id,
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
          <Form
            onSubmit={(values, _) => onSubmit(values, true)}
            validate
            initialValues={initalValue->Js.Json.object_}>
            <div className="flex flex-col gap-4">
              {listLength > 0
                ? <>
                    <AddPLGateway
                      id="json.volumeBasedDistribution"
                      gatewayOptions={connectorOptions}
                      isExpanded={true}
                      isFirst={true}
                      showPriorityIcon={false}
                      showDistributionIcon={false}
                      showFallbackIcon={false}
                      dropDownButtonText="Add Processors"
                      connectorList
                    />
                    <ConfigureRuleButton setShowModal isConfigButtonEnabled />
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
                      submitButton={<SaveAndActivateButton onSubmit handleActivateConfiguration />}
                      headingText="Activate Current Configuration?"
                      subHeadingText="Activating the current configuration will override the current active configuration. Alternatively, save this configuration to access / activate it later from the configuration history. Please confirm."
                      leftIcon="hswitch-warning"
                    />
                  </>
                : <NoDataFound message="Please configure atleast 1 connector" renderType=InfoBox />}
            </div>
            <FormValuesSpy />
          </Form>
        | Preview =>
          <div className="flex flex-col w-full gap-3">
            <div
              className="flex flex-col gap-4 p-6 my-2 bg-white rounded-md border border-jp-gray-600 ">
              <GatewayView
                gateways={gateways->getGatewayTypes("gateway_name", "distribution")}
                isEnforceGatewayPriority=false
                connectorList
              />
            </div>
            <div className="flex flex-col md:flex-row gap-4">
              // <Button
              //   text={"Duplicate & Edit Configuration"}
              //   buttonType={Secondary}
              //   onClick={_ => {
              //     setFormState(_ => AdvancedRoutingTypes.EditConfig)
              //     setInitialValues(_ => VOLUME_SPLIT->RoutingUtils.constructNameDescription)
              //     setPageState(_ => Create)
              //     hyperswitchMixPanel(
              //       ~pageName=`${url.path->LogicUtils.getListHead}_${currentTabName}`,
              //       ~contextName="previewrule",
              //       ~actionName="duplicatevolumeconfiguration",
              //       (),
              //     )
              //   }}
              //   customButtonStyle="w-1/5 rounded-sm"
              // />
              <UIUtils.RenderIf condition={!isActive}>
                <Button
                  text={"Activate Configuration"}
                  buttonType={Primary}
                  onClick={_ => {
                    handleActivateConfiguration(routingId)->ignore
                  }}
                  customButtonStyle="w-1/5 rounded-sm"
                  buttonState={Normal}
                />
              </UIUtils.RenderIf>
              <UIUtils.RenderIf condition={isActive}>
                <Button
                  text={"Deactivate Configuration"}
                  buttonType={Primary}
                  onClick={_ => {
                    handleDeactivateConfiguration()->ignore
                  }}
                  customButtonStyle="w-1/5 rounded-sm"
                  buttonState=Normal
                />
              </UIUtils.RenderIf>
            </div>
          </div>

        | _ => React.null
        }}
      </div>
    </>
  }
}

@react.component
let make = (~routingRuleId, ~isActive) => {
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
  let (profile, setProfile) = React.useState(_ => defaultBusinessProfile.profile_id)
  let (formState, setFormState) = React.useState(_ => AdvancedRoutingTypes.EditReplica)
  let (initialRule, setInitialRule) = React.useState(() => None)
  let (initialValues, setInitialValues) = React.useState(_ => Js.Dict.empty())
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageState, setPageState) = React.useState(() => Create)
  let (connectors, setConnectors) = React.useState(_ => [])
  let currentTabName = Recoil.useRecoilValueFromAtom(RoutingUtils.currentTabNameRecoilAtom)
  let (isConfigButtonEnabled, setIsConfigButtonEnabled) = React.useState(_ => false)
  let connectorListJson =
    HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom->safeParse

  let getConnectorsList = () => {
    setConnectors(_ =>
      connectorListJson
      ->ConnectorTableUtils.getArrayOfConnectorListPayloadType
      ->Js.Array2.filter(connector => connector.connector_name !== "applepay")
    )
  }

  let activeRoutingDetails = async () => {
    let routingUrl = getURL(~entityName=ROUTING, ~methodType=Get, ~id=routingRuleId, ())
    let routingJson = await fetchDetails(routingUrl)
    let algorithm =
      routingJson
      ->getDictFromJsonObject
      ->getObj("algorithm", Js.Dict.empty())
      ->getArrayFromDict("data", [])

    let volumeBasedGatewayDistribution = RoutingUtils.getVolumeSplit(
      algorithm,
      RoutingUtils.itemGateWayObjMapper,
      None,
    )
    let gatewaysDict =
      [("gateways", volumeBasedGatewayDistribution->Js.Json.array)]->Js.Dict.fromArray
    let volDict = [("volumeBasedDistribution", gatewaysDict->Js.Json.object_)]->Js.Dict.fromArray
    let ruleDict = [("json", volDict->Js.Json.object_)]->Js.Dict.fromArray
    let routingJsonToDict = routingJson->getDictFromJsonObject

    let initialValueDict = Js.Dict.fromArray([
      ("name", routingJsonToDict->getString("name", "")->Js.Json.string),
      ("description", routingJsonToDict->getString("description", "")->Js.Json.string),
      ("profile_id", routingJsonToDict->getString("profile_id", "")->Js.Json.string),
    ])
    setFormState(_ => ViewConfig)
    setInitialValues(_ => initialValueDict)
    setInitialRule(_ => Some(ruleDict))
    setProfile(_ => routingJsonToDict->getString("profile_id", defaultBusinessProfile.profile_id))
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
          setInitialValues(_ => VOLUME_SPLIT->RoutingUtils.constructNameDescription)
          setInitialRule(_ => None)
          setPageState(_ => Create)
        }
      }
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  React.useEffect1(() => {
    getDetails()->ignore
    None
  }, [routingRuleId])

  <div className="my-6">
    <PageLoaderWrapper screenState>
      <Form initialValues={initialValues->Js.Json.object_}>
        <div className="w-full flex justify-between">
          <div className="w-full">
            <BasicDetailsForm
              formState
              setFormState
              currentTabName
              setInitialValues
              setIsConfigButtonEnabled
              profile
              setProfile
            />
          </div>
        </div>
      </Form>
      <UIUtils.RenderIf condition={formState != CreateConfig}>
        <VolumeRoutingView
          initialRule
          setScreenState
          pageState
          connectors
          routingId={routingRuleId}
          isActive
          initialValues
          isConfigButtonEnabled
          profile
        />
      </UIUtils.RenderIf>
    </PageLoaderWrapper>
  </div>
}
